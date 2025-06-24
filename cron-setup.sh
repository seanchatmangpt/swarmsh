#!/usr/bin/env bash

# Cron Setup - 80/20 Optimized Automation
# Sets up automated cron jobs for SwarmSH coordination system
# Focus on highest-value automation with minimal complexity

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CRON_BACKUP_FILE="$SCRIPT_DIR/crontab_backup_$(date +%Y%m%d_%H%M%S).txt"
readonly CRON_TAG="SWARMSH_8020"

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging
log_info() {
    echo -e "${BLUE}[CRON-SETUP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1"
}

# Backup existing crontab
backup_crontab() {
    log_info "Backing up existing crontab..."
    
    if crontab -l > "$CRON_BACKUP_FILE" 2>/dev/null; then
        log_success "Crontab backed up to: $CRON_BACKUP_FILE"
    else
        log_info "No existing crontab found"
        touch "$CRON_BACKUP_FILE"
    fi
}

# Generate cron jobs configuration
generate_cron_jobs() {
    cat <<EOF
# SwarmSH 80/20 Optimized Automation - Generated $(date)
# High-value automation jobs for coordination system

# Telemetry Management - Every 4 hours (ROI: 5.0)
# Prevents disk space issues, maintains performance
0 */4 * * * $SCRIPT_DIR/cron-telemetry-manager.sh maintain >> $SCRIPT_DIR/logs/telemetry_manager.log 2>&1 # $CRON_TAG

# System Health Monitoring - Every 2 hours (ROI: 4.5)
# Early issue detection, automated recovery
0 */2 * * * $SCRIPT_DIR/cron-health-monitor.sh monitor >> $SCRIPT_DIR/logs/health_monitor.log 2>&1 # $CRON_TAG

# Work Item Archival - Daily at 3 AM (ROI: 4.2)
# Keeps active datasets small, improves performance
0 3 * * * $SCRIPT_DIR/coordination_helper.sh optimize_work_claims_performance >> $SCRIPT_DIR/logs/work_archival.log 2>&1 # $CRON_TAG

# Performance Baseline Collection - Every 6 hours (ROI: 3.8)
# Continuous performance tracking and trend analysis
0 */6 * * * $SCRIPT_DIR/cron-performance-collector.sh collect >> $SCRIPT_DIR/logs/performance_collector.log 2>&1 # $CRON_TAG

# Autonomous Decision Engine - Every 8 hours (ROI: 3.5)
# System analysis and automated improvement recommendations
0 */8 * * * $SCRIPT_DIR/autonomous_decision_engine.sh analyze >> $SCRIPT_DIR/logs/autonomous_decisions.log 2>&1 # $CRON_TAG

# Log Rotation - Weekly on Sunday at 2 AM
# Manage log file sizes to prevent disk space issues
0 2 * * 0 find $SCRIPT_DIR/logs -name "*.log" -size +50M -exec mv {} {}.old \\; && find $SCRIPT_DIR/logs -name "*.log.old" -mtime +7 -delete # $CRON_TAG

EOF
}

# Install cron jobs
install_cron_jobs() {
    log_info "Installing SwarmSH cron jobs..."
    
    # Create logs directory
    mkdir -p "$SCRIPT_DIR/logs"
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR/cron-telemetry-manager.sh" "$SCRIPT_DIR/cron-health-monitor.sh" 2>/dev/null || true
    
    # Get existing crontab (excluding our entries)
    local existing_cron=""
    if crontab -l 2>/dev/null | grep -v "# $CRON_TAG" > /tmp/existing_cron.txt; then
        existing_cron=$(cat /tmp/existing_cron.txt)
    fi
    
    # Combine existing cron with new jobs
    {
        if [[ -n "$existing_cron" ]]; then
            echo "$existing_cron"
            echo ""
        fi
        generate_cron_jobs
    } | crontab -
    
    # Clean up
    rm -f /tmp/existing_cron.txt
    
    log_success "Cron jobs installed successfully"
}

# Remove SwarmSH cron jobs
remove_cron_jobs() {
    log_info "Removing SwarmSH cron jobs..."
    
    if crontab -l 2>/dev/null | grep -v "# $CRON_TAG" | crontab -; then
        log_success "SwarmSH cron jobs removed"
    else
        log_warn "No cron jobs to remove or error occurred"
    fi
}

# List SwarmSH cron jobs
list_cron_jobs() {
    log_info "Current SwarmSH cron jobs:"
    echo ""
    
    if crontab -l 2>/dev/null | grep "# $CRON_TAG"; then
        echo ""
        log_success "Found SwarmSH cron jobs"
    else
        log_warn "No SwarmSH cron jobs found"
    fi
}

# Check cron job status
check_cron_status() {
    log_info "Checking cron job status..."
    
    local log_dir="$SCRIPT_DIR/logs"
    local jobs_info=()
    
    # Check telemetry manager
    if [[ -f "$log_dir/telemetry_manager.log" ]]; then
        local last_run=$(stat -f%m "$log_dir/telemetry_manager.log" 2>/dev/null || stat -c%Y "$log_dir/telemetry_manager.log" 2>/dev/null || echo "0")
        local hours_ago=$(( ($(date +%s) - last_run) / 3600 ))
        jobs_info+=("Telemetry Manager: Last run ${hours_ago}h ago")
    else
        jobs_info+=("Telemetry Manager: Never run")
    fi
    
    # Check health monitor
    if [[ -f "$log_dir/health_monitor.log" ]]; then
        local last_run=$(stat -f%m "$log_dir/health_monitor.log" 2>/dev/null || stat -c%Y "$log_dir/health_monitor.log" 2>/dev/null || echo "0")
        local hours_ago=$(( ($(date +%s) - last_run) / 3600 ))
        jobs_info+=("Health Monitor: Last run ${hours_ago}h ago")
    else
        jobs_info+=("Health Monitor: Never run")
    fi
    
    # Check if cron daemon is running
    if pgrep -x cron >/dev/null 2>&1 || pgrep -x crond >/dev/null 2>&1; then
        log_success "Cron daemon is running"
    else
        log_warn "Cron daemon may not be running"
    fi
    
    echo ""
    printf '%s\n' "${jobs_info[@]}"
}

