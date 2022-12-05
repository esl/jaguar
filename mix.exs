defmodule Jaguar.MixProject do
  use Mix.Project

  @app :jaguar
  @version "0.1.0"
  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :osd32mp1, :x86_64, :grisp2]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.13",
      archives: [nerves_bootstrap: "~> 1.11"],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      dialyzer: [
        plt_add_deps: :apps_direct
      ],
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Jaguar.Application, []},
      extra_applications: [:logger, :ssl, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.8.0 or ~> 1.9.0", runtime: false},
      {:shoehorn, "~> 0.9.1"},
      {:ring_logger, "~> 0.8.6"},
      {:toolshed, "~> 0.2.26"},
      {:vintage_net, "~> 0.12", targets: @all_targets},
      {:vintage_net_wifi, "~> 0.11.1", targets: @all_targets},
      {:pigpiox, "~> 0.1", targets: @all_targets},
      {:circuits_gpio, "~> 1.0", targets: @all_targets},
      {:jason, "~> 1.4"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.13.3", targets: @all_targets},
      {:nerves_pack, "~> 0.7.0", targets: @all_targets},

      # Development for all targets
      {:recon, "~> 2.5", targets: @all_targets},
      {:dialyxir, "~> 1.2", runtime: false, only: :dev},

      # Dependencies for specific targets
      # NOTE: It's generally low risk and recommended to follow minor version
      # bumps to Nerves systems. Since these include Linux kernel and Erlang
      # version updates, please review their release notes in case
      # changes to your application are needed.
      {:nerves_system_rpi, "~> 1.21", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.21", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.21", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.21", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.21", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.21", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.16", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.10", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.19", runtime: false, targets: :x86_64},
      {:nerves_system_grisp2, "~> 0.5", runtime: false, targets: :grisp2}
    ]
  end

  defp release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end
