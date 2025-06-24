# agent_swarm_orchestrator.sh

## Overview

Advanced multi-agent coordination system orchestrator that manages deployment and lifecycle of AI agent swarms across git worktrees. Integrates Claude Code CLI for intelligent agent behavior and provides centralized swarm management and monitoring.

## Purpose

- Deploy and manage AI agent swarms across isolated environments
- Coordinate work distribution among specialized agents
- Integrate Claude AI for intelligent decision making
- Monitor swarm health and performance
- Manage agent lifecycle (start/stop/status)

## Prerequisites

- **coordination_helper.sh** - Core coordination functionality
- **Git** - For worktree management
- **Claude Code CLI** - For agent intelligence
- **jq** - JSON processing
- **openssl** - Trace ID generation
- **bash** 4.0+

## Usage

```bash
# Initialize swarm configuration
./agent_swarm_orchestrator.sh init

# Deploy agents to worktrees
./agent_swarm_orchestrator.sh deploy

# Start all agents
./agent_swarm_orchestrator.sh start

# Check swarm status
./agent_swarm_orchestrator.sh status

# Stop all agents
./agent_swarm_orchestrator.sh stop

# Run intelligence analysis
./agent_swarm_orchestrator.sh intelligence <analysis_type>

# View swarm logs
./agent_swarm_orchestrator.sh logs
```

## Key Features

### Swarm Management
- Initialize swarm with coordination strategies
- Deploy specialized agents to different worktrees
- Start/stop entire swarm with single command
- Monitor swarm health and performance

### Agent Specialization
- Ash Phoenix migration agents
- N8N integration agents
- Performance optimization agents
- Custom specialization support

### Worktree Isolation
- Each agent operates in isolated git worktree
- Prevents conflicts between agent operations
- Enables parallel development workflows

### Intelligence Integration
- Claude Code CLI for agent decisions
- Swarm-wide intelligence analysis
- Coordinated problem solving

## Configuration

### Swarm Configuration File (`swarm_config.json`)

```json
{
  "swarm": {
    "name": "main_swarm",
    "worktrees": [
      {
        "name": "ash-phoenix-migration",
        "path": "./worktrees/ash-phoenix",
        "agents": 2,
        "specialization": "ash_migration",
        "claude_config": {
          "model": "claude-3-opus-20240229",
          "temperature": 0.3
        }
      },
      {
        "name": "n8n-integration",
        "path": "./worktrees/n8n",
        "agents": 2,
        "specialization": "n8n_integration"
      }
    ],
    "coordination": {
      "strategy": "distributed",
      "rules": {
        "max_concurrent_claims": 3,
        "work_timeout": 3600
      }
    }
  }
}
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SWARM_CONFIG` | Path to swarm configuration | `./swarm_config.json` |
| `SWARM_STATE` | Path to swarm state file | `./swarm_state.json` |
| `COORDINATION_DIR` | Coordination directory | `/tmp/s2s_coordination` |

## Commands Reference

### init
Initialize swarm configuration
```bash
./agent_swarm_orchestrator.sh init
```
Creates default swarm configuration with worktree definitions.

### deploy
Deploy agents to worktrees
```bash
./agent_swarm_orchestrator.sh deploy
```
- Creates agent configuration files
- Generates startup scripts
- Sets up management scripts

### start
Start all agents in swarm
```bash
./agent_swarm_orchestrator.sh start
```
Launches all configured agents across worktrees.

### stop
Stop all agents
```bash
./agent_swarm_orchestrator.sh stop
```
Gracefully shuts down all running agents.

### status
Show swarm status
```bash
./agent_swarm_orchestrator.sh status
```
Displays:
- Active agents and their states
- Work assignments
- Performance metrics
- Health indicators

### intelligence
Run swarm-wide analysis
```bash
./agent_swarm_orchestrator.sh intelligence <type>
```
Types:
- `performance` - Performance optimization analysis
- `health` - System health check
- `priorities` - Work prioritization

