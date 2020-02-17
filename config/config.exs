# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Customize the firmware. Uncomment all or parts of the following
# to add files to the root filesystem or modify the firmware
# archive.

config :nerves, :firmware,
   rootfs_overlay: "rootfs_overlay",
   fwup_conf: "config/rpi0/fwup.conf"

config :logger, level: :debug, backends: [RingLogger]
config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
  ]

  #config :nerves_init_gadget,
  #ifname: "wlan0",
#  ifname: "eth0",
#  ifname: "usb0",
#mdns_domain: nil,
#  address_method: :dhcp

key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "WPA-PSK"

#config :nerves_network, :default,
#  wlan0: [
#    ssid: System.get_env("NERVES_NETWORK_SSID"),
#    psk:  System.get_env("NERVES_NETWORK_PSK"),
#    key_mgmt: String.to_atom(key_mgmt)
#  ],
#eth0: [
#    ipv4_address_method: :dhcp
#  ]

config :vintage_net,
  config: [
    #{"eth0", %{type: VintageNetEthernet, ipv4: %{method: :dhcp}}},
    {"wlan0", %{ type: VintageNetWiFi,
                 vintage_net_wifi: %{
        networks: [
          %{
            key_mgmt: String.to_atom(key_mgmt)
            ssid: System.get_env("NERVES_NETWORK_SSID"),
            psk:  System.get_env("NERVES_NETWORK_PSK"),
          }
        ]
      },
      ipv4: %{method: :dhcp},
      },
    }
    {"usb0", %{type: VintageNetDirect}},
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

#if Mix.target() != :host do
#  import_config "target.exs"
#end
