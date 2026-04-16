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
- machine metadata: `~/repo/environments/machines/`

## Loading Guidance

`task-discipline.md` is always active — load it at the start of every session regardless of task type.

When relevant to the task, also load the appropriate domain rules from `.llms/rules/`:

- `style.md` for code, config, automation, repo maintenance, or shell work
- `homelab.md` for services, Docker, networking, domains, ports, infra, or deployment work
- `secondbrain.md` for Obsidian, projects, notes, or second-brain tasks
- `cpp.md` for C++ parsing, streams, engine, or low-level systems work

Prefer shared `.llms` rules over stale duplicated local copies.

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
