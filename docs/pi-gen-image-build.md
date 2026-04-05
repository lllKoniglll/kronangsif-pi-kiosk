# pi-gen image build

This repository can build a Raspberry Pi OS image with the kiosk and Wi-Fi configuration baked in.

## What gets baked into the image

- Raspberry Pi OS 64-bit desktop base from the official `pi-gen` `arm64` branch
- Chromium kiosk autostart for `https://kronangsif.github.io`
- Wi-Fi autoconnect using a NetworkManager profile
- desktop autologin for the configured first user
- `wtype` installed for kiosk input support

## Local build files

Two local files are used for secrets:

- `config/image-secrets.env`
- `config/wifi.env`

Both files are ignored by Git.

Start from the examples:

```bash
cp config/image-secrets.env.example config/image-secrets.env
cp config/wifi.env.example config/wifi.env
```

Required values:

- `FIRST_USER_PASS`
- `WIFI_SSID`
- `WIFI_PASSWORD`

## Build locally

Docker mode is the default and is the recommended path unless you already have a Debian-based build host prepared for native `pi-gen`.

```bash
./scripts/build-pi-image.sh --build-mode docker --refresh-pigen
```

The generated image artifact ends up in:

```text
.build/pi-gen/deploy/
```

## Build with GitHub Actions

The repository includes a workflow that can build the image on GitHub.

Set these repository secrets before running it:

- `PI_FIRST_USER_PASS`
- `WIFI_SSID`
- `WIFI_PASSWORD`

Optional repository secrets:

- `PI_FIRST_USER_NAME`
- `PI_HOSTNAME`
- `WIFI_COUNTRY`

Then run the `Build Raspberry Pi Image` workflow manually.

## 16GB card note

The image is intended for a 16GB microSD card, but the generated `.img.xz` file itself does not need to be 16GB. Raspberry Pi OS expands the filesystem on first boot after flashing.
