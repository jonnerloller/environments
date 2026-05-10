# Telegram reminder env

This folder holds the local-only pieces for Jonathan's Telegram reminders.

## Files

- `telegram.env.example` — template with the required Bot API variables
- `telegram.env` — local secret file (ignored by git)
- `systemd/` — user timer/service units for exercise + daily journal reminders

## Setup

1. Copy the example file:
   - `cp telegram.env.example telegram.env`
2. Fill in the bot token and chat id.
3. Run `./install.sh` in this folder to symlink and enable the user timers.

The reminders are fixed text and do not call any model.
