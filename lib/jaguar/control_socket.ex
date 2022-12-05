defmodule Jaguar.ControlSocket do
  @moduledoc """
  Registration and control TCP socket.
  """

  @name __MODULE__

  @valid_moves ~w(left right forward backwards stop)a

  use GenServer, restart: :permanent

  require Logger

  alias Jaguar.Vehicle

  ## API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  ## GenServer callbacks

  @impl true
  def init(opts) do
    backend = Keyword.get(opts, :backend, "localhost") |> to_charlist()
    port = Keyword.get(opts, :port, 5000)
    state = %{socket: nil, backend: backend, port: port}
    {:ok, state, {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    Logger.info("connecting to #{inspect(state.backend)}")

    {:ok, socket} = :gen_tcp.connect(state.backend, state.port, keepalive: true)
    _ref = Port.monitor(socket)
    {:noreply, %{state | socket: socket}}
  end

  @impl true
  def handle_info({:tcp, _, data}, state) do
    # FIXME: Naive and error prone
    msg =
      data
      |> :erlang.iolist_to_binary()
      |> :erlang.binary_to_term()

    case msg do
      {:speed, speed} ->
        Vehicle.speed(speed)

      steering when steering in @valid_moves ->
        Vehicle.direction(steering)
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    {:stop, :reconnect, state}
  end

  def handle_info({:tcp_error, _}, state) do
    {:stop, :reconnect, state}
  end
end
