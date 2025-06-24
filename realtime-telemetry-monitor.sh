#!/bin/bash

##############################################################################
# Real-Time Telemetry Monitor
# 
# Continuously monitors telemetry data and generates live updates
# Shows only recent data (24h by default) with options for longer windows
#
# Usage:
#   ./realtime-telemetry-monitor.sh [timeframe] [interval]
#
# Timeframe options:
#   24h  - Last 24 hours (default)
#   7d   - Last 7 days
#   30d  - Last 30 days
#   all  - All available data
#
# Interval: Update frequency in seconds (default: 300 = 5 minutes)
#
# Examples:
#   ./realtime-telemetry-monitor.sh           # 24h window, 5min updates
#   ./realtime-telemetry-monitor.sh 7d 60     # 7 day window, 1min updates
#   ./realtime-telemetry-monitor.sh 24h 600   # 24h window, 10min updates
#
##############################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TELEMETRY_FILE="$SCRIPT_DIR/telemetry_spans.jsonl"
MONITOR_LOG="$SCRIPT_DIR/realtime_monitor.log"
TIMEFRAME="${1:-24h}"
UPDATE_INTERVAL="${2:-300}"  # Default 5 minutes

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get timestamp for filtering
get_filter_timestamp() {
    local timeframe="$1"
    case "$timeframe" in
        "24h")
            date -u -d "24 hours ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            date -u -v-24H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            echo "2025-06-23T00:00:00Z"
            ;;
        "7d")
            date -u -d "7 days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            date -u -v-7d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            echo "2025-06-17T00:00:00Z"
            ;;
        "30d")
            date -u -d "30 days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            date -u -v-30d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            echo "2025-05-25T00:00:00Z"
            ;;
        "all"|*)
            echo "1970-01-01T00:00:00Z"
            ;;
    esac
}

# Count operations in timeframe
count_operations() {
    local timeframe="$1"
    local filter_timestamp=$(get_filter_timestamp "$timeframe")
    local count=0
    
    if [[ -f "$TELEMETRY_FILE" ]]; then
        while IFS= read -r line; do
            if echo "$line" | jq -e --arg ts "$filter_timestamp" '.timestamp >= $ts' >/dev/null 2>&1; then
                ((count++))
            fi
        done < "$TELEMETRY_FILE"
    fi
    
    echo "$count"
}

# Get recent operations
get_recent_operations() {
    local timeframe="$1"
    local limit="${2:-10}"
    local filter_timestamp=$(get_filter_timestamp "$timeframe")
    
    if [[ -f "$TELEMETRY_FILE" ]]; then
        # Filter and get recent operations
        local temp_file="/tmp/recent_ops_$$.jsonl"
        while IFS= read -r line; do
            if echo "$line" | jq -e --arg ts "$filter_timestamp" '.timestamp >= $ts' >/dev/null 2>&1; then
                echo "$line"
            fi
        done < "$TELEMETRY_FILE" > "$temp_file"
        
        # Get last N operations
        tail -n "$limit" "$temp_file" | while IFS= read -r line; do
            local operation=$(echo "$line" | jq -r '.operation_name // .operation // "unknown"' 2>/dev/null || echo "parse_error")
            local timestamp=$(echo "$line" | jq -r '.timestamp // .start_time // ""' 2>/dev/null || echo "")
            local status=$(echo "$line" | jq -r '.status // "unknown"' 2>/dev/null || echo "unknown")
            
            # Format timestamp for display
            if [[ -n "$timestamp" ]]; then
                timestamp=$(echo "$timestamp" | cut -d'T' -f2 | cut -d'.' -f1 | cut -d'Z' -f1)
            else
                timestamp="--:--:--"
            fi
            
            # Status icon
            local status_icon="❓"
            case "$status" in
                "ok"|"completed"|"success") status_icon="✅" ;;
                "warning") status_icon="⚠️ " ;;
                "error"|"failed") status_icon="❌" ;;
            esac
            
            printf "  %s %s %s\n" "$status_icon" "$timestamp" "$operation"
        done
        
        rm -f "$temp_file"
    fi
}

