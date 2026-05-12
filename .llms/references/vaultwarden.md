---
name: Vaultwarden homelab secrets store
description: Self-hosted Bitwarden at https://vault.services.phitrine.com; phi-0-agent user reads Homelab org via bw CLI from ~/.config/bw/agent.env
type: reference
originSessionId: 38b2e1a4-ee33-4d76-a080-520744a953a2
---
**Service:** Vaultwarden 1.36.0, self-hosted on phi-0.
- URL: https://vault.services.phitrine.com (Caddy reverse proxy, **publicly trusted Let's Encrypt cert** via DNS-01 — see `caddy_tls.md`).
- Docker: `~/docker/vaultwarden/` (compose + .env, data in `./data/`)
- Internal port: 80 → host 8222
- Admin panel: `/admin` (token in `~/docker/vaultwarden/.env`, currently plaintext — recommended to upgrade to Argon2 PHC later via `docker exec vaultwarden /vaultwarden hash`)
- Signups disabled (`SIGNUPS_ALLOWED=false`); invitations allowed.

**Users:**
- `chen.enhan.jonathan@gmail.com` — primary/personal account, Owner of `Homelab` org.
- `phi-0-agent@phi-0.local` — agent user, role=User in `Homelab` org, read-only access to `Homelab Secrets` collection only.

**Headless agent access (DIY service account):**
- bw CLI installed globally via npm (`@bitwarden/cli`).
- `bw config server https://vault.services.phitrine.com` (already set).
- Credentials at `~/.config/bw/agent.env` (chmod 600), containing:
  - `BW_CLIENTID`, `BW_CLIENTSECRET` — the agent user's personal API key (Account Settings → Security → Keys → API Key).
  - `BW_PASSWORD` — the agent's master password. Treat as a secret with same gravity as any other on-disk credential; blast radius is read access to Homelab Secrets only (cannot mutate, cannot see other orgs/items, cannot see personal vault).
- (Historical: previously also needed `NODE_EXTRA_CA_CERTS` pointing at Caddy's internal CA. No longer needed now that Caddy serves publicly trusted Let's Encrypt certs.)
- Standard flow in scripts: `source ~/.config/bw/agent.env && export BW_SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw)" && bw sync && bw get item <name>`.

**Important Bitwarden semantics:**
- `bw login` and `bw unlock` are separate. Login authenticates to server; unlock derives the vault encryption key from the master password. Both are needed to read items.
- Vault is encrypted client-side. Server cannot read items even in plaintext DB. This is why the master password (or a session token derived from it) is unavoidable for read access.
- The `bw login --check` command is idempotent and safe to call from scripts.

**Item shape convention:**
- Login-type items with `token` and `chat_id` (etc.) as **custom fields** (not username/password). Cleaner than overloading password field; `jq '.fields[] | select(.name=="X") | .value'` extracts each.

**Wildcard DNS** at 10.0.0.1 resolves `*.services.phitrine.com → 10.0.0.8` (phi-0), so adding new `<service>.services.phitrine.com` hosts needs no DNS work.

**Known quirk:** snap-installed Docker bind-mounts can serve stale snapshots inside containers. If a Caddyfile edit doesn't take after `caddy reload`, restart the caddy container (`docker compose restart`) — the bind mount refreshes.
