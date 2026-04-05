#!/usr/bin/env bash
set -euo pipefail

rm -rf "$ROOTFS_DIR"
mkdir -p "$(dirname "$ROOTFS_DIR")"
cp -a "$PREV_ROOTFS_DIR" "$ROOTFS_DIR"
