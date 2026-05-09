# NovaArch ISO (Light KDE Plasma)

Personalized Arch Linux live image built with `archiso`, focused on a **small package set** and a **normal desktop**: KDE Plasma with System Settings, movable windows, and multi-monitor configuration in the usual place.

## What is included

- Custom distro identity (name, label, publisher — see profile templates).
- **KDE Plasma** (`plasma-desktop`): panel, application launcher (Meta key), Dolphin, Konsole, System Settings.
- **SDDM** with autologin for the live user `live` into the Plasma session.
- Networking: **NetworkManager**, **iwd**, **plasma-nm** (tray applet), **bluez** + **bluedevil** (Bluetooth in Settings).
- **archinstall** for guided installation; NovaArch Welcome / Control Center helpers.
- GPU stack: AMD/Intel microcode, Mesa, Vulkan (common gaming GPUs); **no** Steam/Discord/virt stack on the ISO by default (install later from repos or App Hub).
- Plymouth branding hooks, wallpaper packs, optional HTML scenes.
- Optional NovaArch scripts (wallpaper tools, tweaks, app hub) using **zenity** / **kdialog** menus instead of Hyprland-only tools.

## Build

```bash
sudo ./scripts/setup-archiso-env.sh
sudo ./scripts/build-iso.sh
```

## Live session

- Boots into **Plasma** as user **`live`** (empty password, passwordless sudo for the live session only — removed by Calamares post-install when used).
- **Wi‑Fi**: use the network icon in the panel, or `nmtui`.
- **Install**: Welcome → **Launch Installer**, or run `sudo archinstall` / `novaarch-launch-installer` in Konsole.
- **Displays**: System Settings → **Display**.
- **Welcome** and **Control Center** can autostart (toggle inside each).

## Notes

- `linux-zen` is the default kernel track in CI; the ISO can also ship `linux-lts` entries depending on `scripts/build-iso.sh` / matrix.
- For hardware-specific notes (Logitech G HUB, wheels, etc.), see `firstboot-message` on the image.

## Install to USB

On Linux:

```bash
sudo dd if=out/<your-iso-file>.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `sdX` with your USB device (not a partition).
