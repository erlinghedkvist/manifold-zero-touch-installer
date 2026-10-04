# manifold CLOUD Zero Touch Installer

Prepare a bootable USB installer, then use it to provision a manifold CLOUD
server.

Installer release **1.0.6** provisions manifold CLOUD software version `1.7.3` on
Ubuntu Server `24.04.5` LTS (Noble Numbat), for amd64 servers.

There are two stages:

1. [Create the USB Installer](#1-create-the-usb-installer) on a Windows or Mac
   computer using two downloads: the Ubuntu ISO and the zero-touch files.
2. [Install on the Server](#2-install-on-the-server), then complete the manifold
   CLOUD application setup.

No command line or custom ISO build is required for the USB preparation steps
below. The server needs internet access during installation.

Release 1.0.6 replaces the previous Ubuntu Server 22.04.5 and manifold CLOUD
1.6.7 versions. See [CHANGELOG.md](CHANGELOG.md) for the full release history.

## 1. Create the USB Installer

This stage is done on your Windows or Mac computer, not on the target server.

### What You Need

- `manifold-zero-touch-1.0.6-usb-files.zip` from
  [GitHub Releases](https://github.com/erlinghedkvist/manifold-zero-touch-installer/releases).
- [Ubuntu Server 24.04.5 amd64 ISO](https://releases.ubuntu.com/24.04.5/ubuntu-24.04.5-live-server-amd64.iso).
- An 8 GB or larger USB stick. Preparing it erases its existing contents.
- [Rufus](https://rufus.ie/) on Windows, or Disk Utility and Finder on macOS.

Use exactly the Ubuntu ISO linked above: the zero-touch package includes
boot configuration and integrity checksums for that particular image.
Download both files to your computer, not directly to the USB stick.

The Ubuntu download is one `.iso` file containing the Ubuntu installer.
The zero-touch download is one `.zip` file containing several custom files
and folders. On Windows, Rufus uses **only the Ubuntu ISO**. After Rufus
finishes, use File Explorer to copy the **extracted zero-touch contents**
onto the USB. The ZIP is not opened or processed by Rufus.

**Preparing a new USB erases its existing contents.** Back up anything you need
and check that you have selected the correct device before erasing it.

### Windows

1. Download `ubuntu-24.04.5-live-server-amd64.iso` and
   `manifold-zero-touch-1.0.6-usb-files.zip` to your computer using the links
   above. These are two separate downloads.
2. Insert the USB stick and open Rufus. Select the USB device, click Select,
   and choose **`ubuntu-24.04.5-live-server-amd64.iso` only**.
3. Choose GPT, UEFI (non-CSM), and FAT32. Leave persistence disabled.
4. Click Start. If prompted, select **Write in ISO Image mode**, not DD mode.
   Confirm the USB erase and wait for Rufus to finish, then close Rufus.
   The USB now contains the standard Ubuntu installer, without zero-touch.
5. In File Explorer, right-click `manifold-zero-touch-1.0.6-usb-files.zip`
   and choose **Extract All**. Extract it to a folder on your computer.
6. Open that extracted folder. Copy its contents (`boot`, `nocloud`,
   `manifold_setup.yml`, and `md5sum.txt`) into the USB's top-level folder.
   Merge existing folders and replace existing files when prompted. Copy the
   contents, not the enclosing folder or the ZIP itself.
7. Follow [Check the USB](#check-the-usb) below, then eject it safely.

Do not run Rufus again after adding the zero-touch files: doing so would
overwrite the USB and remove them.

Use ISO Image mode so the USB remains writable and the zero-touch files can
be added. Etcher and Rufus DD mode are not suitable for this two-download
workflow.

Ubuntu documents Rufus's [ISO Image mode workflow](https://ubuntu.com/desktop/docs/en/latest/how-to/create-a-bootable-usb-stick/).
The Rufus-specific workflow has not yet been tested on Windows. See
[Test Status](MAINTAINING.md#test-status) in the maintainer reference.

### macOS

1. In Disk Utility, choose View > Show All Devices, then select the physical
   USB device carefully. Erase it with format **MS-DOS (FAT)** and scheme
   **GUID Partition Map**. This destroys its existing contents.
2. Double-click the downloaded Ubuntu ISO to mount it in Finder.
3. In Finder, press Command-Shift-period to show hidden files. Open the mounted
   Ubuntu image and copy all its contents, including `.disk`, into the USB's
   top-level folder. Wait for copying to finish.
4. If Finder cannot mount the ISO or copy every file, stop. Do not boot an
   incomplete USB; ask the installer maintainer for assistance.
5. Extract the zero-touch ZIP and copy its contents into the USB's top-level
   folder, merging folders and replacing existing files. In Finder's folder
   conflict dialog, hold Option to reveal Merge if needed. Do not replace the
   entire Ubuntu `boot` folder with the package's smaller `boot` folder.
6. Follow [Check the USB](#check-the-usb) below, then eject it safely.

If you already have a writable USB prepared with this exact Ubuntu 24.04.5
image, start at step 5. Updating the zero-touch files does not require erasing
that USB. A USB containing an older Ubuntu release needs the complete new
Ubuntu payload, not just the zero-touch files.

### Check the USB

The USB's top-level folder should contain Ubuntu's `EFI`, `boot`, and `casper`
folders, along with these zero-touch files:

```text
manifold_setup.yml
md5sum.txt
nocloud/
  user-data
  meta-data
boot/
  grub/
    grub.cfg
```

These files must be at the paths shown, not inside an extra package folder.
Copying the unopened ZIP or ISO onto the USB is not sufficient.

The USB is now ready for the target server. You do not need to combine the
downloads into a new ISO.

## 2. Install on the Server

This stage is done on the target manifold CLOUD server using the prepared USB.

### Before You Start

Warning: zero-touch installation automatically repartitions the selected
server disk and erases its existing contents. Back up the server first and
disconnect disks that must not be overwritten. The default boot entry starts
autoinstall after a five-second countdown.

Connect the server to the internet before starting the install. Any available
server network interface can be used; the installer configures server network
interfaces for DHCP during installation. Internet access is required so the
installer can download and install the required manifold CLOUD software and
supporting packages.

### Run the Zero-Touch Installation

1. Insert the prepared USB into the server.
2. Start the server and choose its **UEFI USB** boot entry.
3. Select `Manifold CLOUD - Zero-Touch Autoinstall` if the installer menu
   appears. This is the default entry.
4. Allow Ubuntu installation and provisioning to finish. The installer installs
   supporting packages, downloads and extracts manifold CLOUD 1.7.3, and applies
   the server configuration, including hardware-dependent hugepage settings.
5. When installation completes, remove the USB when prompted, reboot into the
   installed system, and log in using the credentials provided separately.

### Complete the manifold CLOUD Setup

The zero-touch stage prepares Ubuntu and the manifold CLOUD files. The final
application installation, configuration, and licensing remain manual:

1. Run `install.sh` from `/home/manifold/manifold-cloud/1.7.3`.
2. Configure manifold CLOUD using the supplied examples in
   `/home/manifold/manifold-cloud/configuration/`.
3. Apply the appropriate license before putting the server into service.

## Maintenance

For release builds, publishing, test status, and development USB notes, see
[MAINTAINING.md](MAINTAINING.md). These instructions are for repository
maintainers, not for preparing a USB or installing a server.
