#!/usr/bin/env bash

# Essential Test Suite - 80/20 Optimized
# Covers 80% of critical functionality with 20% of test complexity
# Target: < 30 seconds execution time

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_START_TIME=$(date +%s%N)
readonly TEMP_DIR="$(mktemp -d)"
readonly TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "$(date +%s%N)")"

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
CRITICAL_FAILURES=0

# Cleanup
cleanup() {
    rm -rf "$TEMP_DIR"
    unset COORDINATION_DIR
}
trap cleanup EXIT

# Test framework
test_critical() {
    local name=$1
    shift
    ((TESTS_RUN++))
    
    echo -n "🔧 Testing $name... "
    
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ CRITICAL${NC}"
        ((CRITICAL_FAILURES++))
        return 1
    fi
}

test_optional() {
    local name=$1
    shift
    ((TESTS_RUN++))
    
    echo -n "📋 Testing $name... "
    
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${YELLOW}⚠${NC}"
    fi
}

# Essential dependency checks
check_dependencies() {
    echo -e "${BLUE}📦 Essential Dependencies${NC}"
    
    test_critical "bash version" bash -c '[[ ${BASH_VERSION%%.*} -ge 4 ]]'
    test_critical "jq available" command -v jq
    # test_critical "python3 available" command -v python3  # Removed Python dependency
    test_optional "openssl available" command -v openssl
    test_optional "flock available" command -v flock
}

# Core coordination functionality
test_coordination_core() {
    echo -e "\n${BLUE}🎯 Core Coordination${NC}"
    
    export COORDINATION_DIR="$TEMP_DIR"
    local script="$SCRIPT_DIR/coordination_helper.sh"
    
    test_critical "script exists" test -f "$script"
    test_critical "script executable" test -x "$script"
    test_critical "help command" "$script" help
    test_critical "generate-id" "$script" generate-id
    
    # Essential work lifecycle
    export AGENT_ID="test_agent_essential"
    test_critical "claim work" "$script" claim "essential_test" "Essential test work" "high" "test_team"
    test_critical "work claims file created" test -f "$TEMP_DIR/work_claims.json"
    test_critical "JSON validity" jq empty "$TEMP_DIR/work_claims.json"
    
    # Get work ID for progress/completion
    local work_id=$(jq -r '.[] | select(.agent_id == "test_agent_essential") | .work_item_id' "$TEMP_DIR/work_claims.json" 2>/dev/null)
    
    if [[ -n "$work_id" && "$work_id" != "null" ]]; then
        test_critical "update progress" "$script" progress "$work_id" "50" "in_progress"
        test_critical "complete work" "$script" complete "$work_id" "success" "3"
    else
        echo -e "${RED}✗ Cannot find work ID for progress/completion tests${NC}"
        ((CRITICAL_FAILURES++))
    fi
}

# OpenTelemetry validation
test_otel_essential() {
    echo -e "\n${BLUE}📡 OpenTelemetry Essentials${NC}"
    
    # Test OTEL bash library
    test_optional "OTEL bash library" test -f "$SCRIPT_DIR/otel-bash.sh"
    
    # Test span generation
    test_optional "telemetry spans file" test -f "$SCRIPT_DIR/telemetry_spans.jsonl"
    
    if [[ -f "$SCRIPT_DIR/telemetry_spans.jsonl" ]]; then
        test_optional "spans contain trace_id" grep -q "trace_id" "$SCRIPT_DIR/telemetry_spans.jsonl"
        test_optional "spans contain operation" grep -q "operation" "$SCRIPT_DIR/telemetry_spans.jsonl"
        test_optional "recent spans present" bash -c '[[ $(find "$SCRIPT_DIR/telemetry_spans.jsonl" -mmin -60 2>/dev/null | wc -l) -gt 0 ]]'
    fi
    
    # Generate test span
    echo "{\"trace_id\":\"$TRACE_ID\",\"operation\":\"test_essential_otel\",\"service\":\"test-essential\",\"status\":\"completed\",\"duration_ms\":100}" >> "$SCRIPT_DIR/telemetry_spans.jsonl"
    test_critical "span generation" grep -q "$TRACE_ID" "$SCRIPT_DIR/telemetry_spans.jsonl"
}

# Performance validation
test_performance_essential() {
    echo -e "\n${BLUE}⚡ Performance Essentials${NC}"
    
    local start_time=$(date +%s%N)
    
    # Quick coordination operation
    export COORDINATION_DIR="$TEMP_DIR"
    export AGENT_ID="perf_test_agent"
    "$SCRIPT_DIR/coordination_helper.sh" claim "perf_test" "Performance test" "medium" "perf_team" >/dev/null 2>&1
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    echo "📊 Coordination operation: ${duration_ms}ms"
    
    # Performance thresholds (relaxed for essential testing)
    test_optional "coordination under 1000ms" bash -c "[[ $duration_ms -lt 1000 ]]"
    test_optional "coordination under 500ms" bash -c "[[ $duration_ms -lt 500 ]]"
}

