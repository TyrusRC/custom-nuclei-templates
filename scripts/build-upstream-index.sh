#!/usr/bin/env bash
# Clones (or updates) projectdiscovery/nuclei-templates and produces three indexes:
#   docs/upstream-index/cves.txt   — every CVE-ID covered by an official template
#   docs/upstream-index/ids.txt    — every template id (from "id:" field)
#   docs/upstream-index/tags.txt   — every tag (from "tags:" field), de-duped
# Output paths are gitignored (docs/ is in .gitignore).
set -euo pipefail

CACHE_DIR="${CACHE_DIR:-/tmp/nuclei-templates-cache}"
REPO_URL="https://github.com/projectdiscovery/nuclei-templates.git"
INDEX_DIR="docs/upstream-index"

if [[ ! -d "$CACHE_DIR/.git" ]]; then
  echo "Cloning $REPO_URL into $CACHE_DIR ..."
  git clone --depth=1 "$REPO_URL" "$CACHE_DIR"
else
  echo "Updating $CACHE_DIR ..."
  git -C "$CACHE_DIR" pull --ff-only
fi

mkdir -p "$INDEX_DIR"

echo "Building CVE index ..."
# CVE IDs appear in cves/ filenames AND in classification.cve-id fields.
{
  find "$CACHE_DIR" -type f -name 'CVE-*.yaml' -printf '%f\n' | sed 's/\.yaml$//'
  grep -rhoE 'CVE-[0-9]{4}-[0-9]+' "$CACHE_DIR" 2>/dev/null || true
} | sort -u > "$INDEX_DIR/cves.txt"

echo "Building id index ..."
grep -rhoE '^id:[[:space:]]*[A-Za-z0-9_.-]+' "$CACHE_DIR" \
  | awk '{print $2}' | sort -u > "$INDEX_DIR/ids.txt"

echo "Building tag index ..."
# tags: appear as comma-separated strings; split on commas + strip whitespace.
grep -rhE '^[[:space:]]*tags:' "$CACHE_DIR" \
  | sed -E 's/^[[:space:]]*tags:[[:space:]]*//' \
  | tr ',' '\n' \
  | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' \
  | grep -vE '^$' | sort -u > "$INDEX_DIR/tags.txt"

echo "Done."
wc -l "$INDEX_DIR"/cves.txt "$INDEX_DIR"/ids.txt "$INDEX_DIR"/tags.txt
