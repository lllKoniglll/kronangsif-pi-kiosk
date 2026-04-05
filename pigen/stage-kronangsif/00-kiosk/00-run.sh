#!/usr/bin/env bash
set -euo pipefail

SUB_STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRST_USER_HOME="$ROOTFS_DIR/home/$FIRST_USER_NAME"
WIFI_PROFILE_PATH="$ROOTFS_DIR/etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection"

install -d -m 755 \
  "$FIRST_USER_HOME/.config" \
  "$FIRST_USER_HOME/.config/labwc" \
  "$FIRST_USER_HOME/.local" \
  "$FIRST_USER_HOME/.local/bin" \
  "$ROOTFS_DIR/etc/NetworkManager/system-connections"

install -m 755 \
  "$SUB_STAGE_DIR/files/kiosk-browser.sh" \
  "$FIRST_USER_HOME/.local/bin/kiosk-browser.sh"

install -m 644 \
  "$SUB_STAGE_DIR/files/labwc-autostart" \
  "$FIRST_USER_HOME/.config/labwc/autostart"

cat >"$FIRST_USER_HOME/.config/kiosk.env" <<EOF
KIOSK_URL="${KRONANGSIF_KIOSK_URL:-https://kronangsif.github.io}"
EOF

chmod 600 "$FIRST_USER_HOME/.config/kiosk.env"

if [[ -n "${KRONANGSIF_WIFI_SSID:-}" && -n "${KRONANGSIF_WIFI_PASSWORD:-}" ]]; then
  cat >"$WIFI_PROFILE_PATH" <<EOF
[connection]
id=${KRONANGSIF_WIFI_SSID}
uuid=$(cat /proc/sys/kernel/random/uuid)
type=wifi
autoconnect=true

[wifi]
mode=infrastructure
ssid=${KRONANGSIF_WIFI_SSID}

[wifi-security]
auth-alg=open
key-mgmt=wpa-psk
psk=${KRONANGSIF_WIFI_PASSWORD}

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
EOF

  chmod 600 "$WIFI_PROFILE_PATH"
fi
