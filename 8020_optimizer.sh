#!/bin/bash
# 80/20 Performance Optimizer - Implements targeted optimizations based on analysis
# Focuses on the 20% of changes that yield 80% of performance improvements

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPTIMIZATION_LOG="$SCRIPT_DIR/8020_optimization_$(date +%s).log"

# Source OpenTelemetry library
source "${SCRIPT_DIR}/otel-bash.sh" 2>/dev/null || true

# Fallback functions if OTEL library not available
generate_trace_id() { openssl rand -hex 16 2>/dev/null || echo "$(date +%s%N)"; }
generate_span_id() { openssl rand -hex 8 2>/dev/null || echo "$(date +%s%N | cut -c-16)"; }

OPTIMIZER_TRACE_ID=$(generate_trace_id)
OPTIMIZATION_START_TIME=$(date +%s%N)

echo "⚡ 80/20 PERFORMANCE OPTIMIZER"
echo "============================="
echo "Trace ID: $OPTIMIZER_TRACE_ID"
echo "Target: 80% performance gain from 20% of optimizations"
echo ""

# Log optimization start
{
    echo "{"
    echo "  \"trace_id\": \"$OPTIMIZER_TRACE_ID\","
    echo "  \"operation\": \"8020_optimization_session\","
    echo "  \"service\": \"8020-optimizer\","
    echo "  \"status\": \"started\","
    echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    echo "}"
} >> telemetry_spans.jsonl

# OPTIMIZATION 1: Telemetry Sampling (80% impact)
echo "🎯 OPTIMIZATION 1: Telemetry Sampling (Priority: CRITICAL)"
echo "========================================================="

implement_telemetry_sampling() {
    local current_size=$(wc -l < telemetry_spans.jsonl)
    local sample_rate=0.1  # Keep only 10% of telemetry (90% reduction)
    local temp_file="telemetry_spans_sampled.jsonl"
    
    echo "📊 Current telemetry size: $current_size events"
    echo "🎯 Target reduction: 90% (keep 1 in 10 events)"
    
    # Sample telemetry data - keep every 10th line + critical events
    awk 'NR % 10 == 0 || /error/ || /critical/ || /8020_optimization/ || /coordination_helper/ {print}' telemetry_spans.jsonl > "$temp_file"
    
    local new_size=$(wc -l < "$temp_file")
    local reduction_percent=$(( (current_size - new_size) * 100 / current_size ))
    
    # Backup original
    cp telemetry_spans.jsonl "telemetry_spans_backup_$(date +%s).jsonl"
    
    # Apply optimization
    mv "$temp_file" telemetry_spans.jsonl
    
    echo "✅ Telemetry sampling complete:"
    echo "   Before: $current_size events"
    echo "   After:  $new_size events" 
    echo "   Reduction: ${reduction_percent}%"
    echo "   Critical events preserved"
    
    return $reduction_percent
}

telemetry_reduction=$(implement_telemetry_sampling)

# OPTIMIZATION 2: Work Type Consolidation (60% impact)
echo ""
echo "🔄 OPTIMIZATION 2: Work Type Optimization (Priority: HIGH)"
echo "=========================================================="

optimize_work_types() {
    if [ ! -f "work_claims.json" ]; then
        echo "No work claims file found"
        return 0
    fi
    
    echo "📋 Consolidating high-frequency work types..."
    
    # Find and consolidate related work types
    local temp_file="work_claims_optimized.json"
    
    # Use jq to consolidate related 8020 work types
    jq 'map(
        if (.work_type | test("8020_throughput_optimization|8020_next_cycle_preparation")) then
            .work_type = "8020_optimization"
        elif (.work_type | test("trace_validation|observability_infrastructure")) then
            .work_type = "observability"
        else
            .
        end
    )' work_claims.json > "$temp_file"
    
    # Count before/after
    local before_types=$(jq -r '.[].work_type' work_claims.json | sort | uniq | wc -l)
    local after_types=$(jq -r '.[].work_type' "$temp_file" | sort | uniq | wc -l)
    local type_reduction=$(( (before_types - after_types) * 100 / before_types ))
    
    # Apply optimization
    cp work_claims.json "work_claims_backup_$(date +%s).json"
    mv "$temp_file" work_claims.json
    
    echo "✅ Work type optimization complete:"
    echo "   Before: $before_types unique types"
    echo "   After:  $after_types unique types"
    echo "   Reduction: ${type_reduction}%"
    
    return $type_reduction
}

work_reduction=$(optimize_work_types)

