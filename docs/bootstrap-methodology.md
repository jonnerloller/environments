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

- set up Unix/dev defaults when wanted
- link shared `.llms`
- avoid taking over full Claude configuration by default

## Why

This avoids breaking machines with more complicated Claude setups while still giving a single shared source of truth for reusable intelligence.
