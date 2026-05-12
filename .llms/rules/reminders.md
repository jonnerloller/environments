# Reminder Rules

## Reminder default

Use the model-backed reminder path by default.

For reminders, prefer the agent/model form unless there is a strong reason not to. That covers:

- scheduled reminder wording
- context-aware nudges
- anything that should adapt to files, messages, calendar, or recent context

For non-reminder cron-backed automation, still prefer a thin script entrypoint first:

- cron/job text should say "run this script"
- the script should do the work directly
- only use a model when the job actually needs reasoning or dynamic wording

## Notification stack

- **Apprise** (https://apprise.services.phitrine.com) is the central notification gateway. All Telegram (and future Discord, email, etc.) sends route through it.
- **Bitwarden** is the source of truth for credentials. Item `telegram_clawphi` (Homelab org) holds the Telegram bot token and chat id as custom fields `token` / `chat_id`. On phi-0, `bw` is preconfigured via `~/.config/bw/agent.env`.
- **Apprise config refresh:** `scripts/apprise/refresh_configs.sh` pulls credentials from Bitwarden and updates Apprise's stored notification URLs. Run after rotating any source secret.
- **`envs/telegram/telegram.env`** is a deprecated cache from the previous direct-Bot-API setup. The new sender script no longer reads it. `envs/telegram/refresh_env.sh` still exists for parity but is only useful if some legacy consumer needs the env file.

## Telegram reminder layout

- Sender script: `scripts/telegram/send_telegram_message.sh` (POSTs to Apprise — no bot token in env required).
- Systemd user units: `envs/telegram/systemd/`
- See `envs/telegram/README.md` for full Apprise + `bw` usage examples.

## Sending a Telegram message (ad-hoc, from any agent)

If the user asks for a Telegram notification, completion ping, or other one-off message, use the sender script. Do NOT invent a new bot or call the Bot API directly.

Standard invocation (no env preamble needed):

```bash
"$HOME/repo/environments/scripts/telegram/send_telegram_message.sh" --message "your text here"
```

Notes:

- The script POSTs to `https://apprise.services.phitrine.com/notify/telegram`. Caddy serves a publicly trusted Let's Encrypt cert (DNS-01), so any modern HTTP client trusts it out of the box — no `--cacert` flags or trust-store gymnastics needed.
- `chat_id` is the user's personal chat id, configured once in Bitwarden. Do not change it without explicit instruction.
- The script exits non-zero on transport or Apprise errors.
- For repeated/scheduled sends, prefer adding a systemd user unit under `envs/telegram/systemd/` over invoking the script from a long-running agent.

## Time handling

Treat reminder schedules as Pacific time unless a file or user instruction says otherwise.
