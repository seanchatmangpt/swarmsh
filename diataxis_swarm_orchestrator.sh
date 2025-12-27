#!/bin/bash

################################################################################
# Diataxis Swarm Orchestrator
#
# Manages 10 concurrent Claude Code web VM agents specialized in Diataxis
# documentation framework (Tutorials, How-To Guides, Reference, Explanations)
#
# USAGE:
#   ./diataxis_swarm_orchestrator.sh init      # Initialize swarm
#   ./diataxis_swarm_orchestrator.sh deploy    # Deploy work queues
#   ./diataxis_swarm_orchestrator.sh start     # Start all agents
#   ./diataxis_swarm_orchestrator.sh status    # Show swarm status
#   ./diataxis_swarm_orchestrator.sh stop      # Stop all agents
#
# ARCHITECTURE:
#   - 3 Tutorial agents (beginner, intermediate, advanced)
#   - 2 How-to agents (operations, integration)
#   - 3 Reference agents (API, architecture, changelog)
#   - 2 Explanation agents (concepts, architecture)
#
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARM_CONFIG="$SCRIPT_DIR/diataxis_swarm_config.json"
COORDINATION_DIR="${COORDINATION_DIR:-$SCRIPT_DIR/diataxis_coordination}"
AGENT_COORDINATION_DIR="$SCRIPT_DIR/agent_coordination"

# OpenTelemetry configuration
OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-diataxis-swarm}"
export OTEL_SERVICE_NAME

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Generate trace ID for swarm operations
generate_trace_id() {
    openssl rand -hex 16
}

# Initialize swarm coordination
init_swarm() {
    echo -e "${BLUE}🤖 INITIALIZING DIATAXIS SWARM${NC}"
    echo "=================================="
    echo ""

    # Verify configuration exists
    if [ ! -f "$SWARM_CONFIG" ]; then
        echo -e "${RED}❌ Swarm configuration not found: $SWARM_CONFIG${NC}"
        exit 1
    fi

    # Create coordination directory
    mkdir -p "$COORDINATION_DIR"
    mkdir -p "$AGENT_COORDINATION_DIR"

    # Initialize work claims file if not exists
    if [ ! -f "$COORDINATION_DIR/work_claims.json" ]; then
        echo "[]" > "$COORDINATION_DIR/work_claims.json"
    fi

    # Initialize agent status file if not exists
    if [ ! -f "$COORDINATION_DIR/agent_status.json" ]; then
        echo "[]" > "$COORDINATION_DIR/agent_status.json"
    fi

    # Initialize coordination log
    if [ ! -f "$COORDINATION_DIR/coordination_log.json" ]; then
        echo "[]" > "$COORDINATION_DIR/coordination_log.json"
    fi

    # Initialize telemetry file
    if [ ! -f "$COORDINATION_DIR/telemetry_spans.jsonl" ]; then
        touch "$COORDINATION_DIR/telemetry_spans.jsonl"
    fi

    # Create swarm state file
    local swarm_id=$(jq -r '.swarm_id' "$SWARM_CONFIG")
    cat > "$COORDINATION_DIR/swarm_state.json" <<EOF
{
  "swarm_id": "$swarm_id",
  "status": "initialized",
  "initialized_at": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "total_agents": $(jq -r '.total_agents' "$SWARM_CONFIG"),
  "active_agents": 0,
  "configuration_file": "$SWARM_CONFIG"
}
EOF

    echo -e "${GREEN}✅ Diataxis swarm initialized${NC}"
    echo -e "${CYAN}   Swarm ID: $swarm_id${NC}"
    echo -e "${CYAN}   Coordination dir: $COORDINATION_DIR${NC}"
    echo -e "${CYAN}   Total agents: $(jq -r '.total_agents' "$SWARM_CONFIG")${NC}"
    echo ""
}

