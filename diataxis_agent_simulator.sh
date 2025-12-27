#!/bin/bash

################################################################################
# Diataxis Agent Simulator
#
# Simulates 10 concurrent Claude Code web VM agents working on Diataxis
# documentation tasks with realistic coordination patterns
#
# USAGE:
#   ./diataxis_agent_simulator.sh start [duration_seconds]
#   ./diataxis_agent_simulator.sh demo
#
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COORDINATION_DIR="${COORDINATION_DIR:-$SCRIPT_DIR/diataxis_coordination}"
CONFIG_FILE="$SCRIPT_DIR/diataxis_swarm_config.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Simulate agent claiming work
simulate_agent_work() {
    local agent_id="$1"
    local quadrant="$2"
    local agent_name="$3"
    local work_description="$4"

    local work_id="work_$(date +%s%N)"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)

    echo -e "${CYAN}[$timestamp] ${MAGENTA}Agent $agent_id${NC} (${GREEN}$agent_name${NC})"
    echo -e "  ${YELLOW}Quadrant:${NC} $quadrant"
    echo -e "  ${YELLOW}Task:${NC} $work_description"
    echo -e "  ${YELLOW}Work ID:${NC} $work_id"

    # Simulate work progress
    local duration=$((RANDOM % 5 + 1))
    echo -e "  ${BLUE}Progress:${NC} 0% -> "

    for i in $(seq 1 4); do
        sleep $((duration / 4))
        echo -ne "${BLUE}$(( i * 25 ))%${NC} -> "
    done

    echo -e "${GREEN}100% ✓${NC}"
    echo ""

    # Log to telemetry
    cat >> "$COORDINATION_DIR/telemetry_spans.jsonl" <<EOF
{"trace_id":"$(openssl rand -hex 16)","span_id":"$(openssl rand -hex 8)","operation_name":"diataxis_work_$quadrant","status":"ok","agent_id":"$agent_id","work_id":"$work_id","quadrant":"$quadrant","description":"$work_description","timestamp":"$timestamp"}
EOF
}

