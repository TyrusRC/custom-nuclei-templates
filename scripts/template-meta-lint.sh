#!/usr/bin/env bash
# Enforce repo-wide template metadata conventions:
#   1. First line must be "# gap: <id>"
#   2. The <id> in the gap line must equal the filename (without .yaml)
#   3. The id: field must equal the filename
#   4. author: TyrusRC
#   5. tags: must start with "custom"
#   6. No classification: block (we don't ship CVE-specific templates)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
while IFS= read -r f; do
  base=$(basename "$f" .yaml)
  errors=()

  first=$(head -n 1 "$f")
  if [[ ! "$first" =~ ^"# gap: "(.+)$ ]]; then
    errors+=("missing or malformed '# gap: <id>' first line")
  else
    gap_id="${BASH_REMATCH[1]}"
    [[ "$gap_id" != "$base" ]] && errors+=("gap id '$gap_id' != filename '$base'")
  fi

  id_field=$(awk '/^id:/{print $2; exit}' "$f")
  [[ "$id_field" != "$base" ]] && errors+=("id field '$id_field' != filename '$base'")

  if ! grep -qE '^[[:space:]]+author:[[:space:]]+TyrusRC[[:space:]]*$' "$f"; then
    errors+=("author is not TyrusRC")
  fi

  tags_line=$(awk '/^[[:space:]]+tags:/{print; exit}' "$f")
  if [[ -z "$tags_line" ]]; then
    errors+=("missing tags field")
  elif ! grep -qE '^[[:space:]]+tags:[[:space:]]+custom([,[:space:]]|$)' <<<"$tags_line"; then
    errors+=("tags does not start with 'custom'")
  fi

  if grep -qE '^[[:space:]]+classification:[[:space:]]*$' "$f"; then
    errors+=("classification: block present (CVE-specific templates were removed in the 2026-05-25 pivot)")
  fi

  if [[ ${#errors[@]} -gt 0 ]]; then
    echo "FAIL: $f"
    printf '  - %s\n' "${errors[@]}"
    fail=1
  fi
done < <(find templates -name '*.yaml')

if [[ $fail -eq 0 ]]; then
  echo "OK: all templates pass meta-lint ($(find templates -name '*.yaml' | wc -l) templates)"
fi
exit $fail
