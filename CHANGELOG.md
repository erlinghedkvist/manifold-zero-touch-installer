# Changelog

## 1.0.6 - 2026-10-04

This release of manifold CLOUD Zero Touch Installer provisions manifold CLOUD
1.7.3 on Ubuntu Server 24.04.5 LTS (Noble Numbat), for amd64 servers.
The installer release number (1.0.6) is separate from the application version
(1.7.3).

### Changes

- Distribute a small USB-files ZIP on GitHub; download the pinned Ubuntu ISO
  separately from Canonical. Customers combine the files on a writable USB.
- Document graphical Windows (Rufus ISO mode) and macOS USB preparation.
  The Rufus workflow is not yet Windows-tested.
- Upgrade the Ubuntu installer base from 22.04.5 to 24.04.5.
- Download manifold CLOUD 1.7.3 from the updated Google Drive archive.
- Install `gdown` in `/opt/manifold-gdown` using `python3-venv`, rather than
  modifying Ubuntu's managed system Python.
- Set `LANG=C.UTF-8` and `LC_ALL=C.UTF-8` explicitly when running provisioning
  inside the installed system, fixing Ansible's UTF-8 startup error.
- Preserve the playbook's exit status when piping output to the console, so
  provisioning failures stop installation.
- Refresh the ISO's file-integrity checksums for the custom installer files.
- Hide the GRUB memory-test entry when its binary is absent.
- Update the development USB documentation for its Ubuntu 24.04.5 base.

### Installation

Connect the server to the internet before installation. The installer downloads
manifold CLOUD and supporting packages during provisioning.

After the OS installation, run `install.sh` from
`/home/manifold/manifold-cloud/1.7.3`, configure the application using the
provided examples, and apply the deployment license. These application setup
steps remain manual.

Server testing confirmed Ubuntu 24.04 boot, detection of two Altera FPGA cards,
40 hugepages, and successful provisioning after the UTF-8 locale correction.
The subsequent manual manifold CLOUD installation was reported successful.

The 1.0.6 USB-files ZIP was applied to the existing development USB on macOS;
all five copied files matched the package on read-back. All 373 package MD5
entries were verified against the local Ubuntu payload and custom files.
On 2026-10-04, the user reported that the entire setup from this updated USB
completed successfully on the test server. A Rufus-created USB test on Windows
remains pending. A full USB payload rescan was stopped because of slow read speeds;
the unchanged Ubuntu files had been verified during the earlier USB preparation.
