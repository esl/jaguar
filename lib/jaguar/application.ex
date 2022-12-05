defmodule Jaguar.Application do
  @moduledoc false

  use Application

  ## Application callbacks

  @impl true
  def start(_type, _args) do
    vehicle_opts = Application.get_env(:jaguar, Jaguar.Vehicle)
    general_opts = Application.get_env(:jaguar, Jaguar.ControlSocket)

    children =
      [
        # Children for all targets
        {Jaguar.Vehicle, vehicle_opts}
      ] ++ children(target(), general_opts)

    opts = [strategy: :one_for_one, name: Jaguar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host, control_socket_opts) do
    [
      {Jaguar.ControlSocket, control_socket_opts}
    ]
  end

  def children(_target, control_socket_opts) do
    [
      # Children for all targets except host
      {Jaguar.ConnectionMonitor, control_socket_opts}
    ]
  end

  def target() do
    Application.get_env(:jaguar, :target)
  end
end
