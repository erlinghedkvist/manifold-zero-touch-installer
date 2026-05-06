#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <artifact> [artifact...]" >&2
  exit 1
fi

for artifact in "$@"; do
  if [[ ! -f "$artifact" ]]; then
    echo "Not a file: $artifact" >&2
    exit 1
  fi

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$artifact" | tee "$artifact.sha256"
  else
    shasum -a 256 "$artifact" | tee "$artifact.sha256"
  fi
done
