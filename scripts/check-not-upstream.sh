#!/usr/bin/env bash
# Checks whether a Nuclei template id or CVE-id is already covered by
# projectdiscovery/nuclei-templates (per the locally built upstream index).
#
# Usage: scripts/check-not-upstream.sh <id-or-cve>
# Exit codes:
#   0  not in upstream  (safe to write)
#   1  already upstream (skip — don't duplicate)
#   2  usage error or missing index
set -euo pipefail

INDEX_DIR="${INDEX_DIR:-docs/upstream-index}"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <id-or-cve>" >&2
  exit 2
fi

ID="$1"

if [[ ! -f "$INDEX_DIR/cves.txt" || ! -f "$INDEX_DIR/ids.txt" ]]; then
  echo "Error: upstream index not found at $INDEX_DIR" >&2
  echo "Run scripts/build-upstream-index.sh first." >&2
  exit 2
fi

if [[ "$ID" =~ ^CVE-[0-9]{4}-[0-9]+$ ]]; then
  if grep -qxF "$ID" "$INDEX_DIR/cves.txt"; then
    echo "$ID already in upstream nuclei-templates"
    exit 1
  fi
  echo "$ID not in upstream — safe to write"
  exit 0
fi

if grep -qxF "$ID" "$INDEX_DIR/ids.txt"; then
  echo "$ID already in upstream nuclei-templates"
  exit 1
fi

echo "$ID not in upstream — safe to write"
exit 0
