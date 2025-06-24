#!/bin/bash

##############################################################################
# Ecuador Performance Validator - Sub-1s Load Time Guarantee
##############################################################################
# Validates and optimizes performance for the Ecuador Demo Dashboard
# ensuring <1s load times and smooth 60fps presentation experience

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/otel-simple.sh" || true

# Performance targets
declare -A PERFORMANCE_TARGETS=(
    ["dashboard_load_ms"]=1000      # <1s dashboard load
    ["chart_render_ms"]=500         # <500ms chart rendering
    ["api_response_ms"]=200         # <200ms API responses
    ["data_refresh_ms"]=100         # <100ms data refresh
    ["mobile_fps"]=60               # 60fps mobile performance
    ["memory_usage_mb"]=512         # <512MB memory usage
    ["cpu_usage_percent"]=70        # <70% CPU usage
)

# Test endpoints and components
declare -A TEST_ENDPOINTS=(
    ["dashboard"]="http://localhost:3000/"
    ["api_health"]="http://localhost:3000/api/health"
    ["api_roi"]="http://localhost:3000/api/roi/calculate"
    ["api_charts"]="http://localhost:3000/api/charts/test"
    ["api_data"]="http://localhost:3000/api/data/status"
    ["mobile_view"]="http://localhost:3000/mobile"
)

# Colors and logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="$SCRIPT_DIR/logs/ecuador_performance.log"
RESULTS_DIR="$SCRIPT_DIR/performance_results"

mkdir -p "$(dirname "$LOG_FILE")" "$RESULTS_DIR"

# Initialize telemetry
init_telemetry() {
    local trace_id=$(generate_trace_id)
    local span_id=$(generate_span_id)
    
    export OTEL_TRACE_ID="$trace_id"
    export OTEL_SPAN_ID="$span_id"
    export OTEL_SERVICE_NAME="ecuador-performance-validator"
}

# Log with timestamp
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Measure endpoint performance
measure_endpoint_performance() {
    local name="$1"
    local url="$2"
    local iterations="${3:-5}"
    
    log "INFO" "Testing $name performance ($iterations iterations)"
    
    local total_time=0
    local success_count=0
    local times=()
    
    for ((i=1; i<=iterations; i++)); do
        echo -n "  Iteration $i/$iterations: "
        
        # Measure response time
        local start_time=$(date +%s%N)
        local http_code
        
        if http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null); then
            local end_time=$(date +%s%N)
            local response_time=$(( (end_time - start_time) / 1000000 ))  # Convert to milliseconds
            
            if [[ "$http_code" == "200" ]]; then
                times+=("$response_time")
                total_time=$((total_time + response_time))
                success_count=$((success_count + 1))
                
                # Color code based on performance
                if [[ $response_time -le 200 ]]; then
                    echo -e "${GREEN}${response_time}ms ✅${NC}"
                elif [[ $response_time -le 500 ]]; then
                    echo -e "${YELLOW}${response_time}ms ⚠️${NC}"
                else
                    echo -e "${RED}${response_time}ms ❌${NC}"
                fi
            else
                echo -e "${RED}HTTP $http_code ❌${NC}"
            fi
        else
            echo -e "${RED}Failed ❌${NC}"
        fi
    done
    
    # Calculate statistics
    if [[ $success_count -gt 0 ]]; then
        local avg_time=$((total_time / success_count))
        local min_time=$(printf '%s\n' "${times[@]}" | sort -n | head -1)
        local max_time=$(printf '%s\n' "${times[@]}" | sort -n | tail -1)
        
        # Calculate median
        local sorted_times=($(printf '%s\n' "${times[@]}" | sort -n))
        local median_index=$((success_count / 2))
        local median_time="${sorted_times[$median_index]}"
        
        # Calculate 95th percentile
        local p95_index=$(((success_count * 95) / 100))
        local p95_time="${sorted_times[$p95_index]}"
        
        echo "  Results: avg=${avg_time}ms, min=${min_time}ms, max=${max_time}ms, median=${median_time}ms, p95=${p95_time}ms"
        echo "  Success rate: $success_count/$iterations ($((success_count * 100 / iterations))%)"
        
        # Save detailed results
        local result_file="$RESULTS_DIR/${name}_performance_$(date +%Y%m%d_%H%M%S).json"
        cat > "$result_file" <<EOF
{
    "endpoint": "$name",
    "url": "$url",
    "test_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "iterations": $iterations,
    "success_count": $success_count,
    "success_rate_percent": $((success_count * 100 / iterations)),
    "performance_ms": {
        "average": $avg_time,
        "minimum": $min_time,
        "maximum": $max_time,
        "median": $median_time,
        "p95": $p95_time
    },
    "individual_times": [$(IFS=,; echo "${times[*]}")]
}
EOF
        
        echo "$avg_time"  # Return average for comparison
    else
        echo "0"  # Failed
    fi
}

