#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${HOME}/repo/environments"

echo "[1/6] Installing packages (zsh, tmux, mosh, autossh, git, curl)..."
sudo apt-get update
sudo apt-get install -y zsh tmux mosh autossh git curl

echo "[2/5] Installing Oh My Zsh (unattended)..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed"
fi

echo "[3/5] Installing zsh plugins..."
mkdir -p "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
fi

echo "[4/7] Linking dotfiles from repo..."
mkdir -p "$HOME/.ssh"
ln -sf "$REPO_DIR/dotfiles/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$REPO_DIR/dotfiles/ssh/config" "$HOME/.ssh/config"
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

echo "[5/7] Linking AI agent configs..."
# Claude Code — symlink individual config files (not the whole dir)
mkdir -p "$HOME/.claude"
ln -sf "$REPO_DIR/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$REPO_DIR/.claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$REPO_DIR/.claude/commands" "$HOME/.claude/commands"
# LLMs — tool-agnostic rules/skills (whole directory)
ln -sfn "$REPO_DIR/.llms" "$HOME/.llms"
# Codex — keep local state in ~/.codex, but discover shared skills from ~/.llms
mkdir -p "$HOME/.codex/skills"
for skill_dir in "$REPO_DIR/.llms/skills"/*; do
  [ -d "$skill_dir" ] || continue
  ln -sfn "$skill_dir" "$HOME/.codex/skills/$(basename "$skill_dir")"
done
# Ensure a stable general bootstrap/context skill is always present for shared repo-backed rules
ln -sfn "$REPO_DIR/.llms/skills/phitrine-bootstrap-context" "$HOME/.codex/skills/phitrine-bootstrap-context"

echo "[6/7] Making zsh your default shell..."
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" "$USER" || true
fi

echo "[7/7] Notes"
echo "For mosh on servers, allow UDP 60000-61000 (e.g., sudo ufw allow 60000:61000/udp)."
echo "Done. Restart terminal (or run: exec zsh)."
