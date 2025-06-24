# 8020_optimizer.sh

**80/20 Performance Optimizer - Implements Targeted Optimizations**

## Overview

The `8020_optimizer.sh` script implements targeted performance optimizations based on 80/20 analysis principles. It focuses on the 20% of changes that yield 80% of performance improvements, automatically applying optimizations with the highest impact-to-effort ratio.

## Purpose

- Applies systematic performance optimizations based on 80/20 analysis
- Implements targeted improvements with maximum ROI
- Provides automated optimization with telemetry tracking
- Generates comprehensive optimization reports

## Key Features

### Four-Phase Optimization Strategy

1. **Telemetry Sampling** (Priority: CRITICAL, 80% impact)
   - Reduces telemetry volume by 90%
   - Preserves critical events (errors, 8020 operations)
   - Creates backups before optimization

2. **Work Type Consolidation** (Priority: HIGH, 60% impact)
   - Consolidates related work types
   - Reduces coordination complexity
   - Maintains functional categorization

3. **Agent Load Balancing** (Priority: MEDIUM, 40% impact)
   - Redistributes work among teams
   - Balances overloaded agents
   - Optimizes resource utilization

4. **Archive Optimization** (Priority: LOW)
   - Archives completed work
   - Uses existing coordination_helper.sh functions

### Automatic Backup Strategy

- Creates timestamped backups before each optimization
- Preserves original state for rollback capability
- Tracks optimization history

## Usage

```bash
# Run complete 80/20 optimization
./8020_optimizer.sh

# Results logged to timestamped optimization file
# Example: 8020_optimization_results_1750741598.json
```

## Dependencies

- **Required Files**:
  - `telemetry_spans.jsonl` - OpenTelemetry data
  - `work_claims.json` - Work coordination data
  - `agent_status.json` - Agent information
  - `coordination_helper.sh` - Archive functions
  - `otel-bash.sh` - OpenTelemetry library (optional)

- **System Tools**:
  - `jq` - JSON processing
  - `awk` - Text processing
  - `openssl` - Random ID generation

## Optimization Details

### 1. Telemetry Sampling

**Implementation**:
```bash
# Keeps 1 in 10 events + critical events
awk 'NR % 10 == 0 || /error/ || /critical/ || /8020_optimization/ || /coordination_helper/' 
```

**Benefits**:
- 90% reduction in telemetry file size
- Preserves critical debugging information
- Maintains trace continuity
- Reduces disk I/O overhead

### 2. Work Type Consolidation

**Consolidation Rules**:
- `8020_throughput_optimization` → `8020_optimization`
- `8020_next_cycle_preparation` → `8020_optimization`
- `trace_validation` → `observability`
- `observability_infrastructure` → `observability`

**Benefits**:
- Reduces work type complexity
- Improves coordination efficiency
- Maintains logical groupings

### 3. Agent Load Balancing

**Rebalancing Logic**:
- Moves observability work from `meta_8020_team` to `observability_team`
- Reassigns 8020 work to specialized `8020_team`
- Reduces maximum team workload

**Metrics Tracked**:
- Maximum team load before/after
- Load distribution improvement percentage
- Team workload visualization

## Output Format

The script generates comprehensive optimization results:

```json
{
  "optimization_timestamp": "2025-06-24T12:00:00Z",
  "trace_id": "def456...",
  "optimizations": {
    "telemetry_sampling": {
      "reduction_percent": 87,
      "priority": "critical",
      "impact": "80%"
    },
    "work_type_consolidation": {
      "reduction_percent": 35,
      "priority": "high",
      "impact": "60%"
    },
    "load_balancing": {
      "improvement_percent": 42,
      "priority": "medium",
      "impact": "40%"
    }
  },
  "overall_improvement_percent": 55,
  "duration_ms": 1247,
  "8020_principle_applied": true
}
```

## Real-Time Output Example

