#!/usr/bin/env bash

# Edit these paths if your vault/repo locations change.
VAULT_PUBLISH_DIR="${VAULT_PUBLISH_DIR:-$HOME/Obsidian/valhalla/Publishing}"
SITE_CONTENT_DIR="${SITE_CONTENT_DIR:-$HOME/repo/environments/obsidian-blog/site/content}"

# Optional: only copy markdown files marked status: published
ONLY_PUBLISHED="${ONLY_PUBLISHED:-true}"
