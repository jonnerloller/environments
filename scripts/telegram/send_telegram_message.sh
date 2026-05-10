#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOT'
usage:
  send_telegram_message.sh --message "text"
  send_telegram_message.sh "text"

env:
  TELEGRAM_BOT_TOKEN   required
  TELEGRAM_CHAT_ID     required
  TELEGRAM_API_BASE    optional, defaults to https://api.telegram.org
  TELEGRAM_DISABLE_NOTIFICATION optional, 1 to silence the ping
EOT
}

MESSAGE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --message)
      MESSAGE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      [[ $# -gt 0 ]] && MESSAGE="$*"
      break
      ;;
    *)
      if [[ -z "$MESSAGE" ]]; then
        MESSAGE="$1"
      else
        MESSAGE+=" $1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$MESSAGE" ]]; then
  usage >&2
  exit 2
fi

: "${TELEGRAM_BOT_TOKEN:?TELEGRAM_BOT_TOKEN is required}"
: "${TELEGRAM_CHAT_ID:?TELEGRAM_CHAT_ID is required}"

API_BASE="${TELEGRAM_API_BASE:-https://api.telegram.org}"
DISABLE_NOTIFICATION="${TELEGRAM_DISABLE_NOTIFICATION:-0}"

curl -fsS --connect-timeout 10 --max-time 30 \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  --data-urlencode "disable_notification=${DISABLE_NOTIFICATION}" \
  "${API_BASE}/bot${TELEGRAM_BOT_TOKEN}/sendMessage" >/dev/null
