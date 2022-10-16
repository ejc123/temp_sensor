# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

Application.start(:nerves_bootstrap)

config :temp_sensor, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay",
  provisioning: "config/provisioning.conf",
  fwup_conf: "config/rpi3a/fwup.conf"

config :nerves, source_date_epoch: "1585625975"

config :nerves, rpi_v2_ack: true

config :logger,
  backends: [{LoggerFileBackend, :info_log}, {LoggerFileBackend, :error_log}, RingLogger],
  level: :info

config :logger, :info_log,
  path: "/root/info.log",
  level: :info

config :logger, :error_log,
  path: "/root/error.log",
  level: :error

if Mix.target() != :host do
  import_config "target.exs"
end
