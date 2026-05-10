#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage:
  add_flight.sh [--dry-run] [YYYY-MM-DD] FLIGHT FROM TO [AIRLINE]
  add_flight.sh [--dry-run] --date YYYY-MM-DD --flight FLIGHT --from FROM --to TO [--airline AIRLINE]

notes:
  - If --date is omitted, defaults to today in UTC.
  - Explicit invocation by agents/users is allowed.
  - This script performs an external write and should only run on explicit request.
EOF
}

is_date() {
  [[ "$1" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

map_airline_to_icao() {
  local code="${1^^}"
  case "$code" in
    AS) echo "ASA" ;;
    AA) echo "AAL" ;;
    DL) echo "DAL" ;;
    UA) echo "UAL" ;;
    WN) echo "SWA" ;;
    B6) echo "JBU" ;;
    ???) echo "$code" ;;
    *) echo "" ;;
  esac
}

DRY_RUN=0
DATE=""
FLIGHT=""
FROM=""
TO=""
AIRLINE=""
POSITIONAL=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --date)
      DATE="${2:-}"
      shift 2
      ;;
    --flight)
      FLIGHT="${2:-}"
      shift 2
      ;;
    --from)
      FROM="${2:-}"
      shift 2
      ;;
    --to)
      TO="${2:-}"
      shift 2
      ;;
    --airline)
      AIRLINE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [[ $# -gt 0 ]]; do
        POSITIONAL+=("$1")
        shift
      done
      ;;
    -*)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$FLIGHT" && ${#POSITIONAL[@]} -gt 0 ]]; then
  if is_date "${POSITIONAL[0]}"; then
    DATE="${POSITIONAL[0]}"
    POSITIONAL=("${POSITIONAL[@]:1}")
  fi

  if [[ ${#POSITIONAL[@]} -lt 3 ]]; then
    usage >&2
    exit 2
  fi

  FLIGHT="${POSITIONAL[0]}"
  FROM="${POSITIONAL[1]}"
  TO="${POSITIONAL[2]}"
  if [[ ${#POSITIONAL[@]} -ge 4 ]]; then
    AIRLINE="${POSITIONAL[3]}"
  fi
fi

if [[ -z "$DATE" ]]; then
  DATE="$(date -u +%F)"
fi

if [[ -z "$FLIGHT" || -z "$FROM" || -z "$TO" ]]; then
  usage >&2
  exit 2
fi

if ! is_date "$DATE"; then
  echo "invalid date: $DATE (expected YYYY-MM-DD)" >&2
  exit 2
fi

FLIGHT="${FLIGHT^^}"
FROM="${FROM^^}"
TO="${TO^^}"
AIRLINE="${AIRLINE^^}"

KEY_FILE="${AIRTRAIL_ENV_FILE:-$HOME/.openclaw/workspace/.secrets/airtrail.env}"
API_URL="${AIRTRAIL_API_URL:-http://localhost:3001/api/flight/save}"
QUEUE_FILE="${AIRTRAIL_QUEUE_FILE:-$HOME/.openclaw/workspace/automation/airtrail/queue.jsonl}"

mkdir -p "$(dirname "$QUEUE_FILE")"

if [[ ! -f "$KEY_FILE" ]]; then
  echo "airtrail key file missing: $KEY_FILE" >&2
  exit 1
fi

API_KEY="$(awk -F= '/^AIRTRAIL_API_KEY=/{print $2}' "$KEY_FILE")"
if [[ -z "${API_KEY:-}" ]]; then
  echo "AIRTRAIL_API_KEY missing in $KEY_FILE" >&2
  exit 1
fi

AIRLINE_ICAO=""
if [[ -n "$AIRLINE" ]]; then
  AIRLINE_ICAO="$(map_airline_to_icao "$AIRLINE")"
fi
if [[ -z "$AIRLINE_ICAO" ]]; then
  AIRLINE_ICAO="$(map_airline_to_icao "${FLIGHT:0:2}")"
  if [[ -z "$AIRLINE_ICAO" && ${#FLIGHT} -ge 3 ]]; then
    AIRLINE_ICAO="$(map_airline_to_icao "${FLIGHT:0:3}")"
  fi
fi

USER_ID="uqdx6ka2f5jiz96"

PAYLOAD="$(python3 - <<PY
import json
print(json.dumps({
  "from":"$FROM",
  "to":"$TO",
  "departure":"$DATE",
  "flightNumber":"$FLIGHT",
  "airline": ("$AIRLINE_ICAO" if "$AIRLINE_ICAO" else None),
  "flightReason":"leisure",
  "seats":[{"userId":"$USER_ID","seat":"window"}]
}, separators=(",",":")))
PY
)"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "dry-run: would submit $DATE $FLIGHT $FROM->$TO airline=${AIRLINE_ICAO:-unknown}"
  exit 0
fi

HTTP_CODE=$(curl -sS -o /tmp/airtrail-addflight.out -w '%{http_code}' \
  -H "Authorization: Bearer $API_KEY" \
  -H 'content-type: application/json' \
  --data "$PAYLOAD" \
  "$API_URL" || true)

BODY="$(cat /tmp/airtrail-addflight.out)"

python3 - "$HTTP_CODE" "$BODY" "$QUEUE_FILE" "$DATE" "$FLIGHT" "$FROM" "$TO" "$AIRLINE_ICAO" <<'PY'
import json,sys,datetime
code=int(sys.argv[1]) if sys.argv[1].isdigit() else 0
body=sys.argv[2]
queue=sys.argv[3]
date,flight,from_,to,airline = sys.argv[4:9]
ok=False
airtrail_id=None
msg=""
try:
    data=json.loads(body) if body else {}
except Exception:
    data={"raw":body}
if code==200 and isinstance(data,dict) and data.get("success") is True:
    ok=True
    airtrail_id=data.get("id")
    msg=f"ok: added {date} {flight} {from_}->{to} airline={airline or 'unknown'} id={airtrail_id}"
else:
    msg=f"queued: addflight pending (http {code}) for {date} {flight} {from_}->{to}"
entry={
  "queued_at_utc":datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
  "source":"explicit-script",
  "raw":f"/addflight {date} {flight} {from_} {to}",
  "parsed":{"date":date,"flightNumber":flight,"from":from_,"to":to,"airline":airline or None},
  "status":"submitted" if ok else "queued",
  "attempt_result":{"ok":ok,"status":code,"body":body[:500]},
}
if airtrail_id is not None:
    entry["airtrail_id"]=airtrail_id
with open(queue,"a") as f:
    f.write(json.dumps(entry)+"\n")
print(msg)
PY
