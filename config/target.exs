use Mix.Config

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_nerves_ecdsa.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)


key_mgmt = System.get_env("NERVES_NETWORK_KEY_MGMT") || "wpa_psk"

config :vintage_net,
regulatory_domain: "US",
  config: [
    {"wlan0", %{ type: VintageNetWiFi,
      vintage_net_wifi: %{
        key_mgmt: String.to_atom(key_mgmt),
        mode: :client,
        ssid: System.get_env("NERVES_NETWORK_SSID"),
        psk:  System.get_env("NERVES_NETWORK_PSK"),
      },
      ipv4: %{method: :dhcp},
      },
    },
    {"usb0", %{type: VintageNetDirect}},
  ]

