# manage_worktrees.sh

## Overview
List, monitor, cleanup, and coordinate multiple git worktrees for agent development isolation.

## Purpose
- Monitor active worktree environments
- Clean up stale or unused worktrees
- Coordinate worktree-based agent deployments
- Manage development environment isolation

## Usage
```bash
# List all worktrees
./manage_worktrees.sh list

# Monitor worktree status
./manage_worktrees.sh monitor

# Clean up unused worktrees
./manage_worktrees.sh cleanup

# Show detailed status
./manage_worktrees.sh status
```

## Key Features
- **Active Worktree Detection**: Identifies all git worktrees in use
- **Environment Monitoring**: Tracks port allocations and process status
- **Cleanup Automation**: Removes stale worktrees safely
- **Agent Coordination**: Manages worktree-based agent isolation

## Commands

### list
```bash
./manage_worktrees.sh list
```
Shows all active worktrees with their status and assigned agents.

### monitor
```bash
./manage_worktrees.sh monitor [duration]
```
Continuously monitors worktree activity and resource usage.

### cleanup
```bash
./manage_worktrees.sh cleanup [--force]
```
Removes unused worktrees after safety checks.

### status
```bash
./manage_worktrees.sh status [worktree_name]
```
Detailed status including ports, processes, and agent assignments.

## Integration Points
- Works with `worktree_environment_manager.sh` for environment setup
- Coordinates with `agent_swarm_orchestrator.sh` for agent deployment
- Uses `coordination_helper.sh` for work distribution

## Examples
```bash
# Daily workflow
./manage_worktrees.sh list
./manage_worktrees.sh monitor 60

# Cleanup routine
./manage_worktrees.sh cleanup --force
```