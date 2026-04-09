---
name: phitrine-shared-context
description: Use when working on phitrine's homelab, the environments repo, shared agent setup, or Codex/Claude configuration so shared rules and conventions come from ~/.llms instead of tool-local copies.
---

# Phitrine Shared Context

Use this skill when the task involves any of the following:

- `~/repo/environments/`
- `~/.llms/`
- homelab infrastructure, Docker services, ports, DNS, Caddy, or service URLs
- Codex, Claude, or multi-agent setup for this machine

## Canonical Sources

- Shared rules and reusable cross-tool guidance live in `~/.llms/`
- Codex-local state, auth, sessions, and working memory stay in `~/.codex/`
- If shared `.llms` guidance conflicts with stale local notes or duplicated instructions, `.llms` wins

## Rules To Load

- Read `~/.llms/rules/style.md` for any code, config, automation, or repo-maintenance task
- Read `~/.llms/rules/homelab.md` when the task touches homelab infrastructure, Docker, networking, domains, ports, or service deployment
- Read `~/.llms/rules/secondbrain.md` when the task references the Obsidian vault, project/task notes, or second-brain content

Prefer `phitrine-bootstrap-context` as the general shared bootstrap skill on new machines; use this skill as the narrower environments/homelab specialization.

## Working Conventions

- Before editing files in `~/repo/environments/`, run `git -C ~/repo/environments pull`
- After changing files in `~/repo/environments/`, commit and `git -C ~/repo/environments push` promptly
- Never commit secrets, API keys, tokens, or credentials to the repo
- Prefer simple solutions and shell scripts for automation work
- Use `set -euo pipefail` in shell scripts

## Multi-Agent And Multi-Tool Split

- Shared coordination rules belong in `~/.llms/`
- Tool-specific operational memory belongs in the local tool config
- For Codex, do not move sessions, memories, auth, or local permission rules out of `~/.codex/`