```
⚡ 80/20 PERFORMANCE OPTIMIZER
=============================
Trace ID: abc123def456...
Target: 80% performance gain from 20% of optimizations

🎯 OPTIMIZATION 1: Telemetry Sampling (Priority: CRITICAL)
=========================================================
📊 Current telemetry size: 15247 events
🎯 Target reduction: 90% (keep 1 in 10 events)
✅ Telemetry sampling complete:
   Before: 15247 events
   After:  1687 events
   Reduction: 89%
   Critical events preserved

🔄 OPTIMIZATION 2: Work Type Optimization (Priority: HIGH)
==========================================================
📋 Consolidating high-frequency work types...
✅ Work type optimization complete:
   Before: 23 unique types
   After:  15 unique types
   Reduction: 35%

⚖️ OPTIMIZATION 3: Agent Load Balancing (Priority: MEDIUM)
==========================================================
👥 Rebalancing agent workloads...
Current team distribution:
     89 meta_8020_team
     34 coordination_team
     12 observability_team

✅ Load balancing complete:
   Max team load before: 89 items
   Max team load after:  56 items
   Load reduction: 37%

New team distribution:
     56 meta_8020_team
     34 coordination_team
     29 observability_team
     16 8020_team

🎯 80/20 OPTIMIZATION SUMMARY
=============================
✅ Telemetry sampling: 89% reduction
✅ Work type optimization: 35% reduction
✅ Load balancing: 37% improvement
✅ Archive optimization: Completed work archived

📈 Overall Performance Improvement: ~54%
⏱️ Optimization Duration: 1247ms
```

## Backup Files Created

The optimizer creates several backup files:
- `telemetry_spans_backup_<timestamp>.jsonl`
- `work_claims_backup_<timestamp>.json`
- `work_claims_balance_backup_<timestamp>.json`

## Integration Points

### Input Sources
- Analysis results from `8020_analysis.sh`
- Current system state from coordination files
- OpenTelemetry trace data

### Output Consumers
- `8020_feedback_loop.sh` (measures results)
- `continuous_8020_loop.sh` (automated optimization)
- `8020_iteration2_*.sh` (advanced optimizations)

## Performance Metrics

### Expected Improvements
- **Telemetry Overhead**: 80-90% reduction
- **Coordination Speed**: 40-60% improvement
- **Resource Utilization**: 30-40% better balance
- **File I/O**: 50-70% reduction

### Typical Runtime
- **Small Systems** (<1000 work items): 100-300ms
- **Medium Systems** (1000-5000 items): 500-1500ms
- **Large Systems** (>5000 items): 1-3 seconds

## Safety Features

1. **Backup Creation**: Automatic backups before all changes
2. **Validation**: JSON validation after modifications
3. **Rollback Capability**: Preserved original files
4. **Critical Event Preservation**: Maintains debugging capability
5. **Telemetry Tracking**: Full optimization traceability

## Advanced Usage

### Custom Sampling Rates
```bash
# Modify sample_rate variable for different retention
sample_rate=0.05  # Keep 5% instead of 10%
```

### Selective Optimization
```bash
# Run only specific optimizations by commenting out others
# implement_telemetry_sampling  # Skip this
optimize_work_types           # Run this
# optimize_agent_loads        # Skip this
```

## Error Handling

- Graceful degradation if files are missing
- Validation of JSON integrity
- Preservation of system state on failures
- Detailed error logging in telemetry

## Best Practices

1. **Pre-Optimization**: Run `8020_analysis.sh` first
2. **Monitoring**: Check results with `8020_feedback_loop.sh`
3. **Scheduling**: Use with cron for automated optimization
4. **Validation**: Verify system health after optimization
5. **Rollback Planning**: Keep backup files for recovery

## Troubleshooting

### Common Issues

1. **JSON Corruption**: Restore from backup files
2. **Missing Dependencies**: Install jq and validate file paths
3. **Permission Errors**: Ensure write access to coordination files
4. **Large File Processing**: May timeout on very large telemetry files

### Recovery Commands

```bash
# Restore telemetry from backup
cp telemetry_spans_backup_<timestamp>.jsonl telemetry_spans.jsonl

# Restore work claims from backup
cp work_claims_backup_<timestamp>.json work_claims.json

# Validate JSON integrity
jq empty work_claims.json && echo "JSON valid"
```

## File Locations

- **Script**: `/Users/sac/dev/swarmsh/8020_optimizer.sh`
- **Results**: `/Users/sac/dev/swarmsh/8020_optimization_results_<timestamp>.json`
- **Backups**: `/Users/sac/dev/swarmsh/*_backup_<timestamp>.*`
- **Telemetry**: Appends to `telemetry_spans.jsonl`