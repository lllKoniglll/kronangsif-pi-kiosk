# Wi-Fi preconfiguration

This repo supports preloading a Wi-Fi network for Raspberry Pi OS desktop kiosks.

## Current network

The local working copy is configured to use:

- SSID: `Rolofsberg`
- Wi-Fi country: `SE`

The password is stored in `config/wifi.env`, which is ignored by Git so it does not get pushed to the public repository.

## How it works

The installer reads `config/wifi.env` if it exists and writes a NetworkManager connection profile to:

```text
/etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection
```

That allows Raspberry Pi OS Bookworm/Trixie desktop systems to auto-connect on boot.

## Change the network

Edit the local secret file:

```bash
sed -i '' 's/^WIFI_SSID=.*/WIFI_SSID="NewSSID"/' config/wifi.env
sed -i '' 's/^WIFI_PASSWORD=.*/WIFI_PASSWORD="NewPassword"/' config/wifi.env
sed -i '' 's/^WIFI_COUNTRY=.*/WIFI_COUNTRY="SE"/' config/wifi.env
```

Then run the installer again on the Pi.

## First-boot note

For a freshly flashed image, Raspberry Pi officially recommends entering Wi-Fi credentials in Raspberry Pi Imager customisation before first boot. This repo's installer covers the same network after the system is up and can also be reused in a future custom image build pipeline.