### logs
View swarm logs
```bash
./agent_swarm_orchestrator.sh logs [worktree]
```
Shows logs from all agents or specific worktree.

## Generated Files

### Per-Worktree Files

| File | Purpose |
|------|---------|
| `agent_${i}_config.json` | Individual agent configuration |
| `start_agent_${i}.sh` | Agent startup script |
| `manage_agent_${i}.sh` | Agent management commands |
| `agent_${i}.log` | Agent operation logs |

### Agent Configuration Example
```json
{
  "agent_id": "agent_1_ash-phoenix",
  "worktree": "ash-phoenix-migration",
  "specialization": "ash_migration",
  "capabilities": ["code_migration", "test_generation"],
  "team": "phoenix_team",
  "claude_config": {
    "model": "claude-3-opus-20240229",
    "temperature": 0.3
  }
}
```

### Startup Script Example
```bash
#!/bin/bash
# Auto-generated agent startup script
export AGENT_ID="agent_1_ash-phoenix"
export AGENT_CONFIG="./agent_1_config.json"
export COORDINATION_DIR="/tmp/s2s_coordination"

# Start agent with Claude Code
claude code --mode headless \
  --config "$AGENT_CONFIG" \
  --coordination-helper "../../../coordination_helper.sh" \
  >> agent_1.log 2>&1
```

## Swarm Deployment Process

1. **Initialize**: Create swarm configuration
2. **Deploy**: Generate agent files in worktrees
3. **Verify**: Check environment isolation
4. **Start**: Launch agents with coordination
5. **Monitor**: Track agent performance
6. **Optimize**: Run intelligence analysis

## Integration Points

- Uses `coordination_helper.sh` for work coordination
- Integrates with `worktree_environment_manager.sh`
- Compatible with `quick_start_agent_swarm.sh`
- Provides data for monitoring systems

## Examples

### Basic Swarm Setup
```bash
# Initialize and deploy
./agent_swarm_orchestrator.sh init
./agent_swarm_orchestrator.sh deploy

# Start swarm
./agent_swarm_orchestrator.sh start

# Check status
./agent_swarm_orchestrator.sh status
```

### Custom Swarm Configuration
```bash
# Edit swarm_config.json first
vim swarm_config.json

# Deploy with custom config
SWARM_CONFIG=./custom_swarm.json ./agent_swarm_orchestrator.sh deploy
```

### Intelligence Analysis
```bash
# Run performance analysis
./agent_swarm_orchestrator.sh intelligence performance

# Check health
./agent_swarm_orchestrator.sh intelligence health

# Optimize assignments
./agent_swarm_orchestrator.sh intelligence priorities
```

## Troubleshooting

### Common Issues

1. **Deployment failures**: Check worktree paths exist
2. **Agent startup errors**: Review agent logs in worktrees
3. **Coordination conflicts**: Verify `COORDINATION_DIR` is shared
4. **Claude unavailable**: Check Claude Code CLI installation

### Debug Mode
```bash
DEBUG=1 ./agent_swarm_orchestrator.sh <command>
```

### Log Locations
- Swarm logs: `./swarm_orchestrator.log`
- Agent logs: `<worktree>/agent_${i}.log`
- Coordination logs: `$COORDINATION_DIR/coordination.log`

## Performance Tuning

### Agent Count
- Balance between parallelism and resource usage
- Monitor system load with more agents
- Adjust based on available CPU/memory

### Work Distribution
- Configure `max_concurrent_claims` per agent
- Set appropriate `work_timeout` values
- Monitor work completion rates

### Intelligence Optimization
- Adjust Claude temperature for consistency
- Cache intelligence results when appropriate
- Batch analysis requests

## Related Scripts

- `coordination_helper.sh` - Core coordination system
- `quick_start_agent_swarm.sh` - Automated setup
- `implement_real_agents.sh` - Agent process management
- `manage_worktrees.sh` - Worktree utilities