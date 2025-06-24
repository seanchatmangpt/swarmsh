# coordination_helper.sh

## Overview

The core coordination system for autonomous AI agent swarm using Scrum at Scale (S@S) methodology. Provides atomic work claiming with nanosecond-precision IDs to guarantee zero conflicts, implements 40+ shell commands for enterprise-grade coordination, and integrates OpenTelemetry distributed tracing with Claude AI intelligence.

## Purpose

- Coordinate work across multiple AI agents without conflicts
- Implement S@S ceremonies and workflows
- Provide distributed tracing for observability
- Enable AI-powered work prioritization and team formation
- Manage agent lifecycle and work assignments

## Prerequisites

- **bash** 4.0+
- **jq** - JSON processing (with fallback support)
- **openssl** - Trace ID generation
- **python3** - Timestamp calculations
- **claude** - AI analysis (optional, with fallback)

## Usage

```bash
# Basic work management
./coordination_helper.sh claim <work_type> <description> <priority> <team>
./coordination_helper.sh progress <work_id> <percentage> <status>
./coordination_helper.sh complete <work_id> <success|failure> <confidence>

# Agent registration
./coordination_helper.sh register <agent_name> <capabilities> <team>

# Intelligence analysis
./coordination_helper.sh claude-analyze-priorities
./coordination_helper.sh claude-stream <stream_type> <duration>

# S@S ceremonies
./coordination_helper.sh pi-planning
./coordination_helper.sh scrum-of-scrums
./coordination_helper.sh inspect-and-adapt
```

## Key Features

### Atomic Work Management
- File locking prevents concurrent access conflicts
- Nanosecond-precision IDs ensure uniqueness
- TTL-based cleanup prevents work accumulation

### Claude AI Integration
- Intelligent work prioritization
- Dynamic team formation
- Real-time coordination streaming
- Fallback analysis when Claude unavailable

### OpenTelemetry Tracing
- Complete distributed tracing
- Trace context propagation
- Performance metrics collection
- Span correlation across agents

### S@S Ceremonies
- PI Planning automation
- Scrum of Scrums coordination
- System Demo preparation
- Inspect and Adapt workflows

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `COORDINATION_DIR` | Coordination data directory | `/tmp/s2s_coordination` |
| `OTEL_SERVICE_NAME` | OpenTelemetry service name | `s2s-coordination` |
| `FORCE_TRACE_ID` | Force specific trace ID | (none) |
| `AGENT_ID` | Agent identifier | (generated) |
| `AGENT_TEAM` | Team assignment | `unassigned` |

### Data Files

| File | Purpose |
|------|---------|
| `work_claims.json` | Active work items with atomic locking |
| `agent_status.json` | Agent registration and metrics |
| `coordination_log.json` | Completed work history |
| `telemetry_spans.jsonl` | OpenTelemetry trace data |

## Commands Reference

### Work Management Commands

#### claim
Atomically claim a work item
```bash
./coordination_helper.sh claim <work_type> <description> <priority> <team>
```

#### progress
Update work progress
```bash
./coordination_helper.sh progress <work_id> <percentage> <status>
```

#### complete
Mark work as completed
```bash
./coordination_helper.sh complete <work_id> <success|failure> <confidence>
```

#### list-work
List all active work items
```bash
./coordination_helper.sh list-work [<team>]
```

### Agent Commands

#### register
Register an agent in a team
```bash
./coordination_helper.sh register <agent_name> <capabilities> <team>
```

#### heartbeat
Update agent status
```bash
./coordination_helper.sh heartbeat <agent_id>
```

#### list-agents
List all registered agents
```bash
./coordination_helper.sh list-agents [<team>]
```

### Intelligence Commands

#### claude-analyze-priorities
Run Claude priority analysis
```bash
./coordination_helper.sh claude-analyze-priorities
```

#### claude-optimize-assignments
Optimize work assignments
```bash
./coordination_helper.sh claude-optimize-assignments
```

#### claude-stream
Real-time coordination stream
```bash
./coordination_helper.sh claude-stream <type> <duration>
```

### S@S Ceremony Commands

#### pi-planning
Run PI Planning session
```bash
./coordination_helper.sh pi-planning
```

#### scrum-of-scrums
Coordinate Scrum of Scrums
```bash
./coordination_helper.sh scrum-of-scrums
```

#### system-demo
Prepare system demonstration
```bash
./coordination_helper.sh system-demo
```

## Error Handling

- Atomic operations with file locking
- Retry logic with exponential backoff
- Graceful degradation for Claude unavailability
- Comprehensive error logging with color coding

## Integration Points

- Used by `agent_swarm_orchestrator.sh` for swarm management
- Compatible with AgentCoordinationMiddleware in Phoenix
- Provides telemetry data for monitoring systems
- Integrates with worktree management scripts

## Examples

### Complete Work Flow
```bash
# Register agent
./coordination_helper.sh register "agent-1" "code,test" "phoenix-team"

# Claim work
work_id=$(./coordination_helper.sh claim "feature" "Implement user auth" "high" "phoenix-team")

# Update progress
./coordination_helper.sh progress "$work_id" 50 "in_progress"

# Complete work
./coordination_helper.sh complete "$work_id" "success" 9

# Run analysis
./coordination_helper.sh claude-analyze-priorities
```

### Team Coordination
```bash
# Start PI Planning
./coordination_helper.sh pi-planning

# Run Scrum of Scrums
./coordination_helper.sh scrum-of-scrums

# List team work
./coordination_helper.sh list-work "phoenix-team"
```

## Performance Considerations

- Nanosecond precision prevents ID collisions
- File locking ensures atomic operations
- TTL cleanup prevents unbounded growth
- OpenTelemetry spans track performance

## Troubleshooting

### Common Issues

1. **Work claim failures**: Check file permissions in `COORDINATION_DIR`
2. **Claude unavailable**: System falls back to basic analysis
3. **Trace correlation**: Ensure `FORCE_TRACE_ID` is set consistently
4. **Team isolation**: Verify agent team assignments

### Debug Mode
```bash
DEBUG=1 ./coordination_helper.sh <command>
```

## Related Scripts

- `agent_swarm_orchestrator.sh` - Manages agent swarms
- `quick_start_agent_swarm.sh` - Quick setup
- `implement_real_agents.sh` - Convert to real processes