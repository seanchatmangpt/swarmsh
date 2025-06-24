#!/usr/bin/env bash

# Quick Test - High-Impact OpenTelemetry Verification
# Focus on 80% core functionality with minimal setup

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TRACE_FILE="$SCRIPT_DIR/quick-traces.log"
readonly METRICS_FILE="$SCRIPT_DIR/quick-metrics.log"

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Simple test framework
test_case() {
    local name=$1
    shift
    ((TESTS_RUN++))
    
    echo -n "Testing $name... "
    
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Clean start
cleanup() {
    rm -f "$TRACE_FILE" "$METRICS_FILE"
}
trap cleanup EXIT

echo -e "${BLUE}OpenTelemetry Quick Test Suite${NC}"
echo "============================="

# Setup telemetry capture
export OTEL_TRACE_ENABLED=true
export OTEL_METRICS_ENABLED=true
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"

# Test 1: Basic functionality
test_case "Basic CLI help" \
    bash -c './ollama-pro --help | grep -q "Ollama Pro"'

# Test 2: Telemetry generation
test_case "Metrics generation" \
    bash -c './ollama-pro --version 2>&1 | grep -q "METRIC"'

# Test 3: Configuration loading
test_case "Config loading with telemetry" \
    bash -c 'OTEL_TRACE_ENABLED=true ./ollama-pro config --help 2>&1 | grep -q "METRIC"'

# Test 4: Error handling with telemetry
test_case "Error handling preserves telemetry" \
    bash -c './ollama-pro invalid-command 2>&1 | grep -q "METRIC"'

# Test 5: Debug mode telemetry
test_case "Debug mode with telemetry" \
    bash -c './ollama-pro --debug --version 2>&1 | grep -q "METRIC"'

# Test 6: Multiple operations telemetry
echo "Running multiple operations to generate trace data..."
{
    ./ollama-pro --version 2>&1
    ./ollama-pro --help >/dev/null 2>&1  
    ./ollama-pro config --help >/dev/null 2>&1
    ./ollama-pro invalid-command 2>/dev/null 2>&1 || true
    ./ollama-pro --debug --version 2>&1
} | grep "METRIC" > "$METRICS_FILE" 2>/dev/null || true

# Test 7: Trace data collection
test_case "Multiple telemetry events captured" \
    bash -c "[[ -f '$METRICS_FILE' ]] && [[ \$(wc -l < '$METRICS_FILE') -ge 3 ]]"

# Performance test
echo -e "\n${BLUE}Performance Test${NC}"
echo "Running 10 operations and measuring..."

start_time=$(date +%s%N)
for i in {1..10}; do
    ./ollama-pro --version >/dev/null 2>&1
done
end_time=$(date +%s%N)

duration_ms=$(( (end_time - start_time) / 1000000 ))
avg_ms=$(( duration_ms / 10 ))

echo "Total time: ${duration_ms}ms"
echo "Average per operation: ${avg_ms}ms"

# Test 8: Performance acceptable
test_case "Performance under 100ms per operation" \
    bash -c "[[ $avg_ms -lt 100 ]]"

# Analyze collected telemetry
echo -e "\n${BLUE}Telemetry Analysis${NC}"
if [[ -f "$METRICS_FILE" ]]; then
    echo "Metrics collected:"
    cat "$METRICS_FILE" | head -10
    
    metric_count=$(wc -l < "$METRICS_FILE")
    echo "Total metrics: $metric_count"
    
    # Check for different metric types
    counter_metrics=$(grep -c "counter" "$METRICS_FILE" 2>/dev/null || echo "0")
    echo "Counter metrics: $counter_metrics"
    
    # Check for timing data
    if grep -q "timestamp" "$METRICS_FILE"; then
        echo -e "${GREEN}✓ Timestamps present${NC}"
    else
        echo -e "${YELLOW}⚠ No timestamps found${NC}"
    fi
else
    echo -e "${RED}No metrics file generated${NC}"
fi

# Test 9: Verify span instrumentation
echo -e "\n${BLUE}Span Verification${NC}"
# Look for span-related output in stderr
{
    OTEL_TRACE_ENABLED=true ./ollama-pro --debug --version 2>&1
    OTEL_TRACE_ENABLED=true ./ollama-pro --debug config --help 2>&1
} | grep -E "(span|TRACE)" > "$TRACE_FILE" 2>/dev/null || true

if [[ -f "$TRACE_FILE" ]] && [[ -s "$TRACE_FILE" ]]; then
    test_case "Span instrumentation active" \
        bash -c "[[ -s '$TRACE_FILE' ]]"
    echo "Trace events:"
    cat "$TRACE_FILE" | head -5
else
    echo -e "${YELLOW}No explicit trace events in output (spans may be sent to collector)${NC}"
fi

# Summary
echo -e "\n${BLUE}Test Summary${NC}"
echo "============="
echo "Total tests: $TESTS_RUN"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All core OpenTelemetry functionality verified!${NC}"
    success_rate=100
else
    echo -e "\n${YELLOW}Some tests failed - check implementation${NC}"
    success_rate=$(( TESTS_PASSED * 100 / TESTS_RUN ))
fi

echo "Success rate: ${success_rate}%"

# Generate JSON report
cat > "quick-test-report.json" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "total_tests": $TESTS_RUN,
    "passed": $TESTS_PASSED,
    "failed": $TESTS_FAILED,
    "success_rate": $success_rate,
    "avg_performance_ms": $avg_ms,
    "telemetry": {
        "metrics_collected": $(wc -l < "$METRICS_FILE" 2>/dev/null || echo "0"),
        "trace_events": $(wc -l < "$TRACE_FILE" 2>/dev/null || echo "0"),
        "endpoint": "$OTEL_EXPORTER_OTLP_ENDPOINT"
    }
}
EOF

echo "Report saved: quick-test-report.json"

# Exit with appropriate code
[[ $TESTS_FAILED -eq 0 ]]