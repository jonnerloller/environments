---
name: gog (Google CLI) setup on phi-0
description: gog v0.15.0 authorized for chen.enhan.jonathan@gmail.com with gmail/calendar/drive scopes; file keyring + GOG_KEYRING_PASSWORD in env
type: reference
originSessionId: 38b2e1a4-ee33-4d76-a080-520744a953a2
---
**Tool:** `gog` v0.15.0 (Go binary at `~/.local/bin/gog`) — Google CLI for Gmail/Drive/Calendar/Chat/Docs/Sheets/etc.

**Authorized account:** `chen.enhan.jonathan@gmail.com`
- Scopes (full mode): Gmail modify + settings, Drive full, Calendar read+write, OIDC identity.
- Token stored in file-based keyring (`~/.config/gogcli/keyring/`) — encrypted with `GOG_KEYRING_PASSWORD`.

**OAuth client:** custom GCP project `jonduck`, Desktop app type, **published (In production)** — refresh tokens are persistent (won't expire after 7 days like Testing-mode apps).

**Backups in Bitwarden (Homelab Secrets):**
- `gog_oauth_client` — full `{"installed": {...}}` JSON, importable via `gog auth credentials set <file>`.
- `gog_keyring_password` — value of `GOG_KEYRING_PASSWORD`. Without this, existing stored refresh tokens become unreadable on restore.

**Key environment requirement:**
- `GOG_KEYRING_PASSWORD` must be set in any process that calls `gog`. File: `~/.config/gogcli/keyring.env` (chmod 600). Sourced from `~/repo/environments/dotfiles/zsh/.zshrc`.
- Without it, `gog` reports "Object does not exist at path '/'" because the OS keychain (gnome-keyring/D-Bus secret service) isn't running on this headless box. File backend is the workaround.
- For systemd units that invoke `gog`: add `EnvironmentFile=%h/.config/gogcli/keyring.env`.

**Smoke-test recipes:**
```sh
gog -a chen.enhan.jonathan@gmail.com gmail labels list
gog -a chen.enhan.jonathan@gmail.com calendar list
gog -a chen.enhan.jonathan@gmail.com drive ls --limit 3
```

**Common gotchas:**
- Drive uses `ls`, not `list` (other services use `list`).
- The `--account/-a` flag is required for any service-API call. For convenience, can set a default email via `gog config set` or use account aliases (`gog auth alias`).
- `gog auth doctor` is the first thing to run when something feels off.
- `gog --gmail-no-send` flag (or `gog config set gmail_no_send true`) is the agent-safety toggle to block Gmail sends.

**Restore on a new machine (or after losing local config):**
1. Retrieve secrets from Bitwarden:
   ```sh
   bw get item gog_oauth_client | jq -r '.notes' > /tmp/gog-credentials.json
   bw get item gog_keyring_password | jq -r '.notes' \
     | xargs -I{} printf 'export GOG_KEYRING_PASSWORD="%s"\n' {} \
     > ~/.config/gogcli/keyring.env
   chmod 600 ~/.config/gogcli/keyring.env
   source ~/.config/gogcli/keyring.env
   ```
2. `gog auth credentials set /tmp/gog-credentials.json` and `gog auth keyring file`
3. If the token bucket survived: `gog auth doctor` should show `tokens: 1 readable`. Done.
4. Otherwise (fresh machine): SSH tunnel `ssh -N -L 8085:localhost:8085 phitrine@10.0.0.8`, then
   `gog auth add chen.enhan.jonathan@gmail.com --services=gmail,calendar,drive --listen-addr=127.0.0.1:8085`,
   click URL on laptop, consent.
5. `shred -u /tmp/gog-credentials.json`.

**OpenClaw integration:** `gog` is enabled as a skill in `openclaw.json` (`skills.entries.gog.enabled = true`) and on the Coder agent (`agents.list[].skills`).
