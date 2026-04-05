# Raspberry Pi Imager flow

Use this flow to prepare the SD card before the kiosk install script runs.

## Recommended image

- 16GB microSD card
- Raspberry Pi OS (64-bit)
- Desktop variant
- Raspberry Pi 4

Avoid the larger image that includes recommended software. For this project, the Desktop variant is the better fit for a 16GB card.

## Imager customisation

Before writing the card, set:

- hostname: `kronangsif-pi`
- a local user account
- a strong password
- Wi-Fi SSID and password
- SSH enabled
- locale and keyboard settings for the deployment site

## First boot

1. Insert the card into the Raspberry Pi 4.
2. Connect display, power, and network if needed.
3. Wait for the Pi to boot.
4. SSH into the Pi from another machine.

Example:

```bash
ssh <username>@kronangsif-pi.local
```

## Install kiosk mode

Clone this repo on the Pi and run:

```bash
sudo ./scripts/install-kiosk.sh --url https://kronangsif.github.io --hostname kronangsif-pi
```

Reboot when the script finishes.

## Optional hardening

- switch SSH login to keys only
- place the Pi in a physically secure enclosure
- enable the overlay filesystem after validation