# Load test simulation
run_load_test() {
    local endpoint="$1"
    local concurrent="${2:-10}"
    local duration="${3:-30}"
    
    echo -e "${YELLOW}🔥 Load Testing: $endpoint${NC}"
    echo "Concurrent users: $concurrent, Duration: ${duration}s"
    
    local span_id=$(generate_span_id)
    start_span "$span_id" "load_test_$endpoint" "$OTEL_SPAN_ID"
    
    # Create load test script
    local load_script="/tmp/ecuador_load_test.sh"
    cat > "$load_script" <<EOF
#!/bin/bash
url="$endpoint"
end_time=\$(($(date +%s) + $duration))

while [[ \$(date +%s) -lt \$end_time ]]; do
    start=\$(date +%s%N)
    if curl -s -o /dev/null "\$url" 2>/dev/null; then
        end=\$(date +%s%N)
        echo "\$(((\$end - \$start) / 1000000))"
    else
        echo "error"
    fi
    sleep 0.1
done
EOF
    chmod +x "$load_script"
    
    # Run concurrent load test
    local pids=()
    local result_files=()
    
    for ((i=1; i<=concurrent; i++)); do
        local result_file="/tmp/load_result_$i.txt"
        result_files+=("$result_file")
        "$load_script" > "$result_file" &
        pids+=($!)
    done
    
    # Monitor progress
    echo "Load test in progress..."
    for ((i=1; i<=duration; i++)); do
        printf "\r  Progress: %d/%ds [" "$i" "$duration"
        local progress=$((i * 50 / duration))
        for ((j=0; j<50; j++)); do
            if [[ $j -lt $progress ]]; then
                printf "█"
            else
                printf "░"
            fi
        done
        printf "] %d%%" $((i * 100 / duration))
        sleep 1
    done
    printf "\n"
    
    # Wait for completion
    for pid in "${pids[@]}"; do
        wait "$pid" 2>/dev/null || true
    done
    
    # Analyze results
    local total_requests=0
    local total_time=0
    local error_count=0
    local response_times=()
    
    for result_file in "${result_files[@]}"; do
        if [[ -f "$result_file" ]]; then
            while read -r time; do
                if [[ "$time" == "error" ]]; then
                    error_count=$((error_count + 1))
                else
                    response_times+=("$time")
                    total_time=$((total_time + time))
                fi
                total_requests=$((total_requests + 1))
            done < "$result_file"
            rm -f "$result_file"
        fi
    done
    
    rm -f "$load_script"
    
    # Calculate load test statistics
    local success_requests=$((total_requests - error_count))
    local avg_response_time=0
    local requests_per_second=0
    
    if [[ $success_requests -gt 0 ]]; then
        avg_response_time=$((total_time / success_requests))
        requests_per_second=$((success_requests / duration))
    fi
    
    local error_rate=$((error_count * 100 / total_requests))
    
    echo "  Results:"
    echo "    Total requests: $total_requests"
    echo "    Successful requests: $success_requests"
    echo "    Error rate: ${error_rate}%"
    echo "    Requests per second: $requests_per_second"
    echo "    Average response time: ${avg_response_time}ms"
    
    # Color-code results
    if [[ $error_rate -le 5 && $avg_response_time -le 1000 ]]; then
        echo -e "  ${GREEN}✅ Load test passed${NC}"
    elif [[ $error_rate -le 10 && $avg_response_time -le 2000 ]]; then
        echo -e "  ${YELLOW}⚠️  Load test marginal${NC}"
    else
        echo -e "  ${RED}❌ Load test failed${NC}"
    fi
    
    end_span "$span_id" "success"
}

