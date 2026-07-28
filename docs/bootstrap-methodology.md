# Bootstrap Methodology

## Goals

- Keep `.llms/` as the canonical shared intelligence layer
- Keep Claude/Codex/OpenClaw local state in their own native config folders
- Support **opt-in** adoption on machines with existing agent setups
- Avoid replacing a full Claude environment unless explicitly requested

## Core Model

### Shared layer

`~/repo/environments/.llms/`

Contains:

- `rules/`
- `skills/`
- `agents/`

This is the reusable cross-tool intelligence layer.

### Tool-specific bootstrap layer

`~/repo/environments/.claude/CLAUDE.md`

This is a lightweight bootstrap document for Claude, not a mandate to own all of `~/.claude/`.

### Machine metadata layer

`~/repo/environments/machines/*.env`

Use this for machine-specific paths and environment details.

### Local runtime envs

`~/repo/environments/envs/*/`

Use these folders for machine-local runtime state that should stay out of git, such as Telegram bot tokens, chat IDs, or other service-specific secrets.

Keep the secret file itself untracked and provide a checked-in `*.example` file next to it.

### User timers and cron

When a reminder is just a fixed message on a schedule, prefer a direct sender script plus systemd user timers (or cron if that is a better fit on the target machine).

Keep the schedule and the local secret env file together under the matching `envs/<service>/` folder so future agents can find both quickly.

## Adoption Patterns

### 1. Minimal opt-in

- link `~/.llms` to repo `.llms`
- manually point Claude at repo `.claude/CLAUDE.md`
- leave the rest of `~/.claude` untouched

### 2. Mixed setup

- use repo `.llms`
- keep a custom local Claude setup
- reference the repo bootstrap file from the local Claude setup

### 3. Fully managed setup

Only use when explicitly desired.

- symlink more tool-specific config from the repo
- accept stronger repo ownership of the tool environment

## Install Script Policy

`install.sh` should:

- support the repository's CachyOS/Arch, Debian/Ubuntu, and macOS machines
- set up Unix/dev defaults when wanted
- link shared `.llms`
- link shared skills into Codex without replacing Codex-local state
- avoid taking over full Claude configuration by default

`scripts/reinit_env.sh` follows the same policy. Pass `--manage-claude` only
when the machine should use the repo-managed Claude files.

## Component Bootstrap Commands

Focused configuration installers live in `scripts/bootstrap/` and use the
`env_bootstrap_<component>` naming convention. The managed Zsh configuration
adds that directory to `PATH`, so typing `env_bootstrap_` and pressing Tab
lists the available component bootstrap commands.

For example:

```bash
env_bootstrap_alacritty
env_bootstrap_cachyos_packages
```

Component bootstrap commands should be safe to rerun. When adopting an
existing unmanaged config, preserve it as a timestamped backup before linking
the repo-managed file.

The canonical CachyOS package list lives in `packages/cachyos.txt`. Both the
full environment installer and `env_bootstrap_cachyos_packages` consume this
manifest, so package additions only need to be maintained in one place.

## Why

This avoids breaking machines with more complicated Claude setups while still giving a single shared source of truth for reusable intelligence.
