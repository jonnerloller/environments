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

## Time handling

Treat reminder schedules as Pacific time unless a file or user instruction says otherwise.