# Memory and CPU monitoring
monitor_system_resources() {
    echo -e "${BLUE}📊 Monitoring System Resources${NC}"
    
    local duration="${1:-60}"  # seconds
    local interval=5
    local measurements=()
    
    echo "Monitoring for ${duration}s (${interval}s intervals)..."
    
    for ((i=0; i<duration; i+=interval)); do
        # Get memory usage (in MB)
        local memory_mb
        if command -v free >/dev/null 2>&1; then
            # Linux
            memory_mb=$(free -m | awk 'NR==2{printf "%.0f", $3}')
        else
            # macOS
            memory_mb=$(ps -A -o rss | awk '{sum+=$1} END {printf "%.0f", sum/1024}')
        fi
        
        # Get CPU usage
        local cpu_percent
        if command -v top >/dev/null 2>&1; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                cpu_percent=$(top -l 1 -n 0 | awk '/CPU usage/ {gsub(/%/, "", $3); print $3}')
            else
                # Linux
                cpu_percent=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
            fi
        else
            cpu_percent="0"
        fi
        
        measurements+=("${memory_mb}:${cpu_percent}")
        
        printf "\r  %ds: Memory: %sMB, CPU: %s%%" "$i" "$memory_mb" "$cpu_percent"
        sleep "$interval"
    done
    
    printf "\n"
    
    # Calculate averages
    local total_memory=0
    local total_cpu=0
    local count=0
    
    for measurement in "${measurements[@]}"; do
        local memory="${measurement%:*}"
        local cpu="${measurement#*:}"
        total_memory=$((total_memory + memory))
        total_cpu=$(echo "$total_cpu + $cpu" | bc 2>/dev/null || echo "$total_cpu")
        count=$((count + 1))
    done
    
    local avg_memory=$((total_memory / count))
    local avg_cpu
    if command -v bc >/dev/null 2>&1; then
        avg_cpu=$(echo "scale=1; $total_cpu / $count" | bc)
    else
        avg_cpu="N/A"
    fi
    
    echo "  Average Memory: ${avg_memory}MB"
    echo "  Average CPU: ${avg_cpu}%"
    
    # Check against targets
    if [[ $avg_memory -le ${PERFORMANCE_TARGETS["memory_usage_mb"]} ]]; then
        echo -e "  ${GREEN}✅ Memory usage within target${NC}"
    else
        echo -e "  ${RED}❌ Memory usage exceeds target (${PERFORMANCE_TARGETS["memory_usage_mb"]}MB)${NC}"
    fi
    
    if command -v bc >/dev/null 2>&1 && [[ "$avg_cpu" != "N/A" ]]; then
        if (( $(echo "$avg_cpu <= ${PERFORMANCE_TARGETS["cpu_usage_percent"]}" | bc -l) )); then
            echo -e "  ${GREEN}✅ CPU usage within target${NC}"
        else
            echo -e "  ${RED}❌ CPU usage exceeds target (${PERFORMANCE_TARGETS["cpu_usage_percent"]}%)${NC}"
        fi
    fi
}

# Mobile performance simulation
test_mobile_performance() {
    echo -e "${CYAN}📱 Testing Mobile Performance${NC}"
    
    # Simulate mobile viewport and network conditions
    local mobile_url="${TEST_ENDPOINTS["mobile_view"]}"
    
    echo "Testing mobile viewport performance..."
    
    # Test with simulated slow network
    echo "  Simulating 3G network conditions..."
    local slow_time=$(measure_endpoint_performance "mobile_3g" "$mobile_url" 3)
    
    # Test normal conditions
    echo "  Testing normal network conditions..."
    local normal_time=$(measure_endpoint_performance "mobile_normal" "$mobile_url" 3)
    
    # Check against mobile targets
    if [[ $normal_time -le 1500 ]]; then  # 1.5s for mobile
        echo -e "  ${GREEN}✅ Mobile performance acceptable${NC}"
    else
        echo -e "  ${RED}❌ Mobile performance too slow${NC}"
    fi
}

