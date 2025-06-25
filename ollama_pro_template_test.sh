#!/bin/bash

##############################################################################
# Ollama-Pro Template Engine Integration Test
# 
# Tests the SwarmSH Template Engine against ollama-pro for:
# 1. AI-generated template creation
# 2. Dynamic content generation  
# 3. Real-world template processing
# 4. Coordination system under AI workloads
# 5. Full telemetry validation
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
OLLAMA_TIMEOUT=30
TEST_RESULTS_DIR="ollama_test_results"
TELEMETRY_LOG="../../telemetry_spans.jsonl"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup function
cleanup() {
    rm -rf "$TEST_RESULTS_DIR"
    rm -f ai_*.sh ai_*.json ollama_*.out
}

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

# Test AI availability
test_ollama_pro_availability() {
    echo -e "${BLUE}🤖 Testing Ollama-Pro Availability${NC}"
    
    local ai_response=""
    if command -v ollama-pro &>/dev/null; then
        ai_response=$(timeout $OLLAMA_TIMEOUT ollama-pro run qwen3:latest --print "Hello, respond with 'AI_READY'" 2>/dev/null || echo "TIMEOUT")
    else
        ai_response="NOT_AVAILABLE"
    fi
    
    if [[ "$ai_response" =~ "AI_READY" ]]; then
        run_test "ollama-pro availability" "available" "available"
        return 0
    else
        run_test "ollama-pro availability" "available" "unavailable"
        echo -e "${YELLOW}⚠️  Ollama-Pro not available, running simplified tests${NC}"
        return 1
    fi
}

# Generate AI template using ollama-pro
generate_ai_template() {
    local template_type="$1"
    local output_file="$2"
    local context_file="$3"
    
    echo -e "${BLUE}🎨 Generating AI Template: $template_type${NC}"
    
    local prompt=""
    case "$template_type" in
        "system_report")
            prompt="Create a SwarmSH system status template using variables like {{ system.health }}, {{ agents.count }}, and {{ telemetry.spans }}. Include conditional sections for high/low health and loops for agent lists. Use Jinja-style syntax."
            ;;
        "agent_dashboard")
            prompt="Create an agent dashboard template with variables {{ agent.id }}, {{ agent.status }}, {{ agent.workload }}. Include conditionals for active/inactive agents and loops for work items. Use Jinja-style syntax."
            ;;
        "telemetry_summary")
            prompt="Create a telemetry summary template with {{ trace.id }}, {{ operation.name }}, {{ duration }}. Include filters for time formatting and conditionals for error/success status. Use Jinja-style syntax."
            ;;
    esac
    
    # Generate template using ollama-pro
    if command -v ollama-pro &>/dev/null; then
        timeout $OLLAMA_TIMEOUT ollama-pro run qwen3:latest --print "$prompt" > "$output_file" 2>/dev/null || {
            echo "# AI Generation Failed - Using fallback template" > "$output_file"
            create_fallback_template "$template_type" "$output_file"
        }
    else
        create_fallback_template "$template_type" "$output_file"
    fi
    
    # Create corresponding context
    create_test_context "$template_type" "$context_file"
}

# Create fallback templates if AI is unavailable
create_fallback_template() {
    local template_type="$1"
    local output_file="$2"
    
    case "$template_type" in
        "system_report")
            cat > "$output_file" << 'EOF'
SwarmSH System Report
===================
System Health: {{ system.health }}/100
Total Agents: {{ agents.count }}
Active Traces: {{ telemetry.spans }}

{% if system.health > 80 %}
✅ System is running optimally
{% elif system.health > 60 %}
⚠️ System needs attention
{% else %}
❌ System requires immediate action
{% endif %}

Active Agents:
{% for agent in agents.list %}
- {{ agent.id }}: {{ agent.role }} ({{ agent.status }})
{% endfor %}

Generated at: {{ timestamp }}
EOF
            ;;
        "agent_dashboard")
            cat > "$output_file" << 'EOF'
Agent Dashboard
===============
Agent ID: {{ agent.id }}
Status: {{ agent.status | upper }}
Current Workload: {{ agent.workload }}/{{ agent.capacity }}

{% if agent.status == "active" %}
🟢 Agent is active and processing work
Current Tasks:
{% for task in agent.tasks %}
  - {{ task.type }}: {{ task.description }}
{% endfor %}
{% else %}
🔴 Agent is inactive
{% endif %}

