#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/config.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning target repo into temp dir..."
git clone --branch "$TARGET_BRANCH" "$TARGET_REPO_SSH" "$TMP_DIR/repo"

DEST_CONTENT_DIR="$TMP_DIR/repo/$TARGET_CONTENT_DIR_REL"
"$SCRIPT_DIR/sync.sh" "$DEST_CONTENT_DIR"

cd "$TMP_DIR/repo"
git add "$TARGET_CONTENT_DIR_REL"
if git diff --cached --quiet; then
  echo "No content changes to publish."
  exit 0
fi

MSG="publish(obsidian): $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git commit -m "$MSG"
git push origin "$TARGET_BRANCH"

echo "Published to $TARGET_REPO_SSH ($TARGET_BRANCH): $MSG"
