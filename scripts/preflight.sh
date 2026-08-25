#!/usr/bin/env bash

# Read-only SwarmSH environment preflight.

set -euo pipefail

readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

checks='[]'
required_failures=0
optional_missing=0

probe() {
    local name="$1" requirement="$2" command="$3"
    local status detail

    if command -v "$command" >/dev/null 2>&1; then
        status="available"
        detail="$(command -v "$command")"
    else
        status="missing"
        detail="not found in PATH"
        if [[ "$requirement" == "required" ]]; then
            required_failures=$((required_failures + 1))
        else
            optional_missing=$((optional_missing + 1))
        fi
    fi

    checks="$(jq --arg name "$name" --arg requirement "$requirement" --arg status "$status" --arg detail "$detail" '. + [{name:$name,requirement:$requirement,status:$status,detail:$detail}]' <<<"$checks")"
}

file_probe() {
    local name="$1" requirement="$2" path="$3"
    local status detail

    if [[ -f "$path" ]]; then
        status="available"
        detail="$path"
    else
        status="missing"
        detail="$path"
        if [[ "$requirement" == "required" ]]; then
            required_failures=$((required_failures + 1))
        else
            optional_missing=$((optional_missing + 1))
        fi
    fi

    checks="$(jq --arg name "$name" --arg requirement "$requirement" --arg status "$status" --arg detail "$detail" '. + [{name:$name,requirement:$requirement,status:$status,detail:$detail}]' <<<"$checks")"
}

main() {
    # jq is needed to manufacture the machine-readable preflight itself.
    if ! command -v jq >/dev/null 2>&1; then
        echo '{"schema":"swarmsh.preflight.v1","standing":"BLOCKED","reason":"jq is required for preflight output"}'
        return 1
    fi

    probe bash required bash
    probe jq required jq
    probe python3 required python3
    probe git required git
    probe openssl optional openssl
    probe flock optional flock
    probe crontab optional crontab
    probe shellcheck optional shellcheck

    file_probe coordinator required "$ROOT/coordination_helper.sh"
    file_probe environment required "$ROOT/lib/s2s-env.sh"
    file_probe verifier required "$ROOT/scripts/verify-core.sh"
    file_probe cron optional "$ROOT/cron-setup.sh"

    local bash_major standing
    bash_major="${BASH_VERSION%%.*}"
    if [[ "$bash_major" -lt 4 ]]; then
        required_failures=$((required_failures + 1))
        checks="$(jq --arg version "$BASH_VERSION" '. + [{name:"bash-version",requirement:"required",status:"unsupported",detail:$version}]' <<<"$checks")"
    fi

    if [[ "$required_failures" -gt 0 ]]; then
        standing="BLOCKED"
    elif [[ "$optional_missing" -gt 0 ]]; then
        standing="PARTIAL_ALIVE"
    else
        standing="ALIVE"
    fi

    jq -n \
        --arg schema "swarmsh.preflight.v1" \
        --arg standing "$standing" \
        --arg root "$ROOT" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson required_failures "$required_failures" \
        --argjson optional_missing "$optional_missing" \
        --argjson checks "$checks" \
        '{schema:$schema,standing:$standing,root:$root,timestamp:$timestamp,required_failures:$required_failures,optional_missing:$optional_missing,checks:$checks}'

    [[ "$required_failures" -eq 0 ]]
}

main "$@"
