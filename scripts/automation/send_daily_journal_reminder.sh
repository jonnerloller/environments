#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TELEGRAM_ENV_FILE="${TELEGRAM_ENV_FILE:-$ROOT/envs/telegram/telegram.env}"
set -a
source "$TELEGRAM_ENV_FILE"
set +a
"$ROOT/scripts/telegram/send_telegram_message.sh" --message "Reminder: it’s 9:00 PM PST, time to do your daily note. You can write in your 2nd brain or directly here. Prompts: what happened today, anything interesting, your current mental state, and something you’re grateful for."
