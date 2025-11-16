#!/usr/bin/env bash

# Run Ollama Pro Tests with Full OpenTelemetry Instrumentation
# This script sets up the telemetry infrastructure and runs comprehensive tests

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TELEMETRY_DATA_DIR="$SCRIPT_DIR/telemetry-data"
readonly TEST_RESULTS_DIR="$SCRIPT_DIR/tests/results"
readonly TEST_TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Create directories
mkdir -p "$TELEMETRY_DATA_DIR" "$TEST_RESULTS_DIR"

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up telemetry infrastructure...${NC}"
    
    # Stop Docker containers
    docker-compose -f docker-compose.otel.yml down --volumes 2>/dev/null || true
    
    # Kill any local OTEL collector
    pkill -f "otelcol" 2>/dev/null || true
    
    echo -e "${GREEN}Cleanup complete${NC}"
}

trap cleanup EXIT INT TERM

# Start telemetry infrastructure
start_telemetry_infrastructure() {
    echo -e "${BLUE}Starting OpenTelemetry infrastructure...${NC}"
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker not available, starting local OTEL collector...${NC}"
        start_local_collector
        return
    fi
    
    # Set environment variables
    export OTEL_TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    
    # Start Docker infrastructure
    docker-compose -f docker-compose.otel.yml up -d
    
    # Wait for services to be ready
    echo -e "${CYAN}Waiting for services to be ready...${NC}"
    wait_for_service "http://localhost:13133" "OTEL Collector"
    wait_for_service "http://localhost:16686" "Jaeger UI"
    wait_for_service "http://localhost:9090" "Prometheus"
    
    echo -e "${GREEN}✓ Telemetry infrastructure is ready${NC}"
    echo -e "${CYAN}  Jaeger UI: http://localhost:16686${NC}"
    echo -e "${CYAN}  Prometheus: http://localhost:9090${NC}"
    echo -e "${CYAN}  Grafana: http://localhost:3000 (admin/admin123)${NC}"
}

# Start local OTEL collector if Docker is not available
start_local_collector() {
    if ! command -v otelcol-contrib &> /dev/null; then
        echo -e "${RED}Error: otelcol-contrib not found. Please install OpenTelemetry Collector.${NC}"
        echo "Installation: https://opentelemetry.io/docs/collector/getting-started/"
        exit 1
    fi
    
    # Start local collector
    otelcol-contrib --config="$SCRIPT_DIR/otel-collector.yaml" &
    local collector_pid=$!
    
    # Wait for collector to start
    sleep 5
    
    if ! kill -0 $collector_pid 2>/dev/null; then
        echo -e "${RED}Failed to start OTEL collector${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Local OTEL collector started (PID: $collector_pid)${NC}"
}

# Wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -sf "$url" >/dev/null 2>&1; then
            echo -e "${GREEN}✓ $service_name is ready${NC}"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    echo -e "\n${RED}✗ $service_name failed to start${NC}"
    return 1
}

# Configure environment for testing
configure_test_environment() {
    echo -e "${BLUE}Configuring test environment...${NC}"
    
    # OpenTelemetry configuration
    export OTEL_SERVICE_NAME="ollama-pro"
    export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
    export OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="http://localhost:4318/v1/traces"
    export OTEL_TRACE_ENABLED="true"
    export OTEL_METRICS_ENABLED="true"
    export OTEL_RESOURCE_ATTRIBUTES="service.name=ollama-pro,service.version=1.1.0,deployment.environment=test"
    
    # Test-specific configuration
    export TEST_WITH_TELEMETRY="true"
    export OLLAMA_HOST="http://localhost:11434"
    export TDD_WORK_DIR="$SCRIPT_DIR"
    
    echo -e "${GREEN}✓ Test environment configured${NC}"
}

# Run test suite with telemetry
run_instrumented_tests() {
    echo -e "${BLUE}Running instrumented test suite...${NC}"
    
    local test_start_time=$(date +%s%N)
    local test_result=0
    
    # Run the main test suite
    if ./test-ollama-pro.sh --verbose; then
        echo -e "${GREEN}✓ Test suite completed successfully${NC}"
    else
        test_result=$?
        echo -e "${RED}✗ Test suite failed with exit code $test_result${NC}"
    fi
    
    local test_end_time=$(date +%s%N)
    local test_duration=$(( (test_end_time - test_start_time) / 1000000 ))
    
    echo -e "${CYAN}Test execution time: ${test_duration}ms${NC}"
    
    return $test_result
}

