#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-$(date +%Y.%m.%d)}"
VOLUME_ID="${VOLUME_ID:-MANIFOLD_ZT}"
OUT_DIR="$ROOT_DIR/dist"
OUT_ISO="$OUT_DIR/manifold-zero-touch-$VERSION.iso"

required_paths=(
  "$ROOT_DIR/.disk"
  "$ROOT_DIR/boot/grub"
  "$ROOT_DIR/boot/grub/i386-pc/eltorito.img"
  "$ROOT_DIR/casper"
  "$ROOT_DIR/casper/hwe-initrd"
  "$ROOT_DIR/casper/hwe-vmlinuz"
  "$ROOT_DIR/casper/initrd"
  "$ROOT_DIR/casper/vmlinuz"
  "$ROOT_DIR/EFI/boot"
  "$ROOT_DIR/EFI/boot/bootx64.efi"
  "$ROOT_DIR/dists"
  "$ROOT_DIR/install"
  "$ROOT_DIR/pool"
  "$ROOT_DIR/boot.catalog"
  "$ROOT_DIR/md5sum.txt"
  "$ROOT_DIR/nocloud/user-data"
  "$ROOT_DIR/nocloud/meta-data"
  "$ROOT_DIR/manifold_setup.yml"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required installer input: $path" >&2
    echo "Extract the base Ubuntu Server ISO into this workspace first." >&2
    exit 1
  fi
done

if ! command -v xorriso >/dev/null 2>&1; then
  echo "xorriso is required to build the ISO." >&2
  echo "On macOS: brew install xorriso" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Apply tracked overlay files onto the local extracted ISO tree before packing.
if [[ -d "$ROOT_DIR/overlay" ]]; then
  cp -R "$ROOT_DIR/overlay/." "$ROOT_DIR/"
fi

xorriso -as mkisofs \
  -r -V "$VOLUME_ID" \
  -o "$OUT_ISO" \
  -J -joliet-long -l -iso-level 3 \
  -graft-points \
  -b boot/grub/i386-pc/eltorito.img \
  -c boot.catalog \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e EFI/boot/bootx64.efi \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  ".disk=$ROOT_DIR/.disk" \
  "boot=$ROOT_DIR/boot" \
  "casper=$ROOT_DIR/casper" \
  "dists=$ROOT_DIR/dists" \
  "EFI=$ROOT_DIR/EFI" \
  "install=$ROOT_DIR/install" \
  "pool=$ROOT_DIR/pool" \
  "boot.catalog=$ROOT_DIR/boot.catalog" \
  "md5sum.txt=$ROOT_DIR/md5sum.txt" \
  "manifold_setup.yml=$ROOT_DIR/manifold_setup.yml" \
  "nocloud=$ROOT_DIR/nocloud"

echo "Built $OUT_ISO"
