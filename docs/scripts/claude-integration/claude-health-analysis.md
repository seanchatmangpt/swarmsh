# claude-health-analysis

## Overview
AI-powered system health analysis executable that evaluates agent swarm coordination effectiveness and identifies optimization opportunities.

## Purpose
- Assess overall system health and coordination efficiency
- Identify performance bottlenecks and resource issues
- Provide actionable recommendations for improvements
- Monitor agent performance and utilization patterns

## Usage
```bash
# Basic health analysis
./claude/claude-health-analysis

# Pretty-printed output
./claude/claude-health-analysis | jq .

# Extract critical alerts
./claude/claude-health-analysis | jq -r '.alerts[]?.message'
```

## Key Features
- **Comprehensive Health Assessment**: Multi-dimensional system analysis
- **Performance Metrics**: Agent utilization, coordination efficiency, throughput
- **Alert Generation**: Proactive identification of issues
- **Trend Analysis**: Historical performance pattern recognition

## Output Format
```json
{
  "health_score": 0.85,
  "analysis_timestamp": "2025-06-24T14:30:22Z",
  "component_health": {
    "agent_performance": 0.88,
    "work_distribution": 0.82,
    "coordination_efficiency": 0.87,
    "resource_utilization": 0.83
  },
  "alerts": [
    {
      "severity": "warning",
      "component": "work_distribution",
      "message": "Uneven workload detected across agents",
      "recommendation": "Consider load balancing optimization"
    }
  ],
  "recommendations": [
    {
      "priority": "high",
      "action": "optimize_agent_assignments",
      "description": "Rebalance work distribution based on agent capabilities"
    }
  ],
  "trends": {
    "coordination_latency": "improving",
    "work_completion_rate": "stable",
    "agent_availability": "declining"
  }
}
```

## Health Metrics

### Agent Performance (0.0-1.0)
- Work completion rates
- Response times
- Error frequencies
- Availability patterns

### Work Distribution (0.0-1.0)
- Load balancing effectiveness
- Queue depth variations
- Skill-based assignment accuracy
- Throughput consistency

### Coordination Efficiency (0.0-1.0)
- Communication overhead
- Synchronization delays
- Conflict resolution speed
- Decision-making latency

### Resource Utilization (0.0-1.0)
- CPU and memory usage
- Network bandwidth efficiency
- Storage optimization
- Capacity planning accuracy

## Alert Severity Levels
- **Critical**: Immediate action required, system impact
- **Warning**: Attention needed, potential issues
- **Info**: Informational, optimization opportunities

## Integration Examples
```bash
# Monitor health continuously
watch -n 30 './claude/claude-health-analysis | jq .health_score'

# Get critical alerts only
./claude/claude-health-analysis | jq '.alerts[] | select(.severity=="critical")'

# Extract recommendations
./claude/claude-health-analysis | jq -r '.recommendations[] | "\(.priority): \(.description)"'

# Check specific component
./claude/claude-health-analysis | jq '.component_health.agent_performance'
```

## Automation
```bash
# Health check in monitoring scripts
health_score=$(./claude/claude-health-analysis | jq -r '.health_score')
if (( $(echo "$health_score < 0.7" | bc -l) )); then
    echo "Health degraded: $health_score" | mail -s "System Alert" admin@example.com
fi
```

## Dependencies
- Claude AI CLI (optional)
- jq for JSON processing
- bc for numerical comparisons
- Access to coordination logs and metrics
- Historical performance data