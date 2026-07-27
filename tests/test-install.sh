#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/bin"

cat >"$TEST_ROOT/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$COMMAND_LOG"
EOF

cat >"$TEST_ROOT/bin/chsh" <<'EOF'
#!/usr/bin/env bash
printf 'chsh %s\n' "$*" >>"$COMMAND_LOG"
EOF

chmod +x "$TEST_ROOT/bin/sudo" "$TEST_ROOT/bin/chsh"

run_install_test() {
  local distro_name="$1"
  local os_release_content="$2"
  local expected_package_command="$3"
  local test_home="$TEST_ROOT/home-$distro_name"
  local os_release_file="$TEST_ROOT/os-release-$distro_name"
  local command_log="$TEST_ROOT/commands-$distro_name.log"

  mkdir -p \
    "$test_home/.oh-my-zsh/custom/plugins/zsh-autosuggestions" \
    "$test_home/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  printf '%s\n' "$os_release_content" >"$os_release_file"
  : >"$command_log"

  HOME="$test_home" \
    USER="test-user" \
    PATH="$TEST_ROOT/bin:$PATH" \
    COMMAND_LOG="$command_log" \
    OS_RELEASE_FILE="$os_release_file" \
    "$REPO_DIR/install.sh" >/dev/null

  grep -Fx "$expected_package_command" "$command_log" >/dev/null
  [[ "$(readlink "$test_home/.llms")" == "$REPO_DIR/.llms" ]]
  [[ "$(readlink "$test_home/.zshrc")" == "$REPO_DIR/dotfiles/zsh/.zshrc" ]]
  [[ -L "$test_home/.codex/skills/phitrine-bootstrap-context" ]]
  [[ ! -e "$test_home/.claude/CLAUDE.md" ]]
}

run_install_test \
  "cachyos" \
  $'ID=cachyos\nID_LIKE=arch' \
  "pacman -Syu --needed --noconfirm zsh tmux mosh autossh git curl"

run_install_test \
  "ubuntu" \
  $'ID=ubuntu\nID_LIKE=debian' \
  "apt-get update"

grep -Fx "apt-get install -y zsh tmux mosh autossh git curl" \
  "$TEST_ROOT/commands-ubuntu.log" >/dev/null

echo "Installer tests passed."