# Run demo showing all 10 agents
run_demo() {
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}   DIATAXIS SWARM - 10 CONCURRENT AGENTS DEMO${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo ""

    # Verify swarm is initialized
    if [ ! -f "$COORDINATION_DIR/swarm_state.json" ]; then
        echo -e "${RED}❌ Swarm not initialized. Run: ./diataxis_swarm_orchestrator.sh init${NC}"
        exit 1
    fi

    echo -e "${CYAN}Swarm Status:${NC}"
    local status=$(jq -r '.status' "$COORDINATION_DIR/swarm_state.json")
    local swarm_id=$(jq -r '.swarm_id' "$COORDINATION_DIR/swarm_state.json")
    echo -e "  ${GREEN}✓${NC} Swarm ID: $swarm_id"
    echo -e "  ${GREEN}✓${NC} Status: $status"
    echo ""

    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}TUTORIAL AGENTS (3 agents)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo ""

    simulate_agent_work "tutorial_beginner_agent" "tutorials" "Tutorial Agent 1" "Create 'Getting Started in 5 Minutes' tutorial" &
    sleep 0.5
    simulate_agent_work "tutorial_intermediate_agent" "tutorials" "Tutorial Agent 2" "Write 'Agent Coordination Tutorial'" &
    sleep 0.5
    simulate_agent_work "tutorial_advanced_agent" "tutorials" "Tutorial Agent 3" "Develop 'Building Custom Swarms' tutorial" &

    wait

    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}HOW-TO AGENTS (2 agents)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo ""

    simulate_agent_work "howto_operations_agent" "how_to_guides" "How-To Agent 4" "How-To: Troubleshoot Coordination Conflicts" &
    sleep 0.5
    simulate_agent_work "howto_integration_agent" "how_to_guides" "How-To Agent 5" "How-To: Deploy to Kubernetes" &

    wait

    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}REFERENCE AGENTS (3 agents)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo ""

    simulate_agent_work "reference_api_agent" "reference" "Reference Agent 6" "Update coordination_helper.sh API reference" &
    sleep 0.5
    simulate_agent_work "reference_architecture_agent" "reference" "Reference Agent 7" "Document system architecture components" &
    sleep 0.5
    simulate_agent_work "reference_changelog_agent" "reference" "Reference Agent 8" "Update CHANGELOG.md for v1.2.0" &

    wait

    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}EXPLANATION AGENTS (2 agents)${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
    echo ""

    simulate_agent_work "explanation_concepts_agent" "explanations" "Explanation Agent 9" "Explain nanosecond ID conflict prevention" &
    sleep 0.5
    simulate_agent_work "explanation_architecture_agent" "explanations" "Explanation Agent 10" "Explain 8020 automation design rationale" &

    wait

    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ DEMO COMPLETE - All 10 agents executed tasks${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo ""

    # Show telemetry stats
    echo -e "${CYAN}Telemetry Statistics:${NC}"
    local total_spans=$(wc -l < "$COORDINATION_DIR/telemetry_spans.jsonl" | tr -d ' ')
    echo -e "  ${GREEN}✓${NC} Total telemetry spans: $total_spans"

    local recent_count=$(tail -10 "$COORDINATION_DIR/telemetry_spans.jsonl" | grep -c "diataxis_work" || true)
    echo -e "  ${GREEN}✓${NC} Recent Diataxis operations: $recent_count"
    echo ""
}

# Continuous simulation
run_continuous() {
    local duration=${1:-60}  # Default 60 seconds

    echo -e "${BLUE}Starting continuous agent simulation for ${duration}s...${NC}"
    echo ""

    local end_time=$(($(date +%s) + duration))
    local cycle=1

    while [ $(date +%s) -lt $end_time ]; do
        echo -e "${MAGENTA}═══ Cycle $cycle ═══${NC}"

        # Random agent from each quadrant
        local tutorials=("tutorial_beginner_agent" "tutorial_intermediate_agent" "tutorial_advanced_agent")
        local howtos=("howto_operations_agent" "howto_integration_agent")
        local references=("reference_api_agent" "reference_architecture_agent" "reference_changelog_agent")
        local explanations=("explanation_concepts_agent" "explanation_architecture_agent")

        # Pick random agents
        local tutorial_agent=${tutorials[$RANDOM % ${#tutorials[@]}]}
        local howto_agent=${howtos[$RANDOM % ${#howtos[@]}]}
        local reference_agent=${references[$RANDOM % ${#references[@]}]}
        local explanation_agent=${explanations[$RANDOM % ${#explanations[@]}]}

        # Simulate work from 4 agents concurrently
        simulate_agent_work "$tutorial_agent" "tutorials" "Tutorial Agent" "Tutorial work item $cycle" &
        simulate_agent_work "$howto_agent" "how_to_guides" "How-To Agent" "How-to guide $cycle" &
        simulate_agent_work "$reference_agent" "reference" "Reference Agent" "Reference doc $cycle" &
        simulate_agent_work "$explanation_agent" "explanations" "Explanation Agent" "Explanation $cycle" &

        wait

        cycle=$((cycle + 1))

        # Small delay between cycles
        sleep 2
    done

    echo -e "${GREEN}✓ Continuous simulation complete${NC}"
}

# Show live agent activity
show_live_activity() {
    echo -e "${BLUE}Live Agent Activity Monitor${NC}"
    echo -e "${BLUE}Press Ctrl+C to exit${NC}"
    echo ""

    while true; do
        clear
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        echo -e "${BLUE}  DIATAXIS SWARM - LIVE ACTIVITY${NC}"
        echo -e "${BLUE}═══════════════════════════════════════${NC}"
        echo ""

        # Show recent telemetry
        echo -e "${CYAN}Recent Operations (last 10):${NC}"
        tail -10 "$COORDINATION_DIR/telemetry_spans.jsonl" | jq -r 'select(.operation_name | startswith("diataxis_work")) | "[\(.timestamp)] \(.agent_id) - \(.description)"' 2>/dev/null | tail -5

        echo ""
        echo -e "${CYAN}Activity by Quadrant:${NC}"

        local tutorial_count=$(grep -c "diataxis_work_tutorials" "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        local howto_count=$(grep -c "diataxis_work_how_to_guides" "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        local reference_count=$(grep -c "diataxis_work_reference" "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        local explanation_count=$(grep -c "diataxis_work_explanations" "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")

        echo -e "  ${GREEN}Tutorials:${NC} $tutorial_count"
        echo -e "  ${YELLOW}How-To:${NC} $howto_count"
        echo -e "  ${MAGENTA}Reference:${NC} $reference_count"
        echo -e "  ${CYAN}Explanations:${NC} $explanation_count"

        echo ""
        echo -e "${BLUE}Updated: $(date)${NC}"

        sleep 5
    done
}

# Main execution
main() {
    local command="${1:-help}"

    case "$command" in
        "demo")
            run_demo
            ;;
        "continuous"|"start")
            run_continuous "${2:-60}"
            ;;
        "live"|"monitor")
            show_live_activity
            ;;
        "help"|"-h"|"--help")
            echo -e "${BLUE}Diataxis Agent Simulator${NC}"
            echo "========================"
            echo ""
            echo "Simulates 10 concurrent agents working on Diataxis documentation"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  demo                     Run complete demo of all 10 agents"
            echo "  continuous [seconds]     Run continuous simulation (default: 60s)"
            echo "  live                     Show live activity monitor"
            echo "  help                     Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 demo                  # Show all 10 agents working"
            echo "  $0 continuous 120        # Run simulation for 120 seconds"
            echo "  $0 live                  # Monitor live activity"
            echo ""
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo "Run '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
