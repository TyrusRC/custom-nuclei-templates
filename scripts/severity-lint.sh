#!/usr/bin/env bash
# Flag templates whose severity is miscalibrated.
# Rule: severity: critical requires a justifying keyword in the
# description (unauth RCE primitive, in-memory secret leak, full source
# disclosure, takeover, kernel/root execution). Otherwise demote to high.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

JUSTIFY_RE='(unauth.* (rce|code execution|command execution)|remote code execution|in[- ]memory (secret|credential|token)|heap dump|source (code )?(disclosure|files?)|tracked source|full source|account takeover|subdomain takeover|groovy.*(rce|console)|deserialization|sandbox escape|hypervisor|kernel|root (shell|execution)|arbitrary (file (read|write)|code|command)|auth(entication)?( has)?( been)? bypass(ed)?|bypass(es|ed)? .*(authentication|signature|allowlist|authorisation|authorization)|attacker-supplied identity|exec arbitrary|cluster[- ]admin|exposes.* (secret|credential)|leaks? .*(secret|credential|token))'

fail=0
while IFS= read -r f; do
  sev=$(awk '/^[[:space:]]*severity:/{print $2; exit}' "$f")
  [[ "$sev" != "critical" ]] && continue

  # Extract description block (info.description: | ... up to next top-level key)
  desc=$(awk '
    /^[[:space:]]*description:[[:space:]]*\|/{in_desc=1; next}
    in_desc && /^[[:space:]]{0,4}[a-z_-]+:/{in_desc=0}
    in_desc{print}
  ' "$f")

  if ! grep -qiE "$JUSTIFY_RE" <<<"$desc"; then
    echo "FAIL: $f — severity:critical but description lacks justifying keyword"
    fail=1
  fi
done < <(find templates -name '*.yaml')

if [[ $fail -eq 0 ]]; then
  echo "OK: all critical-severity templates have justifying keywords"
fi
exit $fail