# Deploy work queues for each Diataxis quadrant
deploy_work_queues() {
    local trace_id=$(generate_trace_id)

    echo -e "${BLUE}📋 DEPLOYING DIATAXIS WORK QUEUES${NC}"
    echo "==================================="
    echo -e "${CYAN}Trace ID: $trace_id${NC}"
    echo ""

    export COORDINATION_DIR="$COORDINATION_DIR"

    # Deploy Tutorial work items
    echo -e "${YELLOW}📚 Deploying Tutorial work items...${NC}"
    "$SCRIPT_DIR/coordination_helper.sh" claim "tutorial" "Create Getting Started tutorial" "high" "tutorial_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "tutorial" "Write installation guide" "high" "tutorial_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "tutorial" "Develop quickstart guide" "medium" "tutorial_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "tutorial" "Create agent coordination tutorial" "medium" "tutorial_team"

    # Deploy How-to work items
    echo -e "${YELLOW}🔧 Deploying How-to Guide work items...${NC}"
    "$SCRIPT_DIR/coordination_helper.sh" claim "how_to" "Write troubleshooting guide" "high" "howto_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "how_to" "Create configuration recipe" "medium" "howto_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "how_to" "Document deployment process" "high" "howto_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "how_to" "Write integration guide" "medium" "howto_team"

    # Deploy Reference work items
    echo -e "${YELLOW}📖 Deploying Reference work items...${NC}"
    "$SCRIPT_DIR/coordination_helper.sh" claim "reference" "Update API reference documentation" "high" "reference_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "reference" "Document all command parameters" "medium" "reference_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "reference" "Maintain changelog entries" "low" "reference_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "reference" "Update configuration reference" "medium" "reference_team"

    # Deploy Explanation work items
    echo -e "${YELLOW}🧠 Deploying Explanation work items...${NC}"
    "$SCRIPT_DIR/coordination_helper.sh" claim "explanation" "Explain coordination concepts" "medium" "explanation_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "explanation" "Document design decisions" "low" "explanation_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "explanation" "Write architectural explanations" "medium" "explanation_team"
    "$SCRIPT_DIR/coordination_helper.sh" claim "explanation" "Explain 8020 principle" "high" "explanation_team"

    echo ""
    echo -e "${GREEN}✅ Work queues deployed${NC}"
    echo -e "${CYAN}   Total work items: $(jq 'length' "$COORDINATION_DIR/work_claims.json")${NC}"
    echo ""
}

# Register all 10 agents in the coordination system
register_agents() {
    echo -e "${BLUE}👥 REGISTERING DIATAXIS AGENTS${NC}"
    echo "==============================="
    echo ""

    export COORDINATION_DIR="$COORDINATION_DIR"

    # Extract and register agents from config
    local quadrants=("tutorials" "how_to_guides" "reference" "explanations")

    for quadrant in "${quadrants[@]}"; do
        local agent_count=$(jq -r ".diataxis_quadrants.${quadrant}.agent_count" "$SWARM_CONFIG")
        echo -e "${MAGENTA}Registering ${agent_count} ${quadrant} agents...${NC}"

        for i in $(seq 0 $((agent_count - 1))); do
            local agent_id=$(jq -r ".diataxis_quadrants.${quadrant}.agents[$i].agent_id" "$SWARM_CONFIG")
            local specialization=$(jq -r ".diataxis_quadrants.${quadrant}.agents[$i].specialization" "$SWARM_CONFIG")
            local team_name="${specialization}_team"

            # Register agent with nanosecond ID
            local nano_id="agent_$(date +%s%N)"

            "$SCRIPT_DIR/coordination_helper.sh" register-agent \
                --agent-id "$agent_id" \
                --specialization "$specialization" \
                --team "$team_name" \
                --capacity 100

            echo -e "${GREEN}  ✓ Registered: $agent_id${NC}"
        done
        echo ""
    done

    echo -e "${GREEN}✅ All agents registered${NC}"
    echo -e "${CYAN}   Total registered: $(jq 'length' "$COORDINATION_DIR/agent_status.json")${NC}"
    echo ""
}

# Start all agents in the swarm
start_swarm() {
    echo -e "${BLUE}🚀 STARTING DIATAXIS SWARM${NC}"
    echo "==========================="
    echo ""

    # Update swarm state
    jq '.status = "running" | .started_at = "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"' \
        "$COORDINATION_DIR/swarm_state.json" > "$COORDINATION_DIR/swarm_state.json.tmp"
    mv "$COORDINATION_DIR/swarm_state.json.tmp" "$COORDINATION_DIR/swarm_state.json"

    echo -e "${GREEN}✅ Swarm started${NC}"
    echo ""
    echo -e "${CYAN}📊 Agent Distribution:${NC}"
    echo -e "${CYAN}   • Tutorial agents: 3${NC}"
    echo -e "${CYAN}   • How-to agents: 2${NC}"
    echo -e "${CYAN}   • Reference agents: 3${NC}"
    echo -e "${CYAN}   • Explanation agents: 2${NC}"
    echo ""
    echo -e "${YELLOW}💡 Next steps:${NC}"
    echo -e "${YELLOW}   1. Agents will claim work based on their specialization${NC}"
    echo -e "${YELLOW}   2. Monitor progress with: ./diataxis_swarm_orchestrator.sh status${NC}"
    echo -e "${YELLOW}   3. View coordination dashboard: ./coordination_helper.sh dashboard${NC}"
    echo ""
}

