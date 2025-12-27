# How To: Multi-Agent Coordination and Work Distribution

> **Version:** 1.2.0 | **Last Updated:** December 27, 2025 | **Type:** How-To Guide

## Quick Navigation
- **Learning path?** See [10-Agent Quickstart Tutorial](./10-AGENT-QUICKSTART.md)
- **Need reference?** See [Agent Configuration Reference](./AGENT-CONFIGURATION-REFERENCE.md)
- **Troubleshooting?** See [Agent Troubleshooting](./AGENT-TROUBLESHOOTING.md)

## Overview

This guide covers practical scenarios for coordinating work across 10 specialized agents. You'll learn:
- How to distribute work to specific agents or teams
- How agents resolve dependencies and conflicts
- How to monitor cross-team coordination
- How to handle agent failures in a distributed system

**Audience:** Developers managing multi-agent teams
**Prerequisite:** [10-Agent Quickstart Tutorial](./10-AGENT-QUICKSTART.md)

---

## Scenario 1: Priority-Based Work Distribution Across Teams

### The Problem
You have work for 3 different teams with different priorities. You need the system to:
1. Distribute to the right team based on specialization
2. Respect priority levels
3. Balance load within each team
4. Prevent bottlenecks

### Solution: Claim with Team Specification

```bash
# High-priority migration work
# This goes to migration_team, distributed among agents 1-3
./coordination_helper.sh claim \
  "migration" \
  "Convert all Ash v1 models to Phoenix v2.0" \
  "high" \
  --team "migration_team" \
  --depends-on ""

# Medium-priority integration work
# This goes to integration_team, distributed among agents 4-7
./coordination_helper.sh claim \
  "integration" \
  "Update N8n workflows for new payment API" \
  "medium" \
  --team "integration_team" \
  --depends-on ""

# Lower-priority optimization work
# This goes to performance_team (agents 8-9)
./coordination_helper.sh claim \
  "optimization" \
  "Profile and optimize query performance" \
  "low" \
  --team "performance_team" \
  --depends-on ""
```

### How the System Works

1. **Coordinator (Agent 10)** receives all claims
2. **Router logic** analyzes team and priority
3. **Team lead agent** (agent 1, 4, or 8) claims work from its queue
4. **Available agents** in that team claim remaining items
5. **Parallel execution** happens across all teams

### Verification

```bash
# View distribution by team
./coordination_helper.sh list-work --by-team

# Expected output:
# Team: migration_team
#   - Item 1: [CLAIMED] Agent 1
#   - Item 2: [CLAIMED] Agent 2
#
# Team: integration_team
#   - Item 3: [CLAIMED] Agent 4
#   - Item 4: [CLAIMED] Agent 5
#
# Team: performance_team
#   - Item 5: [CLAIMED] Agent 8

# Get per-agent load
./coordination_helper.sh agent-load-report

# Expected: Even distribution within each team
```

---

## Scenario 2: Handling Inter-Team Dependencies

### The Problem
Integration work (Team 2) cannot start until migration work (Team 1) completes. The system must:
1. Prevent integration work claiming until migration completes
2. Queue integration work safely
3. Notify integration team when ready
4. Maintain causal ordering

### Solution: Dependency Chains

```bash
# Step 1: Create high-priority migration work
MIGRATION_ID=$(./coordination_helper.sh claim \
  "migration" \
  "Convert database schema to Phoenix ORM" \
  "high" \
  --team "migration_team" | jq -r '.work_id')

echo "Migration work ID: $MIGRATION_ID"

# Step 2: Create integration work that depends on migration
./coordination_helper.sh claim \
  "integration" \
  "Update N8n workflows to use new schema" \
  "high" \
  --team "integration_team" \
  --depends-on "$MIGRATION_ID"

# Step 3: Both teams work in parallel, but integration waits for migration to complete
```

### How Dependency Resolution Works

```bash
# Check dependency status
./coordination_helper.sh dependency-graph

# Expected output:
# migration_task_xyz (COMPLETED)
#  └─> integration_task_abc (WAITING) ← Waiting for parent
#      └─> performance_task_def (BLOCKED) ← Blocked transitively

# When migration completes, integration auto-transitions to READY
# Coordinator (Agent 10) monitors and notifies integration_team

# View blocked work
./coordination_helper.sh list-work --status "blocked"

# Returns: integration task waiting for migration to complete
```

