#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/config.sh"

mkdir -p "$SITE_CONTENT_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Copy only publishable folders; exclude Private + Templates + Inbox by default
rsync -a --delete \
  --include='*/' \
  --include='*.md' \
  --exclude='Private/***' \
  --exclude='Templates/***' \
  --exclude='Inbox/***' \
  "$VAULT_PUBLISH_DIR/" "$TMP_DIR/content/"

if [[ "$ONLY_PUBLISHED" == "true" ]]; then
  while IFS= read -r -d '' f; do
    if ! grep -q '^status:\s*published\s*$' "$f"; then
      rm -f "$f"
    fi
  done < <(find "$TMP_DIR/content" -type f -name '*.md' -print0)
fi

rsync -a --delete "$TMP_DIR/content/" "$SITE_CONTENT_DIR/"

echo "Synced Obsidian content to: $SITE_CONTENT_DIR"
