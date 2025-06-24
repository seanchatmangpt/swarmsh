#!/bin/bash

##############################################################################
# 80/20 Continuous Improvement Loop
##############################################################################
#
# DESCRIPTION:
#   Implements continuous 80/20 optimization for SwarmSH coordination system.
#   Identifies high-impact, low-effort improvements and applies them automatically.
#
# PRINCIPLE:
#   Focus on the 20% of optimizations that provide 80% of the performance gains.
#
# USAGE:
#   ./continuous_8020_loop.sh [--loop-duration=3600] [--dry-run]
#
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COORDINATION_DIR="${COORDINATION_DIR:-$SCRIPT_DIR}"

# Configuration
LOOP_DURATION=${1:-3600}  # Default 1 hour
DRY_RUN=${2:-false}
METRICS_THRESHOLD=0.8
OPTIMIZATION_TARGET=0.2  # Focus on top 20% of issues

# 80/20 Metrics Collection
collect_8020_metrics() {
    local metrics_file="$COORDINATION_DIR/8020_metrics.jsonl"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
    
    echo "📊 Collecting 80/20 metrics..."
    
    # Core performance metrics (20% effort, 80% insight)
    local work_claims_size=0
    local agent_count=0
    local completed_work=0
    local active_work=0
    local coordination_efficiency=0
    
    if [[ -f "$COORDINATION_DIR/work_claims.json" ]]; then
        work_claims_size=$(stat -f%z "$COORDINATION_DIR/work_claims.json" 2>/dev/null || stat -c%s "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo 0)
        active_work=$(jq '[.[] | select(.status == "active")] | length' "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo 0)
        completed_work=$(jq '[.[] | select(.status == "completed")] | length' "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo 0)
    fi
    
    if [[ -f "$COORDINATION_DIR/agent_status.json" ]]; then
        agent_count=$(jq 'length' "$COORDINATION_DIR/agent_status.json" 2>/dev/null || echo 0)
    fi
    
    # Calculate coordination efficiency (completed / total)
    local total_work=$((active_work + completed_work))
    if [[ $total_work -gt 0 ]]; then
        coordination_efficiency=$(echo "scale=2; $completed_work / $total_work" | bc -l 2>/dev/null || echo "0")
    fi
    
    # High-impact metrics (80/20 principle)
    local metrics=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "metrics": {
    "work_claims_file_size": $work_claims_size,
    "active_agents": $agent_count,
    "active_work_items": $active_work,
    "completed_work_items": $completed_work,
    "coordination_efficiency": $coordination_efficiency,
    "system_load": $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',' || echo "0"),
    "memory_usage": $(free 2>/dev/null | awk '/^Mem:/ {printf "%.2f", $3/$2*100}' || echo "0"),
    "disk_usage": $(df . | tail -1 | awk '{print $5}' | tr -d '%' || echo "0")
  },
  "8020_analysis": {
    "primary_bottleneck": "$(identify_primary_bottleneck)",
    "optimization_opportunity": "$(identify_optimization_opportunity)",
    "effort_score": "$(calculate_effort_score)",
    "impact_score": "$(calculate_impact_score)"
  }
}
EOF
    )
    
    echo "$metrics" >> "$metrics_file"
    echo "$metrics"
}

