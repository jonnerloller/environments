#!/usr/bin/env bash
set -euo pipefail

# Obsidian vault backup (clone -> copy -> commit -> push -> delete clone)
REPO_URL="git@github.com:jonnerloller/obsidian_backup.git"
VAULT_DIR="/home/phitrine/Obsidian/valhalla"
BRANCH="main"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

STAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

echo "[$STAMP] Starting Obsidian backup"

# Clone fresh repository
if ! git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"; then
  echo "[$STAMP] ERROR: git clone failed"
  exit 1
fi

# Sync vault contents into clone
# Exclude volatile/cache files but keep everything meaningful.
rsync -a --delete \
  --exclude='.git/' \
  --exclude='.obsidian/workspace*.json' \
  --exclude='.obsidian/workspaces.json' \
  --exclude='.obsidian/cache/' \
  --exclude='.obsidian/plugins/*/data.json' \
  --exclude='.trash/' \
  "$VAULT_DIR/" "$TMP_DIR/repo/"

cd "$TMP_DIR/repo"

# Commit only when there are changes (including untracked files)
if [[ -z "$(git status --porcelain)" ]]; then
  echo "[$STAMP] No changes to backup"
  exit 0
fi

git add -A
git -c user.name="obsidian-backup-bot" -c user.email="obsidian-backup-bot@local" \
  commit -m "Obsidian backup: $STAMP"
git push origin "$BRANCH"

echo "[$STAMP] Backup pushed successfully"