# Calculate operation rate
get_operation_rate() {
    local timeframe="$1"
    local count=$(count_operations "$timeframe")
    
    case "$timeframe" in
        "24h") echo "scale=2; $count / 24" | bc 2>/dev/null || echo "0" ;;
        "7d") echo "scale=2; $count / 168" | bc 2>/dev/null || echo "0" ;;
        "30d") echo "scale=2; $count / 720" | bc 2>/dev/null || echo "0" ;;
        *) echo "0" ;;
    esac
}

# Get health score
get_health_score() {
    local health_file="$SCRIPT_DIR/system_health_report.json"
    if [[ -f "$health_file" ]]; then
        jq -r '.health_score // 100' "$health_file" 2>/dev/null || echo "100"
    else
        echo "100"
    fi
}

# Get system status
get_system_status() {
    local health_score=$(get_health_score)
    
    if [[ $health_score -ge 80 ]]; then
        echo -e "${GREEN}🟢 Healthy${NC}"
    elif [[ $health_score -ge 60 ]]; then
        echo -e "${YELLOW}🟡 Warning${NC}"
    else
        echo -e "${RED}🔴 Critical${NC}"
    fi
}

# Display live monitor
display_monitor() {
    clear
    
    local current_time=$(date)
    local operations_count=$(count_operations "$TIMEFRAME")
    local operation_rate=$(get_operation_rate "$TIMEFRAME")
    local health_score=$(get_health_score)
    local system_status=$(get_system_status)
    
    # Header
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${CYAN}🔍 Real-Time Telemetry Monitor${NC}                         ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Status bar
    echo -e "${PURPLE}📊 System Status:${NC} $system_status  ${PURPLE}Health Score:${NC} ${health_score}/100"
    echo -e "${PURPLE}⏰ Time Window:${NC} $TIMEFRAME     ${PURPLE}🔄 Update Interval:${NC} ${UPDATE_INTERVAL}s"
    echo -e "${PURPLE}🕐 Last Update:${NC} $current_time"
    echo
    
    # Metrics
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📈 Operations Metrics${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Total Operations (${TIMEFRAME}): ${GREEN}$operations_count${NC}"
    echo -e "  Operation Rate: ${GREEN}${operation_rate}/hour${NC}"
    echo
    
    # Active processes
    local cron_jobs=$(crontab -l 2>/dev/null | grep -c "8020\|cron-" || echo "0")
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}⚙️  Active Automation${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  Cron Jobs: ${GREEN}$cron_jobs${NC} active"
    echo -e "  Next Health Check: $(date -d "+15 minutes" +%H:%M 2>/dev/null || date -v+15M +%H:%M 2>/dev/null || echo "N/A")"
    echo -e "  Next Optimization: $(date -d "+4 hours" +%H:%M 2>/dev/null || date -v+4H +%H:%M 2>/dev/null || echo "N/A")"
    echo
    
    # Recent operations
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📋 Recent Operations${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    get_recent_operations "$TIMEFRAME" 8
    echo
    
    # Footer
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}  |  Next update in ${UPDATE_INTERVAL}s"
    
    # Log update
    echo "[$(date)] Monitor updated - Operations: $operations_count, Health: $health_score" >> "$MONITOR_LOG"
}

# Trap for clean exit
cleanup() {
    echo
    echo -e "${GREEN}✅ Telemetry monitor stopped${NC}"
    exit 0
}
trap cleanup INT TERM

# Main monitoring loop
main() {
    echo -e "${GREEN}🚀 Starting Real-Time Telemetry Monitor${NC}"
    echo -e "${YELLOW}Timeframe: $TIMEFRAME | Update interval: ${UPDATE_INTERVAL}s${NC}"
    echo
    
    # Initial display
    display_monitor
    
    # Continuous monitoring
    while true; do
        sleep "$UPDATE_INTERVAL"
        display_monitor
    done
}

# Validate parameters
if [[ ! "$UPDATE_INTERVAL" =~ ^[0-9]+$ ]] || [[ "$UPDATE_INTERVAL" -lt 1 ]]; then
    echo -e "${RED}Error: Invalid update interval. Must be a positive number.${NC}"
    exit 1
fi

# Run monitor
main