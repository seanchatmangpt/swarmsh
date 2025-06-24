#!/usr/bin/env bash

# System Health Monitor - 80/20 Optimized
# Automated health monitoring for coordination system
# Designed for cron execution with alerting and recovery

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "health_mon_$(date +%s%N)")"
readonly SPAN_ID="$(openssl rand -hex 8 2>/dev/null || echo "$(date +%s%N | cut -c-16)")"
readonly OPERATION_START=$(date +%s%N)

# Health monitoring configuration
readonly COORDINATION_FILES=("work_claims.json" "agent_status.json" "coordination_log.json")
readonly CRITICAL_SCRIPTS=("coordination_helper.sh" "real_agent_worker.sh")
readonly TELEMETRY_FILE="$SCRIPT_DIR/telemetry_spans.jsonl"
readonly HEALTH_REPORT_FILE="$SCRIPT_DIR/system_health_report.json"
readonly ALERT_THRESHOLD=70  # Health score below this triggers alerts

# Health check thresholds
readonly MAX_WORK_ITEMS=100
readonly MAX_STALE_HOURS=24
readonly MIN_COMPLETION_RATE=60
readonly MAX_ERROR_RATE=10

# Logging (redirect to stderr to avoid interfering with function returns)
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH] $1" >&2
}

log_warn() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $1" >&2
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

log_critical() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [CRITICAL] $1" >&2
}

# Generate health monitoring span
generate_health_span() {
    local operation=$1
    local status=$2
    local metrics=$3
    local duration=${4:-0}
    
    local span="{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"operation\":\"health_monitor.$operation\",\"service\":\"cron-health-monitor\",\"status\":\"$status\",\"duration_ms\":$duration,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"metrics\":$metrics}"
    
    echo "$span" >> "$TELEMETRY_FILE"
    echo "$span" >&2
}

