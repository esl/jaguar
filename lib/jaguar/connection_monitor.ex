defmodule Jaguar.ConnectionMonitor do
  use GenServer

  @name __MODULE__

  require Logger

  alias Jaguar.ControlSocket

  ## API

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: @name)
  end

  ## Callbacks

  @impl true
  def init(config) do
    _ref = schedule_check()
    :ok = VintageNet.subscribe(["interface", "wlan0"])

    case check_network() do
      true ->
        {:ok, _pid} = ControlSocket.start_link(config)
        {:ok, %{config: config, online: true}}

      false ->
        {:ok, %{config: config, online: false}}
    end
  end

  @impl true
  def handle_info({VintageNet, _ev, _old, :connected, _meta}, state) do
    {:ok, _pid} = ControlSocket.start_link(state.config)
    {:noreply, %{state | online: true}}
  end

  def handle_info({VintageNet, _ev, _old, :disconnected, _meta}, state) do
    _ref = schedule_check()
    {:noreply, %{state | online: false}}
  end

  def handle_info({VintageNet, _ev, _old, _new, _meta}, state) do
    {:noreply, state}
  end

  def handle_info(:check, %{online: true} = state) do
    _ref = schedule_check()
    {:noreply, state}
  end

  def handle_info(:check, %{online: false} = state) do
    _ref = schedule_check()

    if check_network() do
      {:ok, _pid} = ControlSocket.start_link(state.config)
    end

    {:noreply, state}
  end

  ## Internal functions

  defp check_network do
    :internet == VintageNet.get(["interface", "wlan0", "connection"])
  end

  defp schedule_check do
    Process.send_after(self(), :check, :timer.seconds(1))
  end
end
