# Wi-Fi preconfiguration

This repo supports preloading a Wi-Fi network for Raspberry Pi OS desktop kiosks.

## Current network

The local working copy is configured to use:

- SSID: `Rolofsberg`
- Wi-Fi country: `SE`

The Wi-Fi settings are stored in `config/image-defaults.env`, which is ignored by Git so they do not get pushed to the public repository.

## How it works

The installer reads `config/image-defaults.env` if it exists and writes a NetworkManager connection profile to:

```text
/etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection
```

That allows Raspberry Pi OS Bookworm/Trixie desktop systems to auto-connect on boot.

## Change the network

Edit the local image config file:

```bash
sed -i '' 's/^WIFI_SSID=.*/WIFI_SSID="NewSSID" # Wi-Fi network name that the kiosk should join on boot./' config/image-defaults.env
sed -i '' 's/^WIFI_PASSWORD=.*/WIFI_PASSWORD="NewPassword" # Wi-Fi password for the configured network./' config/image-defaults.env
sed -i '' 's/^WIFI_COUNTRY=.*/WIFI_COUNTRY="SE" # Two-letter regulatory country code for Wi-Fi./' config/image-defaults.env
```

Then run the installer again on the Pi.

## First-boot note

For a freshly flashed image, Raspberry Pi officially recommends entering Wi-Fi credentials in Raspberry Pi Imager customisation before first boot. This repo's installer covers the same network after the system is up and can also be reused in a future custom image build pipeline.
