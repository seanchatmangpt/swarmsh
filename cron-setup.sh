#!/usr/bin/env bash

# SwarmSH cron lifecycle manager.
# Generates tagged, reversible cron entries and never overwrites unrelated jobs.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CRON_TAG="SWARMSH_8020"
readonly BACKUP_DIR="${SWARMSH_CRON_BACKUP_DIR:-$SCRIPT_DIR/.swarmsh-runtime/cron-backups}"

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { echo -e "${BLUE}[CRON-SETUP]${NC} $*"; }
log_success() { echo -e "${GREEN}✅${NC} $*"; }
log_warn() { echo -e "${YELLOW}⚠️${NC} $*"; }
log_error() { echo -e "${RED}❌${NC} $*" >&2; }

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        log_error "Missing required command: $1"
        return 1
    }
}

backup_crontab() {
    mkdir -p "$BACKUP_DIR"
    local backup_file="$BACKUP_DIR/crontab_$(date +%Y%m%d_%H%M%S).txt"
    crontab -l > "$backup_file" 2>/dev/null || :
    log_success "Crontab receipt: $backup_file"
    printf '%s\n' "$backup_file"
}

generate_cron_jobs() {
    cat <<EOF
# SwarmSH managed automation. Remove with: ./cron-setup.sh remove
0 */4 * * * "$SCRIPT_DIR/cron-telemetry-manager.sh" maintain >> "$SCRIPT_DIR/logs/telemetry_manager.log" 2>&1 # $CRON_TAG
0 */2 * * * "$SCRIPT_DIR/cron-health-monitor.sh" monitor >> "$SCRIPT_DIR/logs/health_monitor.log" 2>&1 # $CRON_TAG
0 3 * * * "$SCRIPT_DIR/coordination_helper.sh" optimize_work_claims_performance >> "$SCRIPT_DIR/logs/work_archival.log" 2>&1 # $CRON_TAG
0 */6 * * * "$SCRIPT_DIR/cron-performance-collector.sh" collect >> "$SCRIPT_DIR/logs/performance_collector.log" 2>&1 # $CRON_TAG
0 */8 * * * "$SCRIPT_DIR/autonomous_decision_engine.sh" analyze >> "$SCRIPT_DIR/logs/autonomous_decisions.log" 2>&1 # $CRON_TAG
0 2 * * 0 find "$SCRIPT_DIR/logs" -name '*.log' -size +50M -exec mv {} {}.old \; && find "$SCRIPT_DIR/logs" -name '*.log.old' -mtime +7 -delete # $CRON_TAG
EOF
}

validate_managed_scripts() {
    local missing=0
    local path
    for path in \
        cron-telemetry-manager.sh \
        cron-health-monitor.sh \
        cron-performance-collector.sh \
        coordination_helper.sh \
        autonomous_decision_engine.sh; do
        if [[ ! -f "$SCRIPT_DIR/$path" ]]; then
            log_error "Managed command missing: $path"
            missing=1
        fi
    done
    return "$missing"
}

untagged_crontab() {
    crontab -l 2>/dev/null | grep -v "# $CRON_TAG" || true
}

install_cron_jobs() {
    require_command crontab
    validate_managed_scripts
    mkdir -p "$SCRIPT_DIR/logs"
    backup_crontab >/dev/null

    local current_file next_file
    current_file="$(mktemp)"
    next_file="$(mktemp)"
    trap 'rm -f "$current_file" "$next_file"' RETURN

    untagged_crontab > "$current_file"
    {
        cat "$current_file"
        [[ ! -s "$current_file" ]] || echo
        generate_cron_jobs
    } > "$next_file"

    crontab "$next_file"
    log_success "Installed tagged SwarmSH cron jobs"
}

remove_cron_jobs() {
    require_command crontab
    backup_crontab >/dev/null
    local next_file
    next_file="$(mktemp)"
    trap 'rm -f "$next_file"' RETURN
    untagged_crontab > "$next_file"
    crontab "$next_file"
    log_success "Removed tagged SwarmSH cron jobs"
}

list_cron_jobs() {
    require_command crontab
    if ! crontab -l 2>/dev/null | grep "# $CRON_TAG"; then
        log_warn "No managed SwarmSH cron jobs found"
    fi
}

file_mtime_epoch() {
    local path="$1"
    stat -f '%m' "$path" 2>/dev/null || stat -c '%Y' "$path" 2>/dev/null || return 1
}

check_cron_status() {
    require_command crontab
    local managed_count
    managed_count="$(crontab -l 2>/dev/null | grep -c "# $CRON_TAG" || true)"
    echo "managed_jobs=$managed_count"

    local file timestamp hours_ago
    for file in telemetry_manager.log health_monitor.log performance_collector.log autonomous_decisions.log; do
        if [[ -f "$SCRIPT_DIR/logs/$file" ]] && timestamp="$(file_mtime_epoch "$SCRIPT_DIR/logs/$file")"; then
            hours_ago=$(( ($(date +%s) - timestamp) / 3600 ))
            printf '%s last_run_hours_ago=%s\n' "$file" "$hours_ago"
        else
            printf '%s last_run=never\n' "$file"
        fi
    done
}

test_cron_jobs() {
    validate_managed_scripts
    "$SCRIPT_DIR/cron-telemetry-manager.sh" maintain
    "$SCRIPT_DIR/cron-health-monitor.sh" monitor
    "$SCRIPT_DIR/cron-performance-collector.sh" collect
    log_success "Managed commands executed successfully"
}

usage() {
    cat <<EOF
SwarmSH Cron Setup

Usage: $0 <command>

Commands:
  install   Back up existing crontab and install tagged SwarmSH jobs
  remove    Back up existing crontab and remove only tagged SwarmSH jobs
  list      List tagged SwarmSH jobs
  status    Report managed-job count and recent log activity
  test      Execute managed maintenance commands without editing crontab
  backup    Save the current crontab under .swarmsh-runtime/cron-backups
  render    Print the managed cron fragment without changing the system
  help      Show this help
EOF
}

main() {
    case "${1:-help}" in
        install) install_cron_jobs ;;
        remove) remove_cron_jobs ;;
        list) list_cron_jobs ;;
        status) check_cron_status ;;
        test) test_cron_jobs ;;
        backup) require_command crontab; backup_crontab >/dev/null ;;
        render) generate_cron_jobs ;;
        help|--help|-h) usage ;;
        *) log_error "Unknown command: $1"; usage; return 2 ;;
    esac
}

main "$@"
