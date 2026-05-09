# NovaArch ISO (Lean + Gaming + Privacy)

This project builds a personalized Arch Linux ISO using `archiso`.

## What is included

- Custom distro identity (editable name, label, publisher).
- Gaming-focused package set (Steam, Discord, Vulkan stack, MangoHud, Gamemode).
- Daily-use apps you requested (VirtualBox, Mullvad VPN, private browser options).
- Hardware support packages for AMD Ryzen + Radeon and common gaming peripherals.
- Cross-hardware baseline enabled (AMD/Intel CPU microcode paths, AMD/Intel graphics stack, optional NVIDIA proprietary path).
- Wi-Fi + Bluetooth stack included (`NetworkManager`, `iwd`, `bluez`, `blueman`).
- Lightweight modern desktop (`Hyprland` + `Waybar` + `Wofi`) instead of KDE.
- Easy branding workflow for your own logo and wallpaper pack.
- Animated HTML wallpaper pack support (`index.html` responsive scenes).
- NovaArch Control Center UI (opens on boot, can be disabled in one click).

## Important hardware/software notes

- `Logitech G HUB` has no native Linux release. Closest alternatives are `piper`, `ratbagd`, and `solaar`.
- Logitech wheels typically work via kernel drivers; tuning tools like `oversteer` can help.
- Lian Li SL Wireless LCD fan control on Linux is limited; no official suite equivalent.
- Monsgeek keyboards generally work as HID devices; advanced features depend on firmware ecosystem (QMK/VIA support varies by model).

## Build on Windows (WSL2 path for your setup)

You cannot run `mkarchiso` natively from Windows PowerShell. Use WSL2 and keep project at:

- `C:\Users\1\Desktop\project`

1. Install Ubuntu in WSL2.
2. In Ubuntu:
   - `sudo apt update && sudo apt install -y git rsync arch-install-scripts`
   - `cd /mnt/c/Users/1/Desktop/project`
   - `chmod +x scripts/*.sh`
3. Run:
   - `sudo ./scripts/setup-archiso-env.sh`
   - `sudo ./scripts/build-iso.sh`
4. Output ISO will appear in `out/`.

### If WSL is unavailable (Boot Camp or restricted Windows)

Use one of these methods:

1. Arch Linux VM build (recommended fallback)
   - Create an Arch VM in VirtualBox.
   - Copy project into VM and run:
     - `sudo ./scripts/setup-archiso-env.sh`
     - `sudo ./scripts/build-iso.sh`
2. GitHub Actions build (no local Linux needed)
  - Workflow file: `.github/workflows/build-iso.yml`
  - Trigger manually from Actions tab (`Build ISO`) and choose `kernel_track` (`zen`, `cachy`, `lts`).
  - Download generated ISO artifact + `SHA256SUMS.txt`.

## Quick customization

Edit `scripts/iso-config.env`:

- `ISO_NAME`
- `ISO_LABEL`
- `ISO_PUBLISHER`
- `ISO_APPLICATION`
- `KERNEL_TRACK` (`zen`, `cachy`, or `lts`)
- `ENABLE_BLEEDING_EDGE_TRACK` (`1` enables experimental metadata for future edge presets)

Replace branding assets:

- `branding/logo.svg`
- `branding/logo-variants/*` (alternative A-style marks)
- `branding/wallpapers/*`

Animated wallpaper scenes are included at:

- `profile/airootfs/usr/share/novaarch/web-wallpapers/*/index.html`
- 10 scenes are included by default (2 original + 8 new).

## Build

```bash
sudo ./scripts/setup-archiso-env.sh
sudo ./scripts/build-iso.sh
```

## User setup flow

- Use `archinstall` for full install + user creation (recommended).
- Or run `novaarch-create-user` in live session for manual account creation.
- For animated scenes:
  - `novaarch-web-wallpaper` for terminal selection.
  - `novaarch-wallpaper-selector` for Wofi GUI selection.
  - Preferred scene now auto-starts at Hyprland login.
