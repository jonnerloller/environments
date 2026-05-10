#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
UNIT_DIR="$SCRIPT_DIR/systemd"

mkdir -p "$SYSTEMD_USER_DIR"

for unit in "$UNIT_DIR"/*.service "$UNIT_DIR"/*.timer; do
  [[ -e "$unit" ]] || continue
  ln -sf "$unit" "$SYSTEMD_USER_DIR/$(basename "$unit")"
done

systemctl --user daemon-reload
systemctl --user enable --now telegram-exercise.timer telegram-journal.timer

echo "Installed Telegram reminders from $REPO_ROOT"
echo "If needed, copy $SCRIPT_DIR/telegram.env.example to $SCRIPT_DIR/telegram.env first."
