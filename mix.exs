defmodule TempSensor.MixProject do
  use Mix.Project

  @app :temp_sensor
  @version "0.2.0"
  @all_targets [:rpi0, :rpi3a]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.13",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {TempSensor.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end
  
  # Specify target specific application configurations
  # It is common that the application start function will start and supervise
  # applications which could cause the host to fail. Because of this, we only
  # invoke TempSensor.start/2 when running on a target.
  def application("host") do
    [extra_applications: [:logger]]
  end

  def application(_target) do
    [
      mod: {TempSensor.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nerves, "~> 1.7", runtime: false},
      {:shoehorn, "~> 0.7"},
      {:toolshed, "~> 0.2"},
      {:ring_logger, "~> 0.8"},
      {:logger_file_backend, "~> 0.0.12"},

      {:elixir_ale, "~> 1.0"},
      {:nerves_runtime, "~> 0.11.4", targets: @all_targets},
      {:nerves_pack, "~> 0.6.0", targets: @all_targets},
      {:busybox, "~> 0.1.5", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi0, "~> 1.18", runtime: false, targets: :rpi0},
      {:nerves_system_rpi3a, "~> 1.18", runtime: false, targets: :rpi3a},
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end

end
