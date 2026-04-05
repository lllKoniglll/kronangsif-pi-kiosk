#!/usr/bin/env bash
set -euo pipefail

if command -v raspi-config >/dev/null 2>&1; then
  raspi-config nonint do_boot_behaviour B4 || true
  raspi-config nonint do_boot_wait 1 || true
  raspi-config nonint do_hostname "$TARGET_HOSTNAME" || true

  if [[ -n "${WPA_COUNTRY:-}" ]]; then
    raspi-config nonint do_wifi_country "$WPA_COUNTRY" || true
  fi

  raspi-config nonint do_wayland W2 || true
fi

if ! command -v chromium >/dev/null 2>&1 && ! command -v chromium-browser >/dev/null 2>&1; then
  if apt-cache show chromium-browser >/dev/null 2>&1; then
    apt-get install -y --no-install-recommends chromium-browser
  else
    apt-get install -y --no-install-recommends chromium
  fi
fi

apt-get install -y --no-install-recommends wtype
apt-get clean

chown -R "$FIRST_USER_NAME:$FIRST_USER_NAME" "/home/$FIRST_USER_NAME/.config" "/home/$FIRST_USER_NAME/.local"

if [[ -f /etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection ]]; then
  chmod 600 /etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection
fi
