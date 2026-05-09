#!/usr/bin/env bash
set -euo pipefail

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable firstboot-message.service
systemctl enable greetd
systemctl enable systemd-oomd
systemctl enable fstrim.timer
systemctl enable novaarch-plymouth-oem.service

# Keep live env lean and secure; no default permanent user is created here.
# User creation is handled by:
# - archinstall (recommended), or
# - novaarch-create-user helper on first boot.

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

mkdir -p /usr/share/novaarch

if [[ -f /usr/share/icons/archlinux-icon-crystal/archlinux-logo-crystal-normal.svg ]]; then
  mkdir -p /etc/skel/.local/share/novaarch/waybar
  cp -f /usr/share/icons/archlinux-icon-crystal/archlinux-logo-crystal-normal.svg \
    /etc/skel/.local/share/novaarch/waybar/launcher-icon.svg
fi

chmod +x /usr/local/bin/novaarch-create-user
chmod +x /usr/local/bin/novaarch-web-wallpaper
chmod +x /usr/local/bin/novaarch-wallpaper-selector
chmod +x /usr/local/bin/novaarch-check-updates
chmod +x /usr/local/bin/novaarch-system-update
chmod +x /usr/local/bin/novaarch-gaming-preset
chmod +x /usr/local/bin/novaarch-steam-env
chmod +x /usr/local/bin/novaarch-control-center
chmod +x /usr/local/bin/novaarch-control-center-autostart
chmod +x /usr/local/bin/novaarch-app-installer
chmod +x /usr/local/bin/novaarch-wireless-repair
chmod +x /usr/local/bin/novaarch-welcome
chmod +x /usr/local/bin/novaarch-welcome-autostart
chmod +x /usr/local/bin/novaarch-welcome-gtk
chmod +x /usr/local/bin/novaarch-tweaks
chmod +x /usr/local/bin/novaarch-game-presets
chmod +x /usr/local/bin/novaarch-monitor
chmod +x /usr/local/bin/novaarch-validate-graphics
chmod +x /usr/local/bin/novaarch-install-extras
chmod +x /usr/local/bin/novaarch-launch-installer
chmod +x /usr/local/bin/novaarch-detect-oem
chmod +x /usr/local/bin/novaarch-plymouth-toggle
chmod +x /usr/local/bin/novaarch-wallpaper-manager
chmod +x /usr/local/bin/novaarch-installer-options
chmod +x /usr/local/bin/novaarch-refresh-plymouth-oem
chmod +x /usr/local/bin/novaarch-app-hub
chmod +x /usr/local/bin/novaarch-flatpak-setup
chmod +x /usr/local/bin/novaarch-apply-installer-choices
chmod +x /usr/local/bin/novaarch-ui-customizer
chmod +x /usr/local/bin/novaarch-desktop-clock
chmod +x /usr/local/bin/novaarch-open-trash
chmod +x /usr/local/bin/novaarch-app-shortcuts
chmod +x /usr/local/bin/novaarch-pinned-launcher
chmod +x /usr/local/bin/novaarch-add-desktop-shortcut
chmod +x /usr/local/bin/novaarch-pin-taskbar-shortcut
chmod +x /usr/local/bin/novaarch-countdown-timer
chmod +x /usr/local/bin/novaarch-start-menu
chmod +x /usr/local/bin/novaarch-apply-start-icon
chmod +x /usr/local/bin/novaarch-reload-waybar

/usr/local/bin/novaarch-detect-oem >/dev/null 2>&1 || true
/usr/local/bin/novaarch-refresh-plymouth-oem >/dev/null 2>&1 || true
/usr/local/bin/novaarch-plymouth-toggle on >/dev/null 2>&1 || true
/usr/local/bin/novaarch-flatpak-setup >/dev/null 2>&1 || true