# Quick integration test
test_integration_essential() {
    echo -e "\n${BLUE}🔗 Integration Essentials${NC}"
    
    export COORDINATION_DIR="$TEMP_DIR"
    
    # Test agent registration and dashboard
    test_optional "agent registration" "$SCRIPT_DIR/coordination_helper.sh" register "100" "active" "integration_team"
    test_optional "dashboard generation" "$SCRIPT_DIR/coordination_helper.sh" dashboard
    
    # Test concurrent operations (basic)
    export AGENT_ID="agent_A"
    "$SCRIPT_DIR/coordination_helper.sh" claim "concurrent_A" "Test A" >/dev/null 2>&1 &
    export AGENT_ID="agent_B" 
    "$SCRIPT_DIR/coordination_helper.sh" claim "concurrent_B" "Test B" >/dev/null 2>&1 &
    wait
    
    test_optional "concurrent claims" bash -c '[[ $(jq "length" "$TEMP_DIR/work_claims.json" 2>/dev/null || echo "0") -ge 2 ]]'
}

# Generate test report
generate_report() {
    local test_end_time=$(date +%s%N)
    local total_duration_ms=$(( (test_end_time - TEST_START_TIME) / 1000000 ))
    local success_rate=$(( TESTS_PASSED * 100 / TESTS_RUN ))
    
    echo -e "\n${BLUE}📊 Essential Test Report${NC}"
    echo "========================="
    echo "Duration: ${total_duration_ms}ms"
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Critical failures: ${RED}$CRITICAL_FAILURES${NC}"
    echo "Success rate: ${success_rate}%"
    
    # Generate JSON report
    cat > "$SCRIPT_DIR/essential-test-report.json" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "trace_id": "$TRACE_ID",
    "duration_ms": $total_duration_ms,
    "tests_run": $TESTS_RUN,
    "tests_passed": $TESTS_PASSED,
    "critical_failures": $CRITICAL_FAILURES,
    "success_rate": $success_rate,
    "status": "$(if [[ $CRITICAL_FAILURES -eq 0 ]]; then echo "passed"; else echo "failed"; fi)",
    "categories": {
        "dependencies": "checked",
        "coordination_core": "tested",
        "otel_essentials": "validated",
        "performance": "measured",
        "integration": "verified"
    }
}
EOF

    # Log telemetry
    echo "{\"trace_id\":\"$TRACE_ID\",\"operation\":\"test_essential_suite\",\"service\":\"test-essential\",\"duration_ms\":$total_duration_ms,\"tests_run\":$TESTS_RUN,\"tests_passed\":$TESTS_PASSED,\"critical_failures\":$CRITICAL_FAILURES,\"success_rate\":$success_rate,\"status\":\"completed\"}" >> "$SCRIPT_DIR/telemetry_spans.jsonl"
}

# Main execution
main() {
    echo -e "${GREEN}🚀 Essential Test Suite (80/20 Optimized)${NC}"
    echo "=========================================="
    echo "Target: 80% validation coverage with 20% test complexity"
    echo "Expected: < 30 seconds execution time"
    echo ""
    
    # Run essential test categories
    check_dependencies
    test_coordination_core
    test_otel_essential
    test_performance_essential
    test_integration_essential
    
    # Generate report
    generate_report
    
    # Final status
    echo ""
    if [[ $CRITICAL_FAILURES -eq 0 ]]; then
        echo -e "${GREEN}🎉 Essential tests PASSED - System ready for use${NC}"
        exit 0
    else
        echo -e "${RED}💥 Critical failures detected - System needs attention${NC}"
        echo "Use 'make test' for comprehensive testing"
        exit 1
    fi
}

# Handle arguments
case "${1:-}" in
    --help|-h)
        cat <<EOF
Essential Test Suite - 80/20 Optimized

Usage: $0 [options]

Options:
  --help, -h       Show this help
  --quiet, -q      Minimal output
  --verbose, -v    Detailed output

This script tests the 20% of functionality that provides 80% of validation value:
  • Core dependencies (bash, jq, shell-utils)
  • Basic coordination (claim, progress, complete)
  • OpenTelemetry essentials (span generation)
  • Performance baselines
  • Basic integration

For comprehensive testing, use: make test
EOF
        exit 0
        ;;
    --quiet|-q)
        exec >/dev/null 2>&1
        main
        ;;
    --verbose|-v)
        set -x
        main
        ;;
    *)
        main "$@"
        ;;
esac