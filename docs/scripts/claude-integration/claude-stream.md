# claude-stream

## Overview
Real-time Claude AI streaming executable for live coordination insights and continuous monitoring of agent swarm operations.

## Purpose
- Provide real-time AI insights about system coordination
- Stream continuous analysis of agent performance
- Monitor system health with live feedback
- Enable responsive decision-making with streaming data

## Usage
```bash
# Stream performance insights for 60 seconds
./claude/claude-stream performance 60

# Stream system health analysis for 30 seconds
./claude/claude-stream health 30

# Stream coordination insights for 2 minutes
./claude/claude-stream coordination 120

# Default 30-second stream
./claude/claude-stream priorities
```

## Key Features
- **Real-time Streaming**: Continuous AI analysis with live updates
- **Multiple Focus Areas**: Performance, health, coordination, priorities
- **Configurable Duration**: Flexible time windows for analysis
- **JSON Output**: Structured data for integration and automation

## Stream Focus Areas

### performance
Analyzes system performance metrics in real-time:
- Agent response times
- Work completion rates  
- Resource utilization patterns
- Throughput optimization opportunities

### health
Monitors overall system health continuously:
- Component availability
- Error rates and patterns
- Recovery metrics
- System stability indicators

### coordination
Focuses on agent coordination effectiveness:
- Communication patterns
- Synchronization efficiency
- Conflict resolution speed
- Workflow optimization

### priorities
Streams work prioritization insights:
- Dynamic priority adjustments
- Critical path changes
- Urgency escalations
- Resource reallocation needs

## Output Format
Each streaming update provides:
```json
{
  "timestamp": "2025-06-24T14:30:22Z",
  "focus_area": "performance",
  "urgent_actions": [
    "Optimize agent_003 workload",
    "Address coordination bottleneck in team-phoenix"
  ],
  "system_status": "warning",
  "next_recommendation": "Rebalance work distribution",
  "confidence": 0.87,
  "stream_id": "stream_1719244222"
}
```

## Stream Control
- **Duration**: Specify analysis time in seconds
- **Interruption**: Ctrl+C to stop streaming gracefully
- **Buffer Management**: Automatic buffer flushing for real-time output
- **Resource Optimization**: Efficient streaming with minimal overhead

## Integration Examples
```bash
# Real-time monitoring dashboard
./claude/claude-stream performance 300 | while read -r line; do
    status=$(echo "$line" | jq -r '.system_status')
    if [[ "$status" == "critical" ]]; then
        echo "ALERT: $line" | mail -s "System Alert" admin@example.com
    fi
done

# Log streaming insights
./claude/claude-stream coordination 3600 >> coordination_insights.log &

# Extract urgent actions
./claude/claude-stream health 60 | jq -r '.urgent_actions[]?' | head -5
```

## Performance Monitoring
```bash
# Monitor for performance degradation
./claude/claude-stream performance 180 | jq -r '
  select(.system_status == "warning" or .system_status == "critical") |
  "\(.timestamp): \(.system_status) - \(.urgent_actions[0])"'

# Track system improvements
./claude/claude-stream performance 300 | jq -r '.confidence' | 
  awk '{sum+=$1; count++} END {print "Average confidence:", sum/count}'
```

## Automation Workflows
```bash
# Automated response to critical issues
./claude/claude-stream health 600 | while IFS= read -r update; do
    status=$(echo "$update" | jq -r '.system_status')
    if [[ "$status" == "critical" ]]; then
        # Trigger automatic remediation
        ./coordination_helper.sh claude-analyze-priorities
        ./claude/claude-optimize-assignments
    fi
done

# Continuous optimization loop
while true; do
    recommendation=$(./claude/claude-stream priorities 30 | tail -1 | 
                    jq -r '.next_recommendation')
    echo "$(date): $recommendation"
    sleep 60
done
```

## Resource Management
- **CPU Usage**: Optimized for continuous operation
- **Memory**: Streaming buffer management prevents accumulation
- **Network**: Efficient Claude API usage with rate limiting
- **Disk I/O**: Minimal disk writes for streaming operation

## Error Handling
- **Connection Issues**: Graceful degradation with retries
- **API Limits**: Automatic rate limiting and backoff
- **Interruption**: Clean shutdown on SIGINT/SIGTERM
- **Data Validation**: JSON schema validation for streaming data

## Dependencies
- Claude AI CLI with streaming support
- jq for JSON processing
- Network connection for AI analysis
- Sufficient system resources for continuous operation

## Use Cases
- **Operations Center**: Real-time system monitoring
- **Development Teams**: Live performance feedback during deployment
- **Incident Response**: Continuous analysis during incidents
- **Capacity Planning**: Long-term streaming for trend analysis