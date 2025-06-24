#!/bin/bash

##############################################################################
# 80/20 Cron Automation - High-Impact Scheduled Tasks
##############################################################################
#
# DESCRIPTION:
#   Implements the 20% of cron automation features that deliver 80% of the value.
#   Focuses on system health monitoring and work queue optimization.
#
# 80/20 PRIORITY FEATURES:
#   1. Health monitoring (prevents system failures)
#   2. Work queue optimization (maintains performance)
#   3. Metrics collection (provides visibility)
#
# USAGE:
#   ./8020_cron_automation.sh install    # Install cron jobs
#   ./8020_cron_automation.sh health     # Run health check
#   ./8020_cron_automation.sh optimize   # Run optimization
#   ./8020_cron_automation.sh metrics    # Collect metrics
#   ./8020_cron_automation.sh status     # Show cron status
#
##############################################################################

set -euo pipefail

# Source OpenTelemetry library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if source "${SCRIPT_DIR}/otel-bash.sh" 2>/dev/null; then
    # Use OTEL library functions
    generate_trace_id() { generate_id 16; }
    generate_span_id() { generate_id 8; }
    log_telemetry() { echo "$@" >> "${SCRIPT_DIR}/telemetry_spans.jsonl"; }
else
    # Fallback OTEL functions
    generate_trace_id() { openssl rand -hex 16 2>/dev/null || echo "$(date +%s%N)"; }
    generate_span_id() { openssl rand -hex 8 2>/dev/null || echo "$(date +%s%N | cut -c-16)"; }
    log_telemetry() { echo "$@" >> "${SCRIPT_DIR}/telemetry_spans.jsonl"; }
fi

# Configuration
COORDINATION_DIR="/Users/sac/dev/ai-self-sustaining-system/agent_coordination"
LOG_DIR="${SCRIPT_DIR}/logs"
CRON_LOG="${LOG_DIR}/8020_cron.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Generate telemetry for this operation
TRACE_ID=$(generate_trace_id)
operation_start_time=$(date +%s%N)

# Log function with telemetry
log_with_telemetry() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    echo "[$timestamp] [$level] $message" | tee -a "$CRON_LOG"
    
    # Log telemetry event
    local span_id=$(generate_span_id)
    log_telemetry "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$span_id\",\"operation\":\"8020_cron_log\",\"level\":\"$level\",\"message\":\"$message\",\"timestamp\":\"$timestamp\"}"
}

