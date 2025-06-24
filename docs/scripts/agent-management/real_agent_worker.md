# real_agent_worker.sh

## Overview

Real-time agent worker process that continuously polls for assigned work and executes it. Implements a continuous loop that checks for pending work assignments, claims them, executes simulated work, and reports completion with full integration into the coordination system.

## Purpose

- Process work items assigned to specific agents
- Maintain continuous operation for real-time coordination
- Simulate realistic work execution with timing
- Provide observable agent behavior for system monitoring
- Enable scalable multi-agent work distribution

## Prerequisites

- **jq** - JSON processing for work queries
- **coordination_helper.sh** - Core coordination system
- **work_claims.json** - Work queue data structure
- **bash** - Standard Unix shell environment

## Usage

```bash
# Start single agent worker
./real_agent_worker.sh "agent_001" "coordination"

# Start multiple workers in background
./real_agent_worker.sh "real_coordinator_1" "coordination" &
./real_agent_worker.sh "real_worker_1" "worker" &
./real_agent_worker.sh "real_validator_1" "validation" &

# Monitor running workers
pgrep -af real_agent_worker
```

## Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `AGENT_ID` | Unique identifier for the agent | `"agent_001"` |
| `WORK_TYPE` | Type of work the agent handles | `"coordination"` |

## Key Features

### Continuous Work Polling
- Polls work queue every 2 seconds
- Filters work by agent assignment and status
- Maintains persistent connection to coordination system

### Atomic Work State Management
- Updates work status: `pending` → `active` → `completed`
- Uses coordination_helper.sh for thread-safe operations
- Prevents work conflicts between agents

### Real Work Simulation
- Randomized work duration (1-5 seconds)
- Simulates realistic processing time
- Provides observable work completion patterns

### Timestamped Logging
- Console output with HH:MM:SS timestamps
- Clean monitoring output
- Silent coordination operations

## Work Processing Flow

```
1. Poll for work assigned to this agent
   ↓
2. Find pending work items
   ↓
3. Claim work (pending → active)
   ↓
4. Execute work simulation
   ↓
5. Report completion (active → completed)
   ↓
6. Sleep 2 seconds and repeat
```

## Work Query Logic

The agent uses a sophisticated jq filter to find relevant work:

```bash
jq -r --arg agent_id "$AGENT_ID" --arg work_type "$WORK_TYPE" '
  .[] | select(
    (.assigned_to == $agent_id or .work_type == $work_type) and 
    .status == "pending"
  ) | .work_id
' ../work_claims.json
```

This selects work that:
- Is assigned to the specific agent ID, OR
- Matches the agent's work type
- Has status "pending"

## Configuration

### Polling Interval
```bash
# Hardcoded 2-second interval
sleep 2
```

### Work Duration Simulation
```bash
# Random 1-5 second processing time
work_duration=$((RANDOM % 5 + 1))
sleep $work_duration
```

## Integration Points

### coordination_helper.sh
- `progress` command: Update work status to active
- `complete` command: Mark work as completed
- Silent operation with `/dev/null` redirects

### work_claims.json
- Direct file dependency for work queue
- Located at `../work_claims.json` relative to script
- Contains structured work items with status tracking

### Process Management
- Designed for background daemon operation
- Compatible with process monitoring tools
- Supports multiple concurrent instances

## Example Output

```
14:23:15 Agent real_coordinator_1 (coordination) polling for work...
14:23:17 Agent real_coordinator_1 (coordination) polling for work...
14:23:19 Found work: work_item_123456789
14:23:19 Agent real_coordinator_1 starting work on: work_item_123456
14:23:22 Agent real_coordinator_1 completed work: work_item_123456 (3 seconds)
14:23:24 Agent real_coordinator_1 (coordination) polling for work...
```

## Process Management

### Starting Agents
```bash
# Start in foreground for debugging
./real_agent_worker.sh "debug_agent" "test"

# Start in background for production
./real_agent_worker.sh "prod_agent" "coordination" &
echo $! > agent_prod.pid
```

### Monitoring Agents
```bash
# List all running agents
pgrep -af real_agent_worker

# Check specific agent
ps aux | grep "real_agent_worker.*agent_001"

# Monitor agent output
tail -f /dev/pts/0  # if running in foreground
```

### Stopping Agents
```bash
# Stop all agents
pkill -f real_agent_worker

# Stop specific agent
kill $(pgrep -f "real_agent_worker.*agent_001")

# Graceful shutdown with PID file
kill $(cat agent_prod.pid)
rm agent_prod.pid
```

## Error Handling

### Silent Operation
- coordination_helper.sh calls redirect to `/dev/null`
- Prevents noise in agent output
- Focuses on work processing messages

### Robust Polling
- Continues operation if no work available
- Handles JSON parsing errors gracefully
- Maintains continuous operation

### Work State Safety
- Uses atomic operations through coordination_helper.sh
- Prevents work conflicts between agents
- Maintains data consistency

## Performance Considerations

### Resource Usage
- Minimal CPU usage during polling
- Low memory footprint
- Efficient JSON processing with jq

### Scalability
- Multiple agents can run simultaneously
- Work distribution prevents conflicts
- Polling interval balances responsiveness and efficiency

### Monitoring
- Timestamped output for tracking
- Observable work completion patterns
- Integration with system monitoring tools

## Troubleshooting

### Common Issues

1. **No work found**
   - Check work_claims.json exists and has pending items
   - Verify agent ID and work type assignments
   - Confirm coordination_helper.sh is accessible

2. **Permission errors**
   ```bash
   # Check file permissions
   ls -la ../work_claims.json
   ls -la ../coordination_helper.sh
   
   # Fix permissions if needed
   chmod +x ../coordination_helper.sh
   chmod 664 ../work_claims.json
   ```

3. **JSON parsing errors**
   ```bash
   # Validate JSON structure
   jq . ../work_claims.json
   
   # Check for corruption
   tail ../work_claims.json
   ```

### Debug Mode
```bash
# Add debug output
set -x
./real_agent_worker.sh "debug_agent" "test"
```

## Related Scripts

- `implement_real_agents.sh` - Creates and manages agent workers
- `coordination_helper.sh` - Core coordination system
- `agent_swarm_orchestrator.sh` - Swarm-level management
- `quick_start_agent_swarm.sh` - Complete setup automation

## Use Cases

### Development Testing
- Test coordination system behavior
- Validate work distribution logic
- Debug agent interactions

### Production Deployment
- Background processing of work items
- Scalable multi-agent coordination
- Real-time system operation

### System Monitoring
- Observable agent behavior
- Work completion tracking
- Performance measurement