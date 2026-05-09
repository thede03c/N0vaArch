# NovaArch Release Steps

1. Update branding and package choices:
   - Edit `scripts/iso-config.env` (`KERNEL_TRACK` and release metadata).
   - Confirm app groups in `profile/airootfs/etc/calamares/modules/netinstall.conf`.
2. Validate scripts locally:
   - `bash -n scripts/build-iso.sh scripts/setup-archiso-env.sh`
   - `python -m py_compile profile/airootfs/usr/local/bin/novaarch-app-hub profile/airootfs/usr/local/bin/novaarch-installer-options profile/airootfs/usr/local/bin/novaarch-desktop-clock`
3. Build ISO:
   - `sudo ./scripts/setup-archiso-env.sh`
   - `sudo ./scripts/build-iso.sh`
4. Verify artifacts:
   - `cd out`
   - `sha256sum *.iso > SHA256SUMS.txt`
5. Smoke-test in VM:
   - boot live ISO
   - connect network
   - run installer via welcome
   - validate app choice install log at `/var/log/novaarch-installer-choices.log`
6. Publish through GitHub Actions:
   - open Actions -> `Build NovaArch ISO`
   - choose `kernel_track` (`zen` for zen+LTS menus, or `lts` for LTS-only)
   - download `*.iso` and `SHA256SUMS.txt`
7. Final USB test:
   - flash with Rufus
   - boot on target hardware
   - validate graphics/network/input and wallpaper selector
