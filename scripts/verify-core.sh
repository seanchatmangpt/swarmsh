#!/usr/bin/env bash

# Deterministic release gate for SwarmSH's admitted core.
# This verifier does not install cron jobs, start daemons, or mutate external systems.

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly RECEIPT_DIR="${SWARMSH_TEST_REPORT_DIR:-$ROOT/.swarmsh-test-results}"
readonly RECEIPT="$RECEIPT_DIR/core-verification.json"
readonly START_NS="$(date +%s%N)"

mkdir -p "$RECEIPT_DIR"

passes=0
failures=0
checks='[]'

record() {
    local name="$1" status="$2" detail="$3"
    checks="$(jq --arg name "$name" --arg status "$status" --arg detail "$detail" '. + [{name:$name,status:$status,detail:$detail}]' <<<"$checks")"
    if [[ "$status" == "passed" ]]; then
        passes=$((passes + 1))
    else
        failures=$((failures + 1))
    fi
}

run_check() {
    local name="$1"
    shift
    local output rc
    set +e
    output="$("$@" 2>&1)"
    rc=$?
    set -e
    if [[ "$rc" -eq 0 ]]; then
        record "$name" passed "${output:-ok}"
        printf '✓ %s\n' "$name"
    else
        record "$name" failed "exit=$rc ${output}"
        printf '✗ %s\n' "$name" >&2
    fi
}

require_tools() {
    command -v bash >/dev/null
    command -v jq >/dev/null
    command -v python3 >/dev/null
    command -v git >/dev/null
}

syntax_core() {
    bash -n \
        "$ROOT/swarmsh" \
        "$ROOT/coordination_helper.sh" \
        "$ROOT/real_agent_coordinator.sh" \
        "$ROOT/test-essential.sh" \
        "$ROOT/cron-setup.sh" \
        "$ROOT/lib/s2s-env.sh" \
        "$ROOT/scripts/preflight.sh" \
        "$ROOT/scripts/verify-core.sh"
}

environment_contract() {
    (
        cd "$ROOT"
        # shellcheck disable=SC1091
        source ./lib/s2s-env.sh
        [[ "$S2S_ROOT" == "$ROOT" ]]
        [[ "$SWARMSH_ROOT" == "$ROOT" ]]
        [[ "$PROJECT_ROOT" == "$ROOT" ]]
    )
}

cli_read_only_routes() {
    local version doctor render
    version="$(bash "$ROOT/swarmsh" version)"
    doctor="$(bash "$ROOT/swarmsh" doctor)"
    render="$(bash "$ROOT/swarmsh" cron render)"

    grep -q '^swarmsh ' <<<"$version"
    jq -e '.schema == "swarmsh.preflight.v1" and (.standing == "ALIVE" or .standing == "PARTIAL_ALIVE")' <<<"$doctor" >/dev/null
    grep -q 'SWARMSH_8020' <<<"$render"
}

cron_construct_only() {
    local rendered
    rendered="$(bash "$ROOT/cron-setup.sh" render)"
    grep -q 'SWARMSH_8020' <<<"$rendered"
    grep -q 'coordination_helper.sh' <<<"$rendered"
}

source_hygiene() {
    local path
    for path in swarmsh test-essential.sh scripts/preflight.sh scripts/verify-core.sh; do
        ! git -C "$ROOT" check-ignore -q "$path"
    done
}

working_tree_unchanged() {
    git -C "$ROOT" diff --quiet -- . ':!.swarmsh-test-results'
}

main() {
    cd "$ROOT"
    run_check tools require_tools
    run_check bash-syntax syntax_core
    run_check environment-contract environment_contract
    run_check cli-read-only-routes cli_read_only_routes
    run_check cron-construct-only cron_construct_only
    run_check source-hygiene source_hygiene
    run_check essential-suite env SWARMSH_TEST_REPORT_DIR="$RECEIPT_DIR" bash "$ROOT/test-essential.sh"
    run_check repository-not-mutated working_tree_unchanged

    local end_ns duration_ms subject_sha tree_sha status
    end_ns="$(date +%s%N)"
    duration_ms=$(( (end_ns - START_NS) / 1000000 ))
    subject_sha="$(git rev-parse HEAD 2>/dev/null || echo unknown)"
    tree_sha="$(git rev-parse HEAD^{tree} 2>/dev/null || echo unknown)"
    status=passed
    [[ "$failures" -eq 0 ]] || status=failed

    jq -n \
        --arg schema "swarmsh.verify-core.v1" \
        --arg subject_sha "$subject_sha" \
        --arg tree_sha "$tree_sha" \
        --arg status "$status" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson duration_ms "$duration_ms" \
        --argjson passes "$passes" \
        --argjson failures "$failures" \
        --argjson checks "$checks" \
        '{schema:$schema,subject_sha:$subject_sha,tree_sha:$tree_sha,status:$status,timestamp:$timestamp,duration_ms:$duration_ms,passes:$passes,failures:$failures,checks:$checks}' \
        > "$RECEIPT"

    echo "receipt=$RECEIPT"
    [[ "$failures" -eq 0 ]]
}

main "$@"
