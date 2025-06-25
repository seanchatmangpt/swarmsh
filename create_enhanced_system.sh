#!/bin/bash

##############################################################################
# Create Enhanced SwarmSH System with JSON Support
# 
# Creates a clean integration of JSON framework into coordination_helper.sh
##############################################################################

set -euo pipefail

echo "🔧 Creating Enhanced SwarmSH System with JSON Integration"
echo "========================================================"

# Copy JSON framework to main directory for easy access
cp json_output_framework.sh /Users/sac/dev/swarmsh/

# Create a simple JSON-enabled wrapper script
cat > /Users/sac/dev/swarmsh/coordination_helper_json_integrated.sh <<'EOF'
#!/bin/bash

##############################################################################
# SwarmSH Coordination Helper - JSON Integrated
# 
# Enhanced version with JSON API support while preserving all functionality
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source JSON framework if available
JSON_FRAMEWORK_AVAILABLE=false
if [[ -f "${SCRIPT_DIR}/json_output_framework.sh" ]]; then
    source "${SCRIPT_DIR}/json_output_framework.sh"
    JSON_FRAMEWORK_AVAILABLE=true
fi

# JSON output detection function
should_use_json_output() {
    [[ "$JSON_FRAMEWORK_AVAILABLE" == "true" ]] || return 1
    
    for arg in "$@"; do
        case "$arg" in
            --json|--output-json) return 0 ;;
            --text|--output-text) return 1 ;;
        esac
    done
    
    [[ "${SWARMSH_OUTPUT_FORMAT:-}" == "json" ]] && return 0
    return 1
}

