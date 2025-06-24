#!/bin/bash

##############################################################################
# Telemetry Timeframe Statistics
# 
# Compares telemetry data across different time windows
# Shows how data volume and patterns change over time
#
# Usage:
#   ./telemetry-timeframe-stats.sh
#
##############################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TELEMETRY_FILE="$SCRIPT_DIR/telemetry_spans.jsonl"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Get timestamp for filtering
get_filter_timestamp() {
    local timeframe="$1"
    case "$timeframe" in
        "1h")
            date -u -d "1 hour ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            date -u -v-1H +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || \
            echo "2025-06-24T18:00:00Z"
            ;;
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

# Get operation types distribution
get_operation_types() {
    local timeframe="$1"
    local filter_timestamp=$(get_filter_timestamp "$timeframe")
    local temp_file="/tmp/ops_types_$$.txt"
    
    if [[ -f "$TELEMETRY_FILE" ]]; then
        while IFS= read -r line; do
            if echo "$line" | jq -e --arg ts "$filter_timestamp" '.timestamp >= $ts' >/dev/null 2>&1; then
                echo "$line" | jq -r '.operation_name // .operation // "unknown"' 2>/dev/null
            fi
        done < "$TELEMETRY_FILE" | sort | uniq -c | sort -rn | head -5 > "$temp_file"
        
        cat "$temp_file"
        rm -f "$temp_file"
    fi
}

# Display statistics
display_stats() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}        ${CYAN}📊 Telemetry Timeframe Statistics${NC}                      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${YELLOW}Generated: $(date)${NC}"
    echo
    
    # Get counts for different timeframes
    local count_1h=$(count_operations "1h")
    local count_24h=$(count_operations "24h")
    local count_7d=$(count_operations "7d")
    local count_30d=$(count_operations "30d")
    local count_all=$(count_operations "all")
    
    # Display comparison table
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Operation Counts by Timeframe${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    printf "%-15s %-12s %-15s %-15s\n" "Timeframe" "Operations" "Ops/Hour" "% of Total"
    printf "%-15s %-12s %-15s %-15s\n" "---------" "----------" "--------" "----------"
    
    # Last hour
    local rate_1h=$count_1h
    local pct_1h=$(echo "scale=1; $count_1h * 100 / $count_all" | bc 2>/dev/null || echo "0")
    printf "%-15s ${GREEN}%-12d${NC} %-15.1f %-15s\n" "Last Hour" "$count_1h" "$rate_1h" "${pct_1h}%"
    
    # Last 24 hours
    local rate_24h=$(echo "scale=1; $count_24h / 24" | bc 2>/dev/null || echo "0")
    local pct_24h=$(echo "scale=1; $count_24h * 100 / $count_all" | bc 2>/dev/null || echo "0")
    printf "%-15s ${GREEN}%-12d${NC} %-15.1f %-15s\n" "Last 24 Hours" "$count_24h" "$rate_24h" "${pct_24h}%"
    
    # Last 7 days
    local rate_7d=$(echo "scale=1; $count_7d / 168" | bc 2>/dev/null || echo "0")
    local pct_7d=$(echo "scale=1; $count_7d * 100 / $count_all" | bc 2>/dev/null || echo "0")
    printf "%-15s ${GREEN}%-12d${NC} %-15.1f %-15s\n" "Last 7 Days" "$count_7d" "$rate_7d" "${pct_7d}%"
    
    # Last 30 days
    local rate_30d=$(echo "scale=1; $count_30d / 720" | bc 2>/dev/null || echo "0")
    local pct_30d=$(echo "scale=1; $count_30d * 100 / $count_all" | bc 2>/dev/null || echo "0")
    printf "%-15s ${GREEN}%-12d${NC} %-15.1f %-15s\n" "Last 30 Days" "$count_30d" "$rate_30d" "${pct_30d}%"
    
    # All time
    printf "%-15s ${GREEN}%-12d${NC} %-15s %-15s\n" "All Time" "$count_all" "-" "100.0%"
    echo
    
    # Top operations in last 24h
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Top Operations (Last 24 Hours)${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    get_operation_types "24h" | while read count op; do
        printf "  ${GREEN}%-6s${NC} %s\n" "$count" "$op"
    done
    echo
    
    # Growth analysis
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Growth Analysis${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Calculate growth rates
    local recent_rate=$rate_1h
    local daily_rate=$rate_24h
    
    if (( $(echo "$daily_rate > 0" | bc -l) )); then
        local growth=$(echo "scale=1; ($recent_rate - $daily_rate) * 100 / $daily_rate" | bc 2>/dev/null || echo "0")
        if (( $(echo "$growth > 0" | bc -l) )); then
            echo -e "  Current activity is ${GREEN}${growth}%${NC} higher than 24h average"
        elif (( $(echo "$growth < 0" | bc -l) )); then
            growth=$(echo "$growth * -1" | bc)
            echo -e "  Current activity is ${YELLOW}${growth}%${NC} lower than 24h average"
        else
            echo -e "  Current activity matches 24h average"
        fi
    fi
    
    # Recommendations
    echo
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}💡 Recommendations${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [[ $count_24h -lt 100 ]]; then
        echo -e "  • ${YELLOW}Low activity detected${NC} - Check if all automation is running"
    elif [[ $count_24h -gt 1000 ]]; then
        echo -e "  • ${YELLOW}High activity detected${NC} - Monitor system resources"
    else
        echo -e "  • ${GREEN}Activity levels normal${NC}"
    fi
    
    if [[ $count_all -gt 10000 ]]; then
        echo -e "  • ${YELLOW}Large telemetry file${NC} - Consider archiving old data"
    fi
    
    # File size info
    local file_size=$(stat -f%z "$TELEMETRY_FILE" 2>/dev/null || stat -c%s "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local file_size_mb=$(echo "scale=2; $file_size / 1048576" | bc 2>/dev/null || echo "0")
    echo -e "  • Telemetry file size: ${file_size_mb}MB"
    
    echo
}

# Main execution
main() {
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        echo -e "${YELLOW}Warning: No telemetry file found at $TELEMETRY_FILE${NC}"
        exit 1
    fi
    
    display_stats
}

# Run
main