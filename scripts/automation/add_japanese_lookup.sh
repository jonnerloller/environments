#!/usr/bin/env bash
set -euo pipefail

ARCHIVE_PATH="${JAPANESE_STUDY_ARCHIVE:-$HOME/Obsidian/valhalla/Learning/Japanese/Japanese Study Lookup Archive.md}"
TODAY_UTC="$(date -u +%F)"
KIND="${1:-}"
QUERY="${2:-}"
READING="${3:-}"
MEANING="${4:-}"
CONCEPT_TAGS="${5:-}"
DETAILS="${6:-}"

if [[ -z "$KIND" || -z "$QUERY" ]]; then
  echo "Usage: add_japanese_lookup.sh <word|translate|grammar|phrase> <query> [reading] [meaning] [concept_tags] [details]" >&2
  exit 1
fi

mkdir -p "$(dirname "$ARCHIVE_PATH")"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  cat > "$ARCHIVE_PATH" <<'EOF'
# Japanese Study Lookup Archive

A running archive of Japanese lookups so I can track what I had to ask about and later extract weak spots: vocabulary, grammar, phrasing, and recurring concepts.
EOF
fi

section_title() {
  case "$1" in
    word) echo "### Word lookups" ;;
    translate) echo "### Translation lookups" ;;
    grammar) echo "### Grammar lookups" ;;
    phrase) echo "### Phrase lookups" ;;
    *) echo "### Other lookups" ;;
  esac
}

SECTION="$(section_title "$KIND")"
ENTRY_KEY="- **$QUERY**"
if grep -Fq -- "$ENTRY_KEY" "$ARCHIVE_PATH"; then
  echo "EXISTS: $QUERY"
  exit 0
fi

if ! grep -Fq -- "## $TODAY_UTC" "$ARCHIVE_PATH"; then
  cat >> "$ARCHIVE_PATH" <<EOF

## $TODAY_UTC

EOF
fi

if ! awk -v date_heading="## $TODAY_UTC" -v wanted="$SECTION" '
  $0 == date_heading { in_date = 1; next }
  in_date && /^## / { in_date = 0 }
  in_date && $0 == wanted { found = 1 }
  END { exit found ? 0 : 1 }
' "$ARCHIVE_PATH"; then
  cat >> "$ARCHIVE_PATH" <<EOF
$SECTION

EOF
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

awk -v date_heading="## $TODAY_UTC" \
    -v section="$SECTION" \
    -v kind="$KIND" \
    -v query="$QUERY" \
    -v reading="$READING" \
    -v meaning="$MEANING" \
    -v concept_tags="$CONCEPT_TAGS" \
    -v details="$DETAILS" '
    BEGIN { inserted = 0; in_date = 0; in_section = 0 }
    {
      print $0
      if ($0 == date_heading) {
        in_date = 1
        next
      }
      if (in_date && $0 ~ /^## /) {
        in_date = 0
      }
      if (in_date && $0 == section) {
        in_section = 1
        next
      }
      if (in_section && ($0 ~ /^### / || $0 ~ /^## /) && inserted == 0) {
        print ""
        line = "- **" query "**"
        if (reading != "") line = line "（" reading "）"
        print line
        print "  - type: " kind
        if (meaning != "") print "  - meaning: " meaning
        if (concept_tags != "") print "  - concept tags: " concept_tags
        if (details != "") print "  - notes: " details
        inserted = 1
        in_section = 0
      }
    }
    END {
      if (in_section && inserted == 0) {
        print ""
        line = "- **" query "**"
        if (reading != "") line = line "（" reading "）"
        print line
        print "  - type: " kind
        if (meaning != "") print "  - meaning: " meaning
        if (concept_tags != "") print "  - concept tags: " concept_tags
        if (details != "") print "  - notes: " details
        inserted = 1
      }
      if (inserted == 0) exit 2
    }
' "$ARCHIVE_PATH" > "$TMP_FILE"

mv "$TMP_FILE" "$ARCHIVE_PATH"
echo "ADDED: $KIND -> $QUERY -> $ARCHIVE_PATH"
