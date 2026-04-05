#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BUILD_ROOT="${BUILD_ROOT:-$REPO_ROOT/.build}"
PIGEN_DIR="${PIGEN_DIR:-$BUILD_ROOT/pi-gen}"
PIGEN_REPO="${PIGEN_REPO:-https://github.com/RPi-Distro/pi-gen.git}"
PIGEN_BRANCH="${PIGEN_BRANCH:-arm64}"
CONFIG_OUT="${CONFIG_OUT:-$BUILD_ROOT/pigen-kronangsif.config}"
IMAGE_SECRETS_FILE="${IMAGE_SECRETS_FILE:-$REPO_ROOT/config/image-secrets.env}"
WIFI_CONFIG_FILE="${WIFI_CONFIG_FILE:-$REPO_ROOT/config/wifi.env}"
CUSTOM_STAGE_DIR="$REPO_ROOT/pigen/stage-kronangsif"

BUILD_MODE="docker"
PREPARE_ONLY=0
PRINT_CONFIG=0
REFRESH_PIGEN=0

load_env_file() {
  local env_file="$1"

  if [[ -f "$env_file" ]]; then
    # shellcheck source=/dev/null
    source "$env_file"
  fi
}

shell_quote() {
  printf '%q' "$1"
}

write_config_line() {
  local key="$1"
  local value="$2"
  printf '%s=%s\n' "$key" "$(shell_quote "$value")" >>"$CONFIG_OUT"
}

write_export_line() {
  local key="$1"
  local value="$2"
  printf 'export %s=%s\n' "$key" "$(shell_quote "$value")" >>"$CONFIG_OUT"
}

require_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "Missing required setting: $name" >&2
    exit 1
  fi
}

clone_or_refresh_pigen() {
  local current_branch=""

  mkdir -p "$BUILD_ROOT"

  if [[ ! -d "$PIGEN_DIR/.git" ]]; then
    git clone --depth 1 --branch "$PIGEN_BRANCH" "$PIGEN_REPO" "$PIGEN_DIR"
    return
  fi

  current_branch="$(git -C "$PIGEN_DIR" rev-parse --abbrev-ref HEAD)"

  if [[ "$REFRESH_PIGEN" -eq 1 || "$current_branch" != "$PIGEN_BRANCH" ]]; then
    git -C "$PIGEN_DIR" fetch --depth 1 origin "$PIGEN_BRANCH"
    git -C "$PIGEN_DIR" checkout -B "$PIGEN_BRANCH" "origin/$PIGEN_BRANCH"
    git -C "$PIGEN_DIR" reset --hard "origin/$PIGEN_BRANCH"
  fi
}

prepare_pigen_tree() {
  rm -f "$PIGEN_DIR"/stage{0,1,2,3,4,5}/SKIP
  touch "$PIGEN_DIR/stage2/SKIP_IMAGES"
  touch "$PIGEN_DIR/stage4/SKIP_IMAGES"
  touch "$PIGEN_DIR/stage5/SKIP_IMAGES"
}

