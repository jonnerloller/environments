#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

TEST_HOME="$TEST_ROOT/home"
CONFIG_DIR="$TEST_HOME/.config/alacritty"
TARGET_CONFIG="$CONFIG_DIR/alacritty.toml"
SOURCE_CONFIG="$REPO_DIR/dotfiles/alacritty/alacritty.toml"
COMMAND_LOG="$TEST_ROOT/package-command.log"

mkdir -p "$CONFIG_DIR" "$TEST_ROOT/bin"
printf '%s\n' "unmanaged config" >"$TARGET_CONFIG"

cat >"$TEST_ROOT/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >"$COMMAND_LOG"
EOF
chmod +x "$TEST_ROOT/bin/sudo"

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

PATH="$TEST_ROOT/bin:$PATH" COMMAND_LOG="$COMMAND_LOG" \
  "$REPO_DIR/scripts/bootstrap/env_bootstrap_cachyos_packages" >/dev/null
grep -Fx \
  "pacman -Syu --needed --noconfirm zsh tmux mosh autossh git curl alacritty github-cli openai-codex claude-code" \
  "$COMMAND_LOG" >/dev/null

REPO_DIR="$REPO_DIR" zsh -fc \
  'path=("$REPO_DIR/scripts/bootstrap" $path)
   (( $+commands[env_bootstrap_alacritty] ))
   (( $+commands[env_bootstrap_cachyos_packages] ))'

echo "Component bootstrap tests passed."
