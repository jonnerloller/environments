#!/usr/bin/env bash
# Pull secrets from Vaultwarden (item: telegram_clawphi in the Homelab org)
# and patch them into ~/.openclaw/openclaw.json.
# Run after rotating the bot token in Vaultwarden; openclaw hot-reloads the
# config so no restart is required.
set -euo pipefail

CONFIG="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
ITEM_NAME="${OPENCLAW_BW_ITEM:-telegram_clawphi}"
BW_ENV="${BW_AGENT_ENV:-$HOME/.config/bw/agent.env}"

if [[ ! -f "$CONFIG" ]]; then
  echo "config not found: $CONFIG" >&2
  exit 1
fi

if [[ -z "${BW_CLIENTID:-}" ]]; then
  if [[ -f "$BW_ENV" ]]; then
    # shellcheck disable=SC1090
    source "$BW_ENV"
  else
    echo "BW_CLIENTID not set and $BW_ENV not found" >&2
    exit 1
  fi
fi

# Ensure logged in (login is idempotent — does nothing if already authenticated)
if ! bw login --check >/dev/null 2>&1; then
  bw login --apikey >/dev/null
fi

# Unlock to get a session token (works whether vault is locked or already unlocked)
SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw 2>/dev/null)"
[[ -n "$SESSION" ]] || { echo "bw unlock failed" >&2; exit 1; }
export BW_SESSION="$SESSION"

bw sync >/dev/null

ITEM_JSON="$(bw get item "$ITEM_NAME" 2>/dev/null)" \
  || { echo "bw could not fetch item: $ITEM_NAME" >&2; exit 1; }

BOT_TOKEN="$(printf '%s' "$ITEM_JSON" \
  | jq -er '.fields[] | select(.name=="token") | .value')"
[[ "$BOT_TOKEN" =~ ^[0-9]+:[A-Za-z0-9_-]+$ ]] \
  || { echo "token from bw does not look like a Telegram bot token" >&2; exit 1; }

CURRENT="$(jq -r '.channels.telegram.botToken // ""' "$CONFIG")"
if [[ "$CURRENT" == "$BOT_TOKEN" ]]; then
  echo "botToken already up to date"
  exit 0
fi

TMP="$(mktemp "${CONFIG}.refresh.XXXXXX")"
trap 'rm -f "$TMP"' EXIT
jq --arg t "$BOT_TOKEN" '.channels.telegram.botToken = $t' "$CONFIG" > "$TMP"
cp -p "$CONFIG" "${CONFIG}.bak.refresh_secrets"
mv "$TMP" "$CONFIG"
trap - EXIT

echo "botToken updated (suffix ...${BOT_TOKEN: -8}); openclaw will hot-reload"
