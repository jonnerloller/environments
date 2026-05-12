---
name: Apprise central notification gateway
description: All homelab notifications (Telegram for now, Discord/email later) go through Apprise at apprise.services.phitrine.com; configs refreshed from Bitwarden
type: reference
originSessionId: 38b2e1a4-ee33-4d76-a080-520744a953a2
---
**Service:** [caronc/apprise](https://github.com/caronc/apprise-api) (Docker, container port 8000) at https://apprise.services.phitrine.com (publicly trusted Let's Encrypt cert via Caddy DNS-01 — see `caddy_tls.md`).

- Compose: `~/docker/apprise/docker-compose.yml`
- Config dir: `~/docker/apprise/config/` (persistent storage of named keys)
- Mode: `APPRISE_STATEFUL_MODE=simple` (one named key = one set of URLs)
- No auth (LAN-only). Add Caddy basic-auth if exposing publicly.

**Configured channels:** `telegram` → `tgram://<bot_token>/<chat_id>` from Bitwarden item `telegram_clawphi`.

**Refresh from Bitwarden:** `~/repo/environments/scripts/apprise/refresh_configs.sh` — reads from `bw`, POSTs to `/add/<key>`. Run after rotating any source secret. Extend with new sections to add discord/email/etc.

**Sender script:** `~/repo/environments/scripts/telegram/send_telegram_message.sh` was rewritten to POST to `https://apprise.services.phitrine.com/notify/telegram`. Same CLI as the old direct-Bot-API version, but no `TELEGRAM_BOT_TOKEN` env required. Override targets via `APPRISE_BASE_URL` / `APPRISE_KEY`.

**Sending API (raw):**
- `POST /notify/<key>` form fields: `body` (required), `title`, `type` (info/success/warning/failure), `tag`
- `POST /add/<key>` form field: `urls=<comma-separated apprise urls>`
- `GET /get/<key>` returns the stored config
- `DEL /del/<key>` removes a key

**Why this exists:** previously every consumer (sender script, openclaw, future scripts) needed the Telegram bot token in env. Now only Apprise (and openclaw, which IS the bot) carry the token. One rotation site, one refresh script, one HTTP endpoint per channel.

**Related:** `reference_vaultwarden.md` (where the credentials live), `reference_openclaw_secrets.md` (openclaw still has its own copy because it IS the bot, not a notification consumer).