- For updates:
  - Waybar shows `UPD <count>` from pacman update checks.
  - Click the update module to launch `novaarch-system-update`.
- Control Center:
  - Auto-opens on login by default.
  - Toggle boot autostart from inside the Control Center.
  - Shortcut: `SUPER+SHIFT+C`.
  - Includes tabs/actions for app installs, package updates, richer monitor, game presets, NovaArch tweaks, network/bluetooth, wallpaper, process managers, and settings folder.
- Welcome app:
  - `novaarch-welcome` opens a native GTK starter UI (tabbed, polished layout).
  - Autostarts by default; disable from "Toggle Launch at Startup".
  - Shortcut: `SUPER+SHIFT+A`.
- Terminal style:
  - Fish prompt with NovaArch marker is preconfigured.
  - Konsole default profile starts fish.
  - Fastfetch logo is customized to NovaArch branding.
- Process/task managers:
  - CLI: `btop` and `htop`
  - GUI: `qps`
- Static wallpapers:
  - Use `novaarch-wallpaper-manager` to pick bundled static wallpapers or import your own image files.
- Web wallpapers:
  - Includes responsive scenes and can be extended manually.
- App catalog:
  - Use `novaarch-app-hub` for multi-select software install/remove plus package maintenance actions.
  - Includes browser, VPN, gaming, and daily-use apps in one UI (including Brave via Flatpak).
  - Includes maintenance actions: update system, reset keyrings, reinstall/remove packages.
- Desktop shortcuts and pinning:
  - Use `novaarch-app-shortcuts` to add app launchers to desktop and pin/unpin taskbar launcher entries.
  - Waybar includes a pinned-app launcher module.
  - Thunar right-click actions include `Add to Desktop` and `Pin to Taskbar` for `.desktop` app entries.

## Notes on "fully optimized"

- This profile is debloated (no KDE, no large default desktop suites).
- Desktop stack is lightweight and modern (`Hyprland`).
- Includes practical performance tuning via `sysctl` defaults and reduced package surface.
- For your CPU/GPU combo, `linux-zen` is the safest high-performance baseline.
- Optional `KERNEL_TRACK="cachy"` uses Cachy kernel packages for aggressive performance testing.
- Includes explicit firmware coverage (`linux-firmware-amdgpu` and `linux-firmware-qcom`).
- Adds extra firmware coverage (`linux-firmware-broadcom`) plus Intel graphics Vulkan path.
- Includes `linux-lts` fallback kernel for stability recovery paths.
- Early KMS is enabled through mkinitcpio module config (`amdgpu`).
- UEFI boot menu includes both `linux-zen` (default) and `linux-lts` fallback entries.
- Includes `novaarch-gaming-preset` helper for performance governor + tuning reload.
- Steam helper command: `novaarch-steam-env` for recommended launch options.
- Graphics validation command: `novaarch-validate-graphics` (`vulkaninfo`, `glxinfo` checks).
- Optional bundle installer: `novaarch-install-extras` (RGB/peripheral, privacy browser, virtualization host tools).
- Tweaks panel command: `novaarch-tweaks` (governor, RT audio priority, preset controls).
- Per-game templates command: `novaarch-game-presets`.
- Rich monitor command: `novaarch-monitor` (GPU usage/temp/freq/power + system snapshot).
- HTML scenes are resolution-independent and auto-scale to any display size.

## GitHub Actions release flow

1. Push your branch to GitHub.
2. Open Actions -> `Build ISO`.
3. Run workflow and pick `kernel_track` (`zen`, `cachy`, `lts`).
4. Download artifact bundle (`*.iso` + `SHA256SUMS.txt`).
5. Verify checksum locally:
   - `sha256sum -c SHA256SUMS.txt`
6. Flash ISO with Rufus and test boot/install path.

## Install to USB

On Linux:

```bash
sudo dd if=out/<your-iso-file>.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Replace `/dev/sdX` with your USB device.
