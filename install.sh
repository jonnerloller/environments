#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

install_packages() {
  local os_release_file="${OS_RELEASE_FILE:-/etc/os-release}"
  local distro_id=""
  local distro_like=""

  if [[ "$(uname -s)" == "Darwin" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
      echo "Homebrew is required on macOS: https://brew.sh" >&2
      exit 1
    fi
    brew install zsh tmux mosh autossh git curl
    return
  fi

  if [[ -r "$os_release_file" ]]; then
    # shellcheck disable=SC1090
    source "$os_release_file"
    distro_id="${ID:-}"
    distro_like="${ID_LIKE:-}"
  fi

  case "$distro_id" in
    cachyos)
      "$REPO_DIR/scripts/bootstrap/env_bootstrap_cachyos_packages"
      ;;
    arch)
      sudo pacman -Syu --needed --noconfirm zsh tmux mosh autossh git curl
      ;;
    *)
      case " $distro_id $distro_like " in
        *" arch "*)
          sudo pacman -Syu --needed --noconfirm zsh tmux mosh autossh git curl
          ;;
        *" debian "*|*" ubuntu "*)
          sudo apt-get update
          sudo apt-get install -y zsh tmux mosh autossh git curl
          ;;
        *)
          echo "Unsupported Linux distribution: ${distro_id:-unknown}" >&2
          echo "Install zsh, tmux, mosh, autossh, git, and curl, then rerun this script." >&2
          exit 1
          ;;
      esac
      ;;
  esac
}

echo "[1/7] Installing platform packages..."
install_packages

echo "[2/7] Installing Oh My Zsh (unattended)..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed"
fi

echo "[3/7] Installing zsh plugins..."
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

echo "[5/7] Linking shared AI intelligence..."
# Shared LLM intelligence — cross-tool rules/skills/agents live here
ln -sfn "$REPO_DIR/.llms" "$HOME/.llms"

mkdir -p "$HOME/.codex/skills"
for skill_dir in "$REPO_DIR/.llms/skills"/*; do
  [[ -d "$skill_dir" ]] || continue
  ln -sfn "$skill_dir" "$HOME/.codex/skills/$(basename "$skill_dir")"
done

echo "[6/7] Claude bootstrap is opt-in..."
echo "If desired, manually point Claude at: $REPO_DIR/.claude/CLAUDE.md"
echo "This install script does not replace or take over ~/.claude by default."

echo "[7/7] Making zsh your default shell..."
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" "$USER" || true
fi

echo "For mosh on servers, allow UDP 60000-61000 (e.g., sudo ufw allow 60000:61000/udp)."
echo "Done. Restart terminal (or run: exec zsh)."
