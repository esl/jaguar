defmodule Jaguar.Vehicle do
  @moduledoc """
  Vehicle API.
  """

  use GenServer

  alias Jaguar.Vehicle

  require Logger

  ## Contract

  @type handler_return :: :ok | :ignore | :error
  @type steering :: :forward | :backwards | :left | :right | :stop

  @callback init(vehicle :: Vehicle.t()) :: handler_return()
  @callback speed(vehicle :: Vehicle.t()) :: handler_return()
  @callback direction(vehicle :: Vehicle.t()) :: handler_return()

  # FIXME: These are the default pins on my rpi4, sorry.
  defstruct speed: 0,
            direction: :stop,
            current_direction: :stop,
            left: {24, 23},
            right: {17, 22},
            ena: 25,
            enb: 27

  @type t :: %Vehicle{
          speed: non_neg_integer(),
          direction: steering(),
          current_direction: steering(),
          left: tuple(),
          right: tuple(),
          ena: non_neg_integer(),
          enb: non_neg_integer()
        }

  @name __MODULE__

  ## API

  @doc "Change steering of the vehicle"
  @spec direction(steering()) :: :ok
  def direction(steering) when steering in ~w(stop forward backwards left right)a do
    GenServer.call(@name, {:direction, steering})
  end

  @doc "Change the `left` and `right` motor pins"
  @spec change_pins(left :: tuple(), right :: tuple()) :: :ok
  def change_pins(left, right) when is_tuple(left) when is_tuple(right) do
    GenServer.call(@name, {:change_pins, left, right})
  end

  @doc "Return the current vehicle state"
  @spec state :: {module(), Vehicle.t()}
  def state do
    GenServer.call(@name, :state)
  end

  @doc "Accelerate the vehicle with `speed`"
  @spec speed(speed :: non_neg_integer()) :: :ok
  def speed(speed) when speed >= 0 when speed <= 250 do
    GenServer.call(@name, {:speed, speed})
  end

  @doc "Initialize vehicle"
  def start_link(opts \\ []) do
    impl = Keyword.get(opts, :impl, Jaguar.Vehicle.Dummy)

    # FIXME: This should come from the implementation instead.
    left = Keyword.get(opts, :left, {24, 23})
    right = Keyword.get(opts, :right, {17, 22})
    ena = Keyword.get(opts, :ena, 25)
    enb = Keyword.get(opts, :enb, 27)

    GenServer.start_link(
      __MODULE__,
      {impl, %Vehicle{left: left, right: right, ena: ena, enb: enb, speed: 250}},
      name: @name
    )
  end

  ## GenServer callbacks

  @impl true
  def init({impl, vehicle}) do
    case impl.init(vehicle) do
      :ok ->
        {:ok, %{vehicle: vehicle, impl: impl}}

      :error ->
        {:stop, :error}
    end
  end

  @impl true
  def handle_call({:change_pins, left, right}, _from, %{vehicle: vehicle} = state) do
    {:reply, :ok, %{state | vehicle: %{vehicle | left: left, right: right}}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:direction, dir}, _from, %{vehicle: %Vehicle{direction: dir}} = state) do
    {:reply, :ok, state}
  end

  def handle_call({:direction, dir}, _from, %{vehicle: vehicle, impl: impl} = state) do
    {:reply, :ok,
     %{
       state
       | vehicle:
           set_direction(impl, %{vehicle | direction: dir, current_direction: vehicle.direction})
     }}
  end

  def handle_call({:speed, speed}, _from, %{vehicle: %Vehicle{speed: speed}} = state) do
    {:reply, :ok, state}
  end

  def handle_call({:speed, speed}, _from, %{vehicle: vehicle, impl: impl} = state) do
    {:reply, :ok, %{state | vehicle: set_speed(impl, %{vehicle | speed: speed})}}
  end

  ## Internal functions

  defp set_speed(impl, vehicle) do
    :ok = impl.speed(vehicle)
    vehicle
  end

  defp set_direction(impl, vehicle) do
    :ok = Logger.info(%{impl: impl, vehicle: vehicle})
    :ok = impl.direction(vehicle)
    vehicle
  end
end