# Analyze telemetry data
analyze_telemetry_data() {
    echo -e "${BLUE}Analyzing telemetry data...${NC}"
    
    # Wait for data to be flushed
    sleep 5
    
    # Check for trace files
    if [[ -f "$TELEMETRY_DATA_DIR/traces.json" ]]; then
        local trace_count=$(grep -c '"traceId"' "$TELEMETRY_DATA_DIR/traces.json" 2>/dev/null || echo "0")
        echo -e "${CYAN}Traces collected: $trace_count${NC}"
        
        # Extract trace information
        analyze_traces
    else
        echo -e "${YELLOW}Warning: No trace data found${NC}"
    fi
    
    # Check for metrics files
    if [[ -f "$TELEMETRY_DATA_DIR/metrics.json" ]]; then
        local metric_count=$(grep -c '"name"' "$TELEMETRY_DATA_DIR/metrics.json" 2>/dev/null || echo "0")
        echo -e "${CYAN}Metrics collected: $metric_count${NC}"
        
        # Extract metrics information
        analyze_metrics
    else
        echo -e "${YELLOW}Warning: No metrics data found${NC}"
    fi
}

# Analyze trace data
analyze_traces() {
    echo -e "${BLUE}Trace Analysis:${NC}"
    
    if command -v jq &>/dev/null && [[ -f "$TELEMETRY_DATA_DIR/traces.json" ]]; then
        # Extract trace statistics
        cat "$TELEMETRY_DATA_DIR/traces.json" | jq -r '
            .resourceSpans[]?.scopeSpans[]?.spans[]? |
            select(.name != null) |
            "Span: \(.name) | Duration: \((.endTimeUnixNano - .startTimeUnixNano) / 1000000)ms | Status: \(.status.code // "UNSET")"
        ' | head -20
        
        # Count spans by operation
        echo -e "\n${CYAN}Top Operations:${NC}"
        cat "$TELEMETRY_DATA_DIR/traces.json" | jq -r '
            .resourceSpans[]?.scopeSpans[]?.spans[]?.name // empty
        ' | sort | uniq -c | sort -nr | head -10
        
        # Calculate average durations
        echo -e "\n${CYAN}Average Durations by Operation:${NC}"
        cat "$TELEMETRY_DATA_DIR/traces.json" | jq -r '
            .resourceSpans[]?.scopeSpans[]?.spans[]? |
            select(.name != null and .endTimeUnixNano != null and .startTimeUnixNano != null) |
            "\(.name) \((.endTimeUnixNano - .startTimeUnixNano) / 1000000)"
        ' | awk '{
            durations[$1] += $2
            counts[$1]++
        } END {
            for (op in durations) {
                printf "%s: %.2fms (count: %d)\n", op, durations[op]/counts[op], counts[op]
            }
        }' | sort -k2 -nr | head -10
    fi
}

# Analyze metrics data
analyze_metrics() {
    echo -e "\n${BLUE}Metrics Analysis:${NC}"
    
    if command -v jq &>/dev/null && [[ -f "$TELEMETRY_DATA_DIR/metrics.json" ]]; then
        # Extract metric statistics
        echo -e "${CYAN}Metrics Summary:${NC}"
        cat "$TELEMETRY_DATA_DIR/metrics.json" | jq -r '
            .resourceMetrics[]?.scopeMetrics[]?.metrics[]? |
            select(.name != null) |
            "Metric: \(.name) | Type: \(.gauge // .counter // .histogram // "unknown" | type)"
        ' | sort | uniq -c | sort -nr
        
        # Show recent metric values
        echo -e "\n${CYAN}Recent Metric Values:${NC}"
        cat "$TELEMETRY_DATA_DIR/metrics.json" | jq -r '
            .resourceMetrics[]?.scopeMetrics[]?.metrics[]? |
            select(.name != null) |
            if .gauge then
                "GAUGE \(.name): \(.gauge.dataPoints[]?.asDouble // .gauge.dataPoints[]?.asInt // "N/A")"
            elif .counter then
                "COUNTER \(.name): \(.counter.dataPoints[]?.asDouble // .counter.dataPoints[]?.asInt // "N/A")"
            else
                "OTHER \(.name): \(.histogram.dataPoints[]?.count // "N/A")"
            end
        ' | head -20
    fi
}

