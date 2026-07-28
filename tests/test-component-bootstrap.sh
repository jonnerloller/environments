#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

TEST_HOME="$TEST_ROOT/home"
CONFIG_DIR="$TEST_HOME/.config/alacritty"
TARGET_CONFIG="$CONFIG_DIR/alacritty.toml"
SOURCE_CONFIG="$REPO_DIR/dotfiles/alacritty/alacritty.toml"

mkdir -p "$CONFIG_DIR"
printf '%s\n' "unmanaged config" >"$TARGET_CONFIG"

HOME="$TEST_HOME" "$REPO_DIR/scripts/bootstrap/env_bootstrap_alacritty" >/dev/null

[[ -L "$TARGET_CONFIG" ]]
[[ "$(readlink -f "$TARGET_CONFIG")" == "$(readlink -f "$SOURCE_CONFIG")" ]]
grep -Fx "unmanaged config" "$CONFIG_DIR"/alacritty.toml.backup.* >/dev/null
grep -Fx "opacity = 0.95" "$TARGET_CONFIG" >/dev/null

backup_count_before="$(find "$CONFIG_DIR" -maxdepth 1 \
  -name 'alacritty.toml.backup.*' -type f | wc -l)"
HOME="$TEST_HOME" "$REPO_DIR/scripts/bootstrap/env_bootstrap_alacritty" >/dev/null
backup_count_after="$(find "$CONFIG_DIR" -maxdepth 1 \
  -name 'alacritty.toml.backup.*' -type f | wc -l)"
[[ "$backup_count_before" -eq 1 ]]
[[ "$backup_count_after" -eq "$backup_count_before" ]]

REPO_DIR="$REPO_DIR" zsh -fc \
  'path=("$REPO_DIR/scripts/bootstrap" $path); (( $+commands[env_bootstrap_alacritty] ))'

echo "Component bootstrap tests passed."