### Diagram: Dependency Flow

```
Time →

Migration Team (3 agents)
├─ Agent 1: schema_analysis    [████████████]
├─ Agent 2: orm_conversion     [████████████]
└─ Agent 3: validation         [████████████]

Integration Team (4 agents) - WAITS for migration
├─ Agent 4: BLOCKED (waiting...)
├─ Agent 5: BLOCKED (waiting...)
├─ Agent 6: BLOCKED (waiting...)
└─ Agent 7: BLOCKED (waiting...)

[MIGRATION COMPLETES]

Integration Team - NOW PROCEEDS
├─ Agent 4: workflow_update    [████████████]
├─ Agent 5: api_integration    [████████████]
├─ Agent 6: testing            [████████████]
└─ Agent 7: validation         [████████████]

Performance Team (2 agents) - MONITORS performance during integration
├─ Agent 8: profiling          [████]
└─ Agent 9: optimization       [████]
```

---

## Scenario 3: Distributing Work Within a Specialized Team

### The Problem
The migration team has 3 agents with slightly different skills. You want to:
1. Assign specific agents based on capability
2. Load-balance automatically when preferred agent is busy
3. Maintain team cohesion for complex tasks
4. Allow agent-to-agent handoff

### Solution: Capability-Based Claiming

```bash
# Assign to specific agent by capability
./coordination_helper.sh claim \
  "migration" \
  "Convert complex polymorphic associations" \
  "high" \
  --team "migration_team" \
  --preferred-agent "agent_2" \
  --required-capabilities "ash_framework_knowledge,model_conversion"

# System attempts Agent 2 first. If busy, tries other migration_team agents.

# For less complex work, let any team member claim it
./coordination_helper.sh claim \
  "migration" \
  "Validate converted models" \
  "medium" \
  --team "migration_team" \
  --any-available  # Claims to first available agent in team
```

### Work Queue Within a Team

```bash
# View migration team's work queue
./coordination_helper.sh list-work --team migration_team

# Expected:
# Queue Status: migration_team
# Total: 5 items | Claimed: 2 | In-Progress: 2 | Completed: 1
#
# [CLAIMED]   Migration 001: Convert models (Agent 2)
# [CLAIMED]   Migration 002: Schema conversion (Agent 1)
# [IN PROGRESS] Migration 003: Data validation (Agent 3)
# [IN PROGRESS] Migration 004: Complex associations (Agent 2 swapped in)
# [PENDING]   Migration 005: Final verification

# Agent 2 picked up Migration 004 because it matched
# its "ash_framework_knowledge" capability
```

### Load Balancing Example

```bash
# Check real-time team load
./coordination_helper.sh team-load-report

# Output:
# Migration Team Load:
#   Agent 1 (Schema Migrator):      1/3 slots  (33%)
#   Agent 2 (Ash Phoenix Expert):   3/3 slots  (100%) ← FULL
#   Agent 3 (Data Converter):       2/3 slots  (67%)
#
# New work distribution:
# - Next claim goes to Agent 1 or Agent 3 (Agent 2 at capacity)
# - High-complexity work waits for Agent 2 to free a slot
# - Lower-complexity work claims immediately to available agent

# Monitor load over time
make monitor-24h  # See team load graph
```

---

## Scenario 4: Cross-Team Coordination with Bottleneck Detection

### The Problem
Sometimes one team becomes a bottleneck. For example:
- Migration team slow → Blocks integration team
- Integration testing fails → Requires re-migration
- Performance analysis reveals fundamental design issue

The system must:
1. Detect bottlenecks automatically
2. Alert affected teams
3. Allow dynamic priority adjustment
4. Enable escalation to Coordinator (Agent 10)

### Solution: Monitoring and Escalation

