#!/usr/bin/env bash
set -euo pipefail

timeout="${1:-60}"

if command -v nm-online >/dev/null 2>&1; then
  exec nm-online -q --timeout="$timeout"
fi

exit 0
