#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DEFAULT_URL="https://kronangsif.github.io"
TARGET_URL="$DEFAULT_URL"
TARGET_HOSTNAME=""
TARGET_USER="${SUDO_USER:-}"
SKIP_UPGRADE=0

root_free_kb() {
  df -Pk / | awk 'NR == 2 { print $4 }'
}

usage() {
  cat <<'EOF'
Usage: sudo ./scripts/install-kiosk.sh [options]

Options:
  --url URL           Kiosk URL to open on boot
  --hostname NAME     Optional Raspberry Pi hostname
  --user NAME         Desktop user that should own the kiosk config
  --skip-upgrade      Skip apt full-upgrade
  --help              Show this help text
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url)
      TARGET_URL="$2"
      shift 2
      ;;
    --hostname)
      TARGET_HOSTNAME="$2"
      shift 2
      ;;
    --user)
      TARGET_USER="$2"
      shift 2
      ;;
    --skip-upgrade)
      SKIP_UPGRADE=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this installer with sudo." >&2
  exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
  echo "Unable to determine the desktop user. Re-run with --user <name>." >&2
  exit 1
fi

if ! id "$TARGET_USER" >/dev/null 2>&1; then
  echo "User '$TARGET_USER' does not exist on this Raspberry Pi." >&2
  exit 1
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [[ -z "$TARGET_HOME" || ! -d "$TARGET_HOME" ]]; then
  echo "Could not resolve the home directory for '$TARGET_USER'." >&2
  exit 1
fi

if command -v chromium >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v chromium)"
elif command -v chromium-browser >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v chromium-browser)"
else
  echo "Chromium is not installed. Use Raspberry Pi OS Desktop and try again." >&2
  exit 1
fi

FREE_KB_BEFORE="$(root_free_kb)"
if [[ "$SKIP_UPGRADE" -eq 0 && "$FREE_KB_BEFORE" -lt 3000000 ]]; then
  echo "Warning: less than 3GB is free on /. A full upgrade may fail on a cramped card." >&2
  echo "Use Raspberry Pi OS Desktop on a clean 16GB card, or re-run with --skip-upgrade." >&2
fi

echo "Updating package metadata..."
apt update

if [[ "$SKIP_UPGRADE" -eq 0 ]]; then
  echo "Installing system upgrades..."
  apt -y full-upgrade
fi

echo "Installing kiosk dependency..."
apt -y install wtype
apt -y autoremove
apt clean

if command -v raspi-config >/dev/null 2>&1; then
  echo "Configuring desktop autologin..."
  raspi-config nonint do_boot_behaviour B4

  echo "Ensuring boot waits for the network..."
  raspi-config nonint do_boot_wait 1

  if raspi-config nonint do_wayland W2 >/dev/null 2>&1; then
    echo "Using the Wayland labwc backend."
  fi

  if [[ -n "$TARGET_HOSTNAME" ]]; then
    echo "Setting hostname to '$TARGET_HOSTNAME'..."
    raspi-config nonint do_hostname "$TARGET_HOSTNAME"
  fi
fi

echo "Writing kiosk files for '$TARGET_USER'..."
install -d -m 755 -o "$TARGET_USER" -g "$TARGET_USER" \
  "$TARGET_HOME/.config" \
  "$TARGET_HOME/.config/labwc" \
  "$TARGET_HOME/.local" \
  "$TARGET_HOME/.local/bin"

install -m 755 -o "$TARGET_USER" -g "$TARGET_USER" \
  "$REPO_ROOT/config/kiosk-browser.sh" \
  "$TARGET_HOME/.local/bin/kiosk-browser.sh"

install -m 644 -o "$TARGET_USER" -g "$TARGET_USER" \
  "$REPO_ROOT/config/labwc-autostart" \
  "$TARGET_HOME/.config/labwc/autostart"

cat >"$TARGET_HOME/.config/kiosk.env" <<EOF
KIOSK_URL="$TARGET_URL"
KIOSK_BROWSER_BIN="$BROWSER_BIN"
EOF

chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/kiosk.env"
chmod 600 "$TARGET_HOME/.config/kiosk.env"

echo
echo "Kiosk setup complete."
echo "User:      $TARGET_USER"
echo "URL:       $TARGET_URL"
echo "Browser:   $BROWSER_BIN"
echo "Free space: $(root_free_kb) KB available on /"
if [[ -n "$TARGET_HOSTNAME" ]]; then
  echo "Hostname:  $TARGET_HOSTNAME"
fi
echo
echo "Reboot the Raspberry Pi to launch the kiosk."