Performance Metrics:
- Tasks Completed: {{ agent.metrics.completed }}
- Success Rate: {{ agent.metrics.success_rate }}%
- Average Duration: {{ agent.metrics.avg_duration }}ms
EOF
            ;;
        "telemetry_summary")
            cat > "$output_file" << 'EOF'
Telemetry Summary
================
Trace ID: {{ trace.id }}
Operation: {{ operation.name }}
Duration: {{ duration }}ms
Status: {{ status | upper }}

{% if status == "completed" %}
✅ Operation completed successfully
{% else %}
❌ Operation failed or timed out
{% endif %}

Span Details:
{% for span in spans %}
- {{ span.operation }}: {{ span.duration }}ms ({{ span.status }})
{% endfor %}

Total Operations: {{ spans | length }}
Average Duration: {{ avg_duration }}ms
EOF
            ;;
    esac
}

# Create test context data
create_test_context() {
    local template_type="$1"
    local context_file="$2"
    
    case "$template_type" in
        "system_report")
            cat > "$context_file" << 'EOF'
{
    "system": {
        "health": 85
    },
    "agents": {
        "count": 12,
        "list": [
            {"id": "agent_001", "role": "Parser", "status": "active"},
            {"id": "agent_002", "role": "Renderer", "status": "active"},
            {"id": "agent_003", "role": "Cache", "status": "inactive"}
        ]
    },
    "telemetry": {
        "spans": 1247
    },
    "timestamp": "2025-06-24T16:45:00Z"
}
EOF
            ;;
        "agent_dashboard")
            cat > "$context_file" << 'EOF'
{
    "agent": {
        "id": "agent_render_001",
        "status": "active",
        "workload": 7,
        "capacity": 10,
        "tasks": [
            {"type": "template_parse", "description": "Parse user dashboard"},
            {"type": "render_block", "description": "Render navigation"}
        ],
        "metrics": {
            "completed": 156,
            "success_rate": 98.7,
            "avg_duration": 45
        }
    }
}
EOF
            ;;
        "telemetry_summary")
            cat > "$context_file" << 'EOF'
{
    "trace": {
        "id": "trace_12345"
    },
    "operation": {
        "name": "template_engine.render"
    },
    "duration": 125,
    "status": "completed",
    "spans": [
        {"operation": "parse", "duration": 45, "status": "completed"},
        {"operation": "render", "duration": 80, "status": "completed"}
    ],
    "avg_duration": 62.5
}
EOF
            ;;
    esac
}

# Test AI template generation and rendering
test_ai_template_generation() {
    echo -e "\n${BLUE}Test 1: AI Template Generation${NC}"
    
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Test system report template
    generate_ai_template "system_report" "ai_system_report.sh" "ai_system_context.json"
    
    # Render the AI-generated template
    ./swarmsh-template-v2.sh render ai_system_report.sh ai_system_context.json "$TEST_RESULTS_DIR/system_report.out" 2>/dev/null
    
    # Check if rendering worked
    if [[ -f "$TEST_RESULTS_DIR/system_report.out" ]] && [[ -s "$TEST_RESULTS_DIR/system_report.out" ]]; then
        local output_lines=$(wc -l < "$TEST_RESULTS_DIR/system_report.out")
        if [[ $output_lines -gt 5 ]]; then
            run_test "AI system report generation" "success" "success"
        else
            run_test "AI system report generation" "success" "minimal_output"
        fi
    else
        run_test "AI system report generation" "success" "failed"
    fi
}

# Test AI agent dashboard
test_ai_agent_dashboard() {
    echo -e "\n${BLUE}Test 2: AI Agent Dashboard${NC}"
    
    generate_ai_template "agent_dashboard" "ai_agent_dashboard.sh" "ai_agent_context.json"
    
    # Render the dashboard
    ./swarmsh-template-v2.sh render ai_agent_dashboard.sh ai_agent_context.json "$TEST_RESULTS_DIR/agent_dashboard.out" 2>/dev/null
    
    # Check for key dashboard elements
    if [[ -f "$TEST_RESULTS_DIR/agent_dashboard.out" ]]; then
        local has_agent_id=$(grep -c "agent_render_001" "$TEST_RESULTS_DIR/agent_dashboard.out" || echo 0)
        local has_status=$(grep -ic "active\|ACTIVE" "$TEST_RESULTS_DIR/agent_dashboard.out" || echo 0)
        
        if [[ $has_agent_id -gt 0 ]] && [[ $has_status -gt 0 ]]; then
            run_test "AI agent dashboard" "rendered" "rendered"
        else
            run_test "AI agent dashboard" "rendered" "incomplete"
        fi
    else
        run_test "AI agent dashboard" "rendered" "failed"
    fi
}