# Test cron jobs manually
test_cron_jobs() {
    log_info "Testing cron jobs manually..."
    
    local test_results=()
    
    # Test telemetry manager
    log_info "Testing telemetry manager..."
    if "$SCRIPT_DIR/cron-telemetry-manager.sh" maintain; then
        test_results+=("✅ Telemetry Manager: PASSED")
    else
        test_results+=("❌ Telemetry Manager: FAILED")
    fi
    
    # Test health monitor
    log_info "Testing health monitor..."
    if "$SCRIPT_DIR/cron-health-monitor.sh" monitor; then
        test_results+=("✅ Health Monitor: PASSED")
    else
        test_results+=("❌ Health Monitor: FAILED")
    fi
    
    echo ""
    log_info "Test Results:"
    printf '%s\n' "${test_results[@]}"
}

# Generate performance collector if it doesn't exist
generate_performance_collector() {
    local collector_file="$SCRIPT_DIR/cron-performance-collector.sh"
    
    if [[ ! -f "$collector_file" ]]; then
        log_info "Creating performance collector..."
        
        cat > "$collector_file" <<'EOF'
#!/usr/bin/env bash
# Simple performance collector for cron
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "perf_$(date +%s%N)")"

case "${1:-collect}" in
    "collect")
        # Basic performance metrics collection
        WORK_COUNT=$(jq 'length' "$SCRIPT_DIR/work_claims.json" 2>/dev/null || echo "0")
        TELEMETRY_SIZE=$(stat -f%z "$SCRIPT_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        ACTIVE_AGENTS=$(jq '[.[] | select(.status == "active")] | length' "$SCRIPT_DIR/agent_status.json" 2>/dev/null || echo "0")
        
        METRICS="{\"work_items\":$WORK_COUNT,\"telemetry_size\":$TELEMETRY_SIZE,\"active_agents\":$ACTIVE_AGENTS,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
        
        echo "{\"trace_id\":\"$TRACE_ID\",\"operation\":\"performance_collection\",\"service\":\"cron-performance-collector\",\"status\":\"completed\",\"metrics\":$METRICS}" >> "$SCRIPT_DIR/telemetry_spans.jsonl"
        ;;
esac
EOF
        
        chmod +x "$collector_file"
        log_success "Performance collector created"
    fi
}

# Main execution
main() {
    local command="${1:-help}"
    
    case "$command" in
        "install")
            echo -e "${BLUE}SwarmSH 80/20 Cron Setup${NC}"
            echo "========================="
            echo ""
            
            backup_crontab
            generate_performance_collector
            install_cron_jobs
            
            echo ""
            log_success "SwarmSH automation installed!"
            echo ""
            echo "Installed automation jobs:"
            echo "  • Telemetry management (every 4h)"
            echo "  • System health monitoring (every 2h)"  
            echo "  • Work item archival (daily)"
            echo "  • Performance collection (every 6h)"
            echo "  • Autonomous decisions (every 8h)"
            echo "  • Log rotation (weekly)"
            echo ""
            log_info "Use '$0 status' to monitor job execution"
            log_info "Use '$0 test' to verify jobs work correctly"
            ;;
        "remove")
            backup_crontab
            remove_cron_jobs
            log_success "SwarmSH cron jobs removed"
            ;;
        "list")
            list_cron_jobs
            ;;
        "status")
            check_cron_status
            ;;
        "test")
            test_cron_jobs
            ;;
        "backup")
            backup_crontab
            log_success "Crontab backed up to: $CRON_BACKUP_FILE"
            ;;
        "help")
            cat <<EOF
SwarmSH Cron Setup - 80/20 Optimized Automation

Usage: $0 [command]

Commands:
  install     - Install SwarmSH cron jobs (default)
  remove      - Remove all SwarmSH cron jobs
  list        - List current SwarmSH cron jobs
  status      - Check cron job execution status
  test        - Test cron jobs manually
  backup      - Backup current crontab
  help        - Show this help

80/20 Automation Features:
  • Telemetry Management (every 4h) - ROI: 5.0
  • Health Monitoring (every 2h) - ROI: 4.5  
  • Work Archival (daily) - ROI: 4.2
  • Performance Collection (every 6h) - ROI: 3.8
  • Autonomous Decisions (every 8h) - ROI: 3.5
  • Log Rotation (weekly)

The 20% of automation that provides 80% of operational value.

Examples:
  $0 install          # Set up all automation
  $0 status           # Check job status
  $0 test             # Verify jobs work
  $0 remove           # Clean removal
EOF
            ;;
        *)
            log_error "Unknown command: $command"
            $0 help
            exit 1
            ;;
    esac
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command -v crontab >/dev/null 2>&1; then
        missing_deps+=("crontab")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        echo "Please install missing dependencies and try again"
        exit 1
    fi
}

# Pre-flight checks
check_dependencies

# Ensure scripts exist
if [[ ! -f "$SCRIPT_DIR/cron-telemetry-manager.sh" ]]; then
    log_error "cron-telemetry-manager.sh not found"
    exit 1
fi

if [[ ! -f "$SCRIPT_DIR/cron-health-monitor.sh" ]]; then
    log_error "cron-health-monitor.sh not found"
    exit 1
fi

# Run main function
main "$@"