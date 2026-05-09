#!/bin/bash

echo "[NovaArch] Running hardware detection..."

CPU_MODEL=$(lscpu | awk -F: '/Model name/ {print $2}' | xargs)
RAM_GB=$(free -g | awk '/Mem:/ {print $2}')
GPU_INFO=$(lspci | grep -E "VGA|3D|Display")

echo "CPU: $CPU_MODEL"
echo "RAM: ${RAM_GB}GB"
echo "GPU: $GPU_INFO"

# -----------------------------
# BASIC HARDWARE CLASSIFICATION
# -----------------------------

HIGH_END=false

# simple heuristic rules
if [ "$RAM_GB" -ge 16 ]; then
    HIGH_END=true
fi

if echo "$GPU_INFO" | grep -qi "nvidia\|amd.*rx 6\|amd.*rx 7"; then
    HIGH_END=true
fi

echo "[NovaArch] System tier: $([ "$HIGH_END" = true ] && echo HIGH-END || echo MID/LOW)"

# -----------------------------
# SAFE OPTIMIZATIONS ONLY
# -----------------------------

# CPU governor (safe for most systems)
if command -v cpupower &>/dev/null; then
    echo "[NovaArch] Setting CPU governor to performance..."
    cpupower frequency-set -g performance
fi

# ZRAM only if not high-end (avoid unnecessary compression overhead)
if [ "$HIGH_END" = false ]; then
    echo "[NovaArch] Enabling lightweight ZRAM optimization..."
    modprobe zram
    echo lz4 > /sys/block/zram0/comp_algorithm 2>/dev/null
else
    echo "[NovaArch] High-end system detected — skipping aggressive ZRAM tuning."
fi

echo "[NovaArch] Hardware tuning complete."