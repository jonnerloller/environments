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

# Handy aliases
alias ll='ls -lah'
alias gs='git status -sb'
alias gl='git log --oneline --decorate --graph -20'
alias gcob='git checkout -b'
alias tma='tmux new -A -s main'

# Usage: mhost user@host
mhost() {
  mosh "$1" -- tmux new -A -s main
}