# Identify the primary bottleneck (80/20 analysis)
identify_primary_bottleneck() {
    local bottlenecks=()
    
    # Check file size (major performance impact)
    if [[ -f "$COORDINATION_DIR/work_claims.json" ]]; then
        local size=$(stat -f%z "$COORDINATION_DIR/work_claims.json" 2>/dev/null || stat -c%s "$COORDINATION_DIR/work_claims.json" 2>/dev/null || echo 0)
        if [[ $size -gt 1048576 ]]; then  # >1MB
            echo "large_work_claims_file"
            return
        fi
    fi
    
    # Check agent efficiency
    local agent_efficiency=0
    if [[ -f "$COORDINATION_DIR/agent_status.json" ]]; then
        local total_capacity=$(jq '[.[] | .capacity] | add // 0' "$COORDINATION_DIR/agent_status.json" 2>/dev/null || echo 0)
        local total_workload=$(jq '[.[] | .current_workload] | add // 0' "$COORDINATION_DIR/agent_status.json" 2>/dev/null || echo 0)
        if [[ $total_capacity -gt 0 ]]; then
            agent_efficiency=$(echo "scale=2; $total_workload / $total_capacity" | bc -l 2>/dev/null || echo "0")
            if (( $(echo "$agent_efficiency < 0.5" | bc -l) )); then
                echo "low_agent_utilization"
                return
            fi
        fi
    fi
    
    # Check coordination overhead
    local telemetry_size=0
    if [[ -f "$COORDINATION_DIR/telemetry_spans.jsonl" ]]; then
        telemetry_size=$(wc -l < "$COORDINATION_DIR/telemetry_spans.jsonl" 2>/dev/null || echo 0)
        if [[ $telemetry_size -gt 10000 ]]; then
            echo "excessive_telemetry"
            return
        fi
    fi
    
    echo "no_major_bottleneck"
}

# Identify optimization opportunity (highest impact/effort ratio)
identify_optimization_opportunity() {
    local primary_bottleneck=$(identify_primary_bottleneck)
    
    case "$primary_bottleneck" in
        "large_work_claims_file")
            echo "archive_completed_work"
            ;;
        "low_agent_utilization")
            echo "rebalance_workload"
            ;;
        "excessive_telemetry")
            echo "cleanup_telemetry"
            ;;
        *)
            echo "routine_maintenance"
            ;;
    esac
}

# Calculate effort score (1-10, lower is easier)
calculate_effort_score() {
    local opportunity=$(identify_optimization_opportunity)
    
    case "$opportunity" in
        "archive_completed_work") echo "2" ;;  # Very low effort
        "cleanup_telemetry") echo "3" ;;       # Low effort
        "routine_maintenance") echo "1" ;;     # Minimal effort
        "rebalance_workload") echo "5" ;;      # Medium effort
        *) echo "4" ;;
    esac
}

# Calculate impact score (1-10, higher is better)
calculate_impact_score() {
    local opportunity=$(identify_optimization_opportunity)
    
    case "$opportunity" in
        "archive_completed_work") echo "9" ;;  # High impact on performance
        "rebalance_workload") echo "8" ;;      # High impact on efficiency
        "cleanup_telemetry") echo "6" ;;       # Medium impact
        "routine_maintenance") echo "4" ;;     # Low-medium impact
        *) echo "5" ;;
    esac
}

