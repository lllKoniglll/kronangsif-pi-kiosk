# 16GB SD card profile

This project is designed to fit comfortably on a 16GB microSD card for a Raspberry Pi 4 kiosk deployment.

## Use this combination

- Raspberry Pi 4
- 16GB microSD card
- Raspberry Pi OS (64-bit)
- Desktop image
- Chromium kiosk mode for `https://kronangsif.github.io`

## Why this profile

- the Desktop image includes Chromium and the graphical stack needed for kiosk mode
- the 16GB card leaves enough room for the OS, browser cache, logs, and future updates
- the larger full image is unnecessary for a single-site kiosk and reduces free-space headroom

## Recommended defaults

- hostname: `kronangsif-pi`
- URL: `https://kronangsif.github.io`
- desktop autologin enabled
- SSH enabled during imaging
- Wi-Fi preconfigured in Raspberry Pi Imager

## After install

Run the kiosk installer:

```bash
sudo ./scripts/install-kiosk.sh --url https://kronangsif.github.io --hostname kronangsif-pi
```

Then reboot:

```bash
sudo reboot
```
