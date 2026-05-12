#!/usr/bin/env bash
# Pull notification credentials from Bitwarden and update Apprise's stored
# configurations. Run after rotating any source secret in Vaultwarden.
#
# Currently handles:
#   - "telegram" key  ← from Bitwarden item `telegram_clawphi`
#
# Add more channels by appending another section that POSTs to /add/<key>.
set -euo pipefail

APPRISE_API_URL="${APPRISE_API_URL:-http://localhost:8000}"
BW_ENV="${BW_AGENT_ENV:-$HOME/.config/bw/agent.env}"
TELEGRAM_BW_ITEM="${TELEGRAM_BW_ITEM:-telegram_clawphi}"
TELEGRAM_KEY="${APPRISE_TELEGRAM_KEY:-telegram}"

if [[ -z "${BW_CLIENTID:-}" ]]; then
  if [[ -f "$BW_ENV" ]]; then
    # shellcheck disable=SC1090
    source "$BW_ENV"
  else
    echo "BW_CLIENTID not set and $BW_ENV not found" >&2
    exit 1
  fi
fi

bw login --check >/dev/null 2>&1 || bw login --apikey >/dev/null
SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw 2>/dev/null)"
[[ -n "$SESSION" ]] || { echo "bw unlock failed" >&2; exit 1; }
export BW_SESSION="$SESSION"
bw sync >/dev/null

# --- telegram ---
ITEM_JSON="$(bw get item "$TELEGRAM_BW_ITEM" 2>/dev/null)" \
  || { echo "bw could not fetch item: $TELEGRAM_BW_ITEM" >&2; exit 1; }
TOKEN="$(jq -er '.fields[] | select(.name=="token") | .value' <<<"$ITEM_JSON")"
CHAT="$(jq -er '.fields[] | select(.name=="chat_id") | .value' <<<"$ITEM_JSON")"
[[ "$TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]] \
  || { echo "telegram token does not look right" >&2; exit 1; }

curl -fsS -X POST "${APPRISE_API_URL}/add/${TELEGRAM_KEY}" \
  --data-urlencode "urls=tgram://${TOKEN}/${CHAT}" >/dev/null
echo "apprise key '${TELEGRAM_KEY}' updated (token suffix ...${TOKEN: -8})"