# 80/20 FEATURE 1: Health Monitoring (High Impact)
run_health_monitoring() {
    local span_id=$(generate_span_id)
    local start_time=$(date +%s%N)
    
    log_with_telemetry "INFO" "🏥 Starting 80/20 health monitoring"
    
    # Check coordination system health
    local health_score=100
    local issues=()
    
    # Check work claims file size (performance indicator)
    if [[ -f "$COORDINATION_DIR/work_claims.json" ]]; then
        local work_count=$(grep -c '"work_item_id":' "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo "0")
        if [[ $work_count -gt 100 ]]; then
            health_score=$((health_score - 20))
            issues+=("High work queue size: $work_count items")
        fi
    fi
    
    # Check fast-path file optimization
    if [[ -f "$COORDINATION_DIR/work_claims_fast.jsonl" ]]; then
        local fast_count=$(wc -l < "$COORDINATION_DIR/work_claims_fast.jsonl" 2>/dev/null || echo "0")
        if [[ $fast_count -gt 100 ]]; then
            health_score=$((health_score - 15))
            issues+=("Fast-path file needs optimization: $fast_count entries")
        fi
    fi
    
    # Check agent status file freshness
    if [[ -f "$COORDINATION_DIR/agent_status.json" ]]; then
        local agent_file_age=$(( $(date +%s) - $(stat -f%m "$COORDINATION_DIR/agent_status.json" 2>/dev/null || echo "0") ))
        if [[ $agent_file_age -gt 3600 ]]; then # 1 hour
            health_score=$((health_score - 10))
            issues+=("Agent status file stale: ${agent_file_age}s old")
        fi
    fi
    
    # Check disk space
    local disk_usage=$(df "$COORDINATION_DIR" | awk 'NR==2 {print $5}' | sed 's/%//' || echo "0")
    if [[ $disk_usage -gt 90 ]]; then
        health_score=$((health_score - 25))
        issues+=("High disk usage: ${disk_usage}%")
    fi
    
    # Report health status
    local status="healthy"
    if [[ $health_score -lt 70 ]]; then
        status="degraded"
        if [[ $health_score -lt 50 ]]; then
            status="critical"
        fi
    fi
    
    log_with_telemetry "INFO" "🏥 Health Score: $health_score/100 ($status)"
    
    if [[ ${#issues[@]} -gt 0 ]]; then
        for issue in "${issues[@]}"; do
            log_with_telemetry "WARN" "⚠️ Issue: $issue"
        done
    fi
    
    # Create health report
    local health_report="${LOG_DIR}/health_report_$(date +%Y%m%d_%H%M%S).json"
    cat > "$health_report" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "health_score": $health_score,
  "status": "$status",
  "issues": [$(if [[ ${#issues[@]} -gt 0 ]]; then printf '"%s",' "${issues[@]}" | sed 's/,$//'; fi)],
  "telemetry": {
    "trace_id": "$TRACE_ID",
    "span_id": "$span_id",
    "operation": "8020.health.monitoring"
  }
}
EOF
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    log_telemetry "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$span_id\",\"operation\":\"8020.health.monitoring\",\"duration_ms\":$duration_ms,\"health_score\":$health_score,\"status\":\"$status\",\"issues_count\":${#issues[@]}}"
    
    log_with_telemetry "INFO" "✅ Health monitoring complete (${duration_ms}ms) - Report: $health_report"
}

# 80/20 FEATURE 2: Work Queue Optimization (High Impact)
run_work_queue_optimization() {
    local span_id=$(generate_span_id) 
    local start_time=$(date +%s%N)
    
    log_with_telemetry "INFO" "⚡ Starting 80/20 work queue optimization"
    
    # Optimize fast-path files
    local optimizations=0
    
    if [[ -f "$COORDINATION_DIR/work_claims_fast.jsonl" ]]; then
        local fast_count=$(wc -l < "$COORDINATION_DIR/work_claims_fast.jsonl" 2>/dev/null || echo "0")
        if [[ $fast_count -gt 100 ]]; then
            log_with_telemetry "INFO" "🔄 Optimizing fast-path file ($fast_count entries)"
            tail -50 "$COORDINATION_DIR/work_claims_fast.jsonl" > "$COORDINATION_DIR/work_claims_fast.jsonl.tmp"
            mv "$COORDINATION_DIR/work_claims_fast.jsonl.tmp" "$COORDINATION_DIR/work_claims_fast.jsonl"
            optimizations=$((optimizations + 1))
            log_with_telemetry "INFO" "✅ Fast-path file optimized (kept latest 50 entries)"
        fi
    fi
    
    # Clean up completed work from main claims file
    if [[ -f "$COORDINATION_DIR/work_claims.json" ]] && command -v jq >/dev/null 2>&1; then
        local initial_count=$(jq 'length' "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo "0")
        if [[ $initial_count -gt 50 ]]; then
            log_with_telemetry "INFO" "🧹 Cleaning completed work from main claims file"
            jq '[.[] | select(.status != "completed")]' "$COORDINATION_DIR/work_claims.json" > "$COORDINATION_DIR/work_claims.json.tmp"
            mv "$COORDINATION_DIR/work_claims.json.tmp" "$COORDINATION_DIR/work_claims.json"
            local final_count=$(jq 'length' "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo "0")
            local removed=$((initial_count - final_count))
            if [[ $removed -gt 0 ]]; then
                optimizations=$((optimizations + 1))
                log_with_telemetry "INFO" "✅ Removed $removed completed work items"
            fi
        fi
    fi
    
    # Archive old telemetry data
    if [[ -f "${SCRIPT_DIR}/telemetry_spans.jsonl" ]]; then
        local telemetry_size=$(wc -l < "${SCRIPT_DIR}/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        if [[ $telemetry_size -gt 1000 ]]; then
            log_with_telemetry "INFO" "📦 Archiving telemetry data ($telemetry_size entries)"
            local archive_name="telemetry_archive_$(date +%Y%m%d_%H%M%S).jsonl"
            tail -500 "${SCRIPT_DIR}/telemetry_spans.jsonl" > "${SCRIPT_DIR}/telemetry_spans.jsonl.tmp"
            head -n -500 "${SCRIPT_DIR}/telemetry_spans.jsonl" > "${LOG_DIR}/$archive_name"
            mv "${SCRIPT_DIR}/telemetry_spans.jsonl.tmp" "${SCRIPT_DIR}/telemetry_spans.jsonl"
            optimizations=$((optimizations + 1))
            log_with_telemetry "INFO" "✅ Telemetry archived to $archive_name"
        fi
    fi
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    log_telemetry "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$span_id\",\"operation\":\"8020.work.optimization\",\"duration_ms\":$duration_ms,\"optimizations\":$optimizations}"
    
    log_with_telemetry "INFO" "✅ Work queue optimization complete (${duration_ms}ms) - Applied $optimizations optimizations"
}

# 80/20 FEATURE 3: Metrics Collection (Medium Impact)
run_metrics_collection() {
    local span_id=$(generate_span_id)
    local start_time=$(date +%s%N)
    
    log_with_telemetry "INFO" "📊 Starting 80/20 metrics collection"
    
    # Collect system metrics
    local metrics_file="${LOG_DIR}/metrics_$(date +%Y%m%d_%H%M%S).json"
    
    # Work queue metrics
    local active_work=0
    local pending_work=0
    local completed_work=0
    
    if [[ -f "$COORDINATION_DIR/work_claims.json" ]]; then
        active_work=$(grep -c '"status":"active"' "$COORDINATION_DIR/work_claims.json" 2>/dev/null | tr -d '\n' || echo "0")
        pending_work=$(grep -c '"status":"pending"' "$COORDINATION_DIR/work_claims.json" 2>/dev/null | tr -d '\n' || echo "0")
        completed_work=$(grep -c '"status":"completed"' "$COORDINATION_DIR/work_claims.json" 2>/dev/null | tr -d '\n' || echo "0")
    fi
    
    # Ensure numeric values and strip whitespace
    active_work=$(echo "${active_work:-0}" | tr -d '\n\r\t ')
    pending_work=$(echo "${pending_work:-0}" | tr -d '\n\r\t ')
    completed_work=$(echo "${completed_work:-0}" | tr -d '\n\r\t ')
    
    # Agent metrics
    local active_agents=0
    if [[ -f "$COORDINATION_DIR/agent_status.json" ]]; then
        active_agents=$(grep -c '"agent_id":' "$COORDINATION_DIR/agent_status.json" 2>/dev/null || echo "0")
    fi
    active_agents=${active_agents:-0}
    
    # Fast-path metrics
    local fast_path_entries=0
    if [[ -f "$COORDINATION_DIR/work_claims_fast.jsonl" ]]; then
        fast_path_entries=$(wc -l < "$COORDINATION_DIR/work_claims_fast.jsonl" 2>/dev/null || echo "0")
    fi
    fast_path_entries=${fast_path_entries:-0}
    
    # System metrics
    local disk_usage=$(df "$COORDINATION_DIR" | awk 'NR==2 {print $5}' | sed 's/%//' 2>/dev/null || echo "0")
    local load_avg=$(uptime | awk -F'load average:' '{ print $2 }' | awk '{ print $1 }' | sed 's/,//' 2>/dev/null || echo "0.0")
    disk_usage=${disk_usage:-0}
    load_avg=${load_avg:-0.0}
    
    # Create metrics report
    cat > "$metrics_file" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "work_queue": {
    "active": $active_work,
    "pending": $pending_work,
    "completed": $completed_work,
    "total": $((active_work + pending_work + completed_work))
  },
  "agents": {
    "active": $active_agents
  },
  "fast_path": {
    "entries": $fast_path_entries
  },
  "system": {
    "disk_usage_percent": $disk_usage,
    "load_average": "$load_avg"
  },
  "telemetry": {
    "trace_id": "$TRACE_ID",
    "span_id": "$span_id",
    "operation": "8020.metrics.collection"
  }
}
EOF
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    log_telemetry "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$span_id\",\"operation\":\"8020.metrics.collection\",\"duration_ms\":$duration_ms,\"active_work\":$active_work,\"active_agents\":$active_agents}"
    
    log_with_telemetry "INFO" "✅ Metrics collection complete (${duration_ms}ms) - Report: $metrics_file"
}

# Install cron jobs (80/20 scheduling)
install_cron_jobs() {
    log_with_telemetry "INFO" "🔧 Installing 80/20 cron automation jobs"
    
    # Create cron entries
    local cron_entries="
# 80/20 SwarmSH Automation (High-Impact Scheduled Tasks)
# Health monitoring every 15 minutes (prevents failures)
*/15 * * * * $SCRIPT_DIR/8020_cron_automation.sh health

# Work queue optimization every hour (maintains performance)  
0 * * * * $SCRIPT_DIR/8020_cron_automation.sh optimize

# Metrics collection every 30 minutes (provides visibility)
*/30 * * * * $SCRIPT_DIR/8020_cron_automation.sh metrics

# Daily cleanup at 3 AM (maintenance)
0 3 * * * $SCRIPT_DIR/auto_cleanup.sh
"
    
    # Add to crontab
    (crontab -l 2>/dev/null | grep -v "SwarmSH Automation" || true; echo "$cron_entries") | crontab -
    
    log_with_telemetry "INFO" "✅ Cron jobs installed - Health (15min), Optimize (1hr), Metrics (30min), Cleanup (daily)"
}

# Show cron status
show_cron_status() {
    log_with_telemetry "INFO" "📋 80/20 Cron Automation Status"
    
    echo "=== Current Cron Jobs ==="
    crontab -l | grep -A10 -B2 "SwarmSH Automation" || echo "No SwarmSH cron jobs found"
    
    echo ""
    echo "=== Recent Activity ==="
    if [[ -f "$CRON_LOG" ]]; then
        tail -10 "$CRON_LOG"
    else
        echo "No activity logs found"
    fi
    
    echo ""
    echo "=== System Health ==="
    if [[ -f "${LOG_DIR}/health_report_"*.json ]]; then
        local latest_health=$(ls -t "${LOG_DIR}"/health_report_*.json | head -1)
        echo "Latest health report: $latest_health"
        if command -v jq >/dev/null 2>&1; then
            jq '.health_score, .status, .issues' "$latest_health" 2>/dev/null || cat "$latest_health"
        fi
    else
        echo "No health reports found"
    fi
}

# Main command processing
main() {
    local operation_span_id=$(generate_span_id)
    
    case "${1:-status}" in
        "install")
            install_cron_jobs
            ;;
        "health")
            run_health_monitoring
            ;;
        "optimize")
            run_work_queue_optimization
            ;;
        "metrics")
            run_metrics_collection
            ;;
        "status")
            show_cron_status
            ;;
        *)
            echo "Usage: $0 {install|health|optimize|metrics|status}"
            echo ""
            echo "80/20 Cron Automation - High-Impact Scheduled Tasks"
            echo "  install  - Install cron jobs for automated operations"
            echo "  health   - Run health monitoring check"
            echo "  optimize - Run work queue optimization"
            echo "  metrics  - Collect system metrics"
            echo "  status   - Show cron automation status"
            exit 1
            ;;
    esac
    
    # Final telemetry
    local operation_end_time=$(date +%s%N)
    local total_duration_ms=$(( (operation_end_time - operation_start_time) / 1000000 ))
    
    log_telemetry "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$operation_span_id\",\"operation\":\"8020.cron.automation\",\"command\":\"${1:-status}\",\"total_duration_ms\":$total_duration_ms,\"status\":\"completed\"}"
}

# Run main function
main "$@"