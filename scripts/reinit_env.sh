#!/usr/bin/env bash
# Sync environments repo and re-apply symlinks for the current machine.
# Safe to run anytime — only creates/updates symlinks, never deletes data.
set -euo pipefail

REPO_DIR="${HOME}/repo/environments"

# Pull latest
git -C "$REPO_DIR" pull --ff-only --quiet

# Dotfiles
ln -sf "$REPO_DIR/dotfiles/zsh/.zshrc"   "$HOME/.zshrc"
ln -sf "$REPO_DIR/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$HOME/.ssh"
ln -sf "$REPO_DIR/dotfiles/ssh/config" "$HOME/.ssh/config"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

# Claude Code
mkdir -p "$HOME/.claude"
ln -sf "$REPO_DIR/.claude/CLAUDE.md"      "$HOME/.claude/CLAUDE.md"
ln -sf "$REPO_DIR/.claude/settings.json"  "$HOME/.claude/settings.json"
ln -sfn "$REPO_DIR/.claude/commands"      "$HOME/.claude/commands"

# Tool-agnostic LLM rules/skills
ln -sfn "$REPO_DIR/.llms" "$HOME/.llms"

# Codex skills
mkdir -p "$HOME/.codex/skills"
for skill_dir in "$REPO_DIR/.llms/skills"/*; do
  [ -d "$skill_dir" ] || continue
  ln -sfn "$skill_dir" "$HOME/.codex/skills/$(basename "$skill_dir")"
done
