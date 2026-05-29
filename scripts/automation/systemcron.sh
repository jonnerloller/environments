#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOT'
usage:
  systemcron.sh
  systemcron.sh list
  systemcron.sh add daily-journal
  systemcron.sh add <name> -- <cron> <command...>
  systemcron.sh remove <name>

notes:
  - Managed jobs are tagged with # systemcron:<name>
  - list shows only managed jobs
EOT
}

CRONTAB_BIN="${CRONTAB_BIN:-crontab}"

current_crontab() {
  "$CRONTAB_BIN" -l 2>/dev/null || true
}

list_jobs() {
  local data
  data="$(current_crontab)"
  if [[ -z "$data" ]]; then
    echo "No crontab entries."
    return 0
  fi

  printf '%s\n' "$data"
}

remove_job() {
  local name="$1"
  local data filtered
  data="$(current_crontab)"

  if [[ "$name" == "daily-journal" ]]; then
    filtered="$(printf '%s\n' "$data" | awk '
      /^# systemcron:daily-journal begin$/ { skip=1; next }
      /^# systemcron:daily-journal end$/ { skip=0; next }
      skip != 1 { print }
    ')"
  else
    filtered="$(printf '%s\n' "$data" | awk -v name="$name" '
      $0 !~ "# systemcron:" name "([[:space:]]|$)" { print }
    ')"
  fi

  printf '%s\n' "$filtered" | "$CRONTAB_BIN" -
  echo "Removed: $name"
}

add_job() {
  local name="$1"
  shift

  local entry
  if [[ "$name" == "daily-journal" && $# -eq 0 ]]; then
    entry=$'# systemcron:daily-journal begin\nCRON_TZ=America/Los_Angeles\n0 21 * * * /usr/bin/env bash /home/phitrine/repo/environments/scripts/automation/send_daily_journal_reminder.sh >> /home/phitrine/.local/share/daily-journal-reminder.log 2>&1 # systemcron:daily-journal\n# systemcron:daily-journal end'
  else
    if [[ $# -lt 6 || "$1" != "--" ]]; then
      usage >&2
      exit 2
    fi
    shift
    local schedule=("$1" "$2" "$3" "$4" "$5")
    shift 5
    entry="${schedule[*]} $* # systemcron:${name}"
  fi

  local data filtered
  data="$(current_crontab)"
  if [[ "$name" == "daily-journal" ]]; then
    filtered="$(printf '%s\n' "$data" | awk '
      /^# systemcron:daily-journal begin$/ { skip=1; next }
      /^# systemcron:daily-journal end$/ { skip=0; next }
      skip != 1 { print }
    ')"
  else
    filtered="$(printf '%s\n' "$data" | awk -v name="$name" '
      $0 !~ "# systemcron:" name "([[:space:]]|$)" { print }
    ')"
  fi

  {
    printf '%s\n' "$filtered"
    printf '%s\n' "$entry"
  } | "$CRONTAB_BIN" -
  echo "Added: $name"
}

main() {
  local cmd="${1:-list}"
  shift || true

  case "$cmd" in
    list)
      list_jobs
      ;;
    add)
      if [[ $# -eq 1 && "$1" == "daily-journal" ]]; then
        add_job daily-journal
        exit 0
      fi
      if [[ $# -lt 2 ]]; then
        usage >&2
        exit 2
      fi
      add_job "$@"
      ;;
    remove)
      if [[ $# -ne 1 ]]; then
        usage >&2
        exit 2
      fi
      remove_job "$1"
      ;;
    -h|--help|help)
      usage
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
