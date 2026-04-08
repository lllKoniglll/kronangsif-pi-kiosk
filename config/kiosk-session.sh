#!/usr/bin/env bash
set -euo pipefail

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=kronangsif-kiosk
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export NO_AT_BRIDGE=1

if [[ -z "${XDG_RUNTIME_DIR:-}" || ! -d "${XDG_RUNTIME_DIR:-}" ]]; then
  echo "Missing XDG_RUNTIME_DIR for kiosk session." >&2
  exit 1
fi

mkdir -p "$XDG_CACHE_HOME"

exec /usr/bin/dbus-run-session -- /usr/bin/cage -- /usr/local/lib/kronangsif/kiosk-browser.sh