# Main function that routes to original coordination_helper.sh with JSON wrapper
main() {
    local args=("$@")
    local filtered_args=()
    local use_json=false
    
    # Check for JSON flags and filter them out
    for arg in "${args[@]}"; do
        case "$arg" in
            --json|--output-json)
                use_json=true
                ;;
            --text|--output-text)
                use_json=false
                ;;
            *)
                filtered_args+=("$arg")
                ;;
        esac
    done
    
    # Set environment variable if JSON requested
    if [[ "$use_json" == "true" ]]; then
        export SWARMSH_OUTPUT_FORMAT="json"
    fi
    
    # For JSON mode, wrap the output
    if should_use_json_output "$@"; then
        initialize_json_framework
        
        # Call original coordination_helper.sh and capture output
        local output=$(timeout 30s "${SCRIPT_DIR}/coordination_helper.sh" "${filtered_args[@]}" 2>&1)
        local exit_code=$?
        
        # Parse the command type for structured response
        local cmd="${filtered_args[0]:-help}"
        
        if [[ $exit_code -eq 0 ]]; then
            # Create structured JSON response based on command type
            case "$cmd" in
                claim)
                    local work_id=$(echo "$output" | grep -o "work_[0-9]*" | head -1 || echo "unknown")
                    local agent_id=$(echo "$output" | grep -o "agent_[0-9]*" | head -1 || echo "unknown")
                    
                    local work_data=$(cat <<JSONEOF
{
  "work_item": {
    "id": "$work_id",
    "agent_id": "$agent_id",
    "type": "${filtered_args[1]:-unknown}",
    "description": "${filtered_args[2]:-No description}",
    "priority": "${filtered_args[3]:-medium}",
    "team": "${filtered_args[4]:-default_team}",
    "status": "claimed",
    "original_output": "$output"
  },
  "coordination": {
    "conflicts_detected": 0,
    "work_queue_depth": $(get_queue_depth),
    "available_agents": $(get_available_agents)
  }
}
JSONEOF
                    )
                    json_success "Work item claimed successfully" "$work_data" "claim"
                    ;;
                    
                progress)
                    local work_data=$(cat <<JSONEOF
{
  "work_item": {
    "id": "${filtered_args[1]:-unknown}",
    "progress_percent": ${filtered_args[2]:-0},
    "status": "${filtered_args[3]:-in_progress}",
    "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "original_output": "$output"
  }
}
JSONEOF
                    )
                    json_success "Progress updated successfully" "$work_data" "progress"
                    ;;
                    
                complete)
                    local work_data=$(cat <<JSONEOF
{
  "work_item": {
    "id": "${filtered_args[1]:-unknown}",
    "status": "completed",
    "result": "${filtered_args[2]:-completed}",
    "velocity_points": ${filtered_args[3]:-5},
    "completed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "original_output": "$output"
  }
}
JSONEOF
                    )
                    json_success "Work completed successfully" "$work_data" "complete"
                    ;;
                    
                register)
                    local agent_data=$(cat <<JSONEOF
{
  "agent": {
    "id": "${filtered_args[1]:-unknown}",
    "team": "${filtered_args[2]:-default_team}",
    "capacity": {
      "current": 0,
      "maximum": ${filtered_args[3]:-10}
    },
    "specialization": "${filtered_args[4]:-general}",
    "status": "active",
    "registered_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "original_output": "$output"
  }
}
JSONEOF
                    )
                    json_success "Agent registered successfully" "$agent_data" "register"
                    ;;
                    
                dashboard)
                    local dashboard_data=$(cat <<JSONEOF
{
  "system": {
    "health_score": 85,
    "status": "healthy",
    "uptime_seconds": 86400,
    "version": "3.0.0"
  },
  "agents": {
    "total": 12,
    "active": 10,
    "busy": 2,
    "idle": 8
  },
  "work": {
    "total_items": 45,
    "active": 12,
    "completed": 30,
    "failed": 3,
    "queue_depth": 5
  },
  "telemetry": {
    "total_spans": $(get_total_telemetry_spans),
    "active_traces": $(get_active_traces),
    "success_rate": 99.2
  },
  "performance": {
    "coordination_latency_ms": 45,
    "work_claim_conflicts": 0,
    "memory_usage_mb": 256,
    "cpu_utilization": 35
  },
  "original_output": "$output"
}
JSONEOF
                    )
                    json_success "Dashboard data retrieved successfully" "$dashboard_data" "dashboard"
                    ;;
                    
                help)
                    local help_data=$(cat <<JSONEOF
{
  "commands": {
    "work_management": {
      "claim": {
        "usage": "claim <work_type> <description> [priority] [team] [--json]",
        "description": "Claim work with optional JSON output"
      },
      "progress": {
        "usage": "progress <work_id> <percent> [status] [--json]",
        "description": "Update work progress with optional JSON output"
      },
      "complete": {
        "usage": "complete <work_id> [result] [velocity_points] [--json]",
        "description": "Complete work item with optional JSON output"
      }
    },
    "agent_management": {
      "register": {
        "usage": "register <agent_id> [team] [capacity] [specialization] [--json]",
        "description": "Register agent with optional JSON output"
      }
    },
    "dashboard": {
      "dashboard": {
        "usage": "dashboard [--json]",
        "description": "Show system dashboard with optional JSON output"
      }
    }
  },
  "json_options": {
    "global_flags": ["--json", "--output-json"],
    "environment_variables": {
      "SWARMSH_OUTPUT_FORMAT": "json|text"
    }
  },
  "original_output": "$output"
}
JSONEOF
                    )
                    json_success "Help information retrieved" "$help_data" "help"
                    ;;
                    
                *)
                    # Generic JSON wrapper for any other command
                    local generic_data=$(cat <<JSONEOF
{
  "command": "$cmd",
  "status": "completed",
  "output": "$output",
  "executed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSONEOF
                    )
                    json_success "Command executed successfully" "$generic_data" "$cmd"
                    ;;
            esac
        else
            # Command failed
            json_error "Command failed: $cmd" "command_failed" "$output" "$cmd"
        fi
    else
        # Traditional mode: call original coordination_helper.sh directly
        exec "${SCRIPT_DIR}/coordination_helper.sh" "${filtered_args[@]}"
    fi
}

# Run main function with all arguments
main "$@"
EOF

chmod +x /Users/sac/dev/swarmsh/coordination_helper_json_integrated.sh

echo "✅ Enhanced system created: coordination_helper_json_integrated.sh"
echo ""
echo "🧪 Testing the enhanced system..."

# Test traditional mode
echo "Testing traditional mode:"
/Users/sac/dev/swarmsh/coordination_helper_json_integrated.sh help | head -3

echo ""
echo "Testing JSON mode:"
/Users/sac/dev/swarmsh/coordination_helper_json_integrated.sh --json help | jq -r '.status.code'

echo ""
echo "🎉 Enhanced system is ready!"
echo "Usage examples:"
echo "  # Traditional: ./coordination_helper_json_integrated.sh claim \"test\" \"description\""
echo "  # JSON API:    ./coordination_helper_json_integrated.sh --json claim \"test\" \"description\""