# Environments

Shared environment repository for two related purposes:

1. **Shared agent intelligence** via `.llms/`
2. **Unix dev setup** for machines where Jonathan wants shared shell/tooling defaults

This repo is intentionally designed for **opt-in adoption**.

It should not assume full ownership of a machine's existing Claude or other agent setup unless explicitly requested.

## Layout

- `.llms/` — shared cross-tool rules, skills, and agent coordination
- `.claude/` — Claude bootstrap guidance and Claude-specific shared assets
- `machines/` — machine-specific paths and environment metadata
- `dotfiles/` — shared Unix shell/dev config such as zsh, tmux, ssh
- `scripts/powershell/` — shared PowerShell scripts and profile startup snippets
- `install.sh` — Unix/dev setup helper that links shared `.llms/` and shell config without replacing full Claude config

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