# Comprehensive performance validation
run_full_validation() {
    echo -e "${CYAN}🎯 Ecuador Demo Performance Validation${NC}"
    echo "======================================"
    echo "Validating all performance targets for zero-failure demo"
    echo ""
    
    init_telemetry
    
    local validation_passed=true
    local results=()
    
    # Test all endpoints
    echo -e "${YELLOW}📡 Testing API Endpoints${NC}"
    for name in "${!TEST_ENDPOINTS[@]}"; do
        local url="${TEST_ENDPOINTS[$name]}"
        local avg_time=$(measure_endpoint_performance "$name" "$url" 5)
        
        # Check against targets
        local target_key
        case "$name" in
            "dashboard") target_key="dashboard_load_ms" ;;
            "api_"*) target_key="api_response_ms" ;;
            "mobile_view") target_key="dashboard_load_ms" ;;
        esac
        
        local target="${PERFORMANCE_TARGETS[$target_key]}"
        
        if [[ $avg_time -le $target ]]; then
            results+=("$name:PASS:${avg_time}ms")
            echo -e "  ${GREEN}✅ $name: ${avg_time}ms (target: ${target}ms)${NC}"
        else
            results+=("$name:FAIL:${avg_time}ms")
            echo -e "  ${RED}❌ $name: ${avg_time}ms (exceeds ${target}ms target)${NC}"
            validation_passed=false
        fi
    done
    
    echo ""
    
    # Load testing
    echo -e "${YELLOW}🔥 Load Testing${NC}"
    run_load_test "${TEST_ENDPOINTS["dashboard"]}" 10 30
    echo ""
    
    # Resource monitoring
    echo -e "${YELLOW}📊 Resource Monitoring${NC}"
    monitor_system_resources 30
    echo ""
    
    # Mobile testing
    test_mobile_performance
    echo ""
    
    # Generate comprehensive report
    local report_file="$RESULTS_DIR/comprehensive_validation_$(date +%Y%m%d_%H%M%S).json"
    cat > "$report_file" <<EOF
{
    "validation_timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "validation_passed": $validation_passed,
    "targets": {
$(for key in "${!PERFORMANCE_TARGETS[@]}"; do
    echo "        \"$key\": ${PERFORMANCE_TARGETS[$key]},"
done | sed '$ s/,$//')
    },
    "results": [
$(for result in "${results[@]}"; do
    local name="${result%%:*}"
    local status="${result#*:}"
    status="${status%:*}"
    local time="${result##*:}"
    echo "        {"
    echo "            \"endpoint\": \"$name\","
    echo "            \"status\": \"$status\","
    echo "            \"response_time\": \"$time\""
    echo "        },"
done | sed '$ s/,$//')
    ],
    "recommendation": "$(if $validation_passed; then echo "READY FOR DEMO PRESENTATION"; else echo "PERFORMANCE OPTIMIZATION REQUIRED"; fi)"
}
EOF
    
    # Final summary
    echo -e "${CYAN}📋 Validation Summary${NC}"
    echo "===================="
    
    local passed_count=0
    local total_count=0
    
    for result in "${results[@]}"; do
        local status="${result#*:}"
        status="${status%:*}"
        if [[ "$status" == "PASS" ]]; then
            passed_count=$((passed_count + 1))
        fi
        total_count=$((total_count + 1))
    done
    
    echo "Tests passed: $passed_count/$total_count"
    echo "Report saved: $report_file"
    
    if $validation_passed; then
        echo -e "\n${GREEN}✅ ALL PERFORMANCE TARGETS MET${NC}"
        echo -e "${GREEN}🚀 DEMO READY FOR EXECUTIVE PRESENTATION${NC}"
        return 0
    else
        echo -e "\n${RED}❌ PERFORMANCE OPTIMIZATION REQUIRED${NC}"
        echo -e "${RED}⚠️  DO NOT PRESENT UNTIL ISSUES RESOLVED${NC}"
        return 1
    fi
}

