#!/usr/bin/env bash
set -euo pipefail

DEFAULT_URL="https://kronangsif.github.io"
ENV_FILE="$HOME/.config/kiosk.env"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

URL="${KIOSK_URL:-$DEFAULT_URL}"
BROWSER_BIN="${KIOSK_BROWSER_BIN:-chromium}"

while true; do
  "$BROWSER_BIN" \
    "$URL" \
    --kiosk \
    --noerrdialogs \
    --disable-infobars \
    --no-first-run \
    --enable-features=OverlayScrollbar \
    --start-maximized \
    --overscroll-history-navigation=0
  sleep 2
done
