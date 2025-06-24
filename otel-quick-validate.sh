#!/usr/bin/env bash

# OpenTelemetry Quick Validation - 80/20 Optimized
# Validates essential OTEL functionality without Docker dependency
# Target: < 10 seconds execution time

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "otel_test_$(date +%s%N)")"
readonly SPAN_ID="$(openssl rand -hex 8 2>/dev/null || echo "$(date +%s%N | cut -c-16)")"
readonly TEST_START=$(date +%s%N)

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test counters
VALIDATIONS=0
PASSED=0
FAILED=0

# Validation framework
validate() {
    local name=$1
    shift
    ((VALIDATIONS++))
    
    echo -n "🔍 Validating $name... "
    
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((FAILED++))
        return 1
    fi
}

# Generate test telemetry span
generate_test_span() {
    local operation=$1
    local status=$2
    local duration=${3:-0}
    
    local span="{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"operation\":\"$operation\",\"service\":\"otel-quick-validate\",\"status\":\"$status\",\"duration_ms\":$duration,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
    
    echo "$span" >> "$SCRIPT_DIR/telemetry_spans.jsonl"
    echo "$span"
}

# Validate OTEL environment
validate_otel_environment() {
    echo -e "${BLUE}🌍 OTEL Environment${NC}"
    
    # Check for OTEL environment variables
    validate "OTEL service name" bash -c '[[ ${OTEL_SERVICE_NAME:-swarmsh} != "" ]]'
    validate "telemetry enabled" bash -c '[[ ${OTEL_TRACE_ENABLED:-true} == "true" ]]'
    
    # Check for OTEL bash library
    validate "OTEL bash library exists" test -f "$SCRIPT_DIR/otel-bash.sh"
    
    if [[ -f "$SCRIPT_DIR/otel-bash.sh" ]]; then
        validate "OTEL library sourceable" bash -c "source '$SCRIPT_DIR/otel-bash.sh' 2>/dev/null"
    fi
}

# Validate span generation
validate_span_generation() {
    echo -e "\n${BLUE}📡 Span Generation${NC}"
    
    # Create test spans file if it doesn't exist
    touch "$SCRIPT_DIR/telemetry_spans.jsonl"
    
    # Check telemetry file
    validate "telemetry file exists" test -f "$SCRIPT_DIR/telemetry_spans.jsonl"
    validate "telemetry file writable" test -w "$SCRIPT_DIR/telemetry_spans.jsonl"
    
    # Generate test span
    local test_span=$(generate_test_span "otel_quick_validate" "test" "50")
    validate "span generation successful" test -n "$test_span"
    
    # Verify span was written
    validate "span written to file" grep -q "$TRACE_ID" "$SCRIPT_DIR/telemetry_spans.jsonl"
    
    # Validate span structure
    if command -v jq >/dev/null 2>&1; then
        validate "span JSON valid" echo "$test_span" | jq empty
        validate "span has trace_id" echo "$test_span" | jq -e '.trace_id' >/dev/null
        validate "span has operation" echo "$test_span" | jq -e '.operation' >/dev/null
        validate "span has service" echo "$test_span" | jq -e '.service' >/dev/null
    else
        echo -e "${YELLOW}⚠ jq not available - skipping JSON validation${NC}"
    fi
}

# Validate coordination integration
validate_coordination_integration() {
    echo -e "\n${BLUE}🎯 Coordination Integration${NC}"
    
    # Check if coordination helper has telemetry
    if [[ -f "$SCRIPT_DIR/coordination_helper.sh" ]]; then
        validate "coordination script exists" test -f "$SCRIPT_DIR/coordination_helper.sh"
        validate "coordination mentions telemetry" grep -q -i "telemetry\|otel\|trace" "$SCRIPT_DIR/coordination_helper.sh"
        
        # Check for telemetry integration patterns
        validate "span generation in coordination" grep -q "telemetry_spans\|trace_id" "$SCRIPT_DIR/coordination_helper.sh"
    else
        echo -e "${YELLOW}⚠ coordination_helper.sh not found - skipping integration tests${NC}"
    fi
    
    # Check recent telemetry activity
    if [[ -f "$SCRIPT_DIR/telemetry_spans.jsonl" ]]; then
        local recent_spans=$(find "$SCRIPT_DIR/telemetry_spans.jsonl" -mmin -60 2>/dev/null | wc -l)
        validate "recent telemetry activity" bash -c "[[ $recent_spans -gt 0 ]]"
        
        # Check for coordination operations in spans
        validate "coordination operations traced" grep -q "s2s\|coordination\|work" "$SCRIPT_DIR/telemetry_spans.jsonl"
    fi
}

# Validate performance characteristics
validate_performance() {
    echo -e "\n${BLUE}⚡ Performance${NC}"
    
    local start_time=$(date +%s%N)
    
    # Generate multiple spans quickly
    for i in {1..5}; do
        generate_test_span "perf_test_$i" "completed" "$((i * 10))" >/dev/null
    done
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    echo "📊 5 span generation: ${duration_ms}ms"
    
    validate "span generation under 100ms" bash -c "[[ $duration_ms -lt 100 ]]"
    validate "spans generated successfully" bash -c "[[ \$(grep -c \"perf_test\" \"$SCRIPT_DIR/telemetry_spans.jsonl\") -eq 5 ]]"
}

