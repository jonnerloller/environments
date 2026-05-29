#!/usr/bin/env bash
# Send a Telegram message via the central Apprise service.
# Same CLI as the previous direct-Bot-API version; bot token / chat id
# now live in Apprise (configured by scripts/apprise/refresh_configs.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MACHINE_ENV="${OPENCLAW_MACHINE_ENV:-$ROOT/machines/phi-0.env}"

if [[ -f "$MACHINE_ENV" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "$MACHINE_ENV"
  set +a
fi

usage() {
  cat <<'EOT'
usage:
  send_telegram_message.sh --message "text"
  send_telegram_message.sh "text"

env:
  APPRISE_BASE_URL   optional, defaults to https://apprise.services.phitrine.com
  APPRISE_KEY        optional, defaults to "telegram"
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

BASE="${APPRISE_BASE_URL:-https://apprise.services.phitrine.com}"
KEY="${APPRISE_KEY:-telegram}"

curl -fsS --connect-timeout 10 --max-time 30 -X POST \
  --data-urlencode "body=${MESSAGE}" \
  "${BASE}/notify/${KEY}" >/dev/null
