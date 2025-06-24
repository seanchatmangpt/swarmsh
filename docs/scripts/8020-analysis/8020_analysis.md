# 8020_analysis.sh

**80/20 Performance Analysis Engine for Agent Coordination System**

## Overview

The `8020_analysis.sh` script implements Pareto principle-based performance analysis to identify the 20% of bottlenecks causing 80% of performance issues in the SwarmSH coordination system. It performs comprehensive system analysis focusing on high-impact optimization opportunities.

## Purpose

- Identifies performance bottlenecks using 80/20 analysis principles
- Analyzes data volume, operation frequency, and service performance
- Provides actionable optimization recommendations
- Generates structured analysis reports with confidence scoring

## Key Features

### 1. Multi-Phase Analysis
- **Phase 1**: Data Volume Analysis (file sizes, line counts)
- **Phase 2**: Operation Frequency Analysis (telemetry operations)
- **Phase 3**: Service Performance Analysis (telemetry overhead)
- **Phase 4**: Critical Path Analysis (work claim bottlenecks)
- **Phase 5**: 80/20 Optimization Opportunities

### 2. Metrics Collection
- Telemetry event volume and types
- Work claim distribution and priorities
- Agent workload distribution
- System resource utilization

### 3. Optimization Recommendations
Prioritized by impact/effort ratio:
1. **Telemetry Sampling** (80% overhead reduction, low effort)
2. **Work Claim Optimization** (60% speed improvement, medium effort)
3. **Agent Load Balancing** (40% better utilization, medium effort)

## Usage

```bash
# Run 80/20 analysis
./8020_analysis.sh

# Results saved to timestamped JSON file
# Example: 8020_analysis_1750741598.json
```

## Dependencies

- **Required Files**:
  - `telemetry_spans.jsonl` - OpenTelemetry data
  - `work_claims.json` - Work coordination data
  - `agent_status.json` - Agent status information
  - `otel-bash.sh` - OpenTelemetry library (optional)

- **System Tools**:
  - `jq` - JSON processing
  - `openssl` - Random ID generation
  - `bc` - Calculations

## Output Format

The script generates a structured JSON analysis report containing:

```json
{
  "analysis_timestamp": "2025-06-24T12:00:00Z",
  "trace_id": "abc123...",
  "analysis_type": "8020_performance_optimization",
  "system_metrics": {
    "total_telemetry_events": 15000,
    "total_work_items": 250,
    "total_agents": 12
  },
  "bottleneck_analysis": {
    "telemetry_overhead": {
      "severity": "high",
      "impact": "80% of system overhead from telemetry volume",
      "recommendation": "implement_telemetry_sampling"
    },
    "work_distribution": {
      "critical_threshold": 50,
      "recommendation": "focus_on_top_20_percent_work_types"
    }
  },
  "optimization_priorities": [
    {
      "priority": 1,
      "action": "telemetry_sampling",
      "impact": "80% reduction in telemetry overhead",
      "effort": "low"
    }
  ],
  "confidence_score": 0.85
}
```

## OpenTelemetry Integration

- Creates analysis traces with unique trace IDs
- Logs analysis start/completion events
- Records analysis duration and results
- Integrates with existing telemetry infrastructure

## Performance Thresholds

- **High telemetry overhead**: >10,000 events
- **Critical work threshold**: 20% of total work items
- **File size concern**: >1MB for coordination files

## Example Analysis Output

```
🔍 80/20 PERFORMANCE ANALYSIS ENGINE
====================================
Trace ID: f4e2d1c9b8a7...

📊 PHASE 1: Data Volume Analysis (Finding the Heavy Hitters)
=============================================================
File Size Analysis:
15K telemetry_spans.jsonl
8.2K work_claims.json
2.1K agent_status.json

🎯 PHASE 2: Operation Frequency Analysis
========================================
Top Operations by Frequency:
    125 coordination_helper
     89 work_claim_processing
     67 agent_status_update

🚀 PHASE 5: 80/20 Optimization Opportunities
=============================================
📈 System Scale Analysis:
  Telemetry Events: 15247
  Active Work Items: 156
  Registered Agents: 12

🎯 80/20 Optimization Targets:
  Focus on top 3049 telemetry events (20% of volume)
  Optimize top 31 work types (20% of work)

📋 OPTIMIZATION RECOMMENDATIONS:
  1. 🎯 Implement telemetry sampling (80% overhead reduction)
  2. 🔄 Optimize top 20% of work types (60% speed improvement)
  3. ⚖️ Balance agent loads (40% better utilization)
```

## Integration with Other Scripts

- **Input for**: `8020_optimizer.sh` (implements recommendations)
- **Feeds into**: `8020_feedback_loop.sh` (continuous improvement)
- **Used by**: `continuous_8020_loop.sh` (automated optimization)

## Best Practices

1. Run analysis regularly to catch performance drift
2. Archive old analysis results for trend analysis
3. Validate recommendations before implementation
4. Monitor system after applying optimizations
5. Use confidence scores to prioritize actions

## Troubleshooting

### Common Issues

1. **Missing Dependencies**: Install `jq` and ensure OpenTelemetry files exist
2. **Corrupted JSON**: Validate JSON files before analysis
3. **Insufficient Data**: Ensure system has run long enough to generate meaningful telemetry
4. **Permission Issues**: Ensure script has read access to coordination files

### Expected Performance

- **Analysis Duration**: 100-500ms for typical systems
- **Memory Usage**: Minimal (processes files line by line)
- **Disk I/O**: Read-only operations on existing files

## File Locations

- **Script**: `/Users/sac/dev/swarmsh/8020_analysis.sh`
- **Output**: `/Users/sac/dev/swarmsh/8020_analysis_<timestamp>.json`
- **Telemetry**: Appends to `telemetry_spans.jsonl`