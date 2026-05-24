#!/usr/bin/env bash
# Clones (or updates) projectdiscovery/nuclei-templates AND projectdiscovery/nuclei-templates-ai
# and produces three indexes covering BOTH:
#   docs/upstream-index/cves.txt   — every CVE-ID covered by an official template
#   docs/upstream-index/ids.txt    — every template id (from "id:" field)
#   docs/upstream-index/tags.txt   — every tag (from "tags:" field), de-duped
# Output paths are gitignored (docs/ is in .gitignore).
set -euo pipefail

CACHE_DIR="${CACHE_DIR:-/tmp/nuclei-templates-cache}"
AI_CACHE_DIR="${AI_CACHE_DIR:-/tmp/nuclei-templates-ai-cache}"
REPO_URL="https://github.com/projectdiscovery/nuclei-templates.git"
AI_REPO_URL="https://github.com/projectdiscovery/nuclei-templates-ai.git"
INDEX_DIR="docs/upstream-index"

clone_or_update() {
  local repo_url="$1"
  local dir="$2"
  if [[ ! -d "$dir/.git" ]]; then
    echo "Cloning $repo_url into $dir ..."
    git clone --depth=1 "$repo_url" "$dir"
  else
    echo "Updating $dir ..."
    git -C "$dir" pull --ff-only
  fi
}

clone_or_update "$REPO_URL" "$CACHE_DIR"
clone_or_update "$AI_REPO_URL" "$AI_CACHE_DIR"

mkdir -p "$INDEX_DIR"

echo "Building CVE index (both upstream repos) ..."
# CVE IDs appear in cves/ filenames AND in classification.cve-id fields.
{
  find "$CACHE_DIR" "$AI_CACHE_DIR" -type f -name 'CVE-*.yaml' -printf '%f\n' | sed 's/\.yaml$//'
  grep -rhoE 'CVE-[0-9]{4}-[0-9]+' "$CACHE_DIR" "$AI_CACHE_DIR" 2>/dev/null || true
} | sort -u > "$INDEX_DIR/cves.txt"

echo "Building id index (both upstream repos) ..."
grep -rhE '^id:[[:space:]]*[A-Za-z0-9_.-]+' "$CACHE_DIR" "$AI_CACHE_DIR" 2>/dev/null \
  | sed -E 's/^id:[[:space:]]*//' \
  | sort -u > "$INDEX_DIR/ids.txt" || true

echo "Building tag index (both upstream repos) ..."
# tags: appear as comma-separated strings; split on commas + strip whitespace.
# Heuristic: lines beginning with optional whitespace then "tags:" capture
# top-level template tags. Inline-flow YAML (e.g. metadata: { tags: ... })
# would not match because "tags:" isn't at the start of a logical line.
grep -rhE '^[[:space:]]*tags:' "$CACHE_DIR" "$AI_CACHE_DIR" \
  | sed -E 's/^[[:space:]]*tags:[[:space:]]*//' \
  | tr ',' '\n' \
  | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' \
  | grep -vE '^$' | sort -u > "$INDEX_DIR/tags.txt"

echo "Done."
wc -l "$INDEX_DIR"/cves.txt "$INDEX_DIR"/ids.txt "$INDEX_DIR"/tags.txt
