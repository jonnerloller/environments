# Claude Bootstrap For Environments Repo

This file is an **opt-in bootstrap entrypoint** for Claude on machines that use Jonathan's shared environments repo.

Do not assume this repo owns the machine's full Claude setup.
Do not assume `~/.claude/` should be replaced wholesale.
Prefer compatibility with existing local Claude configuration.

## Purpose

Use this file to teach Claude where shared rules, skills, and environment metadata live.

Shared source of truth:

- rules: `~/repo/environments/.llms/rules/`
- skills: `~/repo/environments/.llms/skills/`
- shared agent conventions: `~/repo/environments/.llms/agents/`
- **references** (infrastructure facts): `~/repo/environments/.llms/references/`
- machine metadata: `~/repo/environments/machines/`

## Loading Guidance

`task-discipline.md` is always active — load it at the start of every session regardless of task type.

When relevant to the task, also load the appropriate domain rules from `.llms/rules/`:

- `style.md` for code, config, automation, repo maintenance, or shell work
- `homelab.md` for services, Docker, networking, domains, ports, infra, or deployment work
- `secondbrain.md` for Obsidian, projects, notes, or second-brain tasks
- `cpp.md` for C++ parsing, streams, engine, or low-level systems work
- `reminders.md` for Telegram messaging, notification scripts, or scheduled reminders

When the task touches a specific service or integration, consult the matching file in `.llms/references/` (see its `README.md` for the index). Examples: anything about secrets / `bw` → `vaultwarden.md`; sending notifications → `apprise.md`; Google APIs → `gog.md`; openclaw config rotation → `openclaw_secrets.md`.

Prefer shared `.llms` files over stale duplicated local copies.

## Memory vs References — what goes where

Three places for durable knowledge on this machine:

1. **Claude Code private memory** (`~/.claude/projects/.../memory/`) — preferences, feedback, things specifically about *how Claude should behave* with this user. Not shared with other agents.
2. **Shared references** (`~/repo/environments/.llms/references/`) — infrastructure facts other agents (openclaw, future Claude sessions, future tooling) would also benefit from. URLs, paths, config layouts, restore procedures, integration patterns.
3. **Shared rules** (`~/repo/environments/.llms/rules/`) — behavior rules ("do X this way", "don't do Y"). Conventions, not facts.

### When to add a new reference

When you learn something during a session that future-you (or another agent) would have to re-discover, write a new file in `~/repo/environments/.llms/references/`. Use this checklist:

- Is it a **fact about state**, not a rule about behavior? → reference (else rule)
- Would **another agent** benefit from seeing it (openclaw, a scheduled cron job, a future Claude session)? → reference (else private memory)
- Will it be **stale in a week**? → don't save (ephemeral; goes in the task plan, not durable storage)

Use the existing files in `references/` as templates. Keep the `type: reference` frontmatter. Update `references/README.md`'s index with a one-line entry.

When a reference becomes stale (service decommissioned, pattern abandoned), **delete or rewrite the file** — don't leave drift. The reference directory is authoritative.

## Path Discipline

Machine-specific paths belong in `~/repo/environments/machines/*.env`.

When path-sensitive behavior depends on the machine, consult those machine env files instead of assuming one hardcoded path.

## Local State Boundary

Keep local-only Claude state outside this repo, including:

- auth
- credentials
- history
- caches
- local settings overrides
- machine-specific preferences not meant to be shared

## Adoption Model

This setup is intentionally opt-in.

A machine may:

- use this file directly
- reference this file from a richer local Claude setup
- selectively copy only the relevant bootstrap guidance

Do not force full replacement of an existing Claude environment unless explicitly requested.
