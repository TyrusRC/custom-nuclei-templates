#!/usr/bin/env bats

setup() {
  export FIXTURE_DIR="$(mktemp -d)"
  mkdir -p "$FIXTURE_DIR/upstream-index"
  cat > "$FIXTURE_DIR/upstream-index/cves.txt" <<EOL
CVE-2024-12345
CVE-2024-99999
EOL
  cat > "$FIXTURE_DIR/upstream-index/ids.txt" <<EOL
existing-template
another-existing
EOL
  export INDEX_DIR="$FIXTURE_DIR/upstream-index"
}

teardown() {
  rm -rf "$FIXTURE_DIR"
}

@test "exits 0 when CVE is NOT in upstream index" {
  run ./scripts/check-not-upstream.sh CVE-2025-00001
  [ "$status" -eq 0 ]
  [[ "$output" == *"not in upstream"* ]]
}

@test "exits 1 when CVE IS in upstream index" {
  run ./scripts/check-not-upstream.sh CVE-2024-12345
  [ "$status" -eq 1 ]
  [[ "$output" == *"already in upstream"* ]]
}

@test "exits 0 when template id is NOT in upstream ids" {
  run ./scripts/check-not-upstream.sh brand-new-template
  [ "$status" -eq 0 ]
}

@test "exits 1 when template id IS in upstream ids" {
  run ./scripts/check-not-upstream.sh existing-template
  [ "$status" -eq 1 ]
}

@test "exits 2 when no argument provided" {
  run ./scripts/check-not-upstream.sh
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage"* ]]
}

@test "exits 2 when index files missing" {
  export INDEX_DIR="/nonexistent/path"
  run ./scripts/check-not-upstream.sh CVE-2025-00001
  [ "$status" -eq 2 ]
  [[ "$output" == *"index not found"* ]]
}
