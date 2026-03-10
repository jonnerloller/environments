#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${HOME}/repo/environments"

echo "[1/5] Installing packages (zsh, tmux, git, curl)..."
sudo apt-get update
sudo apt-get install -y zsh tmux git curl

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

echo "[4/5] Linking dotfiles from repo..."
ln -sf "$REPO_DIR/dotfiles/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"

echo "[5/5] Making zsh your default shell..."
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" "$USER" || true
fi

echo "Done. Restart terminal (or run: exec zsh)."
