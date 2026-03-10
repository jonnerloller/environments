#!/usr/bin/env bash

# Edit these paths if your vault/repo locations change.
VAULT_PUBLISH_DIR="${VAULT_PUBLISH_DIR:-$HOME/Obsidian/valhalla/Publishing}"

# Target publish repo (Quartz site)
TARGET_REPO_SSH="${TARGET_REPO_SSH:-git@github.com:jonnerloller/braindump.git}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"
TARGET_CONTENT_DIR_REL="${TARGET_CONTENT_DIR_REL:-content}"

# Optional: only copy markdown files marked status: published
ONLY_PUBLISHED="${ONLY_PUBLISHED:-true}"
