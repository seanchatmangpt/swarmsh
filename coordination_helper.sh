#!/usr/bin/env bash
# SwarmSH v26.8.25 coordination facade.
#
# This is the stable authority boundary in front of the legacy command surface.
# Canonical lifecycle state is authoritative; fast JSONL is an explicit projection.
# AI/model commands may SELECT or analyze, but combined SELECT+DO is refused.

set -euo pipefail

readonly SWARMSH_COORDINATION_RELEASE="26.8.25"
readonly ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LEGACY="$ROOT/lib/coordination-legacy.sh"
readonly ENV_CONTRACT="$ROOT/lib/s2s-env.sh"

if [[ ! -f "$LEGACY" ]]; then
    printf 'REFUSED: missing legacy coordination implementation: %s\n' "$LEGACY" >&2
    exit 66
fi

# Resolve one portable repository/state contract before entering the implementation.
# shellcheck disable=SC1090
source "$ENV_CONTRACT"

command_name="${1:-help}"
shift || true

case "$command_name" in
    claim)
        # v26.8.25: canonical JSON is the lifecycle source of truth. The former
        # default fast path wrote only a JSONL cache that progress/complete could
        # not consume, splitting one lifecycle across two incompatible truths.
        exec "$LEGACY" claim-slow "$@"
        ;;
    claim-fast)
        # Explicit opt-in projection retained for compatibility/benchmarking.
        exec "$LEGACY" claim-fast "$@"
        ;;
    claim-intelligent|claim-ai)
        # A model may propose/select work, but selection and consequential claim
        # admission must be separate transitions with separate evidence.
        jq -n \
            --arg schema "swarmsh.refusal.v1" \
            --arg release "$SWARMSH_COORDINATION_RELEASE" \
            --arg command "$command_name" \
            --arg reason "SELECT_DO_COLLAPSE" \
            --arg next "run an analysis/select command, inspect its evidence, then invoke claim explicitly" \
            '{schema:$schema,standing:"REFUSED",release:$release,command:$command,reason:$reason,next:$next}' >&2
        exit 64
        ;;
    *)
        exec "$LEGACY" "$command_name" "$@"
        ;;
esac
