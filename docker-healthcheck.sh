#!/bin/bash

# Docker Container Health Check - 80/20 Optimized
# Validates essential container services and coordination health

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HEALTH_TIMEOUT=10
readonly COORDINATION_DIR="${COORDINATION_DIR:-$SCRIPT_DIR}"

# Health check functions
check_coordination_files() {
    local required_files=("work_claims.json" "agent_status.json")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$COORDINATION_DIR/$file" ]]; then
            echo "CRITICAL: Missing coordination file: $file"
            return 1
        fi
        
        # Check if file is readable and valid JSON
        if ! jq empty "$COORDINATION_DIR/$file" 2>/dev/null; then
            echo "CRITICAL: Invalid JSON in $file"
            return 1
        fi
    done
    
    return 0
}

check_coordination_scripts() {
    local required_scripts=("coordination_helper.sh" "cron-health-monitor.sh" "cron-telemetry-manager.sh")
    
    for script in "${required_scripts[@]}"; do
        if [[ ! -x "$COORDINATION_DIR/$script" ]]; then
            echo "CRITICAL: Missing or non-executable script: $script"
            return 1
        fi
    done
    
    return 0
}

check_telemetry_health() {
    if [[ -f "$COORDINATION_DIR/telemetry_spans.jsonl" ]]; then
        local file_size=$(stat -f%z "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || stat -c%s "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        
        # Check if telemetry file is too large (indicates potential issue)
        if [[ $file_size -gt 52428800 ]]; then  # 50MB
            echo "WARNING: Large telemetry file: $file_size bytes"
            return 1
        fi
    fi
    
    return 0
}

check_log_directory() {
    if [[ ! -d "$COORDINATION_DIR/logs" ]]; then
        echo "WARNING: Logs directory missing"
        mkdir -p "$COORDINATION_DIR/logs" 2>/dev/null || return 1
    fi
    
    # Check if logs directory is writable
    if [[ ! -w "$COORDINATION_DIR/logs" ]]; then
        echo "CRITICAL: Logs directory not writable"
        return 1
    fi
    
    return 0
}

check_system_resources() {
    # Check available disk space
    local disk_usage=$(df "$COORDINATION_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 95 ]]; then
        echo "CRITICAL: Disk usage at ${disk_usage}%"
        return 1
    elif [[ $disk_usage -gt 85 ]]; then
        echo "WARNING: Disk usage at ${disk_usage}%"
    fi
    
    # Check if coordination processes are running
    if ! pgrep -f "coordination_helper.sh" >/dev/null 2>&1; then
        echo "WARNING: No coordination processes detected"
    fi
    
    return 0
}

perform_coordination_test() {
    # Quick test of coordination system
    local test_agent_id="healthcheck_$(date +%s%N)"
    
    # Try to generate an agent ID (basic functionality test)
    if ! "$COORDINATION_DIR/coordination_helper.sh" generate-id >/dev/null 2>&1; then
        echo "CRITICAL: Coordination helper not responding"
        return 1
    fi
    
    return 0
}

# Main health check execution
main() {
    local health_issues=0
    local start_time=$(date +%s)
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH-CHECK] Starting container health validation..."
    
    # Run health checks
    if ! check_coordination_files; then
        ((health_issues++))
    fi
    
    if ! check_coordination_scripts; then
        ((health_issues++))
    fi
    
    if ! check_telemetry_health; then
        ((health_issues++))
    fi
    
    if ! check_log_directory; then
        ((health_issues++))
    fi
    
    if ! check_system_resources; then
        ((health_issues++))
    fi
    
    if ! perform_coordination_test; then
        ((health_issues++))
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Generate health check telemetry
    if [[ -f "$COORDINATION_DIR/telemetry_spans.jsonl" ]]; then
        local trace_id="$(openssl rand -hex 16 2>/dev/null || echo "healthcheck_$(date +%s%N)")"
        echo "{\"trace_id\":\"$trace_id\",\"operation\":\"container_health_check\",\"service\":\"docker-healthcheck\",\"status\":\"$(if [[ $health_issues -eq 0 ]]; then echo "healthy"; else echo "unhealthy"; fi)\",\"duration_ms\":$((duration * 1000)),\"health_issues\":$health_issues,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >> "$COORDINATION_DIR/telemetry_spans.jsonl"
    fi
    
    # Health check result
    if [[ $health_issues -eq 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH-CHECK] Container is healthy (${duration}s)"
        exit 0
    elif [[ $health_issues -le 2 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH-CHECK] Container has warnings ($health_issues issues, ${duration}s)"
        exit 0  # Still consider healthy for Docker
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH-CHECK] Container is unhealthy ($health_issues issues, ${duration}s)"
        exit 1
    fi
}

# Timeout protection
timeout_handler() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH-CHECK] Health check timed out"
    exit 1
}

trap timeout_handler TERM

# Run with timeout
if command -v timeout >/dev/null 2>&1; then
    timeout $HEALTH_TIMEOUT bash -c 'main "$@"' _ "$@"
else
    main "$@"
fi