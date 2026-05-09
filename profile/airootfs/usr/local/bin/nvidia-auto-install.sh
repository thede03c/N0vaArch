#!/bin/bash

echo "[NovaArch] Detecting NVIDIA GPU..."

if lspci | grep -i nvidia > /dev/null; then
    echo "[NovaArch] NVIDIA GPU found. Installing drivers..."

    pacman -Sy --noconfirm nvidia nvidia-utils lib32-nvidia-utils

    echo "[NovaArch] NVIDIA drivers installed."
else
    echo "[NovaArch] No NVIDIA GPU detected. Skipping."
fi