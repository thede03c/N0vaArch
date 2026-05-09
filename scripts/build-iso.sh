#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FORCE_NATIVE="${1:-}"

if [[ ! -f "${SCRIPT_DIR}/iso-config.env" ]]; then
  echo "Missing scripts/iso-config.env"
  exit 1
fi

source "${SCRIPT_DIR}/iso-config.env"
export ISO_NAME ISO_LABEL ISO_PUBLISHER ISO_APPLICATION ISO_VERSION INSTALL_DIR

track="${KERNEL_TRACK:-zen}"
case "${track}" in
  zen)
    KERNEL_PACKAGE="linux-zen"
    KERNEL_HEADERS_PACKAGE="linux-zen-headers"
    PRIMARY_KERNEL_BASENAME="linux-zen"
    PRIMARY_TITLE="NovaArch Live (x86_64, gaming daily - zen)"
    ;;
  cachy)
    KERNEL_PACKAGE="linux-cachyos"
    KERNEL_HEADERS_PACKAGE="linux-cachyos-headers"
    PRIMARY_KERNEL_BASENAME="linux-cachyos"
    PRIMARY_TITLE="NovaArch Live (x86_64, gaming daily - cachy)"
    ;;
  lts)
    KERNEL_PACKAGE="linux-lts"
    KERNEL_HEADERS_PACKAGE="linux-lts-headers"
    PRIMARY_KERNEL_BASENAME="linux-lts"
    PRIMARY_TITLE="NovaArch Live (x86_64, stability - lts)"
    ;;
  *)
    echo "Unsupported KERNEL_TRACK '${track}'. Use: zen, cachy, lts"
    exit 1
    ;;
esac

export KERNEL_PACKAGE KERNEL_HEADERS_PACKAGE PRIMARY_KERNEL_BASENAME

# -----------------------------
# Docker fallback
# -----------------------------
if [[ "${FORCE_NATIVE}" != "--native" ]] && ! command -v mkarchiso >/dev/null 2>&1; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "mkarchiso not found and docker is not installed."
    echo "Run: sudo ./scripts/setup-archiso-env.sh"
    exit 1
  fi

  echo "mkarchiso not found on host. Switching to containerized Arch build..."
  exec docker run --rm --privileged \
    -v "${ROOT_DIR}:/workspace" \
    -w /workspace \
    archlinux:latest \
    bash -lc "pacman -Syu --noconfirm archiso git rsync gettext ripgrep bash && ./scripts/build-iso.sh --native"
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

WORK_DIR="${ROOT_DIR}/work"
OUT_DIR="${ROOT_DIR}/out"
PROFILE_DIR="${ROOT_DIR}/profile"

mkdir -p "${WORK_DIR}" "${OUT_DIR}"

envsubst < "${PROFILE_DIR}/profiledef.sh.in" > "${PROFILE_DIR}/profiledef.sh"

# -----------------------------
# Branding
# -----------------------------
install -Dm644 "${ROOT_DIR}/branding/logo.svg" \
  "${PROFILE_DIR}/airootfs/usr/share/pixmaps/${ISO_NAME}.svg" 2>/dev/null || true

install -Dm644 "${ROOT_DIR}/branding/logo2.svg" \
  "${PROFILE_DIR}/airootfs/usr/share/pixmaps/${ISO_NAME}-alt.svg" 2>/dev/null || true

install -Dm644 "${ROOT_DIR}/branding/splash.png" \
  "${PROFILE_DIR}/airootfs/usr/share/backgrounds/${ISO_NAME}-splash.png" 2>/dev/null || true

for extra in splash-photo-2 splash-arch-gradient; do
  install -Dm644 "${ROOT_DIR}/branding/${extra}.png" \
    "${PROFILE_DIR}/airootfs/usr/share/backgrounds/${ISO_NAME}-${extra}.png" 2>/dev/null || true
done

if [[ -d "${ROOT_DIR}/branding/wallpapers" ]]; then
  mkdir -p "${PROFILE_DIR}/airootfs/usr/share/backgrounds/${ISO_NAME}"
  cp -r "${ROOT_DIR}/branding/wallpapers/." \
    "${PROFILE_DIR}/airootfs/usr/share/backgrounds/${ISO_NAME}/"
fi

# -----------------------------
# Packages
# -----------------------------
cp "${PROFILE_DIR}/packages.x86_64.in" "${PROFILE_DIR}/packages.x86_64"
sed -i "s|@KERNEL_PACKAGE@|${KERNEL_PACKAGE}|g" "${PROFILE_DIR}/packages.x86_64"
sed -i "s|@KERNEL_HEADERS_PACKAGE@|${KERNEL_HEADERS_PACKAGE}|g" "${PROFILE_DIR}/packages.x86_64"

# Keep boot entry kernel paths aligned with selected track.
ENTRY_PRIMARY="${PROFILE_DIR}/efiboot/loader/entries/01-novaarch-linux.conf"
ENTRY_FALLBACK="${PROFILE_DIR}/efiboot/loader/entries/02-novaarch-linux-lts.conf"
ENTRY_PRIMARY_BAK="$(mktemp)"
ENTRY_FALLBACK_BAK="$(mktemp)"
cp "${ENTRY_PRIMARY}" "${ENTRY_PRIMARY_BAK}"
cp "${ENTRY_FALLBACK}" "${ENTRY_FALLBACK_BAK}"
trap 'cp "${ENTRY_PRIMARY_BAK}" "${ENTRY_PRIMARY}"; cp "${ENTRY_FALLBACK_BAK}" "${ENTRY_FALLBACK}"; rm -f "${ENTRY_PRIMARY_BAK}" "${ENTRY_FALLBACK_BAK}"' EXIT

sed -i "s|^title .*|title ${PRIMARY_TITLE}|" "${ENTRY_PRIMARY}"
sed -i "s|^linux .*|linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-${PRIMARY_KERNEL_BASENAME#linux-}|" "${ENTRY_PRIMARY}"
sed -i "s|^initrd .*|initrd /%INSTALL_DIR%/boot/x86_64/initramfs-${PRIMARY_KERNEL_BASENAME#linux-}.img|" "${ENTRY_PRIMARY}"

if [[ "${track}" == "lts" ]]; then
  sed -i '/^linux-lts$/d' "${PROFILE_DIR}/packages.x86_64"
  sed -i '/^linux-lts-headers$/d' "${PROFILE_DIR}/packages.x86_64"
fi

if [[ "${track}" == "cachy" ]]; then
  if ! rg -n "\[cachyos\]" "${PROFILE_DIR}/pacman.conf" >/dev/null 2>&1; then
    cat >> "${PROFILE_DIR}/pacman.conf" <<'EOF'

[cachyos]
SigLevel = Optional TrustAll
Server = https://mirror.cachyos.org/repo/$arch/$repo
EOF
  fi
fi

# -----------------------------
# FIX: only chmod, no self-install nonsense
# -----------------------------
AIROOT_BIN="${PROFILE_DIR}/airootfs/usr/local/bin"

if [[ -d "${AIROOT_BIN}" ]]; then
  chmod +x "${AIROOT_BIN}"/*.sh 2>/dev/null || true
fi

echo "[NovaArch] Script permissions applied"

# -----------------------------
# Build ISO
# -----------------------------
mkarchiso -v \
  -w "${WORK_DIR}" \
  -o "${OUT_DIR}" \
  "${PROFILE_DIR}"

echo
echo "ISO build complete. Output directory: ${OUT_DIR}"