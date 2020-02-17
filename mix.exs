defmodule TempSensor.MixProject do
  use Mix.Project

  @target System.get_env("MIX_TARGET") || "host"
  @app :temp_sensor

  def project do
    [
      app: @app,
      version: "0.2.0",
      elixir: "~> 1.9",
      target: @target,
      archives: [nerves_bootstrap: "~> 1.6"],
      deps_path: "deps/#{@target}",
      build_path: "_build/#{@target}",
      lockfile: "mix.lock.#{@target}",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: [loadconfig: [&bootstrap/1]],
      preferred_cli_target: [run: :host, test: :host],
      releases: [{@app, release()}],
      deps: deps()
    ]
  end


  # Starting nerves_bootstrap adds the required aliases to Mix.Project.config()
  # Aliases are only added if MIX_TARGET is set.
  def bootstrap(args) do
    Application.start(:nerves_bootstrap)
    Mix.Task.run("loadconfig", args)
  end

  # Run "mix help compile.app" to learn about applications.
  def application, do: application(@target)

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
      {:nerves, "~> 1.5.0", runtime: false},
      {:ring_logger, "~> 0.4"},
      {:shoehorn, "~> 0.6"},
      {:toolshed, "~> 0.2"},
    ] ++ deps(@target)
  end

  # Specify target specific dependencies
  defp deps("host"), do: []

  defp deps(target) do
    [
      {:nerves_pack, "~> 0.1.0"},
      #{:nerves_init_gadget, "~> 0.5"},
      {:vintage_net_wifi, "~> 0.7"},
      # {:elixir_ale, "~> 1.0"},
      # {:nerves_runtime_shell, "~> 0.1.0"},
      {:nerves_runtime, "~> 0.6"},
    ] ++ system(target)
  end

  defp system("rpi0"), do: [{:nerves_system_rpi0, "~> 1.8", runtime: false}]
  defp system(target), do: Mix.raise "Unknown MIX_TARGET: #{target}"

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      striip_beams: Mix.env() == :prod
    ]
  end

end
