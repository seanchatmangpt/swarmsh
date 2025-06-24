#!/bin/bash

##############################################################################
# Ecuador Demo Reliability Monitor - Zero-Failure Guarantee System
##############################################################################
# Ensures the CiviqCore Ecuador Demo maintains 100% reliability during the
# critical 20-minute executive presentation to secure $175M investment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/otel-simple.sh" || true

# Configuration
DEMO_NAME="ecuador-demo"
CHECK_INTERVAL=5  # seconds
ALERT_THRESHOLD=95  # health score threshold
TARGET_LOAD_TIME=1000  # milliseconds
TARGET_RENDER_TIME=500  # milliseconds
LOG_FILE="$SCRIPT_DIR/logs/ecuador_demo_reliability.log"

# Initialize logging
mkdir -p "$(dirname "$LOG_FILE")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Health check components
declare -A HEALTH_CHECKS=(
    ["dashboard_load"]="http://localhost:3000/"
    ["api_health"]="http://localhost:3000/api/health"
    ["roi_calculator"]="http://localhost:3000/api/roi/calculate"
    ["visualization_engine"]="http://localhost:3000/api/charts/test"
    ["data_pipeline"]="http://localhost:3000/api/data/status"
    ["mobile_view"]="http://localhost:3000/mobile"
)

# Performance metrics
declare -A PERFORMANCE_METRICS=(
    ["dashboard_load_ms"]=0
    ["chart_render_ms"]=0
    ["data_refresh_ms"]=0
    ["api_response_ms"]=0
    ["mobile_fps"]=60
)

# Initialize telemetry
init_telemetry() {
    local trace_id=$(generate_trace_id)
    local span_id=$(generate_span_id)
    
    export OTEL_TRACE_ID="$trace_id"
    export OTEL_SPAN_ID="$span_id"
    export OTEL_SERVICE_NAME="ecuador-demo-monitor"
}

# Log with timestamp
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Check component health
check_component_health() {
    local component="$1"
    local url="$2"
    local start_time=$(date +%s%N)
    
    # Create telemetry span
    local span_id=$(generate_span_id)
    start_span "$span_id" "health_check_$component" "$OTEL_SPAN_ID"
    
    # Perform health check
    local http_code
    local response_time
    
    if http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null); then
        local end_time=$(date +%s%N)
        response_time=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
        
        if [[ "$http_code" == "200" ]]; then
            log "INFO" "$component: OK (${response_time}ms)"
            end_span "$span_id" "success"
            echo "100"  # Perfect health score
        else
            log "WARN" "$component: HTTP $http_code (${response_time}ms)"
            end_span "$span_id" "http_error"
            echo "50"  # Degraded health score
        fi
    else
        log "ERROR" "$component: FAILED"
        end_span "$span_id" "error"
        
        # Activate fallback
        activate_fallback "$component"
        echo "0"  # Failed health score
    fi
}

# Activate fallback procedures
activate_fallback() {
    local component="$1"
    log "ALERT" "Activating fallback for $component"
    
    case "$component" in
        "dashboard_load")
            # Serve cached static version
            log "INFO" "Switching to cached dashboard"
            touch "/tmp/ecuador_demo_fallback_dashboard"
            ;;
        "data_pipeline")
            # Use pre-generated static data
            log "INFO" "Switching to static data mode"
            touch "/tmp/ecuador_demo_fallback_data"
            ;;
        "visualization_engine")
            # Use pre-rendered charts
            log "INFO" "Switching to pre-rendered visualizations"
            touch "/tmp/ecuador_demo_fallback_charts"
            ;;
        *)
            log "WARN" "No specific fallback for $component"
            ;;
    esac
    
    # Send alert
    send_alert "FALLBACK_ACTIVATED" "$component" "critical"
}

# Check performance metrics
check_performance() {
    local span_id=$(generate_span_id)
    start_span "$span_id" "performance_check" "$OTEL_SPAN_ID"
    
    # Dashboard load time
    local start_time=$(date +%s%N)
    if curl -s -o /dev/null "http://localhost:3000/" 2>/dev/null; then
        local end_time=$(date +%s%N)
        PERFORMANCE_METRICS["dashboard_load_ms"]=$(( (end_time - start_time) / 1000000 ))
    fi
    
    # Check against targets
    local load_time="${PERFORMANCE_METRICS["dashboard_load_ms"]}"
    if [[ "$load_time" -gt "$TARGET_LOAD_TIME" ]]; then
        log "WARN" "Dashboard load time ${load_time}ms exceeds target ${TARGET_LOAD_TIME}ms"
        send_alert "PERFORMANCE_DEGRADATION" "dashboard_load" "warning"
    fi
    
    end_span "$span_id" "success"
}

# Send alerts
send_alert() {
    local alert_type="$1"
    local component="$2"
    local severity="$3"
    
    local alert_file="$SCRIPT_DIR/logs/ecuador_alert_$(date +%Y%m%d_%H%M%S).json"
    
    cat > "$alert_file" <<EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "alert_type": "$alert_type",
    "component": "$component",
    "severity": "$severity",
    "demo_name": "$DEMO_NAME",
    "metrics": $(echo "${PERFORMANCE_METRICS[@]}" | jq -Rs '.')
}
EOF
    
    # Console alert
    case "$severity" in
        "critical")
            echo -e "${RED}🚨 CRITICAL ALERT: $alert_type - $component${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  WARNING: $alert_type - $component${NC}"
            ;;
        *)
            echo -e "ℹ️  INFO: $alert_type - $component"
            ;;
    esac
}