# Implement optimization (80/20 focused)
implement_optimization() {
    local opportunity="$1"
    local dry_run="$2"
    
    echo "🚀 Implementing optimization: $opportunity (dry_run: $dry_run)"
    
    case "$opportunity" in
        "archive_completed_work")
            if [[ "$dry_run" == "false" ]]; then
                echo "   ⚡ Archiving completed work claims..."
                ./coordination_helper.sh optimize
            else
                echo "   🔍 Would archive completed work claims"
            fi
            ;;
        "cleanup_telemetry")
            if [[ "$dry_run" == "false" ]]; then
                echo "   ⚡ Cleaning up old telemetry..."
                find "$COORDINATION_DIR" -name "telemetry_spans.jsonl" -size +10M -exec truncate -s 1M {} \;
            else
                echo "   🔍 Would clean up telemetry files"
            fi
            ;;
        "rebalance_workload")
            if [[ "$dry_run" == "false" ]]; then
                echo "   ⚡ Triggering workload rebalancing..."
                if command -v claude >/dev/null 2>&1; then
                    ./coordination_helper.sh claude-optimize-assignments
                else
                    echo "   📋 Claude not available for intelligent rebalancing"
                fi
            else
                echo "   🔍 Would rebalance agent workload"
            fi
            ;;
        "routine_maintenance")
            if [[ "$dry_run" == "false" ]]; then
                echo "   ⚡ Running routine maintenance..."
                # Clean up lock files
                find "$COORDINATION_DIR" -name "*.lock" -mtime +1 -delete 2>/dev/null || true
                # Validate JSON files
                for json_file in "$COORDINATION_DIR"/*.json; do
                    if [[ -f "$json_file" ]]; then
                        jq empty "$json_file" 2>/dev/null || echo "⚠️ Invalid JSON: $json_file"
                    fi
                done
            else
                echo "   🔍 Would run routine maintenance"
            fi
            ;;
        *)
            echo "   ℹ️ No optimization needed"
            ;;
    esac
}

# Test optimization results
test_optimization() {
    local before_metrics="$1"
    local after_metrics="$2"
    
    echo "🧪 Testing optimization results..."
    
    # Extract key metrics for comparison
    local before_efficiency=$(echo "$before_metrics" | jq -r '.metrics.coordination_efficiency // 0')
    local after_efficiency=$(echo "$after_metrics" | jq -r '.metrics.coordination_efficiency // 0')
    
    local before_file_size=$(echo "$before_metrics" | jq -r '.metrics.work_claims_file_size // 0')
    local after_file_size=$(echo "$after_metrics" | jq -r '.metrics.work_claims_file_size // 0')
    
    # Calculate improvements
    local efficiency_delta=$(echo "scale=3; $after_efficiency - $before_efficiency" | bc -l 2>/dev/null || echo "0")
    local size_reduction_percent=0
    
    if [[ $before_file_size -gt 0 ]]; then
        size_reduction_percent=$(echo "scale=1; ($before_file_size - $after_file_size) * 100 / $before_file_size" | bc -l 2>/dev/null || echo "0")
    fi
    
    echo "   📊 Efficiency change: $efficiency_delta"
    echo "   📦 File size reduction: ${size_reduction_percent}%"
    
    # Log test results
    local test_results=$(cat <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "test_results": {
    "efficiency_delta": $efficiency_delta,
    "size_reduction_percent": $size_reduction_percent,
    "optimization_successful": $(if (( $(echo "$efficiency_delta >= 0" | bc -l) )) && (( $(echo "$size_reduction_percent >= 0" | bc -l) )); then echo "true"; else echo "false"; fi)
  }
}
EOF
    )
    
    echo "$test_results" >> "$COORDINATION_DIR/8020_test_results.jsonl"
    
    # Return success if optimization showed improvement
    if (( $(echo "$efficiency_delta >= 0" | bc -l) )) && (( $(echo "$size_reduction_percent >= 0" | bc -l) )); then
        echo "✅ Optimization successful"
        return 0
    else
        echo "⚠️ Optimization had mixed results"
        return 1
    fi
}

# Main 80/20 loop
run_8020_loop() {
    local loop_duration="$1"
    local dry_run="$2"
    local start_time=$(date +%s)
    local end_time=$((start_time + loop_duration))
    local iteration=0
    
    echo "🔄 Starting 80/20 continuous improvement loop"
    echo "   Duration: ${loop_duration}s"
    echo "   Dry run: $dry_run"
    echo "   Target: 20% effort for 80% improvement"
    echo ""
    
    while [[ $(date +%s) -lt $end_time ]]; do
        ((iteration++))
        echo "🔄 Iteration $iteration - $(date)"
        
        # Think: Collect metrics and analyze
        echo "🧠 THINK: Analyzing current state..."
        local before_metrics=$(collect_8020_metrics)
        
        # 80/20: Identify high-impact, low-effort optimization
        echo "📊 80/20: Identifying optimization opportunity..."
        local opportunity=$(echo "$before_metrics" | jq -r '.["8020_analysis"].optimization_opportunity')
        local effort=$(echo "$before_metrics" | jq -r '.["8020_analysis"].effort_score')
        local impact=$(echo "$before_metrics" | jq -r '.["8020_analysis"].impact_score')
        
        echo "   🎯 Opportunity: $opportunity"
        echo "   💪 Effort: $effort/10"
        echo "   🚀 Impact: $impact/10"
        echo "   📈 ROI: $(echo "scale=1; $impact / $effort" | bc -l 2>/dev/null || echo "N/A")"
        
        # Implement: Apply the optimization
        echo "⚡ IMPLEMENT: Applying optimization..."
        implement_optimization "$opportunity" "$dry_run"
        
        # Test: Measure results
        echo "🧪 TEST: Measuring results..."
        sleep 5  # Allow time for changes to take effect
        local after_metrics=$(collect_8020_metrics)
        test_optimization "$before_metrics" "$after_metrics"
        
        # Loop: Wait before next iteration
        echo "🔄 LOOP: Waiting for next iteration..."
        echo "----------------------------------------"
        sleep 300  # 5 minutes between iterations
    done
    
    echo "✅ 80/20 improvement loop completed"
    generate_8020_report
}

# Generate improvement report
generate_8020_report() {
    local report_file="$COORDINATION_DIR/8020_improvement_report.json"
    
    echo "📋 Generating 80/20 improvement report..."
    
    # Analyze metrics trends
    local metrics_file="$COORDINATION_DIR/8020_metrics.jsonl"
    if [[ -f "$metrics_file" ]]; then
        local first_efficiency=$(head -1 "$metrics_file" | jq -r '.metrics.coordination_efficiency // 0')
        local last_efficiency=$(tail -1 "$metrics_file" | jq -r '.metrics.coordination_efficiency // 0')
        local efficiency_improvement=$(echo "scale=3; $last_efficiency - $first_efficiency" | bc -l 2>/dev/null || echo "0")
        
        local report=$(cat <<EOF
{
  "report_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "8020_principle_applied": true,
  "total_iterations": $(wc -l < "$metrics_file" 2>/dev/null || echo 0),
  "efficiency_improvement": $efficiency_improvement,
  "optimizations_applied": [
    $(grep -o '"optimization_opportunity":"[^"]*"' "$metrics_file" | sort | uniq -c | awk '{print "\"" $2 "\": " $1}' | paste -sd ',' -)
  ],
  "key_insights": [
    "Focus on high-impact, low-effort optimizations",
    "Continuous small improvements compound over time",
    "Automated optimization reduces manual overhead"
  ],
  "next_recommendations": [
    "Continue monitoring file size growth",
    "Implement predictive optimization triggers",
    "Add more granular performance metrics"
  ]
}
EOF
        )
        
        echo "$report" > "$report_file"
        echo "📊 Report saved to: $report_file"
        
        # Display summary
        echo ""
        echo "🎯 80/20 IMPROVEMENT SUMMARY"
        echo "============================"
        echo "   📈 Efficiency improvement: $efficiency_improvement"
        echo "   🔄 Total iterations: $(wc -l < "$metrics_file" 2>/dev/null || echo 0)"
        echo "   ⚡ Primary focus: High-impact, low-effort optimizations"
    fi
}

# Show help
show_help() {
    cat << EOF
🎯 80/20 Continuous Improvement Loop

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --loop-duration=SECONDS    Run loop for specified duration (default: 3600)
    --dry-run                  Show what would be done without executing
    --help                     Show this help message

EXAMPLES:
    $0                         # Run for 1 hour
    $0 --loop-duration=7200    # Run for 2 hours
    $0 --dry-run               # Preview optimizations

80/20 PRINCIPLE:
    Focus on the 20% of optimizations that provide 80% of the performance gains.
    
    High-Impact Optimizations:
    - Archive completed work (Effort: 2/10, Impact: 9/10)
    - Cleanup telemetry (Effort: 3/10, Impact: 6/10)
    - Rebalance workload (Effort: 5/10, Impact: 8/10)

AUTOMATION:
    The loop automatically:
    1. THINK - Analyzes current performance metrics
    2. 80/20 - Identifies highest ROI optimizations
    3. IMPLEMENT - Applies optimizations automatically
    4. TEST - Measures improvement results
    5. LOOP - Repeats continuously
EOF
}

# Parse command line arguments
case "${1:-}" in
    --help|-h)
        show_help
        exit 0
        ;;
    --dry-run)
        run_8020_loop 3600 true
        ;;
    --loop-duration=*)
        duration="${1#*=}"
        run_8020_loop "$duration" false
        ;;
    "")
        run_8020_loop 3600 false
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac