#!/usr/bin/env bash

# Essential Test Suite - deterministic core validation for SwarmSH.
# Exercises the admitted coordination lifecycle without mutating repository state.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_START_TIME="$(date +%s%N)"
readonly TEMP_DIR="$(mktemp -d)"
readonly REPORT_DIR="${SWARMSH_TEST_REPORT_DIR:-$SCRIPT_DIR/.swarmsh-test-results}"
readonly TRACE_ID="$(openssl rand -hex 16 2>/dev/null || printf '%s' "$(date +%s%N)")"

readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

TESTS_RUN=0
TESTS_PASSED=0
CRITICAL_FAILURES=0

cleanup() {
    rm -rf "$TEMP_DIR"
    unset COORDINATION_DIR AGENT_ID FORCE_TRACE_ID
}
trap cleanup EXIT

increment() {
    local variable="$1"
    printf -v "$variable" '%d' "$(( ${!variable} + 1 ))"
}

test_critical() {
    local name="$1"
    shift
    increment TESTS_RUN

    echo -n "🔧 Testing $name... "
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        increment TESTS_PASSED
    else
        echo -e "${RED}✗ CRITICAL${NC}"
        increment CRITICAL_FAILURES
        return 1
    fi
}

test_optional() {
    local name="$1"
    shift
    increment TESTS_RUN

    echo -n "📋 Testing $name... "
    if "$@" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        increment TESTS_PASSED
    else
        echo -e "${YELLOW}⚠${NC}"
    fi
}

check_dependencies() {
    echo -e "${BLUE}📦 Essential Dependencies${NC}"
    test_critical "bash version" bash -c '[[ ${BASH_VERSION%%.*} -ge 4 ]]'
    test_critical "jq available" command -v jq
    test_critical "python3 available" command -v python3
    test_optional "openssl available" command -v openssl
    test_optional "flock available" command -v flock
}

test_environment_contract() {
    echo -e "\n${BLUE}🌐 Environment Contract${NC}"
    test_critical "environment helper exists" test -f "$SCRIPT_DIR/lib/s2s-env.sh"
    test_critical "repo root detection" bash -c "cd '$SCRIPT_DIR' && source ./lib/s2s-env.sh && [[ \"\$S2S_ROOT\" == '$SCRIPT_DIR' ]]"
    test_critical "coordination override" bash -c "cd '$SCRIPT_DIR' && COORDINATION_DIR='$TEMP_DIR' source ./lib/s2s-env.sh && [[ \"\$COORDINATION_DIR\" == '$TEMP_DIR' ]]"
}

test_coordination_core() {
    echo -e "\n${BLUE}🎯 Core Coordination${NC}"

    export COORDINATION_DIR="$TEMP_DIR"
    export FORCE_TRACE_ID="$TRACE_ID"
    local script="$SCRIPT_DIR/coordination_helper.sh"

    test_critical "script exists" test -f "$script"
    test_critical "script executable" test -x "$script"
    test_critical "help command" "$script" help
    test_critical "generate-id" "$script" generate-id

    export AGENT_ID="test_agent_essential"
    test_critical "claim work" "$script" claim "essential_test" "Essential test work" "high" "test_team"
    test_critical "work claims file created" test -f "$TEMP_DIR/work_claims.json"
    test_critical "work claims JSON valid" jq empty "$TEMP_DIR/work_claims.json"
    test_critical "agent status JSON valid" jq empty "$TEMP_DIR/agent_status.json"

    local work_id
    work_id="$(jq -r '.[] | select(.agent_id == "test_agent_essential") | .work_item_id' "$TEMP_DIR/work_claims.json" | head -1)"

    if [[ -n "$work_id" && "$work_id" != "null" ]]; then
        test_critical "update progress" "$script" progress "$work_id" "50" "in_progress"
        test_critical "complete work" "$script" complete "$work_id" "success" "3"
    else
        echo -e "${RED}✗ Cannot find work ID for lifecycle tests${NC}"
        increment CRITICAL_FAILURES
    fi
}

test_otel_essential() {
    echo -e "\n${BLUE}📡 OpenTelemetry Essentials${NC}"
    local telemetry_file="$TEMP_DIR/telemetry_spans.jsonl"

    test_optional "OTEL bash library" test -f "$SCRIPT_DIR/otel-bash.sh"
    test_critical "telemetry emitted" test -s "$telemetry_file"
    test_critical "telemetry contains trace_id" grep -q 'trace_id' "$telemetry_file"
    test_critical "forced trace propagated" grep -q "$TRACE_ID" "$telemetry_file"
}

