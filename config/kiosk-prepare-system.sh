#!/usr/bin/env bash
set -euo pipefail

tty_path="${1:-/dev/tty1}"
tty_name="${tty_path#/dev/tty}"

if command -v chvt >/dev/null 2>&1; then
  chvt "$tty_name" || true
fi

if command -v setterm >/dev/null 2>&1; then
  setterm --blank 0 --powerdown 0 --powersave off --cursor off >"$tty_path" <"$tty_path" || true
fi

if [[ -w /sys/module/kernel/parameters/consoleblank ]]; then
  echo 0 >/sys/module/kernel/parameters/consoleblank || true
fi
