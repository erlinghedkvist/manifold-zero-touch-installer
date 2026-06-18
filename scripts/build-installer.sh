#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-$(date +%Y.%m.%d)}"
VOLUME_ID="${VOLUME_ID:-MANIFOLD_ZT}"
UBUNTU_VERSION="${UBUNTU_VERSION:-22.04.5}"
UBUNTU_ISO_NAME="${UBUNTU_ISO_NAME:-ubuntu-${UBUNTU_VERSION}-live-server-amd64.iso}"
BASE_ISO="${BASE_ISO:-$ROOT_DIR/build/base-installer/$UBUNTU_ISO_NAME}"
OUT_DIR="$ROOT_DIR/dist"
OUT_ISO="$OUT_DIR/manifold-zero-touch-$VERSION.iso"

required_paths=(
  "$BASE_ISO"
  "$ROOT_DIR/overlay/boot/grub/grub.cfg"
  "$ROOT_DIR/nocloud/user-data"
  "$ROOT_DIR/nocloud/meta-data"
  "$ROOT_DIR/manifold_setup.yml"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required installer input: $path" >&2
    echo "Run ./scripts/prepare-base-installer.sh first." >&2
    exit 1
  fi
done

if ! command -v xorriso >/dev/null 2>&1; then
  echo "xorriso is required to build the ISO." >&2
  echo "On macOS: brew install xorriso" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

if [[ -e "$OUT_ISO" ]]; then
  echo "Output already exists: $OUT_ISO" >&2
  echo "Choose a different version or remove the existing output first." >&2
  exit 1
fi

# Start from the verified Ubuntu image and replay its boot configuration. This
# preserves the upstream hybrid MBR/GPT layout needed when the ISO is written
# directly to a USB drive.
xorriso \
  -indev "$BASE_ISO" \
  -outdev "$OUT_ISO" \
  -boot_image any replay \
  -volid "$VOLUME_ID" \
  -map "$ROOT_DIR/overlay/boot/grub/grub.cfg" /boot/grub/grub.cfg \
  -map "$ROOT_DIR/manifold_setup.yml" /manifold_setup.yml \
  -map "$ROOT_DIR/nocloud/user-data" /nocloud/user-data \
  -map "$ROOT_DIR/nocloud/meta-data" /nocloud/meta-data \
  -commit \
  -end

system_area="$(
  xorriso -indev "$OUT_ISO" -report_system_area plain 2>&1
)"
if [[ "$system_area" != *"System area summary:"*"MBR"*"GPT"* ]]; then
  echo "Built image is missing the expected hybrid MBR/GPT partition table." >&2
  exit 1
fi

echo "Built $OUT_ISO"