```bash
# Step 1: Monitor for bottlenecks
./coordination_helper.sh detect-bottlenecks

# Expected output:
# Bottleneck Analysis:
# migration_team: NORMAL (3/3 agents active, avg queue: 1.2 items)
# integration_team: WARNING (4/4 agents active, avg queue: 4.5 items)
# performance_team: NORMAL (2/2 agents active, avg queue: 0.8 items)
#
# Root Cause: migration_team completing items faster than
# integration_team can process them. Creating backup queue.

# Step 2: Escalate to Coordinator (Agent 10)
./coordination_helper.sh escalate-to-coordinator \
  --reason "integration_team_backlog" \
  --affected-teams "integration_team,performance_team"

# Coordinator (Agent 10) now:
# - Analyzes integration bottleneck
# - Checks if Agent 4 (lead) needs help
# - Can request temporary assistance from performance_team
# - Adjusts work priorities dynamically
```

### Dynamic Priority Adjustment

```bash
# Before escalation: normal priority distribution
./coordination_helper.sh list-work --with-priorities

# After escalation: Coordinator adjusts
./coordination_helper.sh adjust-priorities \
  --team integration_team \
  --boost-by 2  # Increase priority of queued integration work

# Result: Integration team's work now takes precedence system-wide
```

### Telemetry Pattern for Bottleneck Detection

```bash
# View bottleneck indicator in telemetry
tail -n 100 telemetry_spans.jsonl | \
  jq '.[] | select(.span_name == "bottleneck_detection") | {team: .team, queue_depth: .queue_depth, status: .status}'

# Shows progression:
# {"team": "migration_team", "queue_depth": 0, "status": "HEALTHY"}
# {"team": "integration_team", "queue_depth": 4, "status": "WARNING"}
# {"team": "integration_team", "queue_depth": 7, "status": "CRITICAL"}
# ... Escalation triggered ...
# {"team": "integration_team", "queue_depth": 5, "status": "RECOVERING"}
```

---

## Scenario 5: Agent Failure and Graceful Recovery

### The Problem
Agent 5 crashes while working on critical N8n integration. The system must:
1. Detect the failure
2. Reassign the work
3. Maintain progress
4. Alert the team lead (Agent 4)

### Solution: Automatic Failover

```bash
# Step 1: Monitor agent health
./coordination_helper.sh monitor-agent-health agent_5

# Agent becomes unresponsive...
# Telemetry shows no heartbeat for 30 seconds

# Step 2: System automatically:
# - Marks Agent 5 as UNHEALTHY
# - Recovers in-flight work
# - Redistributes to available agents

./coordination_helper.sh list-agents --status

# Output now shows:
# agent_5: status = "UNHEALTHY" (last_heartbeat: 45s ago)
# Queued work: 2 items being reassigned

# Step 3: Team lead (Agent 4) is notified
./coordination_helper.sh team-notifications --team integration_team

# Shows: "Agent 5 failed. Work item WI_007 reassigned to Agent 6"

# Step 4: Agent 5 comes back online
# System automatically re-syncs state
./coordination_helper.sh sync-agent agent_5

# Agent 5 rejoins the team and claims new work
```

### Prevention: Health Check Configuration

```bash
# Configure health monitoring for all agents
./coordination_helper.sh configure-health-check \
  --interval 30 \
  --timeout 60 \
  --failure-threshold 3 \
  --action "auto_reassign"

# Now the system:
# - Checks each agent every 30 seconds
# - Waits up to 60 seconds for response
# - After 3 failures (90 seconds), marks unhealthy
# - Automatically reassigns its work
```

---

## Scenario 6: Parallel Work Across Multiple Teams

### The Problem
You want to maximize parallelism by running independent work across all teams simultaneously. For example:
- Migration and integration can proceed in parallel
- Performance optimization can happen concurrently
- All 3 teams working on different aspects

### Solution: Independent Work Queue Management

```bash
# Step 1: Create work for each team (completely independent)

# Migration team starts full conversion
./coordination_helper.sh claim \
  "migration" \
  "Batch 1: Convert accounts module" \
  "high" \
  --team "migration_team"

./coordination_helper.sh claim \
  "migration" \
  "Batch 2: Convert payments module" \
  "high" \
  --team "migration_team"

./coordination_helper.sh claim \
  "migration" \
  "Batch 3: Convert reports module" \
  "high" \
  --team "migration_team"

# Integration team works on N8n independently
./coordination_helper.sh claim \
  "integration" \
  "Design new workflow architecture" \
  "high" \
  --team "integration_team"

./coordination_helper.sh claim \
  "integration" \
  "Implement trigger system" \
  "high" \
  --team "integration_team"

# Performance team profiles during the work
./coordination_helper.sh claim \
  "optimization" \
  "Baseline performance metrics" \
  "medium" \
  --team "performance_team"

# Step 2: Monitor all teams in parallel
./coordination_helper.sh swarm-status

# Output shows real-time progress:
# ┌─ Migration Team (Agents 1-3) ─────────────────┐
# │ [██████████░░░░░░] 60% Batch 1               │
# │ [████░░░░░░░░░░░░] 20% Batch 2               │
# │ [░░░░░░░░░░░░░░░░] 0% Batch 3 (queued)       │
# └────────────────────────────────────────────────┘
# ┌─ Integration Team (Agents 4-7) ────────────────┐
# │ [████████████████░] 80% Architecture design    │
# │ [████░░░░░░░░░░░░] 20% Trigger implementation │
# └────────────────────────────────────────────────┘
# ┌─ Performance Team (Agents 8-9) ────────────────┐
# │ [████████░░░░░░░░] 40% Baseline metrics       │
# └────────────────────────────────────────────────┘
#
# Overall: All 3 teams actively working in parallel
```

### Measuring Parallelism Efficiency

```bash
# Get detailed metrics on parallel execution
./coordination_helper.sh parallelism-report

# Output:
# Parallelism Analysis (last hour):
# Total work items: 6
# Completed work items: 3
# Currently in-progress: 3
# Parallel efficiency: 95%
#
# Timeline:
# 0s  - All 3 teams claimed work simultaneously
# 45s - Migration Batch 1 completes
# 60s - Integration architecture design completes
# 90s - Migration Batch 2 completes, performance baseline completes
# ...
#
# Key insight: Teams worked in parallel 95% of the time
# (Only 5% sequential waiting due to natural dependencies)
```

---

## Best Practices for Multi-Agent Coordination

### 1. Always Specify Team or Capabilities
```bash
# Good: Explicit team routing
./coordination_helper.sh claim \
  "migration" \
  "..." \
  "high" \
  --team "migration_team"

# Avoid: Generic claims that load-balance unpredictably
./coordination_helper.sh claim "work" "..." "high"
```

### 2. Monitor Team Health Before Assigning Critical Work
```bash
# Check team status first
./coordination_helper.sh team-health

# Then assign if healthy
if [ $(team_health) -gt 0.8 ]; then
  claim_critical_work
fi
```

### 3. Use Dependencies to Express Causality
```bash
# Not recommended: Assume implicit ordering
./coordination_helper.sh claim "step_1" "..." "high"
./coordination_helper.sh claim "step_2" "..." "high"

# Better: Explicit dependencies
STEP1_ID=$(claim "step_1" "..." "high")
claim "step_2" "..." "high" --depends-on "$STEP1_ID"
```

### 4. Set Realistic Priority Levels
```bash
# Avoid: Everything marked "high"
claim "..." "..." "high" # Over-prioritized

# Better: Graduated priority
claim "schema_conversion" "..." "high"      # Blocks integration
claim "api_mapping" "..." "medium"          # After schema
claim "optimization" "..." "low"            # Nice to have
```

### 5. Monitor Before Escalating
```bash
# Always gather data first
./coordination_helper.sh detect-bottlenecks
./coordination_helper.sh team-performance-report
./coordination_helper.sh agent-load-report

# Then escalate with context
./coordination_helper.sh escalate-to-coordinator \
  --reason "integration_team_backlog_7_items" \
  --data-attached "true"
```

---

## Related Documentation

- **Configuration Guide:** [Agent Configuration Guide](./AGENT-CONFIGURATION-GUIDE.md)
- **Monitoring:** [Agent Monitoring Dashboard](./AGENT-MONITORING-DASHBOARD.md)
- **Troubleshooting:** [Agent Troubleshooting](./AGENT-TROUBLESHOOTING.md)
- **Advanced Patterns:** [Advanced Coordination Patterns](./ADVANCED-COORDINATION-PATTERNS.md)

---

**Status:** ✅ How-To Guide Complete
**Next:** [Monitor Your Multi-Agent System](./AGENT-MONITORING-DASHBOARD.md)