# Check file system health
check_filesystem_health() {
    log_info "Checking filesystem health..."
    
    local fs_issues=0
    local file_health=()
    
    # Check coordination files
    for file in "${COORDINATION_FILES[@]}"; do
        local file_path="$SCRIPT_DIR/$file"
        local file_status="healthy"
        local file_size=0
        local file_age_hours=0
        
        if [[ ! -f "$file_path" ]]; then
            log_warn "Missing coordination file: $file"
            file_status="missing"
            ((fs_issues++))
        else
            file_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")
            file_age_hours=$(( ($(date +%s) - $(stat -f%m "$file_path" 2>/dev/null || stat -c%Y "$file_path" 2>/dev/null || echo "0")) / 3600 ))
            
            # Check if file is too old (stale)
            if [[ $file_age_hours -gt $MAX_STALE_HOURS ]]; then
                log_warn "Stale file detected: $file (${file_age_hours}h old)"
                file_status="stale"
                ((fs_issues++))
            fi
            
            # Validate JSON files
            if [[ "$file" == *.json ]] && command -v jq >/dev/null 2>&1; then
                if ! jq empty "$file_path" 2>/dev/null; then
                    log_error "Invalid JSON: $file"
                    file_status="invalid_json"
                    ((fs_issues++))
                fi
            fi
        fi
        
        file_health+=("{\"file\":\"$file\",\"status\":\"$file_status\",\"size_bytes\":$file_size,\"age_hours\":$file_age_hours}")
    done
    
    # Check script executability
    for script in "${CRITICAL_SCRIPTS[@]}"; do
        local script_path="$SCRIPT_DIR/$script"
        if [[ ! -f "$script_path" ]]; then
            log_error "Missing critical script: $script"
            ((fs_issues++))
        elif [[ ! -x "$script_path" ]]; then
            log_warn "Script not executable: $script"
            ((fs_issues++))
        fi
    done
    
    local file_health_json=$(printf '%s\n' "${file_health[@]}" | jq -s .)
    local metrics="{\"filesystem_issues\":$fs_issues,\"file_health\":$file_health_json,\"checked_files\":${#COORDINATION_FILES[@]},\"checked_scripts\":${#CRITICAL_SCRIPTS[@]}}"
    
    generate_health_span "filesystem_check" "completed" "$metrics" 150
    
    # Ensure clean numeric output
    fs_issues=$(echo "$fs_issues" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
    echo "$fs_issues"
}

# Check coordination system health
check_coordination_health() {
    log_info "Checking coordination system health..."
    
    local coord_issues=0
    local work_claims_file="$SCRIPT_DIR/work_claims.json"
    local agent_status_file="$SCRIPT_DIR/agent_status.json"
    
    # Default values
    local total_work=0
    local active_work=0
    local completed_work=0
    local failed_work=0
    local completion_rate=0
    local error_rate=0
    local active_agents=0
    
    # Analyze work claims
    if [[ -f "$work_claims_file" ]] && command -v jq >/dev/null 2>&1; then
        total_work=$(jq 'length' "$work_claims_file" 2>/dev/null || echo "0")
        active_work=$(jq '[.[] | select(.status == "active")] | length' "$work_claims_file" 2>/dev/null || echo "0")
        completed_work=$(jq '[.[] | select(.status == "completed")] | length' "$work_claims_file" 2>/dev/null || echo "0")
        failed_work=$(jq '[.[] | select(.status == "failed")] | length' "$work_claims_file" 2>/dev/null || echo "0")
        
        if [[ $total_work -gt 0 ]]; then
            completion_rate=$(( completed_work * 100 / total_work ))
            error_rate=$(( failed_work * 100 / total_work ))
        fi
        
        # Check for too many work items
        if [[ $total_work -gt $MAX_WORK_ITEMS ]]; then
            log_warn "High work item count: $total_work (max: $MAX_WORK_ITEMS)"
            ((coord_issues++))
        fi
        
        # Check completion rate
        if [[ $completion_rate -lt $MIN_COMPLETION_RATE ]] && [[ $total_work -gt 10 ]]; then
            log_warn "Low completion rate: ${completion_rate}% (min: ${MIN_COMPLETION_RATE}%)"
            ((coord_issues++))
        fi
        
        # Check error rate
        if [[ $error_rate -gt $MAX_ERROR_RATE ]]; then
            log_warn "High error rate: ${error_rate}% (max: ${MAX_ERROR_RATE}%)"
            ((coord_issues++))
        fi
    else
        log_warn "Cannot analyze work claims file"
        ((coord_issues++))
    fi
    
    # Analyze agent status
    if [[ -f "$agent_status_file" ]] && command -v jq >/dev/null 2>&1; then
        active_agents=$(jq '[.[] | select(.status == "active")] | length' "$agent_status_file" 2>/dev/null || echo "0")
        
        if [[ $active_agents -eq 0 ]] && [[ $active_work -gt 0 ]]; then
            log_warn "No active agents but active work exists"
            ((coord_issues++))
        fi
    fi
    
    local metrics="{\"coordination_issues\":$coord_issues,\"total_work\":$total_work,\"active_work\":$active_work,\"completed_work\":$completed_work,\"failed_work\":$failed_work,\"completion_rate\":$completion_rate,\"error_rate\":$error_rate,\"active_agents\":$active_agents}"
    
    generate_health_span "coordination_check" "completed" "$metrics" 200
    
    # Ensure clean numeric output
    coord_issues=$(echo "$coord_issues" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
    echo "$coord_issues"
}

# Check telemetry health
check_telemetry_health() {
    log_info "Checking telemetry health..."
    
    local telemetry_issues=0
    local telemetry_metrics="{}"
    
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        log_warn "Telemetry file missing"
        telemetry_metrics='{"status":"missing","size_bytes":0,"line_count":0,"recent_spans":0}'
        ((telemetry_issues++))
    else
        local file_size=$(stat -f%z "$TELEMETRY_FILE" 2>/dev/null || stat -c%s "$TELEMETRY_FILE" 2>/dev/null || echo "0")
        local line_count=$(wc -l < "$TELEMETRY_FILE" 2>/dev/null || echo "0")
        
        # Count recent spans (last hour)
        local recent_spans=0
        local current_hour=$(date +%Y-%m-%dT%H)
        if [[ $line_count -gt 0 ]]; then
            recent_spans=$(grep -c "$current_hour" "$TELEMETRY_FILE" 2>/dev/null || echo "0")
        fi
        recent_spans=${recent_spans:-0}
        
        # Ensure all variables are numeric only
        file_size=$(echo "$file_size" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
        line_count=$(echo "$line_count" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
        recent_spans=$(echo "$recent_spans" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
        
        telemetry_metrics="{\"status\":\"present\",\"size_bytes\":$file_size,\"line_count\":$line_count,\"recent_spans\":$recent_spans}"
        
        # Check for telemetry inactivity
        if [[ $recent_spans -eq 0 ]] && [[ $line_count -gt 0 ]]; then
            log_warn "No recent telemetry activity"
            ((telemetry_issues++))
        fi
        
        # Check for excessive telemetry size
        if [[ $file_size -gt 20971520 ]]; then  # 20MB
            log_warn "Large telemetry file: $file_size bytes"
            ((telemetry_issues++))
        fi
    fi
    
    local metrics="{\"telemetry_issues\":$telemetry_issues,\"telemetry_details\":$telemetry_metrics}"
    
    generate_health_span "telemetry_check" "completed" "$metrics" 100
    
    # Ensure clean numeric output
    telemetry_issues=$(echo "$telemetry_issues" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
    echo "$telemetry_issues"
}

# Check system resources
check_system_resources() {
    log_info "Checking system resources..."
    
    local resource_issues=0
    
    # Check disk space
    local disk_usage=$(df "$SCRIPT_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        log_critical "High disk usage: ${disk_usage}%"
        ((resource_issues++))
    elif [[ $disk_usage -gt 80 ]]; then
        log_warn "Moderate disk usage: ${disk_usage}%"
    fi
    
    # Check memory usage (if available)
    local memory_usage=0
    if command -v free >/dev/null 2>&1; then
        memory_usage=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS memory check
        local pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
        local pages_total=$(( $(vm_stat | grep "Pages free\|Pages active\|Pages inactive\|Pages speculative\|Pages wired down" | awk '{sum += $3} END {print sum}') ))
        if [[ $pages_total -gt 0 ]]; then
            memory_usage=$(( (pages_total - pages_free) * 100 / pages_total ))
        fi
    fi
    
    if [[ $memory_usage -gt 95 ]]; then
        log_critical "High memory usage: ${memory_usage}%"
        ((resource_issues++))
    elif [[ $memory_usage -gt 85 ]]; then
        log_warn "Moderate memory usage: ${memory_usage}%"
    fi
    
    local metrics="{\"resource_issues\":$resource_issues,\"disk_usage_percent\":$disk_usage,\"memory_usage_percent\":$memory_usage}"
    
    generate_health_span "resource_check" "completed" "$metrics" 100
    
    # Ensure clean numeric output
    resource_issues=$(echo "$resource_issues" | tr -d '\n\r\t ' | grep -o '^[0-9]*' || echo "0")
    echo "$resource_issues"
}

# Calculate overall health score
calculate_health_score() {
    local fs_issues=$1
    local coord_issues=$2
    local telemetry_issues=$3
    local resource_issues=$4
    
    # Ensure numeric values
    fs_issues=${fs_issues:-0}
    coord_issues=${coord_issues:-0}
    telemetry_issues=${telemetry_issues:-0}
    resource_issues=${resource_issues:-0}
    
    local total_issues=$((fs_issues + coord_issues + telemetry_issues + resource_issues))
    local base_score=100
    
    # Deduct points based on issue severity
    local fs_penalty=$((fs_issues * 15))
    local coord_penalty=$((coord_issues * 20))
    local telemetry_penalty=$((telemetry_issues * 10))
    local resource_penalty=$((resource_issues * 25))
    
    local health_score=$((base_score - fs_penalty - coord_penalty - telemetry_penalty - resource_penalty))
    
    # Ensure score doesn't go below 0
    if [[ $health_score -lt 0 ]]; then
        health_score=0
    fi
    
    echo "$health_score"
}

# Generate alert if needed
generate_alert() {
    local health_score=$1
    local issues_summary=$2
    
    if [[ $health_score -lt $ALERT_THRESHOLD ]]; then
        local alert_file="$SCRIPT_DIR/health_alert_$(date +%Y%m%d_%H%M%S).json"
        
        cat > "$alert_file" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "alert_type": "system_health",
    "severity": "$(if [[ $health_score -lt 50 ]]; then echo "critical"; elif [[ $health_score -lt 70 ]]; then echo "warning"; else echo "info"; fi)",
    "health_score": $health_score,
    "threshold": $ALERT_THRESHOLD,
    "issues_summary": $issues_summary,
    "trace_id": "$TRACE_ID",
    "recommended_actions": [
        "Review system health report",
        "Check coordination files",
        "Monitor resource usage",
        "Consider system maintenance"
    ]
}
EOF
        
        log_critical "Health alert generated: $alert_file (score: $health_score)"
        
        # Attempt to notify if notification system is available
        if command -v osascript >/dev/null 2>&1; then
            osascript -e "display notification \"System health score: $health_score\" with title \"SwarmSH Health Alert\"" 2>/dev/null || true
        fi
        
        echo "$alert_file"
    else
        echo ""
    fi
}

# Generate comprehensive health report
generate_health_report() {
    local health_score=$1
    local fs_issues=$2
    local coord_issues=$3
    local telemetry_issues=$4
    local resource_issues=$5
    local alert_file=$6
    
    log_info "Generating health report..."
    
    # Ensure numeric values
    fs_issues=${fs_issues:-0}
    coord_issues=${coord_issues:-0}
    telemetry_issues=${telemetry_issues:-0}
    resource_issues=${resource_issues:-0}
    
    local total_issues=$((fs_issues + coord_issues + telemetry_issues + resource_issues))
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    cat > "$HEALTH_REPORT_FILE" <<EOF
{
    "timestamp": "$current_time",
    "trace_id": "$TRACE_ID",
    "health_score": $health_score,
    "status": "$(if [[ $health_score -ge 90 ]]; then echo "excellent"; elif [[ $health_score -ge 75 ]]; then echo "good"; elif [[ $health_score -ge 50 ]]; then echo "fair"; else echo "poor"; fi)",
    "total_issues": $total_issues,
    "issue_breakdown": {
        "filesystem_issues": $fs_issues,
        "coordination_issues": $coord_issues,
        "telemetry_issues": $telemetry_issues,
        "resource_issues": $resource_issues
    },
    "alert_generated": $(if [[ -n "$alert_file" ]]; then echo "true"; else echo "false"; fi),
    "alert_file": "$(basename "${alert_file:-}")",
    "next_check_recommended": "$(date -d "+2 hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v+2H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "N/A")",
    "recommendations": $(if [[ $health_score -lt 80 ]]; then echo '["Schedule system maintenance", "Review error logs", "Check resource allocation"]'; else echo '["System is healthy", "Continue monitoring"]'; fi)
}
EOF
    
    local metrics="{\"health_score\":$health_score,\"total_issues\":$total_issues,\"alert_generated\":$(if [[ -n "$alert_file" ]]; then echo "true"; else echo "false"; fi)}"
    
    generate_health_span "health_report" "completed" "$metrics" 150
    
    log_info "Health report generated: $HEALTH_REPORT_FILE"
    echo "$HEALTH_REPORT_FILE"
}

# Main execution
main() {
    local command="${1:-monitor}"
    
    case "$command" in
        "monitor")
            log_info "Starting system health monitoring..."
            
            local fs_issues=$(check_filesystem_health)
            local coord_issues=$(check_coordination_health)
            local telemetry_issues=$(check_telemetry_health)
            local resource_issues=$(check_system_resources)
            
            local health_score=$(calculate_health_score "$fs_issues" "$coord_issues" "$telemetry_issues" "$resource_issues")
            local issues_summary="{\"filesystem\":$fs_issues,\"coordination\":$coord_issues,\"telemetry\":$telemetry_issues,\"resources\":$resource_issues}"
            
            local alert_file=$(generate_alert "$health_score" "$issues_summary")
            local report_file=$(generate_health_report "$health_score" "$fs_issues" "$coord_issues" "$telemetry_issues" "$resource_issues" "$alert_file")
            
            local operation_end=$(date +%s%N)
            local duration_ms=$(( (operation_end - OPERATION_START) / 1000000 ))
            
            # Ensure numeric values for final calculation
            fs_issues=${fs_issues:-0}
            coord_issues=${coord_issues:-0}
            telemetry_issues=${telemetry_issues:-0}
            resource_issues=${resource_issues:-0}
            health_score=${health_score:-0}
            
            local total_issues_final=$((fs_issues + coord_issues + telemetry_issues + resource_issues))
            local final_metrics="{\"health_score\":$health_score,\"total_issues\":$total_issues_final,\"duration_ms\":$duration_ms,\"alert_generated\":$(if [[ -n "$alert_file" ]]; then echo "true"; else echo "false"; fi)}"
            
            generate_health_span "monitoring_complete" "completed" "$final_metrics" "$duration_ms"
            
            log_info "Health monitoring completed: Score $health_score/100 in ${duration_ms}ms"
            
            # Exit with appropriate code
            if [[ $health_score -lt 50 ]]; then
                exit 2  # Critical
            elif [[ $health_score -lt $ALERT_THRESHOLD ]]; then
                exit 1  # Warning
            else
                exit 0  # OK
            fi
            ;;
        "status")
            if [[ -f "$HEALTH_REPORT_FILE" ]]; then
                jq -r '.health_score' "$HEALTH_REPORT_FILE" 2>/dev/null || echo "Unknown"
            else
                echo "No health report available"
            fi
            ;;
        "report")
            if [[ -f "$HEALTH_REPORT_FILE" ]]; then
                cat "$HEALTH_REPORT_FILE" | jq '.' 2>/dev/null || cat "$HEALTH_REPORT_FILE"
            else
                echo "No health report available - run monitor first"
                exit 1
            fi
            ;;
        "help")
            cat <<EOF
System Health Monitor - 80/20 Optimized Cron Automation

Usage: $0 [command]

Commands:
  monitor     - Full health monitoring cycle (default, for cron)
  status      - Show current health score
  report      - Show detailed health report
  help        - Show this help

Exit Codes:
  0 - Healthy (score >= $ALERT_THRESHOLD)
  1 - Warning (score < $ALERT_THRESHOLD)
  2 - Critical (score < 50)

Cron Integration:
  # Monitor health every 2 hours
  0 */2 * * * $SCRIPT_DIR/cron-health-monitor.sh monitor

Configuration:
  Alert threshold: $ALERT_THRESHOLD
  Max work items: $MAX_WORK_ITEMS
  Max stale hours: $MAX_STALE_HOURS
  Min completion rate: ${MIN_COMPLETION_RATE}%
EOF
            ;;
        *)
            log_error "Unknown command: $command"
            $0 help
            exit 1
            ;;
    esac
}

# Ensure telemetry file exists
touch "$TELEMETRY_FILE"

# Run with error handling
if ! main "$@"; then
    local operation_end=$(date +%s%N)
    local duration_ms=$(( (operation_end - OPERATION_START) / 1000000 ))
    generate_health_span "monitoring_failed" "error" "{\"duration_ms\":$duration_ms}" "$duration_ms"
    exit 3  # Script error
fi