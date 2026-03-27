# Code Style Rules

- Keep it simple. No over-engineering.
- Prefer shell scripts (bash) for automation and system tasks.
- Use `set -euo pipefail` in all shell scripts.
- Prefer `ln -sf` for symlinks (force overwrite).
- When writing configs (YAML, TOML, etc.), include comments explaining non-obvious values.
- Never commit secrets, API keys, tokens, or credentials to the environments repo. Keep auth in local-only files (e.g., `.env`, `settings.local.json`, `~/.claude/.credentials.json`). Use `.gitignore` to enforce this.

## Environments Repo Sync
- At the start of a session, `git pull` in `~/repo/environments/` to get the latest config.
- After any change to environments repo files, commit and `git push` immediately.
- Keep the repo up-to-date — other machines and tools depend on it.
