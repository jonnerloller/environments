# Shared infrastructure references

Fact sheets for tools, services, and integrations that any agent operating on Jonathan's homelab should be able to find. **Read these the way you'd read a runbook**: they describe what's set up, where things live, how to interact with them, and how to restore them.

These are not behavior rules — those live in `../rules/`. These are facts about state.

## Index

- [apprise.md](apprise.md) — central notification gateway (Apprise at `apprise.services.phitrine.com`); how to send, how to add channels
- [caddy_tls.md](caddy_tls.md) — Caddy reverse proxy with publicly trusted Let's Encrypt certs via Cloudflare DNS-01; how to add services, recovery scenarios
- [gog.md](gog.md) — `gog` Google CLI setup (Gmail/Drive/Calendar); file keyring + `GOG_KEYRING_PASSWORD`; restore steps from Bitwarden
- [openclaw_oauth.md](openclaw_oauth.md) — SSH port-forwarding pattern for openclaw's OAuth flow (1455 + 18789)
- [openclaw_secrets.md](openclaw_secrets.md) — how openclaw's `openclaw.json` gets refreshed from Vaultwarden via `refresh_secrets.sh`; hot-reload semantics
- [vaultwarden.md](vaultwarden.md) — self-hosted Bitwarden at `vault.services.phitrine.com`; `phi-0-agent` user; `bw` CLI via `~/.config/bw/agent.env`
- [vaultwarden_backup.md](vaultwarden_backup.md) — daily systemd-timer backup to `/mnt/hdds/store/backups/vaultwarden/`; restore procedure

## When to add a new file here

Add a reference when you learn an **infrastructure fact** that other agents (openclaw, future Claude sessions, etc.) would also benefit from seeing. Good candidates:

- A new service is deployed (URL, port, where its config lives, how to update its secrets)
- A non-obvious integration pattern that costs time to rediscover (TLS trust, keyring choice, refresh flow)
- A restore / disaster-recovery procedure
- A "this is where the secret/config/state actually lives" pointer

Don't add: behavior rules (`../rules/`), tool-specific personality (Claude Code's `~/.claude/projects/...` private memory, openclaw's `~/.openclaw/workspace/MEMORY.md`), or anything trivially re-derivable from the codebase.

## Frontmatter convention

Each file uses YAML frontmatter for searchability:

```markdown
---
name: short identifier
description: one-line summary suitable for an index
type: reference
---
```

The `type: reference` field is what tags this as infrastructure-fact rather than rule or preference.
