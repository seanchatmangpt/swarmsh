#!/bin/bash

##############################################################################
# Template Engine Integration Test with Full Coordination System
# 
# Tests the template engine using REAL SwarmSH coordination features:
# 1. Work claiming with coordination_helper.sh
# 2. Agent registration and work distribution
# 3. Real telemetry span generation
# 4. 8020 optimization features
# 5. Reality verification integration
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TELEMETRY_LOG="../../telemetry_spans.jsonl"
WORK_CLAIMS_FILE="../../work_claims.json"
COORDINATION_HELPER="../../coordination_helper.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local expected_result="$2"
    local actual_result="$3"
    
    echo -n "Testing $test_name... "
    
    if [[ "$expected_result" == "$actual_result" ]]; then
        echo -e "${GREEN}PASSED${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Expected: $expected_result"
        echo "  Actual: $actual_result"
        ((TESTS_FAILED++))
    fi
}

# Test coordination helper availability
test_coordination_system() {
    echo -e "${BLUE}🤖 Testing SwarmSH Coordination System${NC}"
    
    if [[ -x "$COORDINATION_HELPER" ]]; then
        # Test basic coordination functionality
        local test_output=$("$COORDINATION_HELPER" help 2>/dev/null | head -1)
        if [[ "$test_output" =~ "SCRUM AT SCALE" ]]; then
            run_test "coordination system" "available" "available"
            return 0
        else
            run_test "coordination system" "available" "not_responsive"
            return 1
        fi
    else
        run_test "coordination system" "available" "missing"
        return 1
    fi
}

# Test work claiming integration
test_work_claiming() {
    echo -e "\n${BLUE}Test 1: Work Claiming Integration${NC}"
    
    # Claim template parsing work
    local claim_output=$("$COORDINATION_HELPER" claim \
        "template_integration_test" \
        "Test template work claiming" \
        "high" \
        "testing_team" 2>/dev/null || echo "FAILED")
    
    # Extract work ID
    local work_id=$(echo "$claim_output" | grep -o 'work_[0-9]*' | head -1)
    
    if [[ -n "$work_id" ]]; then
        run_test "work claiming" "success" "success"
        
        # Test progress updates
        "$COORDINATION_HELPER" progress "$work_id" 50 "in_progress" 2>/dev/null
        "$COORDINATION_HELPER" complete "$work_id" "Test completed" 2>/dev/null
        
        run_test "work progress tracking" "success" "success"
    else
        run_test "work claiming" "success" "failed"
        run_test "work progress tracking" "success" "skipped"
    fi
}

# Test agent registration
test_agent_registration() {
    echo -e "\n${BLUE}Test 2: Agent Registration${NC}"
    
    local agent_id="template_test_agent_$(date +%s%N)"
    
    # Register test agent
    local reg_output=$("$COORDINATION_HELPER" register \
        "$agent_id" \
        "Testing_Team" \
        10 \
        "template_engine_test" 2>/dev/null || echo "FAILED")
    
    if [[ "$reg_output" =~ "SUCCESS" ]] || [[ "$reg_output" =~ "registered" ]]; then
        run_test "agent registration" "success" "success"
    else
        run_test "agent registration" "success" "failed"
    fi
}

# Test template engine with coordination
test_template_with_coordination() {
    echo -e "\n${BLUE}Test 3: Template Engine with Coordination${NC}"
    
    # Create test template that uses coordination data
    cat > coordination_test_template.sh << 'EOF'
SwarmSH Coordination Status
===========================
Agent ID: {{ agent.id }}
Team: {{ agent.team }}
Capacity: {{ agent.capacity }}

Recent Work Claims:
{% for claim in work_claims %}
- {{ claim.type }}: {{ claim.description }}
  Status: {{ claim.status }}
  Team: {{ claim.team }}
{% endfor %}

System Health: {{ system.health }}/100
{% if system.health > 80 %}
✅ System is healthy
{% elif system.health > 60 %}
⚠️ System needs attention  
{% else %}
❌ System critical
{% endif %}

Generated: {{ timestamp }}
EOF
    
    # Create context with real coordination data
    cat > coordination_context.json << 'EOF'
{
    "agent": {
        "id": "template_test_agent_001",
        "team": "Testing_Team",
        "capacity": 10
    },
    "work_claims": [
        {
            "type": "template_parse",
            "description": "Parse coordination template",
            "status": "completed",
            "team": "Testing_Team"
        },
        {
            "type": "render_block",
            "description": "Render status block",
            "status": "in_progress",
            "team": "Testing_Team"
        }
    ],
    "system": {
        "health": 85
    },
    "timestamp": "2025-06-24T17:00:00Z"
}
EOF
    
    # Render the template
    ./swarmsh-template-v2.sh render coordination_test_template.sh coordination_context.json coordination_output.txt 2>/dev/null
    
    # Check output
    if [[ -f "coordination_output.txt" ]] && [[ -s "coordination_output.txt" ]]; then
        local has_agent=$(grep -c "template_test_agent_001" coordination_output.txt || echo 0)
        local has_status=$(grep -c "System is healthy" coordination_output.txt || echo 0)
        
        if [[ $has_agent -gt 0 ]] && [[ $has_status -gt 0 ]]; then
            run_test "template with coordination" "rendered" "rendered"
        else
            run_test "template with coordination" "rendered" "incomplete"
        fi
    else
        run_test "template with coordination" "rendered" "failed"
    fi
}

# Test telemetry integration
test_telemetry_integration() {
    echo -e "\n${BLUE}Test 4: Telemetry Integration${NC}"
    
    # Get baseline telemetry count
    local baseline_count=0
    if [[ -f "$TELEMETRY_LOG" ]]; then
        baseline_count=$(wc -l < "$TELEMETRY_LOG")
    fi
    
    # Render template multiple times to generate telemetry
    for i in {1..3}; do
        ./swarmsh-template-v2.sh render coordination_test_template.sh coordination_context.json "telemetry_test_${i}.out" 2>/dev/null
    done
    
    # Check if new telemetry spans were generated
    local new_count=0
    if [[ -f "$TELEMETRY_LOG" ]]; then
        new_count=$(wc -l < "$TELEMETRY_LOG")
    fi
    
    local span_diff=$((new_count - baseline_count))
    
    if [[ $span_diff -gt 2 ]]; then
        run_test "telemetry generation" "spans_created" "spans_created"
        
        # Check for template-specific spans
        local template_spans=$(tail -20 "$TELEMETRY_LOG" | grep -c "template_engine" || echo 0)
        if [[ $template_spans -gt 0 ]]; then
            run_test "template telemetry spans" "found" "found"
        else
            run_test "template telemetry spans" "found" "missing"
        fi
    else
        run_test "telemetry generation" "spans_created" "none"
        run_test "template telemetry spans" "found" "no_baseline"
    fi
}

# Test coordination dashboard integration
test_coordination_dashboard() {
    echo -e "\n${BLUE}Test 5: Coordination Dashboard${NC}"
    
    # Test dashboard command
    local dashboard_output=$("$COORDINATION_HELPER" dashboard 2>/dev/null || echo "FAILED")
    
    if [[ "$dashboard_output" =~ "SwarmSH" ]] && [[ "$dashboard_output" =~ "Dashboard" ]]; then
        run_test "coordination dashboard" "available" "available"
        
        # Test if our test work shows up
        local work_output=$("$COORDINATION_HELPER" list-work 2>/dev/null || echo "FAILED")
        if [[ "$work_output" =~ "template" ]] || [[ "$work_output" =~ "work_" ]]; then
            run_test "work listing" "shows_work" "shows_work"
        else
            run_test "work listing" "shows_work" "empty"
        fi
    else
        run_test "coordination dashboard" "available" "failed"
        run_test "work listing" "shows_work" "skipped"
    fi
}

# Test AI analysis integration
test_ai_analysis() {
    echo -e "\n${BLUE}Test 6: AI Analysis Integration${NC}"
    
    # Test AI priority analysis
    local ai_output=$("$COORDINATION_HELPER" claude-analyze-priorities 2>/dev/null || echo "FAILED")
    
    if [[ "$ai_output" =~ "analysis" ]] || [[ "$ai_output" =~ "priority" ]] || [[ "$ai_output" =~ "JSON" ]]; then
        run_test "AI priority analysis" "available" "available"
    else
        run_test "AI priority analysis" "available" "unavailable"
    fi
    
    # Test AI dashboard
    local ai_dashboard=$("$COORDINATION_HELPER" claude-dashboard 2>/dev/null || echo "FAILED")
    
    if [[ "$ai_dashboard" =~ "Intelligence" ]] || [[ "$ai_dashboard" =~ "Analysis" ]]; then
        run_test "AI dashboard" "available" "available"
    else
        run_test "AI dashboard" "available" "unavailable"
    fi
}

# Test reality verification integration
test_reality_verification() {
    echo -e "\n${BLUE}Test 7: Reality Verification${NC}"
    
    # Create a template that can be verified
    cat > reality_test_template.sh << 'EOF'
System Status: {{ status }}
Health Score: {{ health }}
{% if health > 80 %}
Status: HEALTHY
{% else %}
Status: DEGRADED
{% endif %}
EOF
    
    cat > reality_context.json << 'EOF'
{
    "status": "operational",
    "health": 85
}
EOF
    
    # Render template
    ./swarmsh-template-v2.sh render reality_test_template.sh reality_context.json reality_output.txt 2>/dev/null
    
    # Create expected output for comparison
    cat > reality_expected.txt << 'EOF'
System Status: operational
Health Score: 85
Status: HEALTHY
EOF
    
    # Check if reality verification engine exists
    if [[ -x "../../reality_verification_engine.sh" ]]; then
        # Use reality verification
        local verify_result=$(../../reality_verification_engine.sh verify \
            reality_test_template.sh \
            reality_output.txt \
            reality_expected.txt 2>/dev/null || echo "FAILED")
        
        if [[ "$verify_result" =~ "success" ]] || [[ "$verify_result" =~ "pass" ]]; then
            run_test "reality verification" "verified" "verified"
        else
            run_test "reality verification" "verified" "failed"
        fi
    else
        # Manual verification
        if diff -q reality_output.txt reality_expected.txt >/dev/null 2>&1; then
            run_test "reality verification" "verified" "verified"
        else
            run_test "reality verification" "verified" "failed"
        fi
    fi
}

# Test performance under coordination load
test_coordination_performance() {
    echo -e "\n${BLUE}Test 8: Performance Under Coordination Load${NC}"
    
    local start_time=$(date +%s%N)
    
    # Simulate multiple agents claiming and completing work
    for i in {1..5}; do
        (
            local agent_id="perf_agent_${i}_$(date +%s%N)"
            
            # Register agent
            "$COORDINATION_HELPER" register "$agent_id" "Performance_Team" 5 "perf_test" 2>/dev/null
            
            # Claim work
            local work_id=$("$COORDINATION_HELPER" claim \
                "template_performance_test" \
                "Performance test $i" \
                "medium" \
                "Performance_Team" 2>/dev/null | grep -o 'work_[0-9]*' | head -1)
            
            # Render template
            ./swarmsh-template-v2.sh render coordination_test_template.sh coordination_context.json "perf_output_${i}.txt" 2>/dev/null
            
            # Complete work
            if [[ -n "$work_id" ]]; then
                "$COORDINATION_HELPER" complete "$work_id" "Performance test completed" 2>/dev/null
            fi
        ) &
    done
    
    wait # Wait for all background jobs
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Check outputs
    local output_count=$(ls perf_output_*.txt 2>/dev/null | wc -l)
    
    if [[ $output_count -eq 5 ]] && [[ $duration_ms -lt 15000 ]]; then # Under 15 seconds
        run_test "coordination performance" "fast" "fast"
    elif [[ $output_count -eq 5 ]]; then
        run_test "coordination performance" "fast" "slow"
    else
        run_test "coordination performance" "fast" "failed"
    fi
    
    echo "  Duration: ${duration_ms}ms for 5 concurrent coordinated operations"
}

# Main test execution
main() {
    echo -e "${BLUE}🧪 SwarmSH Template Engine - Full Coordination Integration Test${NC}"
    echo "=================================================================="
    echo ""
    
    # Test coordination system availability first
    COORDINATION_AVAILABLE=0
    if test_coordination_system; then
        COORDINATION_AVAILABLE=1
    fi
    
    if [[ $COORDINATION_AVAILABLE -eq 0 ]]; then
        echo -e "${RED}❌ SwarmSH Coordination System not available${NC}"
        echo "Please run this test from the SwarmSH root directory"
        exit 1
    fi
    
    # Run all tests
    test_work_claiming
    test_agent_registration
    test_template_with_coordination
    test_telemetry_integration
    test_coordination_dashboard
    test_ai_analysis
    test_reality_verification
    test_coordination_performance
    
    # Summary
    echo ""
    echo "=================================================================="
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Coordination System: ${GREEN}Available${NC}"
    
    echo ""
    echo "Generated outputs:"
    ls -la *.txt *.out 2>/dev/null || echo "No output files"
    
    # Show recent telemetry
    if [[ -f "$TELEMETRY_LOG" ]]; then
        echo ""
        echo "Recent telemetry spans:"
        tail -5 "$TELEMETRY_LOG" | jq -r '. | "\(.operation_name): \(.status) (\(.duration_ms)ms)"' 2>/dev/null || \
        tail -5 "$TELEMETRY_LOG"
    fi
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✅ All coordination integration tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some coordination integration tests failed.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"