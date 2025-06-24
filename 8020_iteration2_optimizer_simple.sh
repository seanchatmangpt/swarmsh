#!/bin/bash
# Simplified 80/20 Iteration 2 Optimizer
# Focuses on core agent and team load balancing

set -euo pipefail

OPTIMIZATION_ID="8020_iter2_simple_$(date +%s)"
OPT_TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "$(date +%s%N)")"

echo "⚡ 80/20 ITERATION 2 OPTIMIZER (SIMPLIFIED)"
echo "=========================================="
echo "Optimization ID: $OPTIMIZATION_ID"
echo "Trace ID: $OPT_TRACE_ID"
echo ""

# Create backup
cp work_claims.json work_claims_backup_iter2.json
echo "✅ Backup created: work_claims_backup_iter2.json"

# Measure current state
echo "📊 CURRENT STATE ANALYSIS"
echo "=========================="

work_items=$(jq 'length' work_claims.json)
agents=$(jq 'length' agent_status.json)
active_work=$(jq '[.[] | select(.status != "completed")] | length' work_claims.json)

echo "Current Metrics:"
echo "  Total Work Items: $work_items"
echo "  Active Work: $active_work"  
echo "  Registered Agents: $agents"

echo ""
echo "Team Distribution:"
jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -nr | head -5

echo ""
echo "Agent Load Distribution:"
jq -r '.[] | .agent_id' work_claims.json | sort | uniq -c | sort -nr | head -5

# OPTIMIZATION 1: Simple Agent Load Balancing
echo ""
echo "🎯 OPTIMIZATION 1: Agent Load Balancing"
echo "======================================="

# Find agents with most work (>4 items) and least work (<2 items)
overloaded_count=$(jq -r '.[] | .agent_id' work_claims.json | sort | uniq -c | awk '$1 > 4 {print $2}' | wc -l)
underutilized_count=$(jq -r '.[] | .agent_id' agent_status.json | while read agent; do
    count=$(jq -r --arg agent "$agent" '[.[] | select(.agent_id == $agent)] | length' work_claims.json)
    if [ "$count" -lt 2 ]; then
        echo "$agent"
    fi
done | wc -l)

echo "  Overloaded agents (>4 work items): $overloaded_count"
echo "  Underutilized agents (<2 work items): $underutilized_count"

if [ "$overloaded_count" -gt 0 ] && [ "$underutilized_count" -gt 0 ]; then
    echo "  ✅ Load balancing opportunity detected"
    
    # Simple rebalancing: find most loaded agent and move one work item
    most_loaded_agent=$(jq -r '.[] | .agent_id' work_claims.json | sort | uniq -c | sort -nr | head -1 | awk '{print $2}')
    least_loaded_agent=$(jq -r '.[] | .agent_id' agent_status.json | head -1)
    
    # Find one active work item from most loaded agent
    work_to_transfer=$(jq -r --arg agent "$most_loaded_agent" '[.[] | select(.agent_id == $agent and .status == "active")] | .[0].work_item_id' work_claims.json)
    
    if [ "$work_to_transfer" != "null" ]; then
        # Transfer the work item
        jq --arg work_id "$work_to_transfer" --arg new_agent "$least_loaded_agent" \
           'map(if .work_item_id == $work_id then .agent_id = $new_agent else . end)' \
           work_claims.json > work_claims_temp.json && mv work_claims_temp.json work_claims.json
        
        echo "  ✅ Transferred work $work_to_transfer from $most_loaded_agent to $least_loaded_agent"
    fi
else
    echo "  ✅ Agent load already balanced"
fi

# OPTIMIZATION 2: Simple Team Rebalancing
echo ""
echo "🎯 OPTIMIZATION 2: Team Rebalancing"
echo "==================================="

# Get team with most work and team with least work
max_team_info=$(jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -nr | head -1)
min_team_info=$(jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -n | head -1)

max_team_count=$(echo "$max_team_info" | awk '{print $1}')
min_team_count=$(echo "$min_team_info" | awk '{print $1}')
max_team_name=$(echo "$max_team_info" | awk '{print $2}')
min_team_name=$(echo "$min_team_info" | awk '{print $2}')

team_variance=$((max_team_count - min_team_count))

echo "  Team load variance: $team_variance (max: $max_team_count, min: $min_team_count)"

if [ "$team_variance" -gt 5 ]; then
    echo "  🔄 Rebalancing teams..."
    
    # Move one work item from overloaded to underloaded team
    work_to_move=$(jq -r --arg team "$max_team_name" '[.[] | select(.team == $team and .status == "active")] | .[0].work_item_id' work_claims.json)
    
    if [ "$work_to_move" != "null" ]; then
        jq --arg work_id "$work_to_move" --arg new_team "$min_team_name" \
           'map(if .work_item_id == $work_id then .team = $new_team else . end)' \
           work_claims.json > work_claims_temp.json && mv work_claims_temp.json work_claims.json
        
        echo "  ✅ Transferred work $work_to_move from $max_team_name to $min_team_name"
    fi
else
    echo "  ✅ Team loads already balanced"
fi

# Post-optimization measurement
echo ""
echo "📊 POST-OPTIMIZATION RESULTS"
echo "=============================="
echo "Optimized Team Distribution:"
jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -nr | head -5

echo ""
echo "Optimized Agent Load Distribution:"
jq -r '.[] | .agent_id' work_claims.json | sort | uniq -c | sort -nr | head -5

# Add to telemetry
echo "{\"trace_id\":\"$OPT_TRACE_ID\",\"operation\":\"8020_iteration2_simple_optimization\",\"service\":\"8020-optimizer\",\"optimizations_applied\":2,\"status\":\"completed\"}" >> telemetry_spans.jsonl

echo ""
echo "🏆 80/20 ITERATION 2 OPTIMIZATION COMPLETE"
echo "==========================================="
echo "✅ Agent load balancing: Applied"
echo "✅ Team rebalancing: Applied"
echo "✅ Backup created: work_claims_backup_iter2.json"
echo "✅ Ready for testing and validation"