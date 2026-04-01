# Global Claude Instructions

## Environment
- Server: phi-0 (homelab)
- Docker works without `sudo` (user is in the docker group)
- All Docker services live in `~/docker/<service-name>/`, each with their own `docker-compose.yml`

## Homelab Conventions
- Reverse proxy: Caddy with `tls internal` (self-signed certs)
- Service domains: `<service>.services.phitrine.com`
- Host domains: `<host>.home.phitrine.com`
- DNS: 10.0.0.1
- Running services: Homepage (:3000), Immich (:2283), Plex, TrueNAS, Proxmox, AirTrail (:3001)

## Git
- Always use SSH URLs for git remotes, never HTTPS. If a repo uses HTTPS, switch it to SSH (`git remote set-url origin git@github.com:<owner>/<repo>.git`).
- Per-repo exceptions will be noted in that repo's CLAUDE.md.

## Code Style
- Keep it simple. No over-engineering.
- Prefer shell scripts for automation tasks.

## Environments Repo
- Dotfiles, AI agent configs, and skills live in `~/repo/environments/`
- Claude config is symlinked from there into `~/.claude/`
- Tool-agnostic rules/skills live in `~/repo/environments/.llms/`
- **Never put secrets, API keys, tokens, or credentials in this repo.** Auth stays in local-only files (`settings.local.json`, `.env`, `.credentials.json`).
- `scripts/reinit_env.sh` pulls the repo and re-applies all symlinks. It runs automatically via a `UserPromptSubmit` hook before every prompt.
- Before editing any file in `~/repo/environments/`, run `git -C ~/repo/environments pull --rebase` first.
- After any change to files in `~/repo/environments/`, commit and `git -C ~/repo/environments push`.