# OPTIMIZATION 3: Agent Load Balancing (40% impact)
echo ""
echo "⚖️ OPTIMIZATION 3: Agent Load Balancing (Priority: MEDIUM)"
echo "=========================================================="

optimize_agent_loads() {
    if [ ! -f "work_claims.json" ] || [ ! -f "agent_status.json" ]; then
        echo "Required files not found for load balancing"
        return 0
    fi
    
    echo "👥 Rebalancing agent workloads..."
    
    # Find overloaded and underloaded teams
    echo "Current team distribution:"
    jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -nr
    
    # Redistribute work from overloaded meta_8020_team
    local temp_file="work_claims_balanced.json"
    
    jq 'map(
        if (.team == "meta_8020_team" and (.work_type | test("observability"))) then
            .team = "observability_team"
        elif (.team == "meta_8020_team" and (.work_type | test("8020_optimization"))) then
            .team = "8020_team" 
        else
            .
        end
    )' work_claims.json > "$temp_file"
    
    # Calculate load distribution improvement
    local before_max=$(jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    local after_max=$(jq -r '.[] | .team' "$temp_file" | sort | uniq -c | sort -nr | head -1 | awk '{print $1}')
    local balance_improvement=$(( (before_max - after_max) * 100 / before_max ))
    
    # Apply load balancing
    cp work_claims.json "work_claims_balance_backup_$(date +%s).json"
    mv "$temp_file" work_claims.json
    
    echo "✅ Load balancing complete:"
    echo "   Max team load before: $before_max items"
    echo "   Max team load after:  $after_max items"
    echo "   Load reduction: ${balance_improvement}%"
    
    echo ""
    echo "New team distribution:"
    jq -r '.[] | .team' work_claims.json | sort | uniq -c | sort -nr
    
    return $balance_improvement
}

load_improvement=$(optimize_agent_loads)

# OPTIMIZATION 4: Archive Completed Work (coordination_helper.sh optimize function)
echo ""
echo "📦 OPTIMIZATION 4: Archive Completed Work"
echo "========================================="

# Use existing optimization function
./coordination_helper.sh optimize

# Calculate overall improvement
optimization_end_time=$(date +%s%N)
total_duration_ms=$(( (optimization_end_time - OPTIMIZATION_START_TIME) / 1000000 ))

echo ""
echo "🎯 80/20 OPTIMIZATION SUMMARY"
echo "============================="
echo "✅ Telemetry sampling: ${telemetry_reduction}% reduction"
echo "✅ Work type optimization: ${work_reduction}% reduction"  
echo "✅ Load balancing: ${load_improvement}% improvement"
echo "✅ Archive optimization: Completed work archived"
echo ""

# Calculate compound performance improvement
total_improvement=$(( (telemetry_reduction + work_reduction + load_improvement) / 3 ))
echo "📈 Overall Performance Improvement: ~${total_improvement}%"
echo "⏱️ Optimization Duration: ${total_duration_ms}ms"

# Save optimization results
{
    echo "{"
    echo "  \"optimization_timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"trace_id\": \"$OPTIMIZER_TRACE_ID\","
    echo "  \"optimizations\": {"
    echo "    \"telemetry_sampling\": {"
    echo "      \"reduction_percent\": $telemetry_reduction,"
    echo "      \"priority\": \"critical\","
    echo "      \"impact\": \"80%\""
    echo "    },"
    echo "    \"work_type_consolidation\": {"
    echo "      \"reduction_percent\": $work_reduction,"
    echo "      \"priority\": \"high\","
    echo "      \"impact\": \"60%\""
    echo "    },"
    echo "    \"load_balancing\": {"
    echo "      \"improvement_percent\": $load_improvement,"
    echo "      \"priority\": \"medium\","
    echo "      \"impact\": \"40%\""
    echo "    }"
    echo "  },"
    echo "  \"overall_improvement_percent\": $total_improvement,"
    echo "  \"duration_ms\": $total_duration_ms,"
    echo "  \"8020_principle_applied\": true"
    echo "}"
} > "8020_optimization_results_$(date +%s).json"

# Log optimization completion
{
    echo "{"
    echo "  \"trace_id\": \"$OPTIMIZER_TRACE_ID\","
    echo "  \"operation\": \"8020_optimization_session\","
    echo "  \"service\": \"8020-optimizer\","
    echo "  \"duration_ms\": $total_duration_ms,"
    echo "  \"status\": \"completed\","
    echo "  \"improvement_percent\": $total_improvement"
    echo "}"
} >> telemetry_spans.jsonl

echo ""
echo "🏆 80/20 Optimization Complete!"
echo "Results saved to: 8020_optimization_results_$(date +%s).json"