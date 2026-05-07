#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

UBUNTU_VERSION="${UBUNTU_VERSION:-22.04.5}"
UBUNTU_ISO_NAME="${UBUNTU_ISO_NAME:-ubuntu-${UBUNTU_VERSION}-live-server-amd64.iso}"
UBUNTU_BASE_URL="${UBUNTU_BASE_URL:-https://releases.ubuntu.com/${UBUNTU_VERSION}}"
CACHE_DIR="${CACHE_DIR:-$ROOT_DIR/build/base-installer}"
ISO_PATH="$CACHE_DIR/$UBUNTU_ISO_NAME"
SHA256SUMS_PATH="$CACHE_DIR/SHA256SUMS"
ISO_SHA256_PATH="$CACHE_DIR/$UBUNTU_ISO_NAME.sha256"

required_tools=(curl xorriso)

for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool is required." >&2
    if [[ "$tool" == "xorriso" ]]; then
      echo "On macOS: brew install xorriso" >&2
    fi
    exit 1
  fi
done

if ! command -v shasum >/dev/null 2>&1 && ! command -v sha256sum >/dev/null 2>&1; then
  echo "shasum or sha256sum is required." >&2
  exit 1
fi

base_payload_paths=(
  "$ROOT_DIR/.disk"
  "$ROOT_DIR/boot"
  "$ROOT_DIR/casper"
  "$ROOT_DIR/dists"
  "$ROOT_DIR/EFI"
  "$ROOT_DIR/install"
  "$ROOT_DIR/pool"
  "$ROOT_DIR/boot.catalog"
  "$ROOT_DIR/md5sum.txt"
)

force_extract=0
if [[ "${1:-}" == "--force" ]]; then
  force_extract=1
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--force]" >&2
  exit 1
fi

payload_exists=0
for path in "${base_payload_paths[@]}"; do
  if [[ -e "$path" ]]; then
    payload_exists=1
    break
  fi
done

if [[ "$payload_exists" -eq 1 && "$force_extract" -ne 1 ]]; then
  echo "Base installer payload already exists in this workspace." >&2
  echo "Run $0 --force to extract the pinned Ubuntu ISO over it." >&2
  exit 1
fi

mkdir -p "$CACHE_DIR"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "Downloading $UBUNTU_ISO_NAME"
  curl -L --fail --continue-at - \
    -o "$ISO_PATH" \
    "$UBUNTU_BASE_URL/$UBUNTU_ISO_NAME"
else
  echo "Using cached $ISO_PATH"
fi

echo "Downloading SHA256SUMS"
curl -L --fail \
  -o "$SHA256SUMS_PATH" \
  "$UBUNTU_BASE_URL/SHA256SUMS"

awk -v iso="$UBUNTU_ISO_NAME" '$2 == iso || $2 == "*" iso { print }' \
  "$SHA256SUMS_PATH" > "$ISO_SHA256_PATH"

if [[ ! -s "$ISO_SHA256_PATH" ]]; then
  echo "Could not find checksum for $UBUNTU_ISO_NAME in SHA256SUMS." >&2
  exit 1
fi

echo "Verifying $UBUNTU_ISO_NAME"
if command -v sha256sum >/dev/null 2>&1; then
  (cd "$CACHE_DIR" && sha256sum -c "$ISO_SHA256_PATH")
else
  (cd "$CACHE_DIR" && shasum -a 256 -c "$ISO_SHA256_PATH")
fi

echo "Extracting base installer payload into $ROOT_DIR"
xorriso -osirrox on \
  -indev "$ISO_PATH" \
  -extract / "$ROOT_DIR"

chmod -R u+w "${base_payload_paths[@]}" 2>/dev/null || true

echo "Base installer payload is ready."