# Show swarm status
show_status() {
    echo -e "${BLUE}📊 DIATAXIS SWARM STATUS${NC}"
    echo "========================"
    echo ""

    if [ ! -f "$COORDINATION_DIR/swarm_state.json" ]; then
        echo -e "${RED}❌ Swarm not initialized${NC}"
        return 1
    fi

    # Swarm overview
    local swarm_id=$(jq -r '.swarm_id' "$COORDINATION_DIR/swarm_state.json")
    local status=$(jq -r '.status' "$COORDINATION_DIR/swarm_state.json")
    local total_agents=$(jq -r '.total_agents' "$COORDINATION_DIR/swarm_state.json")

    echo -e "${CYAN}🆔 Swarm ID: $swarm_id${NC}"
    echo -e "${CYAN}📈 Status: $status${NC}"
    echo -e "${CYAN}🤖 Total Agents: $total_agents${NC}"
    echo ""

    # Work distribution by quadrant
    echo -e "${BLUE}📋 WORK DISTRIBUTION${NC}"
    echo "-------------------"

    export COORDINATION_DIR="$COORDINATION_DIR"

    for quadrant in "tutorial" "how_to" "reference" "explanation"; do
        local total=$(jq "[.[] | select(.work_type == \"$quadrant\")] | length" "$COORDINATION_DIR/work_claims.json")
        local in_progress=$(jq "[.[] | select(.work_type == \"$quadrant\" and .status == \"in_progress\")] | length" "$COORDINATION_DIR/work_claims.json")
        local completed=$(jq "[.[] | select(.work_type == \"$quadrant\" and .status == \"completed\")] | length" "$COORDINATION_DIR/work_claims.json")

        echo -e "${MAGENTA}${quadrant}:${NC} Total: $total | In Progress: $in_progress | Completed: $completed"
    done

    echo ""

    # Agent status summary
    echo -e "${BLUE}👥 AGENT STATUS${NC}"
    echo "---------------"

    local registered_agents=$(jq 'length' "$COORDINATION_DIR/agent_status.json")
    local active_agents=$(jq '[.[] | select(.status == "active")] | length' "$COORDINATION_DIR/agent_status.json")

    echo -e "${CYAN}Registered: $registered_agents${NC}"
    echo -e "${CYAN}Active: $active_agents${NC}"
    echo ""

    # Recent telemetry
    echo -e "${BLUE}📡 TELEMETRY${NC}"
    echo "-----------"

    if [ -f "$COORDINATION_DIR/telemetry_spans.jsonl" ]; then
        local span_count=$(wc -l < "$COORDINATION_DIR/telemetry_spans.jsonl" | tr -d ' ')
        echo -e "${CYAN}Total spans: $span_count${NC}"

        # Show recent operations
        echo -e "${YELLOW}Recent operations:${NC}"
        tail -5 "$COORDINATION_DIR/telemetry_spans.jsonl" | jq -r '.operation_name' | sed 's/^/  • /'
    fi

    echo ""
}

# Stop all agents
stop_swarm() {
    echo -e "${BLUE}🛑 STOPPING DIATAXIS SWARM${NC}"
    echo "==========================="
    echo ""

    # Update swarm state
    jq '.status = "stopped" | .stopped_at = "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'"' \
        "$COORDINATION_DIR/swarm_state.json" > "$COORDINATION_DIR/swarm_state.json.tmp"
    mv "$COORDINATION_DIR/swarm_state.json.tmp" "$COORDINATION_DIR/swarm_state.json"

    echo -e "${GREEN}✅ Swarm stopped${NC}"
    echo ""
}

# Show swarm dashboard
show_dashboard() {
    echo -e "${BLUE}📊 DIATAXIS SWARM DASHBOARD${NC}"
    echo "==========================="
    echo ""

    # Use coordination helper dashboard
    export COORDINATION_DIR="$COORDINATION_DIR"
    "$SCRIPT_DIR/coordination_helper.sh" dashboard
}

