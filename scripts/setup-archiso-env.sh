#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

if command -v pacman >/dev/null 2>&1; then
  pacman -Sy --noconfirm archiso git rsync gettext
  echo "archiso environment ready (native Arch host)."
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y docker.io rsync gettext-base
  echo "Ubuntu/WSL environment ready for containerized archiso builds."
  echo "Next step: sudo ./scripts/build-iso.sh"
  exit 0
fi

echo "Unsupported host distro. Install either:"
echo "- Arch native tools (pacman + archiso), or"
echo "- Docker + gettext + rsync for containerized build."
exit 1