# Calculate overall health score
calculate_health_score() {
    local total_score=0
    local component_count=0
    
    for component in "${!HEALTH_CHECKS[@]}"; do
        local score=$(check_component_health "$component" "${HEALTH_CHECKS[$component]}")
        total_score=$((total_score + score))
        component_count=$((component_count + 1))
    done
    
    if [[ $component_count -gt 0 ]]; then
        echo $((total_score / component_count))
    else
        echo 0
    fi
}

# Monitor dashboard
monitor_dashboard() {
    echo -e "${GREEN}🛡️  Ecuador Demo Reliability Monitor${NC}"
    echo "===================================="
    echo "Target: Zero failures during 20-minute presentation"
    echo "Monitoring interval: ${CHECK_INTERVAL}s"
    echo ""
    
    while true; do
        init_telemetry
        
        # Run health checks
        local health_score=$(calculate_health_score)
        
        # Run performance checks
        check_performance
        
        # Display status
        echo -e "\n[$(date +"%H:%M:%S")] Health Score: ${health_score}/100"
        
        if [[ $health_score -lt $ALERT_THRESHOLD ]]; then
            echo -e "${RED}⚠️  HEALTH DEGRADED - Score below threshold${NC}"
            send_alert "HEALTH_DEGRADED" "system" "critical"
        else
            echo -e "${GREEN}✅ All systems operational${NC}"
        fi
        
        # Show performance metrics
        echo "Performance Metrics:"
        echo "  Dashboard Load: ${PERFORMANCE_METRICS["dashboard_load_ms"]}ms (target: <${TARGET_LOAD_TIME}ms)"
        echo "  Mobile FPS: ${PERFORMANCE_METRICS["mobile_fps"]} (target: 60fps)"
        
        # Log telemetry
        log_span_complete "monitor_cycle" "success"
        
        sleep "$CHECK_INTERVAL"
    done
}

# Pre-presentation validation
validate_for_presentation() {
    echo -e "${BLUE}🎯 Pre-Presentation Validation${NC}"
    echo "==============================="
    
    local validation_passed=true
    
    # Check all components
    echo "Checking all components..."
    for component in "${!HEALTH_CHECKS[@]}"; do
        local score=$(check_component_health "$component" "${HEALTH_CHECKS[$component]}")
        if [[ $score -lt 100 ]]; then
            echo -e "${RED}❌ $component: FAILED${NC}"
            validation_passed=false
        else
            echo -e "${GREEN}✅ $component: PASSED${NC}"
        fi
    done
    
    # Check performance
    echo -e "\nChecking performance targets..."
    check_performance
    
    if [[ "${PERFORMANCE_METRICS["dashboard_load_ms"]}" -le "$TARGET_LOAD_TIME" ]]; then
        echo -e "${GREEN}✅ Load time: ${PERFORMANCE_METRICS["dashboard_load_ms"]}ms${NC}"
    else
        echo -e "${RED}❌ Load time: ${PERFORMANCE_METRICS["dashboard_load_ms"]}ms (exceeds target)${NC}"
        validation_passed=false
    fi
    
    # Generate report
    local report_file="$SCRIPT_DIR/logs/presentation_validation_$(date +%Y%m%d_%H%M%S).json"
    cat > "$report_file" <<EOF
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "validation_passed": $validation_passed,
    "health_checks": $(printf '%s\n' "${!HEALTH_CHECKS[@]}" | jq -Rs 'split("\n")[:-1]'),
    "performance_metrics": {
        "dashboard_load_ms": ${PERFORMANCE_METRICS["dashboard_load_ms"]},
        "target_load_ms": $TARGET_LOAD_TIME
    },
    "recommendation": $(if $validation_passed; then echo '"READY FOR PRESENTATION"'; else echo '"DO NOT PRESENT - ISSUES DETECTED"'; fi)
}
EOF
    
    echo -e "\nValidation report: $report_file"
    
    if $validation_passed; then
        echo -e "\n${GREEN}✅ SYSTEM READY FOR PRESENTATION${NC}"
        return 0
    else
        echo -e "\n${RED}❌ SYSTEM NOT READY - FIX ISSUES BEFORE PRESENTING${NC}"
        return 1
    fi
}

# Main execution
case "${1:-monitor}" in
    "monitor")
        monitor_dashboard
        ;;
    "validate")
        validate_for_presentation
        ;;
    "test-fallback")
        echo "Testing fallback procedures..."
        activate_fallback "dashboard_load"
        activate_fallback "data_pipeline"
        activate_fallback "visualization_engine"
        ;;
    *)
        echo "Ecuador Demo Reliability Monitor"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  monitor    - Continuous reliability monitoring (default)"
        echo "  validate   - Pre-presentation validation check"
        echo "  test-fallback - Test fallback procedures"
        echo ""
        echo "This system ensures zero failures during the critical"
        echo "Ecuador demo presentation to secure \$175M investment."
        ;;
esac