# Test telemetry integration under AI load
test_telemetry_under_ai_load() {
    echo -e "\n${BLUE}Test 3: Telemetry Under AI Load${NC}"
    
    # Generate multiple AI templates concurrently
    for i in {1..3}; do
        (
            generate_ai_template "telemetry_summary" "ai_telemetry_${i}.sh" "ai_telemetry_context_${i}.json"
            ./swarmsh-template-v2.sh render "ai_telemetry_${i}.sh" "ai_telemetry_context_${i}.json" "$TEST_RESULTS_DIR/telemetry_${i}.out" 2>/dev/null
        ) &
    done
    
    wait # Wait for all background jobs
    
    # Check telemetry spans were generated
    if [[ -f "$TELEMETRY_LOG" ]]; then
        local recent_spans=$(tail -50 "$TELEMETRY_LOG" | grep -c "template_engine" || echo 0)
        
        if [[ $recent_spans -gt 2 ]]; then
            run_test "telemetry under AI load" "generated" "generated"
        else
            run_test "telemetry under AI load" "generated" "minimal"
        fi
    else
        run_test "telemetry under AI load" "generated" "missing"
    fi
}

# Test coordination system with AI workloads
test_coordination_with_ai() {
    echo -e "\n${BLUE}Test 4: Coordination System with AI${NC}"
    
    # Create a complex AI-generated template
    local complex_prompt="Create a complex template with multiple conditionals, nested loops, and various filters. Include system metrics, agent lists, and telemetry data."
    
    if command -v ollama-pro &>/dev/null; then
        timeout $OLLAMA_TIMEOUT ollama-pro run qwen3:latest --print "$complex_prompt" > "ai_complex_template.sh" 2>/dev/null || {
            # Fallback complex template
            cat > "ai_complex_template.sh" << 'EOF'
Complex SwarmSH Dashboard
========================
{% for system in systems %}
System: {{ system.name }}
Health: {{ system.health }}/100

{% if system.health > 90 %}
Status: Excellent ✅
{% elif system.health > 70 %}
Status: Good ⚠️
{% else %}
Status: Critical ❌
{% endif %}

Agents in {{ system.name }}:
{% for agent in system.agents %}
  - {{ agent.id | upper }}: {{ agent.workload }}/{{ agent.capacity }}
    {% if agent.active %}
    Active Tasks: {{ agent.tasks | length }}
    {% endif %}
{% endfor %}

{% endfor %}

Overall Status: {{ total_health | default:"Unknown" }}
Generated: {{ timestamp }}
EOF
        }
    else
        # Use fallback template
        cat > "ai_complex_template.sh" << 'EOF'
Complex Template (Fallback)
===========================
System Health: {{ health }}
Agent Count: {{ agent_count }}
{% if health > 80 %}
System is healthy
{% endif %}
EOF
    fi
    
    # Create complex context
    cat > "ai_complex_context.json" << 'EOF'
{
    "systems": [
        {
            "name": "SwarmSH-Core",
            "health": 95,
            "agents": [
                {"id": "core_001", "workload": 8, "capacity": 10, "active": true, "tasks": ["parse", "render"]},
                {"id": "core_002", "workload": 6, "capacity": 10, "active": true, "tasks": ["cache"]}
            ]
        },
        {
            "name": "SwarmSH-Template",
            "health": 78,
            "agents": [
                {"id": "template_001", "workload": 9, "capacity": 10, "active": true, "tasks": ["ai_gen", "validate"]}
            ]
        }
    ],
    "total_health": 86,
    "timestamp": "2025-06-24T16:50:00Z"
}
EOF
    
    # Render with coordination enabled
    ./swarmsh-template-v2.sh render ai_complex_template.sh ai_complex_context.json "$TEST_RESULTS_DIR/complex.out" 2>/dev/null
    
    # Check coordination worked
    if [[ -f "$TEST_RESULTS_DIR/complex.out" ]] && [[ -s "$TEST_RESULTS_DIR/complex.out" ]]; then
        local system_count=$(grep -c "System:" "$TEST_RESULTS_DIR/complex.out" || echo 0)
        if [[ $system_count -gt 0 ]]; then
            run_test "coordination with AI" "success" "success"
        else
            run_test "coordination with AI" "success" "partial"
        fi
    else
        run_test "coordination with AI" "success" "failed"
    fi
}

