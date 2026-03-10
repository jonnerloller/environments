#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/sync.sh"

cd "$REPO_DIR"

git add obsidian-blog/site/content
if git diff --cached --quiet; then
  echo "No content changes to publish."
  exit 0
fi

MSG="publish(obsidian-blog): $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git commit -m "$MSG"
git push

echo "Published: $MSG"