# Generate Mermaid diagram of swarm architecture
generate_diagram() {
    echo -e "${BLUE}📊 GENERATING SWARM ARCHITECTURE DIAGRAM${NC}"
    echo "========================================="
    echo ""

    local output_file="${1:-diataxis_swarm_architecture.mmd}"

    cat > "$output_file" <<'EOF'
graph TB
    subgraph "Diataxis Swarm - 10 Concurrent Agents"
        direction TB

        CO[Coordination<br/>System]

        subgraph "Tutorials (3 agents)"
            T1[Tutorial Agent 1<br/>Beginner]
            T2[Tutorial Agent 2<br/>Intermediate]
            T3[Tutorial Agent 3<br/>Advanced]
        end

        subgraph "How-To Guides (2 agents)"
            H1[How-To Agent 4<br/>Operations]
            H2[How-To Agent 5<br/>Integration]
        end

        subgraph "Reference (3 agents)"
            R1[Reference Agent 6<br/>API]
            R2[Reference Agent 7<br/>Architecture]
            R3[Reference Agent 8<br/>Changelog]
        end

        subgraph "Explanations (2 agents)"
            E1[Explanation Agent 9<br/>Concepts]
            E2[Explanation Agent 10<br/>Architecture]
        end

        CO -->|Claim Work| T1
        CO -->|Claim Work| T2
        CO -->|Claim Work| T3
        CO -->|Claim Work| H1
        CO -->|Claim Work| H2
        CO -->|Claim Work| R1
        CO -->|Claim Work| R2
        CO -->|Claim Work| R3
        CO -->|Claim Work| E1
        CO -->|Claim Work| E2

        T1 -->|Progress Updates| CO
        T2 -->|Progress Updates| CO
        T3 -->|Progress Updates| CO
        H1 -->|Progress Updates| CO
        H2 -->|Progress Updates| CO
        R1 -->|Progress Updates| CO
        R2 -->|Progress Updates| CO
        R3 -->|Progress Updates| CO
        E1 -->|Progress Updates| CO
        E2 -->|Progress Updates| CO
    end

    style CO fill:#4a90e2,stroke:#2e5c8a,color:#fff
    style T1 fill:#50c878,stroke:#2d7a4a,color:#fff
    style T2 fill:#50c878,stroke:#2d7a4a,color:#fff
    style T3 fill:#50c878,stroke:#2d7a4a,color:#fff
    style H1 fill:#ff9f43,stroke:#cc7f36,color:#fff
    style H2 fill:#ff9f43,stroke:#cc7f36,color:#fff
    style R1 fill:#a55eea,stroke:#7d45b0,color:#fff
    style R2 fill:#a55eea,stroke:#7d45b0,color:#fff
    style R3 fill:#a55eea,stroke:#7d45b0,color:#fff
    style E1 fill:#fc5c65,stroke:#c94851,color:#fff
    style E2 fill:#fc5c65,stroke:#c94851,color:#fff
EOF

    echo -e "${GREEN}✅ Diagram generated: $output_file${NC}"
    echo ""
}

# Main execution
main() {
    local command="${1:-help}"

    case "$command" in
        "init")
            init_swarm
            ;;
        "deploy")
            deploy_work_queues
            ;;
        "register")
            register_agents
            ;;
        "start")
            start_swarm
            ;;
        "status")
            show_status
            ;;
        "stop")
            stop_swarm
            ;;
        "dashboard")
            show_dashboard
            ;;
        "diagram")
            generate_diagram "${2:-diataxis_swarm_architecture.mmd}"
            ;;
        "full-setup")
            init_swarm
            register_agents
            deploy_work_queues
            start_swarm
            ;;
        "help"|"-h"|"--help")
            echo -e "${BLUE}Diataxis Swarm Orchestrator${NC}"
            echo "============================"
            echo ""
            echo "Manages 10 concurrent Claude Code web VM agents for Diataxis documentation"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  init         Initialize swarm coordination"
            echo "  register     Register all 10 agents"
            echo "  deploy       Deploy work queues for all quadrants"
            echo "  start        Start the swarm"
            echo "  status       Show swarm status"
            echo "  stop         Stop the swarm"
            echo "  dashboard    Show coordination dashboard"
            echo "  diagram      Generate Mermaid architecture diagram"
            echo "  full-setup   Run init + register + deploy + start"
            echo "  help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 full-setup                    # Complete swarm setup"
            echo "  $0 status                        # Check swarm status"
            echo "  $0 diagram swarm_arch.mmd       # Generate diagram"
            echo ""
            echo "Agent Distribution:"
            echo "  • 3 Tutorial agents (beginner, intermediate, advanced)"
            echo "  • 2 How-to agents (operations, integration)"
            echo "  • 3 Reference agents (API, architecture, changelog)"
            echo "  • 2 Explanation agents (concepts, architecture)"
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
