#!/bin/bash
# Documentation Validation Script
# Tests that the instructions in GETTING_STARTED.md and NEW_PROJECT_GUIDE.md work correctly

set -euo pipefail

VALIDATION_ID="doc_validation_$(date +%s)"
echo "📚 DOCUMENTATION VALIDATION"
echo "============================"
echo "Validation ID: $VALIDATION_ID"
echo ""

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Helper function to run tests
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo "✅ PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("$test_name")
    fi
}

echo "🔍 TESTING GETTING_STARTED.md INSTRUCTIONS"
echo "==========================================="

# Test basic prerequisites 
run_test "bash version check" "bash --version | grep -q 'version [4-9]'"
run_test "jq availability" "command -v jq"
run_test "python3 availability" "command -v python3"
run_test "git availability" "command -v git"

# Test basic SwarmSH functionality
run_test "coordination_helper.sh executable" "test -x ./coordination_helper.sh"
run_test "generate-id command" "./coordination_helper.sh generate-id | grep -q 'agent_'"
run_test "dashboard command" "./coordination_helper.sh dashboard | grep -q 'DASHBOARD'"

# Test work claiming workflow
echo ""
echo "🔍 TESTING WORK CLAIMING WORKFLOW"
echo "================================="

# Create and complete a test work item
WORK_OUTPUT=$(./coordination_helper.sh claim "doc_test" "Documentation validation test" "low" 2>/dev/null)
if echo "$WORK_OUTPUT" | grep -q "work_"; then
    WORK_ID=$(echo "$WORK_OUTPUT" | grep -o "work_[0-9]*")
    echo "✅ Work claiming: PASS (created $WORK_ID)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    
    # Test work completion
    if ./coordination_helper.sh complete "$WORK_ID" "success" 5 >/dev/null 2>&1; then
        echo "✅ Work completion: PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "❌ Work completion: FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        FAILED_TESTS+=("Work completion")
    fi
else
    echo "❌ Work claiming: FAIL"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILED_TESTS+=("Work claiming")
fi

echo ""
echo "🔍 TESTING NEW_PROJECT_GUIDE.md INSTRUCTIONS"
echo "============================================="

# Test flock availability (mentioned in real agent section)
run_test "flock availability check" "command -v flock"

# Test agent swarm orchestrator (correct script name)
run_test "agent_swarm_orchestrator.sh exists" "test -x ./agent_swarm_orchestrator.sh"
run_test "agent swarm help command" "./agent_swarm_orchestrator.sh help | grep -q 'Commands:'"

# Test quick start script
run_test "quick_start_agent_swarm.sh exists" "test -x ./quick_start_agent_swarm.sh"

# Test real agent worker
run_test "real_agent_worker.sh exists" "test -x ./real_agent_worker.sh"

# Test required JSON files exist or can be created
run_test "agent_status.json readable" "test -r agent_status.json || echo '[]' > agent_status.json"
run_test "work_claims.json readable" "test -r work_claims.json || echo '[]' > work_claims.json"

# Test directory structure can be created
mkdir -p test_project_structure/{logs,metrics,backups,real_agents,real_work_results} 2>/dev/null
run_test "project directories creatable" "test -d test_project_structure/logs"
rm -rf test_project_structure 2>/dev/null

echo ""
echo "🔍 TESTING DOCUMENTATION ACCURACY"
echo "================================="

# Check for script name discrepancies
INCORRECT_REFS=0

# Check if documentation mentions non-existent scripts
if grep -q "real_agent_coordinator.sh" GETTING_STARTED.md NEW_PROJECT_GUIDE.md 2>/dev/null; then
    echo "❌ Documentation references non-existent real_agent_coordinator.sh"
    INCORRECT_REFS=$((INCORRECT_REFS + 1))
else
    echo "✅ No references to non-existent scripts"
fi

# Check if correct script names are used
if grep -q "agent_swarm_orchestrator.sh" GETTING_STARTED.md NEW_PROJECT_GUIDE.md 2>/dev/null; then
    echo "✅ Correct agent_swarm_orchestrator.sh references found"
else
    echo "⚠️ Limited references to correct orchestrator script"
fi

echo ""
echo "📊 VALIDATION RESULTS"
echo "====================="
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo "Incorrect References: $INCORRECT_REFS"

if [ $TESTS_FAILED -eq 0 ] && [ $INCORRECT_REFS -eq 0 ]; then
    echo "🎉 All documentation validation tests passed!"
    VALIDATION_STATUS="success"
else
    echo "⚠️ Some tests failed or documentation needs updates:"
    if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
        printf '  - %s\n' "${FAILED_TESTS[@]}"
    fi
    if [ $INCORRECT_REFS -gt 0 ]; then
        echo "  - Documentation has incorrect script references"
    fi
    VALIDATION_STATUS="needs_updates"
fi

# Create validation report
cat > "documentation_validation_${VALIDATION_ID}.json" <<EOF
{
  "validation_id": "$VALIDATION_ID",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "tests_passed": $TESTS_PASSED,
  "tests_failed": $TESTS_FAILED,
  "failed_tests": [$(printf '"%s",' "${FAILED_TESTS[@]}" | sed 's/,$//')],
  "incorrect_references": $INCORRECT_REFS,
  "validation_status": "$VALIDATION_STATUS",
  "documentation_files_tested": [
    "GETTING_STARTED.md",
    "NEW_PROJECT_GUIDE.md"
  ],
  "key_findings": {
    "basic_functionality": "$([ $TESTS_PASSED -gt 5 ] && echo "working" || echo "issues")",
    "work_claiming_workflow": "$(echo "$WORK_OUTPUT" | grep -q "work_" && echo "working" || echo "issues")",
    "script_availability": "$([ -x ./coordination_helper.sh ] && echo "available" || echo "missing")",
    "documentation_accuracy": "$([ $INCORRECT_REFS -eq 0 ] && echo "accurate" || echo "needs_updates")"
  }
}
EOF

echo ""
echo "📄 Validation report saved: documentation_validation_${VALIDATION_ID}.json"
echo "✅ Documentation validation complete"

# Add to telemetry
echo "{\"trace_id\":\"$(openssl rand -hex 16)\",\"operation\":\"documentation_validation\",\"service\":\"doc-validator\",\"tests_passed\":$TESTS_PASSED,\"tests_failed\":$TESTS_FAILED,\"status\":\"$VALIDATION_STATUS\"}" >> telemetry_spans.jsonl

exit $TESTS_FAILED