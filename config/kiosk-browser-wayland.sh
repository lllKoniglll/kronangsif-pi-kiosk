#!/usr/bin/env bash
set -euo pipefail

DEFAULT_URL="https://kronangsif.github.io"
ENV_FILE="$HOME/.config/kiosk.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

URL="${KIOSK_URL:-$DEFAULT_URL}"

if [[ -n "${KIOSK_BROWSER_BIN:-}" ]]; then
  BROWSER_BIN="$KIOSK_BROWSER_BIN"
elif command -v chromium >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v chromium)"
elif command -v chromium-browser >/dev/null 2>&1; then
  BROWSER_BIN="$(command -v chromium-browser)"
else
  echo "Chromium is not installed." >&2
  exit 1
fi

exec "$BROWSER_BIN" \
  "$URL" \
  --kiosk \
  --start-fullscreen \
  --noerrdialogs \
  --disable-infobars \
  --disable-session-crashed-bubble \
  --no-first-run \
  --password-store=basic \
  --enable-features=UseOzonePlatform \
  --disable-features=Translate,OverlayScrollbar \
  --ozone-platform=wayland \
  --overscroll-history-navigation=0
