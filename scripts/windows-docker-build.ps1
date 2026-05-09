#Requires -Version 5.1
<#
  Build NovaArch ISO on Windows using Docker Desktop (same path as scripts/build-iso.sh).

  Prerequisites:
  - Docker Desktop installed, running, Linux containers (WSL2 backend recommended)
  - Project path should stay short (Docker volume limits on Windows)

  Usage (PowerShell, from anywhere):
    & "C:\path\to\project\scripts\windows-docker-build.ps1"
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

try {
  docker version | Out-Null
} catch {
  Write-Error 'Docker is not running or not in PATH. Start Docker Desktop and retry.'
}

Write-Host "[NovaArch] Building in archlinux container (privileged)..." -ForegroundColor Cyan
Write-Host "[NovaArch] Project: $ProjectRoot"

docker run --rm --privileged `
  -v "${ProjectRoot}:/workspace" `
  -w /workspace `
  archlinux:latest `
  bash -lc 'pacman -Syu --noconfirm archiso git rsync gettext ripgrep bash && ./scripts/build-iso.sh --native'

Write-Host "[NovaArch] Done. ISO should be under: $(Join-Path $ProjectRoot 'out')" -ForegroundColor Green
