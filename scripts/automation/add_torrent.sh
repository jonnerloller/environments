#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage:
  add_torrent.sh [--dry-run] <magnet-or-torrent-url>

notes:
  - Adds a torrent to Transmission via RPC.
  - Env overrides: TRANSMISSION_ENV_FILE, TRANSMISSION_RPC_URL
  - Performs an external write; use --dry-run to preview, -h/--help to introspect.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  shift
fi

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

INPUT="$1"
ENV_FILE="${TRANSMISSION_ENV_FILE:-/home/phitrine/docker/transmission/.env}"
RPC_URL="${TRANSMISSION_RPC_URL:-http://localhost:9091/transmission/rpc}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "transmission env not found: $ENV_FILE" >&2
  exit 1
fi

RPC_USER="$(awk -F= '/^TRANSMISSION_RPC_USERNAME=/{print $2}' "$ENV_FILE")"
RPC_PASS="$(awk -F= '/^TRANSMISSION_RPC_PASSWORD=/{print $2}' "$ENV_FILE")"

if [[ -z "${RPC_USER:-}" || -z "${RPC_PASS:-}" ]]; then
  echo "missing transmission rpc creds in $ENV_FILE" >&2
  exit 1
fi

build_payload() {
  python3 - "$INPUT" <<'PY'
import json,sys
print(json.dumps({"method":"torrent-add","arguments":{"filename":sys.argv[1]}}))
PY
}

PAYLOAD="$(build_payload)"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "dry-run: would add torrent -> $INPUT"
  exit 0
fi

TMP_HEADERS="$(mktemp)"
TMP_BODY="$(mktemp)"
trap 'rm -f "$TMP_HEADERS" "$TMP_BODY"' EXIT

curl -sS -D "$TMP_HEADERS" -o "$TMP_BODY" \
  -u "$RPC_USER:$RPC_PASS" \
  -H 'Content-Type: application/json' \
  -d "$PAYLOAD" \
  "$RPC_URL" >/dev/null || true

SESSION_ID="$(awk -F': ' 'tolower($1)=="x-transmission-session-id"{gsub("\r","",$2); print $2}' "$TMP_HEADERS" | tail -n1)"

if [[ -n "$SESSION_ID" ]]; then
  curl -sS -D "$TMP_HEADERS" -o "$TMP_BODY" \
    -u "$RPC_USER:$RPC_PASS" \
    -H 'Content-Type: application/json' \
    -H "X-Transmission-Session-Id: $SESSION_ID" \
    -d "$PAYLOAD" \
    "$RPC_URL" >/dev/null
fi

python3 - "$TMP_BODY" <<'PY'
import json,sys
body=open(sys.argv[1]).read().strip()
if not body:
  print("error: empty rpc response")
  raise SystemExit(1)
try:
  data=json.loads(body)
except Exception:
  print(body)
  raise SystemExit(1)
res=data.get("result")
args=data.get("arguments",{})
if res!="success":
  print(body)
  raise SystemExit(1)
added=args.get("torrent-added") or args.get("torrent-duplicate") or {}
name=added.get("name") or "(unknown)"
tid=added.get("id")
hashs=added.get("hashString")
print(f"ok: {name} | id={tid} | hash={hashs}")
PY
