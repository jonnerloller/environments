---
name: openclaw secret refresh workflow
description: How to refresh secrets in ~/.openclaw/openclaw.json from Vaultwarden via the refresh_secrets.sh patcher (hot-reload supported)
type: reference
originSessionId: 38b2e1a4-ee33-4d76-a080-520744a953a2
---
`~/.openclaw/openclaw.json` is openclaw's live config; openclaw writes back to it (timestamps, .bak rotation), so it cannot be a templated/rendered file. Pattern is patch-in-place from the password manager.

**Source of truth:** Vaultwarden, item `telegram_clawphi` in the `Homelab` org's `Homelab Secrets` collection. Custom fields `token` and `chat_id`.

**Patcher script:** `~/repo/environments/scripts/openclaw/refresh_secrets.sh`
- Sources `~/.config/bw/agent.env` (gets BW_CLIENTID/BW_CLIENTSECRET/BW_PASSWORD) if not already in env.
- Idempotent: runs login/unlock/sync, fetches item, patches only if changed.
- Creates `~/.openclaw/openclaw.json.bak.refresh_secrets` before writing.
- Overrides: `OPENCLAW_CONFIG`, `OPENCLAW_BW_ITEM`, `BW_AGENT_ENV`.

**Usage after rotating the bot token in Vaultwarden:**
```sh
~/repo/environments/scripts/openclaw/refresh_secrets.sh
# no restart needed — openclaw hot-reloads on config change
```

**Hot reload confirmed:** openclaw logs `[reload] config change detected; evaluating reload (channels.telegram.botToken)` → `[reload] config hot reload applied` → `[telegram] [default] starting provider` within milliseconds of the file mtime changing. No `systemctl restart` required.

**Service supervision:** `systemctl --user openclaw-gateway.service` (unit at `~/.config/systemd/user/openclaw-gateway.service`). Restart only needed for changes that aren't hot-reloadable.

**History:** This script previously used `dcli` (Dashlane). The dcli device key has been removed; Vaultwarden is the sole source. The `phi-0:secrets` Dashlane note may still exist as cold backup but is not kept in sync.

**Other secrets in openclaw.json** not yet migrated to Vaultwarden: `gateway.auth.token`. Add a Login item to the Homelab Secrets collection and extend the patcher when migrating.
