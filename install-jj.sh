#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="${HOME}/.local/bin"
mkdir -p "$DEST_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

API_URL="https://api.github.com/repos/jj-vcs/jj/releases/latest"
ASSET_URL=$(curl -fsSL "$API_URL" | grep -Eo 'https://[^" ]*jj-v[0-9.]+-x86_64-unknown-linux-musl\.tar\.gz' | head -n1)

if [[ -z "$ASSET_URL" ]]; then
  echo "Could not find latest jj Linux x86_64 asset URL."
  exit 1
fi

echo "Downloading: $ASSET_URL"
curl -fL "$ASSET_URL" -o "$TMP_DIR/jj.tgz"
tar -xzf "$TMP_DIR/jj.tgz" -C "$TMP_DIR"

JJ_BIN=$(find "$TMP_DIR" -type f -name jj | head -n1)
if [[ -z "$JJ_BIN" ]]; then
  echo "jj binary not found in archive"
  exit 1
fi

install -m 755 "$JJ_BIN" "$DEST_DIR/jj"

echo "Installed jj to $DEST_DIR/jj"
"$DEST_DIR/jj" --version

echo "If needed, add ~/.local/bin to PATH in your shell config."
