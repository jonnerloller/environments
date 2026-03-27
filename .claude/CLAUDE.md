# Global Claude Instructions

## Environment
- Server: phi-0 (homelab)
- Docker requires `sudo`
- All Docker services live in `~/docker/<service-name>/`, each with their own `docker-compose.yml`

## Homelab Conventions
- Reverse proxy: Caddy with `tls internal` (self-signed certs)
- Service domains: `<service>.services.phitrine.com`
- Host domains: `<host>.home.phitrine.com`
- DNS: 10.0.0.1
- Running services: Homepage (:3000), Immich (:2283), Plex, TrueNAS, Proxmox, AirTrail (:3001)

## Code Style
- Keep it simple. No over-engineering.
- Prefer shell scripts for automation tasks.

## Environments Repo
- Dotfiles, AI agent configs, and skills live in `~/repo/environments/`
- Claude config is symlinked from there into `~/.claude/`
- Tool-agnostic rules/skills live in `~/repo/environments/.llms/`
- **Never put secrets, API keys, tokens, or credentials in this repo.** Auth stays in local-only files (`settings.local.json`, `.env`, `.credentials.json`).
- At the start of a session, run `git -C ~/repo/environments pull` to stay up-to-date.
- After any change to files in `~/repo/environments/`, commit and `git -C ~/repo/environments push`.
