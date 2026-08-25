#!/usr/bin/env bash
# SwarmSH environment contract.
# Resolves repository and coordination paths without workstation-specific fallbacks.

set -o pipefail

_s2s_env_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_s2s_repo_candidate="$(cd "$_s2s_env_dir/.." && pwd)"

detect_s2s_root() {
    if [[ -n "${SWARMSH_ROOT:-}" && -d "$SWARMSH_ROOT" ]]; then
        (cd "$SWARMSH_ROOT" && pwd)
        return 0
    fi

    if [[ -f "$_s2s_repo_candidate/coordination_helper.sh" && -f "$_s2s_repo_candidate/CLAUDE.md" ]]; then
        printf '%s\n' "$_s2s_repo_candidate"
        return 0
    fi

    local current="$PWD"
    local depth=0
    while [[ "$current" != "/" && "$depth" -lt 10 ]]; do
        if [[ -f "$current/coordination_helper.sh" && -f "$current/CLAUDE.md" ]]; then
            printf '%s\n' "$current"
            return 0
        fi
        current="$(dirname "$current")"
        depth=$((depth + 1))
    done

    printf '%s\n' "$PWD"
    return 1
}

get_coordination_dir() {
    if [[ -n "${COORDINATION_DIR:-}" ]]; then
        printf '%s\n' "$COORDINATION_DIR"
        return 0
    fi

    local root
    root="$(detect_s2s_root)" || true

    # SwarmSH stores coordination state at the repository root by default.
    # Callers can isolate state by exporting COORDINATION_DIR before invoking scripts.
    printf '%s\n' "$root"
}

get_project_path() {
    local target_path="${1:?target path required}"
    local root
    root="$(detect_s2s_root)" || return 1
    printf '%s/%s\n' "$root" "$target_path"
}

export_s2s_env() {
    local detected_root detected_coordination
    detected_root="$(detect_s2s_root)" || true
    detected_coordination="$(get_coordination_dir)"

    export S2S_ROOT="${S2S_ROOT:-$detected_root}"
    export SWARMSH_ROOT="${SWARMSH_ROOT:-$S2S_ROOT}"
    export PROJECT_ROOT="${PROJECT_ROOT:-$S2S_ROOT}"
    export COORDINATION_DIR="${COORDINATION_DIR:-$detected_coordination}"
}

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    export_s2s_env
fi
