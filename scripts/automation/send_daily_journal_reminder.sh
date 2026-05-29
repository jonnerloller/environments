#!/usr/bin/env bash
set -euo pipefail

"$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/telegram/send_telegram_message.sh" --message "Reminder: it’s 9:00 PM PST, time to do your daily note. You can write in your 2nd brain or directly here. Prompts: what happened today, anything interesting, your current mental state, and something you’re grateful for."
