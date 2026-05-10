#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TELEGRAM_ENV_FILE="${TELEGRAM_ENV_FILE:-$ROOT/envs/telegram/telegram.env}"
set -a
source "$TELEGRAM_ENV_FILE"
set +a
"$ROOT/scripts/telegram/send_telegram_message.sh" --message "Reminder: do a bit of exercise. Meditation, sit-ups, push-ups, or a walk — just do something small."