# Test performance under AI load
test_performance_under_ai_load() {
    echo -e "\n${BLUE}Test 5: Performance Under AI Load${NC}"
    
    local start_time=$(date +%s%N)
    
    # Generate and render 5 templates concurrently
    for i in {1..5}; do
        (
            local template_file="perf_test_${i}.sh"
            echo "Performance Test Template $i" > "$template_file"
            echo "Timestamp: {{ timestamp }}" >> "$template_file"
            echo "Test ID: {{ test_id }}" >> "$template_file"
            echo "{% if active %}Status: Active{% endif %}" >> "$template_file"
            
            echo "{\"timestamp\": \"$(date)\", \"test_id\": $i, \"active\": true}" > "perf_context_${i}.json"
            
            ./swarmsh-template-v2.sh render "$template_file" "perf_context_${i}.json" "$TEST_RESULTS_DIR/perf_${i}.out" 2>/dev/null
        ) &
    done
    
    wait # Wait for all background jobs
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Check all outputs were generated
    local output_count=$(ls "$TEST_RESULTS_DIR"/perf_*.out 2>/dev/null | wc -l)
    
    if [[ $output_count -eq 5 ]] && [[ $duration_ms -lt 10000 ]]; then # Under 10 seconds
        run_test "performance under load" "fast" "fast"
    elif [[ $output_count -eq 5 ]]; then
        run_test "performance under load" "fast" "slow"
    else
        run_test "performance under load" "fast" "failed"
    fi
    
    echo "  Duration: ${duration_ms}ms for 5 concurrent templates"
}

# Test AI-generated content validation
test_ai_content_validation() {
    echo -e "\n${BLUE}Test 6: AI Content Validation${NC}"
    
    # Check if any AI-generated templates contain valid Jinja syntax
    local valid_templates=0
    
    for template in ai_*.sh; do
        if [[ -f "$template" ]]; then
            # Check for Jinja-style patterns
            local has_variables=$(grep -c "{{.*}}" "$template" || echo 0)
            local has_conditionals=$(grep -c "{%.*if.*%}" "$template" || echo 0)
            local has_loops=$(grep -c "{%.*for.*%}" "$template" || echo 0)
            
            if [[ $has_variables -gt 0 ]] || [[ $has_conditionals -gt 0 ]] || [[ $has_loops -gt 0 ]]; then
                ((valid_templates++))
            fi
        fi
    done
    
    if [[ $valid_templates -gt 2 ]]; then
        run_test "AI content validation" "valid" "valid"
    elif [[ $valid_templates -gt 0 ]]; then
        run_test "AI content validation" "valid" "partial"
    else
        run_test "AI content validation" "valid" "invalid"
    fi
    
    echo "  Valid templates found: $valid_templates"
}

# Main test execution
main() {
    echo -e "${BLUE}🧪 SwarmSH Template Engine - Ollama-Pro Integration Test Suite${NC}"
    echo "=================================================================="
    echo ""
    
    # Setup
    mkdir -p "$TEST_RESULTS_DIR"
    
    # Test ollama-pro availability first
    OLLAMA_AVAILABLE=0
    if test_ollama_pro_availability; then
        OLLAMA_AVAILABLE=1
    fi
    
    # Run all tests
    test_ai_template_generation
    test_ai_agent_dashboard
    test_telemetry_under_ai_load
    test_coordination_with_ai
    test_performance_under_ai_load
    test_ai_content_validation
    
    # Summary
    echo ""
    echo "=================================================================="
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $OLLAMA_AVAILABLE -eq 1 ]]; then
        echo -e "Ollama-Pro: ${GREEN}Available${NC}"
    else
        echo -e "Ollama-Pro: ${YELLOW}Unavailable (fallback mode)${NC}"
    fi
    
    echo ""
    echo "Generated files in: $TEST_RESULTS_DIR/"
    ls -la "$TEST_RESULTS_DIR/" 2>/dev/null || echo "No output files generated"
    
    # Cleanup
    # cleanup
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✅ All integration tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some integration tests failed.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"