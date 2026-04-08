#!/usr/bin/env bash
set -euo pipefail

SUB_STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRST_USER_HOME="$ROOTFS_DIR/home/$FIRST_USER_NAME"
KIOSK_LIB_DIR="$ROOTFS_DIR/usr/local/lib/kronangsif"
WIFI_PROFILE_PATH="$ROOTFS_DIR/etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection"

install -d -m 755 \
  "$FIRST_USER_HOME/.config" \
  "$ROOTFS_DIR/etc/NetworkManager/system-connections" \
  "$ROOTFS_DIR/etc/systemd/logind.conf.d" \
  "$ROOTFS_DIR/etc/systemd/sleep.conf.d" \
  "$KIOSK_LIB_DIR"

install -m 755 \
  "$SUB_STAGE_DIR/files/kiosk-browser-wayland.sh" \
  "$KIOSK_LIB_DIR/kiosk-browser.sh"
install -m 755 \
  "$SUB_STAGE_DIR/files/kiosk-session.sh" \
  "$KIOSK_LIB_DIR/kiosk-session.sh"
install -m 755 \
  "$SUB_STAGE_DIR/files/kiosk-wait-online.sh" \
  "$KIOSK_LIB_DIR/kiosk-wait-online.sh"
install -m 755 \
  "$SUB_STAGE_DIR/files/kiosk-prepare-system.sh" \
  "$KIOSK_LIB_DIR/kiosk-prepare-system.sh"
install -m 644 \
  "$SUB_STAGE_DIR/files/kronangsif-kiosk.service.template" \
  "$KIOSK_LIB_DIR/kronangsif-kiosk.service.template"
install -m 644 \
  "$SUB_STAGE_DIR/files/kronangsif-logind.conf" \
  "$ROOTFS_DIR/etc/systemd/logind.conf.d/kronangsif.conf"
install -m 644 \
  "$SUB_STAGE_DIR/files/kronangsif-sleep.conf" \
  "$ROOTFS_DIR/etc/systemd/sleep.conf.d/kronangsif.conf"

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
