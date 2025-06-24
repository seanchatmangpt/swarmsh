#!/bin/bash

# Real-Time Telemetry Dashboard
# Advanced monitoring for SwarmSH coordination system with S2S integration

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="realtime_telemetry_dashboard"
readonly TELEMETRY_FILE="${TELEMETRY_FILE:-telemetry_spans.jsonl}"
readonly REFRESH_INTERVAL="${REFRESH_INTERVAL:-5}"
readonly TRACE_ID="$(openssl rand -hex 16)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m'

# OpenTelemetry span generation for dashboard operations
log_dashboard_span() {
    local operation="$1"
    local status="$2"
    local duration_ms="$3"
    local attributes="$4"
    
    local span_data=$(cat <<EOF
{
  "trace_id": "$TRACE_ID",
  "span_id": "$(openssl rand -hex 8)",
  "operation_name": "dashboard.$operation",
  "status": "$status",
  "duration_ms": $duration_ms,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "service": {
    "name": "telemetry-dashboard",
    "version": "1.0.0"
  },
  "attributes": $attributes
}
EOF
    )
    
    echo "$span_data" >> "$TELEMETRY_FILE"
}

# Calculate telemetry statistics
calculate_telemetry_stats() {
    local start_time=$(date +%s%N)
    
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        echo "0,0,0,0,0,0"
        return
    fi
    
    # Get basic counts
    local total_spans=$(wc -l < "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local last_hour_spans=$(grep -c "$(date -u -d '1 hour ago' +%Y-%m-%dT%H 2>/dev/null || date -u -v-1H +%Y-%m-%dT%H 2>/dev/null || echo '1970-01-01T00')" "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local last_minute_spans=$(grep -c "$(date -u -d '1 minute ago' +%Y-%m-%dT%H:%M 2>/dev/null || date -u -v-1M +%Y-%m-%dT%H:%M 2>/dev/null || echo '1970-01-01T00:00')" "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    
    # Calculate error rate
    local error_spans=$(grep -c '"status":"error"' "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local success_spans=$(grep -c '"status":"completed\|success\|ok"' "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    
    # Calculate average duration
    local avg_duration=$(jq -r 'select(.duration_ms != null) | .duration_ms' "$TELEMETRY_FILE" 2>/dev/null | \
        awk '{sum+=$1; count++} END {if(count>0) print int(sum/count); else print 0}' || echo "0")
    
    local end_time=$(date +%s%N)
    local calc_duration=$(( (end_time - start_time) / 1000000 ))
    
    # Log calculation performance
    log_dashboard_span "stats_calculation" "completed" "$calc_duration" \
        "{\"total_spans\": $total_spans, \"error_spans\": $error_spans, \"avg_duration_ms\": $avg_duration}"
    
    echo "$total_spans,$last_hour_spans,$last_minute_spans,$error_spans,$success_spans,$avg_duration"
}

# Get top operations by frequency
get_top_operations() {
    local limit="${1:-5}"
    
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        return
    fi
    
    jq -r '.operation_name // .operation // "unknown"' "$TELEMETRY_FILE" 2>/dev/null | \
        sort | uniq -c | sort -nr | head -"$limit" | \
        awk '{printf "%-4s %s\n", $1, $2}'
}

# Get service distribution
get_service_distribution() {
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        return
    fi
    
    jq -r '.service.name // .service // "unknown"' "$TELEMETRY_FILE" 2>/dev/null | \
        sort | uniq -c | sort -nr | head -8 | \
        awk '{printf "%-4s %s\n", $1, $2}'
}

# Get recent errors
get_recent_errors() {
    local limit="${1:-3}"
    
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        return
    fi
    
    grep '"status":"error"' "$TELEMETRY_FILE" 2>/dev/null | tail -"$limit" | \
        jq -r '"\(.timestamp // "N/A") | \(.operation_name // .operation // "unknown") | \(.error_message // "No message")"' 2>/dev/null || \
        echo "No recent errors"
}

# Show coordination status
show_coordination_status() {
    local work_claims_file="agent_coordination/work_claims.json"
    local agent_status_file="agent_coordination/agent_status.json"
    
    if [[ -f "$work_claims_file" ]]; then
        local active_work=$(jq '[.[] | select(.status == "in_progress" or .status == "pending")] | length' "$work_claims_file" 2>/dev/null || echo "0")
        local completed_work=$(jq '[.[] | select(.status == "completed")] | length' "$work_claims_file" 2>/dev/null || echo "0")
        echo "Active: $active_work  Completed: $completed_work"
    else
        echo "No coordination data"
    fi
}

# Display the dashboard
display_dashboard() {
    local stats
    stats=$(calculate_telemetry_stats)
    IFS=',' read -r total_spans last_hour_spans last_minute_spans error_spans success_spans avg_duration <<< "$stats"
    
    # Calculate rates and percentages
    local error_rate="0"
    if [[ $total_spans -gt 0 ]]; then
        error_rate=$(( (error_spans * 100) / total_spans ))
    fi
    
    local ops_per_minute="${last_minute_spans:-0}"
    local ops_per_hour="${last_hour_spans:-0}"
    
    # Header
    echo -e "${WHITE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║                    🔍 Real-Time Telemetry Dashboard                         ║${NC}"
    echo -e "${WHITE}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║ $(date '+%Y-%m-%d %H:%M:%S UTC') | Trace: ${TRACE_ID:0:8}... ║${NC}"
    echo -e "${WHITE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Key Metrics
    echo -e "${CYAN}📊 Key Metrics${NC}"
    echo -e "   Total Operations: ${WHITE}$total_spans${NC}"
    echo -e "   Operations/Hour:  ${GREEN}$ops_per_hour${NC}"
    echo -e "   Operations/Min:   ${YELLOW}$ops_per_minute${NC}"
    echo -e "   Error Rate:       ${RED}$error_rate%${NC} ($error_spans errors)"
    echo -e "   Avg Duration:     ${BLUE}${avg_duration}ms${NC}"
    echo ""
    
    # Top Operations
    echo -e "${PURPLE}🔥 Top Operations${NC}"
    get_top_operations 5 | while read -r line; do
        echo -e "   $line"
    done
    echo ""
    
    # Service Distribution
    echo -e "${CYAN}🏗️  Service Distribution${NC}"
    get_service_distribution | while read -r line; do
        echo -e "   $line"
    done
    echo ""
    
    # Recent Errors
    echo -e "${RED}❌ Recent Errors${NC}"
    get_recent_errors 3 | while read -r line; do
        if [[ "$line" == "No recent errors" ]]; then
            echo -e "   ${GREEN}✅ No recent errors${NC}"
        else
            echo -e "   ${RED}$line${NC}"
        fi
    done
    echo ""
    
    # Coordination Status
    echo -e "${YELLOW}🤝 Coordination Status${NC}"
    echo -e "   Work Items: $(show_coordination_status)"
    echo ""
    
    # System Health Indicator
    local health_indicator="🟢 HEALTHY"
    if [[ $error_rate -gt 10 ]]; then
        health_indicator="🔴 CRITICAL"
    elif [[ $error_rate -gt 5 ]]; then
        health_indicator="🟡 WARNING"
    fi
    
    echo -e "${WHITE}System Status: $health_indicator${NC}"
    echo ""
    echo -e "${WHITE}Press Ctrl+C to exit | Refresh every ${REFRESH_INTERVAL}s${NC}"
    echo "────────────────────────────────────────────────────────────────────────────────"
}

# Main monitoring loop
main_loop() {
    echo -e "${GREEN}🚀 Starting Real-Time Telemetry Dashboard${NC}"
    echo -e "${BLUE}📁 Monitoring: $TELEMETRY_FILE${NC}"
    echo ""
    
    # Log dashboard startup
    log_dashboard_span "dashboard_start" "started" "0" \
        "{\"telemetry_file\": \"$TELEMETRY_FILE\", \"refresh_interval\": $REFRESH_INTERVAL}"
    
    local iteration=0
    
    while true; do
        clear
        
        local start_time=$(date +%s%N)
        display_dashboard
        local end_time=$(date +%s%N)
        local display_duration=$(( (end_time - start_time) / 1000000 ))
        
        # Log dashboard iteration
        if [[ $((iteration % 10)) -eq 0 ]]; then  # Log every 10th iteration
            log_dashboard_span "dashboard_refresh" "completed" "$display_duration" \
                "{\"iteration\": $iteration, \"display_duration_ms\": $display_duration}"
        fi
        
        ((iteration++))
        sleep "$REFRESH_INTERVAL"
    done
}

# Handle cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Dashboard stopped${NC}"
    
    # Log dashboard shutdown
    log_dashboard_span "dashboard_stop" "completed" "0" \
        "{\"total_iterations\": $((iteration)), \"trace_id\": \"$TRACE_ID\"}"
    
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Usage information
show_usage() {
    echo "Real-Time Telemetry Dashboard"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -f, --file FILE     Telemetry file to monitor (default: telemetry_spans.jsonl)"
    echo "  -i, --interval SEC  Refresh interval in seconds (default: 5)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  TELEMETRY_FILE     Path to telemetry file"
    echo "  REFRESH_INTERVAL   Refresh interval in seconds"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Use defaults"
    echo "  $0 -f custom_telemetry.jsonl -i 2   # Custom file, 2s refresh"
    echo "  REFRESH_INTERVAL=10 $0               # 10s refresh via env var"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            TELEMETRY_FILE="$2"
            shift 2
            ;;
        -i|--interval)
            REFRESH_INTERVAL="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate inputs
if [[ ! -f "$TELEMETRY_FILE" ]]; then
    echo -e "${RED}❌ Error: Telemetry file '$TELEMETRY_FILE' not found${NC}"
    echo -e "${YELLOW}💡 Tip: Create some telemetry data first:${NC}"
    echo "   ./test-essential.sh"
    echo "   ./coordination_helper.sh claim 'test' 'Generate telemetry' 'high'"
    exit 1
fi

if ! [[ "$REFRESH_INTERVAL" =~ ^[0-9]+$ ]] || [[ "$REFRESH_INTERVAL" -lt 1 ]]; then
    echo -e "${RED}❌ Error: Invalid refresh interval '$REFRESH_INTERVAL'${NC}"
    echo "Refresh interval must be a positive integer"
    exit 1
fi

# Start the dashboard
main_loop