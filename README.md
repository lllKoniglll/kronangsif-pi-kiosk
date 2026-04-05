# kronangsif-pi-kiosk

Raspberry Pi 4 kiosk setup for showing `https://kronangsif.github.io` in fullscreen on boot from a 16GB microSD card.

The repository is built around Raspberry Pi OS desktop mode on current Raspberry Pi OS, using:

- desktop autologin
- `labwc` autostart
- Chromium kiosk mode
- NetworkManager Wi-Fi preconfiguration
- a small launcher loop so the browser restarts if it exits

## What this repo does

- configures a Raspberry Pi to boot straight to the desktop and auto-login
- starts Chromium in fullscreen kiosk mode
- points the browser at `https://kronangsif.github.io` by default
- supports a preconfigured Wi-Fi network for autoconnect on boot
- keeps the kiosk browser coming back after crashes or manual exits

## 16GB card target

This repo is sized around a **16GB microSD card**.

- use **Raspberry Pi OS (64-bit)** with **Desktop**
- do **not** use the larger "with recommended software" image on a 16GB card
- keep some free space for browser cache, logs, and OS updates

## Quick start

1. Flash a **16GB microSD card** with **Raspberry Pi OS (64-bit)** and the **Desktop** variant using Raspberry Pi Imager.
2. In Imager customisation, set:
   - hostname, for example `kronangsif-pi`
   - username and password
   - Wi-Fi, or let this repo configure it later
   - SSH
3. Boot the Pi and SSH into it.
4. Clone this repo onto the Pi.
5. Run:

```bash
sudo ./scripts/install-kiosk.sh --url https://kronangsif.github.io --hostname kronangsif-pi
```

6. Reboot:

```bash
sudo reboot
```

After reboot, Chromium should launch automatically in fullscreen and open the target site.

## Wi-Fi

For Raspberry Pi OS Bookworm and newer, Raspberry Pi officially recommends setting first-boot Wi-Fi in Raspberry Pi Imager.

This repo also supports applying Wi-Fi settings through the installer with a local secret file:

```bash
cp config/wifi.env.example config/wifi.env
```

Then set your Wi-Fi values in `config/wifi.env` and run the installer. The local `config/wifi.env` file is ignored by Git so the password does not get pushed to the public repo.

The current local working copy has been seeded with the `Rolofsberg` network.

## Change the URL

The installer writes the URL to `~/.config/kiosk.env`.

To point the kiosk at a different page later:

```bash
sed -i 's|^KIOSK_URL=.*|KIOSK_URL="https://example.com"|' ~/.config/kiosk.env
sudo reboot
```

## Files

- `scripts/install-kiosk.sh`: installs the kiosk dependencies and writes user config
- `config/kiosk-browser.sh`: browser launcher used by autostart
- `config/kiosk-wifi.nmconnection.template`: NetworkManager template for Wi-Fi autoconnect
- `config/wifi.env.example`: local secret template for Wi-Fi credentials
- `config/labwc-autostart`: autostart file for Raspberry Pi OS desktop mode
- `docs/raspberry-pi-imager.md`: recommended imaging flow
- `docs/wifi-preconfiguration.md`: Wi-Fi setup details

## Notes

- This repo assumes Raspberry Pi OS with the desktop environment installed.
- This repo targets a 16GB card, so the desktop image is the right starting point.
- The install script uses `raspi-config` non-interactive commands for desktop autologin and hostname setup.
- Wi-Fi credentials should stay in `config/wifi.env`, which is intentionally ignored by Git.
- If you want a more durable public kiosk, consider enabling the Raspberry Pi overlay filesystem after setup and testing.

## References

- Raspberry Pi kiosk tutorial: <https://www.raspberrypi.com/tutorials/how-to-use-a-raspberry-pi-in-kiosk-mode/>
- Raspberry Pi `raspi-config` documentation: <https://www.raspberrypi.com/documentation/configuration/device-tree/>
