# Environments

Shared environment repository for two related purposes:

1. **Shared agent intelligence** via `.llms/`
2. **Unix dev setup** for machines where Jonathan wants shared shell/tooling defaults

This repo is intentionally designed for **opt-in adoption**.

It should not assume full ownership of a machine's existing Claude or other agent setup unless explicitly requested.

## Layout

- `.llms/` — shared cross-tool rules, skills, and agent coordination
- `.claude/` — Claude bootstrap guidance and Claude-specific shared assets
- `envs/` — local-only runtime env files and user-service setup (never commit secrets)
- `machines/` — machine-specific paths and environment metadata
- `dotfiles/` — shared Unix shell/dev config such as zsh, tmux, ssh
- `scripts/` — shared automation helpers, including reminder senders, cron entrypoints, and setup scripts
- `scripts/automation/` — canonical script-first entrypoints for recurring automation
- `scripts/powershell/` — shared PowerShell scripts and profile startup snippets
- `install.sh` — Unix/dev setup helper that links shared `.llms/` and shell config without replacing full Claude config

## Telegram reminders

Static Telegram reminders live under `envs/telegram/`:

- `envs/telegram/telegram.env` — local-only Bot API credentials (copy from the example only if a legacy consumer still needs it)
- `envs/telegram/systemd/` — legacy user timer/service units for the reminder schedule
- `scripts/telegram/send_telegram_message.sh` — sender used by the reminders

The daily journal reminder now lives in user crontab and runs at 9:00 PM Pacific time.

## Shared Agent Model

### `.llms/` is the canonical shared layer

Use `.llms/` for:

- reusable rules
- reusable skills
- shared agent conventions
- cross-tool context that should work across Claude, Codex, OpenClaw, Gemini, and future tools

### Tool-local state stays local

Keep these outside the repo:

- auth tokens
- credentials
- session history
- caches
- working memory databases
- tool-specific local overrides

Examples:

- Claude local state remains in `~/.claude/`
- Codex local state remains in `~/.codex/`

## Claude Bootstrap Methodology

This repo does **not** require replacing a machine's full `~/.claude/` directory.

Instead, use `.claude/CLAUDE.md` here as an **opt-in bootstrap entrypoint**.

On any machine, you can:

1. manually point Claude at `~/repo/environments/.claude/CLAUDE.md`, or
2. copy/paste a small local bootstrap note into an existing Claude setup, or
3. selectively symlink only the Claude files you want

This keeps adoption flexible for machines that already have a more complex Claude setup.

## Paths And Machine Metadata

Machine-specific paths belong in `machines/*.env`.

Shared rules and skills should refer to machine metadata via those env files rather than hardcoding a single machine path when possible.

## Install Script Policy

`install.sh` is for:

- Unix/dev shell setup
- shared `.llms` linking
- optional developer ergonomics

`install.sh` should **not** fully take over Claude configuration by default.

## New Machine Bootstrap

Recommended baseline on a new Unix machine:

1. clone `~/repo/environments`
2. run `install.sh`
3. verify `~/.llms -> ~/repo/environments/.llms`
4. manually opt Claude into `~/repo/environments/.claude/CLAUDE.md` if desired
5. keep local tool state in native tool directories
