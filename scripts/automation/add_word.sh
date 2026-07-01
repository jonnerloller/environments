#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
usage:
  add_word.sh <word> [reading] [meaning] [nuance] [example_jp] [example_en]

notes:
  - Deduplicates by word; appends under today's UTC date heading.
  - Archive path override: JAPANESE_WORD_ARCHIVE
  - Performs a local write; safe to introspect with -h/--help (no write).
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

ARCHIVE_PATH="${JAPANESE_WORD_ARCHIVE:-$HOME/Obsidian/valhalla/Learning/Japanese/Japanese Word Lookup Archive.md}"
TODAY_UTC="$(date -u +%F)"

WORD="${1:-}"
READING="${2:-}"
MEANING="${3:-}"
NUANCE="${4:-}"
EXAMPLE_JP="${5:-}"
EXAMPLE_EN="${6:-}"

if [[ -z "$WORD" ]]; then
  usage >&2
  exit 1
fi

mkdir -p "$(dirname "$ARCHIVE_PATH")"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  cat > "$ARCHIVE_PATH" <<'EOF'
# Japanese Word Lookup Archive

A running archive of Japanese words I looked up and wanted to keep.
EOF
fi

if grep -Fq -- "**$WORD**" "$ARCHIVE_PATH"; then
  echo "EXISTS: $WORD"
  exit 0
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

if grep -Fq -- "## $TODAY_UTC" "$ARCHIVE_PATH"; then
  awk -v date_heading="## $TODAY_UTC" \
      -v word="$WORD" \
      -v reading="$READING" \
      -v meaning="$MEANING" \
      -v nuance="$NUANCE" \
      -v example_jp="$EXAMPLE_JP" \
      -v example_en="$EXAMPLE_EN" '
      BEGIN { inserted = 0 }
      {
        print $0
        if ($0 == date_heading && inserted == 0) {
          print ""
          line = "- **" word "**"
          if (reading != "") line = line "（" reading "）"
          print line
          if (meaning != "") print "  - meaning: " meaning
          if (nuance != "") print "  - nuance: " nuance
          if (example_jp != "") {
            ex = "  - example: **" example_jp "**"
            if (example_en != "") ex = ex " — " example_en
            print ex
          }
          inserted = 1
        }
      }
      END {
        if (inserted == 0) exit 2
      }' "$ARCHIVE_PATH" > "$TMP_FILE"
  mv "$TMP_FILE" "$ARCHIVE_PATH"
else
  cat "$ARCHIVE_PATH" > "$TMP_FILE"
  {
    printf '\n## %s\n\n' "$TODAY_UTC"
    printf -- '- **%s**' "$WORD"
    if [[ -n "$READING" ]]; then
      printf '（%s）' "$READING"
    fi
    printf '\n'
    [[ -n "$MEANING" ]] && printf '  - meaning: %s\n' "$MEANING"
    [[ -n "$NUANCE" ]] && printf '  - nuance: %s\n' "$NUANCE"
    if [[ -n "$EXAMPLE_JP" ]]; then
      printf '  - example: **%s**' "$EXAMPLE_JP"
      [[ -n "$EXAMPLE_EN" ]] && printf ' — %s' "$EXAMPLE_EN"
      printf '\n'
    fi
  } >> "$TMP_FILE"
  mv "$TMP_FILE" "$ARCHIVE_PATH"
fi

echo "ADDED: $WORD -> $ARCHIVE_PATH"
