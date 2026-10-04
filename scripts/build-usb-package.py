#!/usr/bin/env python3
"""Package the custom files for a writable, extracted Ubuntu USB installer."""

import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import zipfile


def main():
    root = Path(__file__).resolve().parent.parent
    manifest = json.loads((root / "manifest.json").read_text())
    version = manifest["installerVersion"]
    base = root / "build/base-installer" / manifest["baseInstaller"]["iso"]
    output = root / "dist" / f"manifold-zero-touch-{version}-usb-files.zip"
    if not base.is_file():
        raise SystemExit(f"Cache the pinned Ubuntu ISO at {base} first.")
    if not shutil.which("xorriso"):
        raise SystemExit("xorriso is required (macOS: brew install xorriso).")
    if output.exists():
        raise SystemExit(f"Output already exists: {output}")

    files = {
        "boot/grub/grub.cfg": root / "overlay/boot/grub/grub.cfg",
        "manifold_setup.yml": root / "manifold_setup.yml",
        "nocloud/user-data": root / "nocloud/user-data",
        "nocloud/meta-data": root / "nocloud/meta-data",
    }
    payload = {name: path.read_bytes() for name, path in files.items()}
    with tempfile.TemporaryDirectory(prefix="manifold-usb-") as directory:
        checksum_path = Path(directory) / "md5sum.txt"
        subprocess.run([
            "xorriso", "-osirrox", "on", "-indev", str(base),
            "-extract", "/md5sum.txt", str(checksum_path),
        ], check=True)
        overrides = {
            f"./{name}": hashlib.md5(data).hexdigest()
            for name, data in payload.items()
        }
        lines = []
        for line in checksum_path.read_text().splitlines():
            digest, name = line.split(maxsplit=1)
            lines.append(f"{overrides.pop(name, digest)}  {name}")
        lines.extend(f"{digest}  {name}" for name, digest in sorted(overrides.items()))
        payload["md5sum.txt"] = ("\n".join(lines) + "\n").encode("ascii")

    output.parent.mkdir(exist_ok=True)
    with zipfile.ZipFile(output, "x", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(payload.items()):
            archive.writestr(name, data)
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    output.with_suffix(".zip.sha256").write_text(f"{digest}  {output.name}\n")
    print(f"Built {output} ({output.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
