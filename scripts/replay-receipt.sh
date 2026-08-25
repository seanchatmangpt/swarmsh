#!/usr/bin/env bash

# Replay a SwarmSH core-verification receipt against the current checkout identity.

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DEFAULT_RECEIPT="${SWARMSH_TEST_REPORT_DIR:-$ROOT/.swarmsh-test-results}/core-verification.json"
readonly RECEIPT="${1:-$DEFAULT_RECEIPT}"

if [[ ! -f "$RECEIPT" ]]; then
    echo "receipt not found: $RECEIPT" >&2
    exit 2
fi

jq -e '.schema == "swarmsh.verify-core.v1"' "$RECEIPT" >/dev/null || {
    echo "unsupported receipt schema" >&2
    exit 2
}

readonly EXPECTED_SHA="$(jq -r '.subject_sha' "$RECEIPT")"
readonly EXPECTED_TREE="$(jq -r '.tree_sha' "$RECEIPT")"
readonly RECEIPT_STATUS="$(jq -r '.status' "$RECEIPT")"
readonly CURRENT_SHA="$(git -C "$ROOT" rev-parse HEAD)"
readonly CURRENT_TREE="$(git -C "$ROOT" rev-parse HEAD^{tree})"

standing="ALIVE"
reason="receipt identity matches current checkout"

if [[ "$RECEIPT_STATUS" != "passed" ]]; then
    standing="BUILD_BROKEN"
    reason="receipt itself records failed verification"
elif [[ "$EXPECTED_SHA" != "$CURRENT_SHA" || "$EXPECTED_TREE" != "$CURRENT_TREE" ]]; then
    standing="UNKNOWN"
    reason="receipt subject identity does not match current checkout"
fi

jq -n \
    --arg schema "swarmsh.replay.v1" \
    --arg standing "$standing" \
    --arg reason "$reason" \
    --arg receipt "$RECEIPT" \
    --arg expected_sha "$EXPECTED_SHA" \
    --arg current_sha "$CURRENT_SHA" \
    --arg expected_tree "$EXPECTED_TREE" \
    --arg current_tree "$CURRENT_TREE" \
    '{schema:$schema,standing:$standing,reason:$reason,receipt:$receipt,expected_sha:$expected_sha,current_sha:$current_sha,expected_tree:$expected_tree,current_tree:$current_tree}'

[[ "$standing" == "ALIVE" ]]
