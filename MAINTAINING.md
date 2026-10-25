# Maintainer Reference

The following sections are for maintaining and publishing the installer.
They are not required to create a USB or install a server.

## Test Status

On 2026-10-04, the updated USB package completed the entire setup successfully
on the test server using the existing development USB prepared on macOS.
Earlier checks confirmed Ubuntu 24.04, two Altera FPGA cards, and 40 hugepages.
On 2026-10-25, WeTTY was confirmed reachable over HTTPS on port 8022 from a
Mac on the local network after accepting the self-signed certificate warning.
Nano syntax highlighting was also confirmed through WeTTY for YAML, shell, and
TypeScript files.

This verifies the tested USB's extracted-file layout. A fresh USB created using
the Finder instructions and a Windows USB created using Rufus still need
end-to-end testing.

## Release Assets

Each customer release should include:

- `manifold-zero-touch-<version>-usb-files.zip` - ready-to-copy custom files.
- `manifold-zero-touch-<version>-usb-files.zip.sha256` - package checksum.

The small ZIP is uploaded to GitHub Releases. Ubuntu's ISO is downloaded
separately from Canonical, not uploaded to GitHub or committed into Git.
The two downloads are combined on the USB, not combined into a new ISO.

## Tracked Source

- `manifold_setup.yml` - Ansible provisioning playbook run after install.
- `nocloud/user-data` - Ubuntu autoinstall cloud-init seed.
- `nocloud/meta-data` - NoCloud metadata file.
- `overlay/` - authored files copied over the extracted Ubuntu ISO tree.
- `scripts/` - build and checksum helpers for maintainers.
- `manifest.json` - base installer and release metadata.

## Build the Release Package

Maintainers use this repository to build the release USB-files ZIP. A custom
ISO build remains available for local testing and image-based deployment.

Both builds use a locally cached, verified Ubuntu installer ISO. The optional
ISO build preserves Ubuntu's hybrid USB boot metadata. The workspace may contain
extracted Ubuntu installer files and directories such as `.disk/`, `boot/`,
`casper/`, `pool/`, `EFI/`, `dists/`, `install/`, `boot.catalog`, and
`md5sum.txt`. These are intentionally ignored by Git because they include large
upstream binaries.

To make a fresh workspace buildable, download and extract the pinned Ubuntu
Server installer payload first:

```sh
./scripts/prepare-base-installer.sh
```

The script downloads and caches `ubuntu-24.04.5-live-server-amd64.iso` from
`https://releases.ubuntu.com/24.04.5/`, verifies it against Ubuntu's
`SHA256SUMS`, and extracts the ignored base installer files into the repository
root. If those files are already present, it leaves them unchanged; pass
`--force` to extract over them.

Build the customer package from the cached, verified Ubuntu ISO:

```sh
python3 scripts/build-usb-package.py
```

Publish the ZIP and its checksum from `dist/` as GitHub Release assets. The
package places the four custom files at their USB paths and regenerates
`md5sum.txt` using the pinned Ubuntu image's checksums for unchanged files.

Optionally build a complete local ISO:

```sh
./scripts/build-installer.sh 1.0.7
./scripts/checksum.sh dist/manifold-zero-touch-1.0.7.iso
```

The complete ISO exceeds GitHub's 2 GiB per-asset limit and is not the customer
release download. It can still be flashed with Etcher for local tests.

## Development USB

The current release configuration uses Ubuntu Server 24.04.5 and provisions
manifold CLOUD 1.7.8. The development USB uses extracted installer files on a
writable FAT32 filesystem, including `EFI/`, `boot/`, `casper/`, and `nocloud/`.
For configuration changes on that same Ubuntu base, rebuild the USB-files
ZIP and merge its contents onto the USB. This also updates `md5sum.txt` so
the installer integrity checks match the custom files.

When changing the Ubuntu base in future, updating those custom files alone
does not upgrade the installer. Replace the complete Ubuntu installer payload,
or build the updated ISO and flash it to a USB. Flashing erases the destination
USB.

The provisioning playbook installs `gdown` into `/opt/manifold-gdown`, using
`python3-venv` to keep it separate from Ubuntu's managed system Python.
The autoinstall command explicitly sets `LANG=C.UTF-8` and `LC_ALL=C.UTF-8`
when running Ansible inside the target system.

The playbook installs Node.js 24.22.1 LTS and WeTTY 4.0.1 under `/opt`, then
runs WeTTY as an unprivileged system user over HTTPS on TCP port 8022. It
generates a self-signed certificate and allows HTTPS origins for the machine's
hostname and current IPv4 addresses. Restart `wetty.service` after a DHCP
address change. This is intentionally a trusted-LAN service; internet exposure
requires a trusted certificate, reverse proxy, and separate security review.

Nano uses Ubuntu's packaged YAML and shell syntax definitions. The playbook
adds `/usr/share/nano/typescript.nanorc` for `.ts` and `.tsx` files and manages
`/home/manifold/.nanorc` for the editor preferences documented in the README.

Server testing must also verify the FPGA driver installed by the vendor's
`1.7.8/install.sh` and confirm that the driver package in the new archive is
compatible with Ubuntu 24.04.5. The zero-touch playbook continues to leave
`install.sh`, application configuration, and licensing for manual setup after
the OS installation.
