# ~/.zshrc managed by ~/repo/environments/dotfiles/zsh/.zshrc

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  history
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"

# --- History: long, shared, and useful ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# Better completion behavior
zstyle ':completion:*' menu select
zmodload zsh/complist

# Quality of life
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# --- Machine-specific paths ---
_environments_repo="${${(%):-%N}:A:h:h:h}"
_machine_env="$_environments_repo/machines/$(hostname -s).env"
[[ -f "$_machine_env" ]] && set -a && source "$_machine_env" && set +a
unset _machine_env

# --- Dashlane CLI device key (local-only file, not committed) ---
[[ -f "$HOME/.config/dcli/device.env" ]] && source "$HOME/.config/dcli/device.env"

# --- gog (Google CLI) keyring password (local-only file, not committed) ---
[[ -f "$HOME/.config/gogcli/keyring.env" ]] && source "$HOME/.config/gogcli/keyring.env"

# Handy aliases
alias ll='ls -lah'
alias gs='git status -sb'
alias gl='git log --oneline --decorate --graph -20'
alias gcob='git checkout -b'
alias tma='tmux new -A -s main'
alias reinit_env="bash $_environments_repo/scripts/reinit_env.sh"
unset _environments_repo

# Usage: mhost user@host
mhost() {
  mosh "$1" -- tmux new -A -s main
}