render_config() {
  mkdir -p "$BUILD_ROOT"
  : >"$CONFIG_OUT"

  write_config_line IMG_NAME "${IMG_NAME:-kronangsif-pi-kiosk}"
  write_config_line PI_GEN_RELEASE "${PI_GEN_RELEASE:-Kronangs IF kiosk}"
  write_config_line ARCH "${ARCH:-arm64}"
  write_config_line RELEASE "${RELEASE:-trixie}"
  write_config_line DEPLOY_COMPRESSION "${DEPLOY_COMPRESSION:-xz}"
  write_config_line LOCALE_DEFAULT "${LOCALE_DEFAULT:-sv_SE.UTF-8}"
  write_config_line KEYBOARD_KEYMAP "${KEYBOARD_KEYMAP:-se}"
  write_config_line KEYBOARD_LAYOUT "${KEYBOARD_LAYOUT:-Swedish}"
  write_config_line TIMEZONE_DEFAULT "${TIMEZONE_DEFAULT:-Europe/Stockholm}"
  write_config_line TARGET_HOSTNAME "${TARGET_HOSTNAME:-kronangsif-pi}"
  write_config_line FIRST_USER_NAME "${FIRST_USER_NAME:-kiosk}"
  write_config_line FIRST_USER_PASS "${FIRST_USER_PASS}"
  write_config_line DISABLE_FIRST_BOOT_USER_RENAME "${DISABLE_FIRST_BOOT_USER_RENAME:-1}"
  write_config_line PASSWORDLESS_SUDO "${PASSWORDLESS_SUDO:-0}"
  write_config_line ENABLE_SSH "${ENABLE_SSH:-1}"
  write_config_line ENABLE_CLOUD_INIT "${ENABLE_CLOUD_INIT:-0}"
  write_config_line WPA_COUNTRY "${WPA_COUNTRY:-${WIFI_COUNTRY:-SE}}"
  write_config_line STAGE_LIST "stage0 stage1 stage2 stage3 stage4 ${CUSTOM_STAGE_DIR}"
  write_export_line KRONANGSIF_KIOSK_URL "${KIOSK_URL:-https://kronangsif.github.io}"
  write_export_line KRONANGSIF_WIFI_SSID "${WIFI_SSID}"
  write_export_line KRONANGSIF_WIFI_PASSWORD "${WIFI_PASSWORD}"
  write_export_line KRONANGSIF_WIFI_COUNTRY "${WIFI_COUNTRY:-SE}"
}

usage() {
  cat <<'EOF'
Usage: ./scripts/build-pi-image.sh [options]

Options:
  --build-mode MODE         docker (default) or native
  --prepare-only            Render the pi-gen config but do not clone/build
  --print-config            Print the rendered pi-gen config to stdout
  --refresh-pigen           Refresh the local pi-gen checkout before building
  --image-secrets FILE      Path to the local image secret file
  --wifi-config FILE        Path to the local Wi-Fi secret file
  --pigen-dir DIR           Path to the pi-gen checkout
  --pigen-branch BRANCH     pi-gen branch to use, default arm64
  --kiosk-url URL           Page to launch in Chromium
  --help                    Show this help text
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-mode)
      BUILD_MODE="$2"
      shift 2
      ;;
    --prepare-only)
      PREPARE_ONLY=1
      shift
      ;;
    --print-config)
      PRINT_CONFIG=1
      shift
      ;;
    --refresh-pigen)
      REFRESH_PIGEN=1
      shift
      ;;
    --image-secrets)
      IMAGE_SECRETS_FILE="$2"
      shift 2
      ;;
    --wifi-config)
      WIFI_CONFIG_FILE="$2"
      shift 2
      ;;
    --pigen-dir)
      PIGEN_DIR="$2"
      shift 2
      ;;
    --pigen-branch)
      PIGEN_BRANCH="$2"
      shift 2
      ;;
    --kiosk-url)
      KIOSK_URL="$2"
      shift 2
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

load_env_file "$IMAGE_SECRETS_FILE"
load_env_file "$WIFI_CONFIG_FILE"

require_var FIRST_USER_PASS
require_var WIFI_SSID
require_var WIFI_PASSWORD

render_config

if [[ "$PRINT_CONFIG" -eq 1 ]]; then
  cat "$CONFIG_OUT"
fi

if [[ "$PREPARE_ONLY" -eq 1 ]]; then
  exit 0
fi

clone_or_refresh_pigen
prepare_pigen_tree

case "$BUILD_MODE" in
  docker)
    (
      cd "$PIGEN_DIR"
      ./build-docker.sh -c "$CONFIG_OUT"
    )
    ;;
  native)
    if [[ "$(id -u)" -ne 0 ]]; then
      echo "Native pi-gen builds must run as root. Use sudo or --build-mode docker." >&2
      exit 1
    fi
    (
      cd "$PIGEN_DIR"
      ./build.sh -c "$CONFIG_OUT"
    )
    ;;
  *)
    echo "Unsupported build mode: $BUILD_MODE" >&2
    exit 1
    ;;
esac

echo
echo "Image build complete."
echo "Artifacts: $PIGEN_DIR/deploy"
