---
name: phitrine-bootstrap-context
description: Use on new or existing phitrine machines when working with agent setup, bootstrapping Claude/Codex from the environments repo, homelab tasks, second-brain tasks, or repo/config work that should load shared context from ~/.llms. This is the general shared bootstrap/context skill for Claude, Codex, and compatible agents.
---

# Phitrine Bootstrap Context

Treat this as the default shared context loader for phitrine environments.

Use shared repo-backed guidance from `~/.llms/` as the canonical source for rules and reusable workflows. Keep tool-specific working memory, auth, session state, and caches in each tool's own config directory.

## Canonical Sources

- Shared rules: `~/.llms/rules/`
- Shared skills: `~/.llms/skills/`
- Shared agent coordination notes: `~/.llms/agents/`
- Environments repo: `~/repo/environments/`

Do not duplicate shared rules into tool-local files unless the tool requires a tiny bootstrap pointer.

## Always Load The Right Rules

Read these depending on task scope:

1. `~/.llms/rules/style.md`
   - Load for any code, config, shell, automation, repo-maintenance, or bootstrap task.
2. `~/.llms/rules/homelab.md`
   - Load for Docker, networking, services, domains, Caddy, ports, infra, or deployment work.
3. `~/.llms/rules/secondbrain.md`
   - Load when the task references second brain, Obsidian, notes, projects, tasks, or vault content.
4. `~/.llms/rules/cpp.md`
   - Load for C++ implementation, parsing, stream-reading, engine, or low-level systems code.

If multiple apply, load all relevant rule files.

## Bootstrap Goals

On a new machine, prefer this setup model:

- `~/.claude/` keeps Claude-local state, but repo-backed config files point into `~/repo/environments/.claude/`
- `~/.llms/` points at `~/repo/environments/.llms`
- `~/.codex/` keeps Codex-local state, but shared skills from `~/.llms/skills/` are linked into `~/.codex/skills/`

This keeps the environments repo as shared source of truth while preserving per-tool memory and credentials locally.

## Working Conventions

- Before editing `~/repo/environments/`, run `git -C ~/repo/environments pull`
- After changing files in `~/repo/environments/`, commit and push promptly
- Never commit secrets, API keys, tokens, or credentials
- Prefer simple shell-based bootstrap flows
- Use `set -euo pipefail` in shell scripts

## Tool Split

- Claude-specific behavior belongs in `~/repo/environments/.claude/`
- Cross-tool behavior belongs in `~/repo/environments/.llms/`
- Codex local permissions/state remain in `~/.codex/`
- OpenClaw/OpenCode/Gemini should consume shared context via small bootstrap glue, not by copying shared rules everywhere

## When Extending The System

When adding support for another agent/tool:

1. Point the tool at `~/.llms/` for shared context.
2. Keep only minimal tool-native bootstrap instructions locally.
3. Prefer one shared bootstrap/context skill over many duplicated tool-specific copies.
4. Reuse existing shared rules before adding new ones.
