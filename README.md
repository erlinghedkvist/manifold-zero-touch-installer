# manifold CLOUD Zero Touch Installer

Source files for building and publishing the manifold CLOUD zero-touch Ubuntu
Server installer.

This repository should track the authored installer configuration and build
helpers, not the full extracted Ubuntu installer payload. Keep the base Ubuntu
ISO contents on a build machine, generate a release ISO, and publish that ISO
as a GitHub Release asset or via object storage.

## Tracked Source

- `manifold_setup.yml` - Ansible provisioning playbook run after install.
- `nocloud/user-data` - Ubuntu autoinstall cloud-init seed.
- `nocloud/meta-data` - NoCloud metadata file.
- `overlay/` - Authored files copied over the extracted Ubuntu ISO tree.
- `scripts/` - Build and checksum helpers.
- `manifest.json` - Base installer and release metadata.

## Local Build

The local workspace may also contain extracted Ubuntu installer directories such
as `boot/`, `casper/`, `pool/`, `EFI/`, and `dists/`. These are intentionally
ignored by Git because they include large upstream binaries.

Build a customer ISO from a workspace that contains those ignored base files:

```sh
./scripts/build-installer.sh
./scripts/checksum.sh dist/manifold-zero-touch-*.iso
```

Publish the ISO and checksum from `dist/` as release assets.