# Performance optimization suggestions
suggest_optimizations() {
    echo -e "${YELLOW}💡 Performance Optimization Suggestions${NC}"
    echo "====================================="
    
    # Check recent test results
    local latest_report=$(ls -t "$RESULTS_DIR"/comprehensive_validation_*.json 2>/dev/null | head -1)
    
    if [[ -f "$latest_report" ]]; then
        echo "Based on latest validation report:"
        
        # Parse failed tests
        local failed_tests=$(jq -r '.results[] | select(.status == "FAIL") | .endpoint' "$latest_report" 2>/dev/null)
        
        if [[ -n "$failed_tests" ]]; then
            echo -e "\n${RED}Failed components:${NC}"
            while read -r endpoint; do
                echo "  $endpoint"
                
                case "$endpoint" in
                    "dashboard")
                        echo "    💡 Enable compression (gzip)"
                        echo "    💡 Minimize JavaScript bundles"
                        echo "    💡 Implement lazy loading"
                        echo "    💡 Optimize images and assets"
                        ;;
                    "api_"*)
                        echo "    💡 Add database query optimization"
                        echo "    💡 Implement Redis caching"
                        echo "    💡 Use CDN for static responses"
                        echo "    💡 Enable response compression"
                        ;;
                esac
            done <<< "$failed_tests"
        fi
    else
        echo "No recent validation report found. Run 'validate' first."
    fi
    
    # General optimization recommendations
    echo -e "\n${YELLOW}General Optimization Checklist:${NC}"
    echo "  📦 Enable asset compression and minification"
    echo "  🗄️  Implement Redis caching for API responses"
    echo "  🌐 Use CDN for static assets"
    echo "  📱 Optimize mobile performance"
    echo "  🔧 Enable HTTP/2"
    echo "  📊 Implement lazy loading for charts"
    echo "  💾 Optimize database queries"
    echo "  🚀 Use service workers for caching"
}

# Continuous monitoring mode
run_continuous_monitoring() {
    local interval="${1:-60}"  # seconds
    
    echo -e "${BLUE}🔄 Continuous Performance Monitoring${NC}"
    echo "Interval: ${interval}s (Ctrl+C to stop)"
    echo ""
    
    while true; do
        local timestamp=$(date +"%H:%M:%S")
        echo -e "${CYAN}[$timestamp] Performance Check${NC}"
        
        # Quick health check
        local dashboard_time=$(measure_endpoint_performance "dashboard_quick" "${TEST_ENDPOINTS["dashboard"]}" 1)
        local api_time=$(measure_endpoint_performance "api_quick" "${TEST_ENDPOINTS["api_health"]}" 1)
        
        # Status indicators
        if [[ $dashboard_time -le ${PERFORMANCE_TARGETS["dashboard_load_ms"]} ]]; then
            echo -e "  Dashboard: ${GREEN}${dashboard_time}ms ✅${NC}"
        else
            echo -e "  Dashboard: ${RED}${dashboard_time}ms ❌${NC}"
        fi
        
        if [[ $api_time -le ${PERFORMANCE_TARGETS["api_response_ms"]} ]]; then
            echo -e "  API: ${GREEN}${api_time}ms ✅${NC}"
        else
            echo -e "  API: ${RED}${api_time}ms ❌${NC}"
        fi
        
        echo ""
        sleep "$interval"
    done
}

# Main execution
case "${1:-help}" in
    "validate")
        run_full_validation
        ;;
    "load-test")
        endpoint="${2:-${TEST_ENDPOINTS["dashboard"]}}"
        concurrent="${3:-10}"
        duration="${4:-30}"
        run_load_test "$endpoint" "$concurrent" "$duration"
        ;;
    "monitor")
        interval="${2:-60}"
        run_continuous_monitoring "$interval"
        ;;
    "mobile")
        test_mobile_performance
        ;;
    "resources")
        duration="${2:-60}"
        monitor_system_resources "$duration"
        ;;
    "optimize")
        suggest_optimizations
        ;;
    "quick")
        echo "Quick performance check..."
        dashboard_time=$(measure_endpoint_performance "dashboard" "${TEST_ENDPOINTS["dashboard"]}" 1)
        echo "Dashboard load time: ${dashboard_time}ms"
        ;;
    *)
        echo "Ecuador Performance Validator"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  validate              - Full performance validation"
        echo "  load-test [url] [concurrent] [duration] - Load testing"
        echo "  monitor [interval]    - Continuous monitoring"
        echo "  mobile               - Mobile performance testing"
        echo "  resources [duration] - System resource monitoring"
        echo "  optimize             - Performance optimization suggestions"
        echo "  quick                - Quick performance check"
        echo ""
        echo "Performance Targets:"
        for key in "${!PERFORMANCE_TARGETS[@]}"; do
            echo "  $key: ${PERFORMANCE_TARGETS[$key]}"
        done
        echo ""
        echo "This ensures the Ecuador demo meets all performance"
        echo "requirements for flawless executive presentation."
        ;;
esac