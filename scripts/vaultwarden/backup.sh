#!/usr/bin/env bash
# Snapshot the live vaultwarden database via its built-in online backup,
# bundle it with the RSA key and any attachments/sends into a tarball,
# and ship the tarball to a backup destination.
#
# Defaults assume the vaultwarden container is named "vaultwarden" with
# its data volume bind-mounted from ~/docker/vaultwarden/data.
set -euo pipefail

CONTAINER="${VW_CONTAINER:-vaultwarden}"
DATA_DIR="${VW_DATA_DIR:-$HOME/docker/vaultwarden/data}"
DEST_DIR="${VW_BACKUP_DIR:-/mnt/hdds/store/backups/vaultwarden}"
RETENTION="${VW_BACKUP_RETENTION:-14}"   # keep this many newest tarballs

mkdir -p "$DEST_DIR"

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q true; then
  echo "container '$CONTAINER' is not running" >&2
  exit 1
fi

# 1. Trigger an online SQLite backup inside the container.
#    Output: data/db_YYYYMMDD_HHMMSS.sqlite3
BACKUP_LINE="$(docker exec "$CONTAINER" /vaultwarden backup 2>&1 \
  | grep -E "^Backup to '" | tail -1)"
[[ -n "$BACKUP_LINE" ]] || { echo "vaultwarden backup did not produce a file" >&2; exit 1; }
SNAPSHOT_REL="$(printf '%s' "$BACKUP_LINE" | sed -E "s|^Backup to '([^']+)'.*|\1|")"
SNAPSHOT_NAME="$(basename "$SNAPSHOT_REL")"
SNAPSHOT_PATH="$DATA_DIR/$SNAPSHOT_NAME"

[[ -f "$SNAPSHOT_PATH" ]] || { echo "snapshot not found at $SNAPSHOT_PATH" >&2; exit 1; }

# 2. Assemble tarball contents. Include the snapshot under db.sqlite3 so the
#    restore is "drop the file in place" without renaming.
STAMP="$(printf '%s' "$SNAPSHOT_NAME" | sed -E 's/^db_([0-9]+_[0-9]+)\.sqlite3$/\1/')"
TARBALL="$DEST_DIR/vaultwarden-${STAMP}.tar.gz"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"; docker exec "$CONTAINER" rm -f "/data/$SNAPSHOT_NAME" >/dev/null 2>&1 || true' EXIT

cp "$SNAPSHOT_PATH" "$STAGE/db.sqlite3"
cp "$DATA_DIR/rsa_key.pem" "$STAGE/rsa_key.pem"
for d in attachments sends config.json; do
  [[ -e "$DATA_DIR/$d" ]] && cp -a "$DATA_DIR/$d" "$STAGE/"
done

tar -C "$STAGE" -czf "$TARBALL" .
chmod 600 "$TARBALL"

# 3. Apply retention: keep the newest $RETENTION tarballs.
mapfile -t OLD < <(ls -1t "$DEST_DIR"/vaultwarden-*.tar.gz 2>/dev/null | tail -n +"$((RETENTION + 1))")
for f in "${OLD[@]:-}"; do
  [[ -n "$f" ]] && rm -f "$f"
done

SIZE="$(du -h "$TARBALL" | awk '{print $1}')"
KEPT="$(ls -1 "$DEST_DIR"/vaultwarden-*.tar.gz 2>/dev/null | wc -l)"
echo "backup ok: $TARBALL ($SIZE); $KEPT total, retention=$RETENTION"
