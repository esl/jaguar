import Config

config :jaguar, Jaguar.ControlSocket,
  backend: "localhost",
  # backend: "winter-resonance-3169.fly.dev",
  port: 5000

config :jaguar, Jaguar.Vehicle, impl: Jaguar.Vehicle.Dummy
