---
name: Vaultwarden backup setup
description: Daily systemd-timer runs backup.sh; tarballs land in /mnt/hdds/store/backups/vaultwarden (CIFS to TrueNAS); retention=14
type: reference
originSessionId: 38b2e1a4-ee33-4d76-a080-520744a953a2
---
**Script:** `~/repo/environments/scripts/vaultwarden/backup.sh`
- Uses `vaultwarden`'s built-in online backup (`/vaultwarden backup`) — consistent snapshot while the container runs, no downtime.
- Tarball contains `db.sqlite3` (renamed from the timestamped snapshot, so restore is drop-in) + `rsa_key.pem` + `attachments/` and `sends/` if present.
- Cleans up the in-data snapshot via `docker exec` (it's root-owned).
- Retention: keeps the newest `$VW_BACKUP_RETENTION` tarballs (default 14).
- Overrides: `VW_CONTAINER`, `VW_DATA_DIR`, `VW_BACKUP_DIR`, `VW_BACKUP_RETENTION`.

**Schedule:** user systemd timer.
- `~/.config/systemd/user/vaultwarden-backup.service` + `vaultwarden-backup.timer`
- Daily at 04:00 America/Los_Angeles, `Persistent=true`.
- Manage: `systemctl --user {start,stop,status,disable} vaultwarden-backup.timer`; `journalctl --user -u vaultwarden-backup`.
- Linger is enabled for user `phitrine`, so the timer runs even when no session is active.

**Destination:** `/mnt/hdds/store/backups/vaultwarden/` (CIFS mount → `//truenas.home.phitrine.com/store`).
- **CIFS-mount caveat:** `chmod 600` on the tarball is a no-op as displayed (`file_mode=0664` forces the visible mode). Real access control lives in the ZFS ACL on the TrueNAS `store` dataset; tighten there if backups are sensitive.
- Wildcard DNS handles `truenas.home.phitrine.com` (10.0.0.3).

**Restore procedure** (not yet tested):
1. Stop vaultwarden: `cd ~/docker/vaultwarden && docker compose down`
2. `tar -xzf <tarball> -C ~/docker/vaultwarden/data/` (overwrite the current files)
3. Bring back: `docker compose up -d`
The renamed `db.sqlite3` slots straight in; `rsa_key.pem` keeps existing JWT sessions valid.
