#!/usr/bin/env bash
set -euo pipefail

apt-get install -y --no-install-recommends \
  cage \
  chromium \
  dbus-user-session \
  fonts-noto-color-emoji \
  fonts-noto-core \
  wtype
apt-get clean

first_user_uid="$(id -u "$FIRST_USER_NAME")"
first_user_home="$(getent passwd "$FIRST_USER_NAME" | cut -d: -f6)"

sed \
  -e "s|__FIRST_USER_NAME__|$FIRST_USER_NAME|g" \
  -e "s|__FIRST_USER_HOME__|$first_user_home|g" \
  -e "s|__FIRST_USER_UID__|$first_user_uid|g" \
  /usr/local/lib/kronangsif/kronangsif-kiosk.service.template >/etc/systemd/system/kronangsif-kiosk.service

systemctl disable getty@tty1.service
systemctl enable NetworkManager-wait-online.service
systemctl enable kronangsif-kiosk.service
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

if [[ -f /boot/firmware/cmdline.txt ]] && ! grep -qw 'consoleblank=0' /boot/firmware/cmdline.txt; then
  sed -i '1 s#$# consoleblank=0#' /boot/firmware/cmdline.txt
fi

chown "$FIRST_USER_NAME:$FIRST_USER_NAME" "/home/$FIRST_USER_NAME/.config" "/home/$FIRST_USER_NAME/.config/kiosk.env"

if [[ -f /etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection ]]; then
  chmod 600 /etc/NetworkManager/system-connections/kronangsif-kiosk-wifi.nmconnection
fi
