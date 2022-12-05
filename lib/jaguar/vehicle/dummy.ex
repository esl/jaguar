defmodule Jaguar.Vehicle.Dummy do
  @moduledoc """
  Dummy motor implementation.
  """

  @behaviour Jaguar.Vehicle

  ## Callbacks

  @impl true
  def init(_vehicle), do: :ok

  @impl true
  def speed(vehicle) do
    IO.inspect(vehicle, label: "speed")
    :ok
  end

  @impl true
  def direction(vehicle) do
    IO.inspect(vehicle, label: "direction")
    :ok
  end
end
