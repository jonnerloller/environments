#!/usr/bin/env bash
# Sync the environments repo and re-apply shared symlinks.
#
# Options:
#   --once            Skip if already run by this parent process.
#   --manage-claude   Link the repo-managed Claude files into ~/.claude.
set -euo pipefail

RUN_ONCE=false
MANAGE_CLAUDE=false

for arg in "$@"; do
  case "$arg" in
    --once)
      RUN_ONCE=true
      ;;
    --manage-claude)
      MANAGE_CLAUDE=true
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--once] [--manage-claude]" >&2
      exit 2
      ;;
  esac
done

if [[ "$RUN_ONCE" == true ]]; then
  LOCK="/tmp/reinit_env_done_${PPID}"
  [[ -f "$LOCK" ]] && exit 0
  touch "$LOCK"
fi

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

# Pull latest
git -C "$REPO_DIR" pull --ff-only --quiet

# Dotfiles
ln -sf "$REPO_DIR/dotfiles/zsh/.zshrc"   "$HOME/.zshrc"
ln -sf "$REPO_DIR/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.ssh"
ln -sf "$REPO_DIR/dotfiles/ssh/config" "$HOME/.ssh/config"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

# Claude Code is opt-in because these links replace existing configuration.
if [[ "$MANAGE_CLAUDE" == true ]]; then
  mkdir -p "$HOME/.claude"
  ln -sf "$REPO_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
  ln -sf "$REPO_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
  ln -sfn "$REPO_DIR/.claude/commands" "$HOME/.claude/commands"
fi

# Tool-agnostic LLM rules/skills
ln -sfn "$REPO_DIR/.llms" "$HOME/.llms"

# Codex skills
mkdir -p "$HOME/.codex/skills"
for skill_dir in "$REPO_DIR/.llms/skills"/*; do
  [ -d "$skill_dir" ] || continue
  ln -sfn "$skill_dir" "$HOME/.codex/skills/$(basename "$skill_dir")"
done