# Generate comprehensive report
generate_telemetry_report() {
    echo -e "${BLUE}Generating telemetry report...${NC}"
    
    local report_file="$TEST_RESULTS_DIR/telemetry-report-$TEST_TIMESTAMP.json"
    
    cat > "$report_file" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "test_session": "$TEST_TIMESTAMP",
    "infrastructure": {
        "collector_endpoint": "$OTEL_EXPORTER_OTLP_ENDPOINT",
        "jaeger_ui": "http://localhost:16686",
        "prometheus": "http://localhost:9090"
    },
    "data_files": {
        "traces": "$TELEMETRY_DATA_DIR/traces.json",
        "metrics": "$TELEMETRY_DATA_DIR/metrics.json"
    },
    "summary": {
        "traces_collected": $(grep -c '"traceId"' "$TELEMETRY_DATA_DIR/traces.json" 2>/dev/null || echo "0"),
        "metrics_collected": $(grep -c '"name"' "$TELEMETRY_DATA_DIR/metrics.json" 2>/dev/null || echo "0"),
        "test_duration_ms": "calculated_in_test",
        "status": "completed"
    }
}
EOF
    
    echo -e "${GREEN}✓ Telemetry report saved: $report_file${NC}"
}

# Verify trace completeness
verify_trace_completeness() {
    echo -e "${BLUE}Verifying trace completeness...${NC}"
    
    local required_spans=(
        "ollama_pro.main"
        "api.request"
        "model.list"
        "chat.completion"
        "config.load"
    )
    
    local missing_spans=()
    
    for span in "${required_spans[@]}"; do
        if [[ -f "$TELEMETRY_DATA_DIR/traces.json" ]]; then
            if ! grep -q "\"$span\"" "$TELEMETRY_DATA_DIR/traces.json"; then
                missing_spans+=("$span")
            fi
        else
            missing_spans+=("$span")
        fi
    done
    
    if [[ ${#missing_spans[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓ All required spans are present${NC}"
        return 0
    else
        echo -e "${RED}✗ Missing spans:${NC}"
        for span in "${missing_spans[@]}"; do
            echo -e "  ${RED}- $span${NC}"
        done
        return 1
    fi
}

# Main execution
main() {
    echo -e "${GREEN}Ollama Pro - OpenTelemetry Test Suite${NC}"
    echo "======================================"
    
    # Start telemetry infrastructure
    start_telemetry_infrastructure
    
    # Configure environment
    configure_test_environment
    
    # Run tests
    local test_exit_code=0
    run_instrumented_tests || test_exit_code=$?
    
    # Analyze results
    analyze_telemetry_data
    
    # Verify completeness
    verify_trace_completeness
    
    # Generate report
    generate_telemetry_report
    
    # Final summary
    echo
    echo "======================================"
    if [[ $test_exit_code -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed with full telemetry${NC}"
    else
        echo -e "${RED}✗ Tests failed (exit code: $test_exit_code)${NC}"
    fi
    
    echo -e "${CYAN}Telemetry data saved in: $TELEMETRY_DATA_DIR${NC}"
    echo -e "${CYAN}View traces: http://localhost:16686${NC}"
    echo -e "${CYAN}View metrics: http://localhost:9090${NC}"
    
    exit $test_exit_code
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        cat <<EOF
OpenTelemetry Test Runner for Ollama Pro

Usage: $0 [options]

Options:
  --help, -h       Show this help message
  --local          Use local OTEL collector instead of Docker
  --analyze-only   Only analyze existing telemetry data
  --no-cleanup     Don't cleanup infrastructure after tests

Environment Variables:
  OTEL_EXPORTER_OTLP_ENDPOINT    Override OTLP endpoint
  TEST_FILTER                    Filter tests to run
  DOCKER_COMPOSE_FILE            Override Docker Compose file
EOF
        exit 0
        ;;
    --local)
        export USE_LOCAL_COLLECTOR=true
        shift
        main "$@"
        ;;
    --analyze-only)
        analyze_telemetry_data
        verify_trace_completeness
        generate_telemetry_report
        exit 0
        ;;
    --no-cleanup)
        trap - EXIT
        main "$@"
        ;;
    *)
        main "$@"
        ;;
esac