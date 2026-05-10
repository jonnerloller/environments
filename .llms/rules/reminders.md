# Reminder Rules

## Fixed reminders

If a reminder is just a static message on a schedule, keep it model-free.

Use a direct sender script plus cron/systemd timers instead of an agent model when the job is simply:

- send a fixed Telegram message
- at a fixed time
- with no need to inspect files, messages, calendar, or recent context

## Telegram reminder layout

- Local secret env file: `envs/telegram/telegram.env`
- Example env file: `envs/telegram/telegram.env.example`
- Systemd user units: `envs/telegram/systemd/`
- Sender script: `scripts/telegram/send_telegram_message.sh`

## Sending a Telegram message (ad-hoc, from any agent)

If the user asks for a Telegram notification, completion ping, or other one-off message, use the same sender script the timers use. Do NOT invent a new bot or call the Bot API directly.

Standard invocation:

```bash
set -a
source "$HOME/repo/environments/envs/telegram/telegram.env"
set +a
"$HOME/repo/environments/scripts/telegram/send_telegram_message.sh" --message "your text here"
```

Notes:

- `TELEGRAM_CHAT_ID` is the user's personal chat id, not the bot's id. Do not change it without explicit instruction.
- If `telegram.env` is missing, the user has not yet set it up — point them at `envs/telegram/README.md` rather than guessing values.
- The script exits non-zero on Bot API errors. A 403 with `the bot can't send messages to the bot` means `TELEGRAM_CHAT_ID` is wrong (set to the bot itself).
- For repeated/scheduled sends, prefer adding a systemd user unit under `envs/telegram/systemd/` over invoking the script from a long-running agent.

## Time handling

Treat reminder schedules as Pacific time unless a file or user instruction says otherwise.