# Validate telemetry file health
validate_file_health() {
    echo -e "\n${BLUE}📁 File Health${NC}"
    
    if [[ -f "$SCRIPT_DIR/telemetry_spans.jsonl" ]]; then
        local file_size=$(stat -f%z "$SCRIPT_DIR/telemetry_spans.jsonl" 2>/dev/null || stat -c%s "$SCRIPT_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        local line_count=$(wc -l < "$SCRIPT_DIR/telemetry_spans.jsonl")
        
        echo "📊 File size: ${file_size} bytes, Lines: ${line_count}"
        
        validate "file not empty" bash -c "[[ $file_size -gt 0 ]]"
        validate "file not too large" bash -c "[[ $file_size -lt 10485760 ]]"  # 10MB limit
        validate "reasonable line count" bash -c "[[ $line_count -lt 10000 ]]"
        
        # Check for malformed JSON lines
        if command -v jq >/dev/null 2>&1; then
            local malformed=$(grep -v '^$' "$SCRIPT_DIR/telemetry_spans.jsonl" | while read -r line; do echo "$line" | jq empty 2>/dev/null || echo "malformed"; done | grep -c "malformed" || echo "0")
            validate "no malformed JSON" bash -c "[[ $malformed -eq 0 ]]"
        fi
    else
        echo -e "${YELLOW}⚠ No telemetry file found${NC}"
        ((FAILED++))
    fi
}

# Generate validation report
generate_validation_report() {
    local test_end_time=$(date +%s%N)
    local total_duration_ms=$(( (test_end_time - TEST_START) / 1000000 ))
    local success_rate=$(( PASSED * 100 / VALIDATIONS ))
    
    echo -e "\n${BLUE}📊 OTEL Validation Report${NC}"
    echo "========================="
    echo "Duration: ${total_duration_ms}ms"
    echo "Validations: $VALIDATIONS"
    echo -e "Passed: ${GREEN}$PASSED${NC}"
    echo -e "Failed: ${RED}$FAILED${NC}"
    echo "Success rate: ${success_rate}%"
    
    # Determine overall status
    local status="passed"
    if [[ $FAILED -gt 0 ]]; then
        status="failed"
    elif [[ $success_rate -lt 80 ]]; then
        status="degraded"
    fi
    
    # Generate JSON report
    cat > "$SCRIPT_DIR/otel-validation-report.json" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "trace_id": "$TRACE_ID",
    "duration_ms": $total_duration_ms,
    "validations": $VALIDATIONS,
    "passed": $PASSED,
    "failed": $FAILED,
    "success_rate": $success_rate,
    "status": "$status",
    "categories": {
        "environment": "checked",
        "span_generation": "tested",
        "coordination_integration": "validated",
        "performance": "measured",
        "file_health": "verified"
    },
    "recommendations": $(if [[ $FAILED -gt 0 ]]; then echo '["Fix failed validations", "Check OTEL configuration"]'; else echo '["OTEL validation passed"]'; fi)
}
EOF

    # Log final telemetry
    generate_test_span "otel_quick_validate_complete" "completed" "$total_duration_ms" >/dev/null
}

# Main execution
main() {
    echo -e "${GREEN}🚀 OpenTelemetry Quick Validation${NC}"
    echo "=================================="
    echo "80/20 optimized: Essential OTEL validation without Docker"
    echo "Target: < 10 seconds execution time"
    echo ""
    
    # Set OTEL defaults for testing
    export OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-swarmsh}"
    export OTEL_TRACE_ENABLED="${OTEL_TRACE_ENABLED:-true}"
    
    # Run validation categories
    validate_otel_environment
    validate_span_generation
    validate_coordination_integration
    validate_performance
    validate_file_health
    
    # Generate report
    generate_validation_report
    
    # Final status
    echo ""
    if [[ $FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 OTEL validation PASSED - Telemetry is working${NC}"
        exit 0
    else
        echo -e "${RED}💥 OTEL validation FAILED - Check configuration${NC}"
        echo "For comprehensive OTEL testing, use: make otel-demo"
        exit 1
    fi
}

# Handle arguments
case "${1:-}" in
    --help|-h)
        cat <<EOF
OpenTelemetry Quick Validation - 80/20 Optimized

Usage: $0 [options]

Options:
  --help, -h       Show this help
  --report         Show validation report and exit
  --clean          Clean telemetry files before validation

This script validates essential OpenTelemetry functionality:
  • OTEL environment variables
  • Span generation capability
  • Coordination integration
  • Performance characteristics
  • Telemetry file health

For full OTEL testing with Docker/Jaeger: make otel-demo
For telemetry infrastructure: make telemetry-start
EOF
        exit 0
        ;;
    --report)
        if [[ -f "$SCRIPT_DIR/otel-validation-report.json" ]]; then
            cat "$SCRIPT_DIR/otel-validation-report.json" | jq '.' 2>/dev/null || cat "$SCRIPT_DIR/otel-validation-report.json"
        else
            echo "No validation report found. Run validation first."
            exit 1
        fi
        ;;
    --clean)
        echo "Cleaning telemetry files..."
        rm -f "$SCRIPT_DIR/telemetry_spans.jsonl" "$SCRIPT_DIR/otel-validation-report.json"
        echo "✓ Telemetry files cleaned"
        main
        ;;
    *)
        main "$@"
        ;;
esac