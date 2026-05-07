# manifold CLOUD Zero Touch Installer

Zero-touch Ubuntu Server installer for manifold CLOUD appliances.

Customers should use the published installer ISO from the GitHub Releases page.
The files in this repository are the source files used to build that ISO.

This installer provisions manifold CLOUD software version `1.6.7`.

## Customer Install

Use a Windows or macOS computer to create the bootable USB installer.

You need:

- The latest `manifold-zero-touch-<version>.iso` from GitHub Releases.
- A USB stick large enough for the ISO.
- Balena Etcher for Windows or macOS.

Writing the ISO to USB erases the USB stick. Do not copy the ISO file or this
repository folder onto a normal formatted USB drive. The ISO must be written to
the USB stick as a bootable disk image.

### Create the USB Installer

1. Download `manifold-zero-touch-<version>.iso` from GitHub Releases.
2. Insert the USB stick into the computer.
3. Open Balena Etcher.
4. Choose `Flash from file` and select the downloaded `.iso` file.
5. Choose the USB stick as the target.
6. Start the flash process and allow Etcher to erase and image the USB stick.
7. When Etcher finishes, eject the USB stick.
8. Insert the USB stick into the target server and boot from USB.

### Server Boot

After the target server boots from the USB stick, select
`Manifold CLOUD - Zero-Touch Autoinstall` if the boot menu appears.

Connect the server to the internet before starting the install. Any available
server network interface can be used; the installer configures server network
interfaces for DHCP during installation. Internet access is required so the
installer can download and install the required manifold CLOUD software and
supporting packages.

The installer runs Ubuntu autoinstall, installs the required packages, copies
`manifold_setup.yml` from the installer media, and runs the Ansible playbook.
When installation completes, reboot into the installed system and log in using
the credentials provided separately.

The zero-touch installer installs the manifold CLOUD software, but final
application setup still has to be completed after the server is installed.
Run install.sh from the 1.6.7 directory, configure the manifold CLOUD configuration files (cluster.ts and cloud.ts) and apply
the appropriate license before putting the server into service.

## Release Assets

Each customer release should include:

- `manifold-zero-touch-<version>.iso` - bootable Ubuntu installer image.
- `manifold-zero-touch-<version>.iso.sha256` - checksum for verifying the ISO.

The ISO is uploaded as a GitHub Release asset. It is not committed into normal
Git history.

## Tracked Source

- `manifold_setup.yml` - Ansible provisioning playbook run after install.
- `nocloud/user-data` - Ubuntu autoinstall cloud-init seed.
- `nocloud/meta-data` - NoCloud metadata file.
- `overlay/` - authored files copied over the extracted Ubuntu ISO tree.
- `scripts/` - build and checksum helpers for maintainers.
- `manifest.json` - base installer and release metadata.

## Maintainer Build

Maintainers use this repository to build the release ISO.

The local workspace may also contain extracted Ubuntu installer files and
directories such as `.disk/`, `boot/`, `casper/`, `pool/`, `EFI/`, `dists/`,
`install/`, `boot.catalog`, and `md5sum.txt`. These are intentionally ignored by
Git because they include large upstream binaries.

To make a fresh workspace buildable, download and extract the pinned Ubuntu
Server installer payload first:

```sh
./scripts/prepare-base-installer.sh
```

The script downloads `ubuntu-22.04.5-live-server-amd64.iso` from
`https://releases.ubuntu.com/22.04.5/`, verifies it against Ubuntu's
`SHA256SUMS`, and extracts the ignored base installer files into the repository
root. If those files are already present, pass `--force` to extract over them.

Build a customer ISO from a workspace that contains those ignored base files:

```sh
./scripts/build-installer.sh
./scripts/checksum.sh dist/manifold-zero-touch-*.iso
```

Publish the ISO and checksum from `dist/` as GitHub Release assets.
