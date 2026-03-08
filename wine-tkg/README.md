# Wine-TkG Build Infrastructure

This directory contains the wine-tkg build system, integrated from
[Frogging-Family/wine-tkg-git](https://github.com/Frogging-Family/wine-tkg-git)
via the EdgeOfAssembly fork.

Wine-tkg is a build-system aiming at easier custom wine builds creation.

## Quick How-To

### Configuration/Customization

Basic settings: [`customization.cfg`](customization.cfg)
Advanced settings: [`wine-tkg-profiles/advanced-customization.cfg`](wine-tkg-profiles/advanced-customization.cfg)

### Building (Arch Linux / pacman/makepkg distros)

From the `wine-tkg` directory:
```
makepkg -si
```

### Building (other distros)

From the `wine-tkg` directory:
```
./non-makepkg-build.sh
```

## Directory Structure

- `PKGBUILD` — Arch Linux package build script
- `customization.cfg` — Basic build settings
- `non-makepkg-build.sh` — Build script for non-Arch distros
- `wine.install` — Post-install hooks
- `wine-tkg-patches/` — Patch sets:
  - `misc/` — Miscellaneous config files (`30-win32-aliases.conf`, `wine-binfmt.conf`)
- `wine-tkg-profiles/` — Build profiles and advanced configuration
- `wine-tkg-scripts/` — Build helper scripts (`build-32.sh`, `build-64.sh`, `Makefile.single`, launchers, `package-debian.sh`)
- `wine-tkg-userpatches/` — Directory for user-supplied patches

## Key Features Available via Configuration

The `customization.cfg` and `wine-tkg-profiles/advanced-customization.cfg` files
expose toggles for the following features (most require a full wine-tkg clone with
upstream `prepare.sh`/`build.sh` to build):

- Wine-Staging patchset support (`_use_staging`)
- NTsync / fsync / esync synchronization primitives (`_use_ntsync`, `_use_fsync`, `_use_esync`)
- Proton compatibility patches: BattlEye/EAC bridge, fullscreen hack, rawinput (`_proton_battleye_support`, `_proton_eac_support`, `_proton_fs_hack`)
- CSMT toggle (`_CSMT_toggle`)
- Wayland driver support (`_wayland_driver`)
- Game-specific fixes: MK11, Assetto Corsa, etc.
- Debian package generation (`_GENERATE_DEBIAN_PACKAGE`)

## License

Wine is released under the GNU LGPL. See the main repository LICENSE file.