test_performance_essential() {
    echo -e "\n${BLUE}⚡ Performance Essentials${NC}"

    local start_time end_time duration_ms
    start_time="$(date +%s%N)"
    export AGENT_ID="perf_test_agent"
    "$SCRIPT_DIR/coordination_helper.sh" claim "perf_test" "Performance test" "medium" "perf_team" >/dev/null 2>&1
    end_time="$(date +%s%N)"
    duration_ms=$(( (end_time - start_time) / 1000000 ))

    echo "📊 Coordination operation: ${duration_ms}ms"
    test_optional "coordination under 1000ms" bash -c "[[ $duration_ms -lt 1000 ]]"
    test_optional "coordination under 500ms" bash -c "[[ $duration_ms -lt 500 ]]"
}

test_integration_essential() {
    echo -e "\n${BLUE}🔗 Integration Essentials${NC}"

    test_optional "agent registration" "$SCRIPT_DIR/coordination_helper.sh" register "100" "active" "integration_team"
    test_optional "dashboard generation" "$SCRIPT_DIR/coordination_helper.sh" dashboard
    test_critical "compatibility proxy" "$SCRIPT_DIR/real_agent_coordinator.sh" help

    AGENT_ID="agent_A" "$SCRIPT_DIR/coordination_helper.sh" claim "concurrent_A" "Test A" >/dev/null 2>&1 &
    local pid_a=$!
    AGENT_ID="agent_B" "$SCRIPT_DIR/coordination_helper.sh" claim "concurrent_B" "Test B" >/dev/null 2>&1 &
    local pid_b=$!

    local concurrent_ok=0
    wait "$pid_a" || concurrent_ok=1
    wait "$pid_b" || concurrent_ok=1

    if [[ "$concurrent_ok" -eq 0 ]]; then
        test_critical "concurrent claims persisted" bash -c "[[ \$(jq '[.[] | select(.agent_id == \"agent_A\" or .agent_id == \"agent_B\")] | length' '$TEMP_DIR/work_claims.json') -eq 2 ]]"
    else
        echo -e "${RED}✗ Concurrent claim process failed${NC}"
        increment CRITICAL_FAILURES
    fi
}

generate_report() {
    local test_end_time total_duration_ms success_rate status
    test_end_time="$(date +%s%N)"
    total_duration_ms=$(( (test_end_time - TEST_START_TIME) / 1000000 ))

    if [[ "$TESTS_RUN" -eq 0 ]]; then
        success_rate=0
    else
        success_rate=$(( TESTS_PASSED * 100 / TESTS_RUN ))
    fi

    if [[ "$CRITICAL_FAILURES" -eq 0 ]]; then
        status="passed"
    else
        status="failed"
    fi

    mkdir -p "$REPORT_DIR"

    echo -e "\n${BLUE}📊 Essential Test Report${NC}"
    echo "========================="
    echo "Duration: ${total_duration_ms}ms"
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Critical failures: ${RED}$CRITICAL_FAILURES${NC}"
    echo "Success rate: ${success_rate}%"

    jq -n \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --arg trace_id "$TRACE_ID" \
        --arg status "$status" \
        --argjson duration_ms "$total_duration_ms" \
        --argjson tests_run "$TESTS_RUN" \
        --argjson tests_passed "$TESTS_PASSED" \
        --argjson critical_failures "$CRITICAL_FAILURES" \
        --argjson success_rate "$success_rate" \
        '{timestamp:$timestamp,trace_id:$trace_id,duration_ms:$duration_ms,tests_run:$tests_run,tests_passed:$tests_passed,critical_failures:$critical_failures,success_rate:$success_rate,status:$status,categories:{dependencies:"checked",environment:"verified",coordination_core:"tested",otel_essentials:"validated",performance:"measured",integration:"verified"}}' \
        > "$REPORT_DIR/essential-test-report.json"

    cp "$TEMP_DIR/telemetry_spans.jsonl" "$REPORT_DIR/telemetry_spans.jsonl" 2>/dev/null || true
}

main() {
    echo -e "${GREEN}🚀 SwarmSH Essential Test Suite${NC}"
    echo "================================"
    echo "Subject root: $SCRIPT_DIR"
    echo "State sandbox: $TEMP_DIR"
    echo ""

    check_dependencies
    test_environment_contract
    test_coordination_core
    test_otel_essential
    test_performance_essential
    test_integration_essential
    generate_report

    echo ""
    if [[ "$CRITICAL_FAILURES" -eq 0 ]]; then
        echo -e "${GREEN}🎉 Essential tests PASSED${NC}"
        exit 0
    fi

    echo -e "${RED}💥 Critical failures detected${NC}"
    exit 1
}

case "${1:-}" in
    --help|-h)
        cat <<EOF
SwarmSH Essential Test Suite

Usage: $0 [options]

Options:
  --help, -h       Show this help
  --quiet, -q      Minimal output
  --verbose, -v    Shell trace output

The suite validates dependencies, environment portability, coordination lifecycle,
telemetry propagation, compatibility routing, concurrency, and performance smoke gates.
Runtime state is isolated in a temporary directory and receipts are written to:
  ${SWARMSH_TEST_REPORT_DIR:-$SCRIPT_DIR/.swarmsh-test-results}
EOF
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
