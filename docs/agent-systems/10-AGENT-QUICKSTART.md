# Tutorial: Launch a 10-Agent Claude Code Swarm in 15 Minutes

> **Version:** 1.2.0 | **Last Updated:** December 27, 2025 | **Difficulty:** Intermediate

## Quick Navigation
- **New to SwarmSH?** Start with [Getting Started](../../../README.md#tutorials)
- **Looking for reference?** See [Agent Configuration Reference](#reference-documentation)
- **Need troubleshooting?** See [Common Issues](#troubleshooting)

## What You'll Learn

In this tutorial, you'll:
1. Understand the 10-agent swarm architecture
2. Configure 10 concurrent Claude code agents with specialized roles
3. Deploy all agents with a single command
4. Monitor concurrent operation across all agents
5. Verify successful coordination and work distribution

**Time Required:** 15 minutes
**Skill Level:** Intermediate (requires familiarity with [Agent Coordination Basics](https://github.com/seanchatmangpt/swarmsh/blob/main/AGENT_SWARM_OPERATIONS_GUIDE.md))
**Prerequisites:** SwarmSH 1.2.0+, 2GB RAM minimum, 10 available ports (4001-4010)

---

## What is a 10-Agent Concurrent Claude Code Swarm?

A **10-agent concurrent swarm** is a specialized deployment of SwarmSH where:

- **10 independent Claude code agents** execute in parallel
- **Each agent** runs in an isolated **web VM** environment
- **Each agent** has a **distinct specialization** (migration, testing, performance, etc.)
- **Each agent** coordinates work through the **SwarmSH coordination core**
- **Zero-conflict guarantees** ensure safe concurrent execution

**Why 10 agents?**
- Optimal balance between parallelism and coordination overhead
- Covers typical team scenarios (3 feature teams + coordination)
- Achievable in standard development environments
- Scales effectively to 100+ agents with same architecture

### Real-World Example

Imagine automating a codebase migration project:

```
Your Project
├── 3-Agent Migration Team      (Ash Phoenix framework conversion)
├── 4-Agent Integration Team    (N8n workflow updates)
├── 2-Agent Performance Team    (Optimization across codebase)
└── 1-Agent Coordinator         (Orchestrates and monitors all)
```

Each agent works independently on its domain, but through the coordination system, they share progress, resolve dependencies, and collectively advance the project.

---

## Step 1: Understand Agent Roles (2 minutes)

SwarmSH's 10-agent system uses **specialized teams**:

### Migration Team (3 Agents)
- **Agent 1: Schema Migrator** - Converts database schemas, model definitions
- **Agent 2: Ash Phoenix Expert** - Framework-specific migration logic
- **Agent 3: Data Converter** - Data transformation and validation

**Team Port Range:** 4001-4003
**Database Prefix:** `swarmsh_agent_1`, `swarmsh_agent_2`, `swarmsh_agent_3`
**Worktree:** `ash-phoenix-migration`

### Integration Team (4 Agents)
- **Agent 4: N8n Integration Lead** - Workflow design and coordination
- **Agent 5: Automation Expert** - Trigger and action optimization
- **Agent 6: API Mapper** - External API integration planning
- **Agent 7: Testing Specialist** - Workflow validation and testing

**Team Port Range:** 4004-4007
**Database Prefix:** `swarmsh_agent_4-7`
**Worktree:** `n8n-improvements`

### Performance Team (2 Agents) + Coordinator (1 Agent)
- **Agent 8: Profiler** - Performance bottleneck detection
- **Agent 9: Optimizer** - Code optimization and refactoring
- **Agent 10: Coordinator** - Cross-team orchestration and monitoring

**Port Range:** 4008-4010
**Database Prefix:** `swarmsh_agent_8-10`
**Worktree:** `performance-boost`

---

## Step 2: Create the Team Configuration (3 minutes)

Copy this configuration to `10-agent-team-config.json`:

```json
{
  "team_id": "concurrent_swarm_v1",
  "created_at": "2025-12-27T00:00:00Z",
  "environment": "web_vm_cluster",
  "agent_count": 10,

  "agents": [
    {
      "agent_id": "agent_001_migration",
      "agent_number": 1,
      "name": "Schema Migrator",
      "specialization": "schema_migration",
      "team": "migration_team",
      "port": 4001,
      "database": "swarmsh_agent_1",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "ash-phoenix-migration",
      "capabilities": ["database_analysis", "schema_conversion", "validation"],
      "status": "pending"
    },
    {
      "agent_id": "agent_002_ash_phoenix",
      "agent_number": 2,
      "name": "Ash Phoenix Expert",
      "specialization": "ash_migration",
      "team": "migration_team",
      "port": 4002,
      "database": "swarmsh_agent_2",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "ash-phoenix-migration",
      "capabilities": ["ash_framework_knowledge", "model_conversion", "migration_orchestration"],
      "status": "pending"
    },
    {
      "agent_id": "agent_003_data_converter",
      "agent_number": 3,
      "name": "Data Converter",
      "specialization": "data_transformation",
      "team": "migration_team",
      "port": 4003,
      "database": "swarmsh_agent_3",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "ash-phoenix-migration",
      "capabilities": ["data_migration", "transformation_logic", "validation"],
      "status": "pending"
    },
    {
      "agent_id": "agent_004_n8n_lead",
      "agent_number": 4,
      "name": "N8n Integration Lead",
      "specialization": "n8n_integration",
      "team": "integration_team",
      "port": 4004,
      "database": "swarmsh_agent_4",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "n8n-improvements",
      "capabilities": ["workflow_design", "n8n_expertise", "team_coordination"],
      "status": "pending"
    },
    {
      "agent_id": "agent_005_automation",
      "agent_number": 5,
      "name": "Automation Expert",
      "specialization": "automation_logic",
      "team": "integration_team",
      "port": 4005,
      "database": "swarmsh_agent_5",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "n8n-improvements",
      "capabilities": ["trigger_optimization", "action_logic", "error_handling"],
      "status": "pending"
    },
    {
      "agent_id": "agent_006_api_mapper",
      "agent_number": 6,
      "name": "API Mapper",
      "specialization": "api_integration",
      "team": "integration_team",
      "port": 4006,
      "database": "swarmsh_agent_6",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "n8n-improvements",
      "capabilities": ["api_discovery", "integration_planning", "specification_analysis"],
      "status": "pending"
    },
    {
      "agent_id": "agent_007_testing",
      "agent_number": 7,
      "name": "Testing Specialist",
      "specialization": "workflow_testing",
      "team": "integration_team",
      "port": 4007,
      "database": "swarmsh_agent_7",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "n8n-improvements",
      "capabilities": ["test_design", "workflow_validation", "quality_assurance"],
      "status": "pending"
    },
    {
      "agent_id": "agent_008_profiler",
      "agent_number": 8,
      "name": "Profiler",
      "specialization": "performance_analysis",
      "team": "performance_team",
      "port": 4008,
      "database": "swarmsh_agent_8",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "performance-boost",
      "capabilities": ["profiling", "bottleneck_detection", "metrics_collection"],
      "status": "pending"
    },
    {
      "agent_id": "agent_009_optimizer",
      "agent_number": 9,
      "name": "Optimizer",
      "specialization": "code_optimization",
      "team": "performance_team",
      "port": 4009,
      "database": "swarmsh_agent_9",
      "capacity": 100,
      "max_concurrent_work": 3,
      "worktree": "performance-boost",
      "capabilities": ["optimization_strategy", "refactoring", "performance_verification"],
      "status": "pending"
    },
    {
      "agent_id": "agent_010_coordinator",
      "agent_number": 10,
      "name": "Coordinator",
      "specialization": "orchestration",
      "team": "coordinator_team",
      "port": 4010,
      "database": "swarmsh_agent_10",
      "capacity": 150,
      "max_concurrent_work": 5,
      "worktree": "main",
      "capabilities": ["work_distribution", "monitoring", "conflict_resolution", "reporting"],
      "status": "pending"
    }
  ],

  "teams": [
    {
      "team_id": "migration_team",
      "name": "Migration Team",
      "agent_count": 3,
      "agents": [1, 2, 3],
      "lead_agent": 1,
      "priority": "high"
    },
    {
      "team_id": "integration_team",
      "name": "Integration Team",
      "agent_count": 4,
      "agents": [4, 5, 6, 7],
      "lead_agent": 4,
      "priority": "high"
    },
    {
      "team_id": "performance_team",
      "name": "Performance Team",
      "agent_count": 2,
      "agents": [8, 9],
      "lead_agent": 8,
      "priority": "medium"
    },
    {
      "team_id": "coordinator_team",
      "name": "Coordinator",
      "agent_count": 1,
      "agents": [10],
      "lead_agent": 10,
      "priority": "critical"
    }
  ],

  "resource_allocation": {
    "total_agents": 10,
    "ports_used": "4001-4010",
    "total_capacity": 1050,
    "memory_per_agent": "512MB",
    "cpu_per_agent": "1.0 core",
    "total_memory": "5.5GB",
    "total_cpu": "10 cores",
    "max_concurrent_work": 30
  },

  "coordination_settings": {
    "strategy": "priority_based",
    "conflict_resolution": "atomic_with_claude_mediation",
    "health_check_interval": 30,
    "telemetry_aggregation": "realtime",
    "failure_recovery": "automatic"
  },

  "monitoring": {
    "enabled": true,
    "dashboard_port": 3000,
    "metrics_retention_days": 30,
    "alert_thresholds": {
      "agent_health": 0.7,
      "team_health": 0.75,
      "system_health": 0.8
    }
  }
}
```

Save this file:
```bash
cat > 10-agent-team-config.json << 'EOF'
{
  ... (full JSON above)
}
EOF
```

---

## Step 3: Bootstrap All 10 Agents (5 minutes)

### 3a. Register all agents at once

```bash
# Source the coordination helper
source ./coordination_helper.sh

# Register all 10 agents with their specializations
./coordination_helper.sh register-agent \
  --specialization "migration" \
  --team "migration_team" \
  --capacity 100 \
  --worktree "ash-phoenix-migration" \
  --count 3

./coordination_helper.sh register-agent \
  --specialization "integration" \
  --team "integration_team" \
  --capacity 100 \
  --worktree "n8n-improvements" \
  --count 4

./coordination_helper.sh register-agent \
  --specialization "performance" \
  --team "performance_team" \
  --capacity 100 \
  --worktree "performance-boost" \
  --count 2

./coordination_helper.sh register-agent \
  --specialization "orchestration" \
  --team "coordinator_team" \
  --capacity 150 \
  --worktree "main" \
  --count 1
```

### 3b. Verify all agents registered

```bash
# List all agents
./coordination_helper.sh list-agents

# Expected output shows 10 agents:
# agent_1, agent_2, agent_3 (migration_team)
# agent_4, agent_5, agent_6, agent_7 (integration_team)
# agent_8, agent_9 (performance_team)
# agent_10 (coordinator_team)
```

### 3c. Check agent health

```bash
# View overall swarm health
./coordination_helper.sh swarm-health

# Example output:
# Team Status Summary:
#   migration_team:    3 agents, health: 98%
#   integration_team:  4 agents, health: 97%
#   performance_team:  2 agents, health: 99%
#   coordinator_team:  1 agent,  health: 100%
# Overall Swarm Health: 98.5% (HEALTHY)
```

---

## Step 4: Distribute Work Across Teams (3 minutes)

### 4a. Create work for each team

```bash
# Migration team work
./coordination_helper.sh claim \
  "migration" \
  "Convert Ash v1 models to Phoenix" \
  "high" \
  --team "migration_team"

# Integration team work
./coordination_helper.sh claim \
  "integration" \
  "Update N8n workflows for new API" \
  "high" \
  --team "integration_team"

# Performance team work
./coordination_helper.sh claim \
  "optimization" \
  "Optimize database query performance" \
  "medium" \
  --team "performance_team"

# Create additional work for parallel processing
./coordination_helper.sh claim \
  "migration" \
  "Validate schema conversion" \
  "high" \
  --team "migration_team"
```

### 4b. Monitor concurrent work distribution

```bash
# View work queue by team
./coordination_helper.sh list-work --by-team

# Expected output:
# migration_team:    2 items claimed, 0 in-progress, 0 completed
# integration_team:  1 item claimed, 0 in-progress, 0 completed
# performance_team:  1 item claimed, 0 in-progress, 0 completed

# View all agents' current load
./coordination_helper.sh agent-load-report
```

---

## Step 5: Monitor Concurrent Operations (2 minutes)

### 5a. Real-time team monitoring

```bash
# Start real-time monitoring dashboard
make monitor-24h

# This displays:
# - All 10 agents' status
# - Work progress per team
# - Throughput metrics
# - Error rates
# - Telemetry span generation
```

### 5b. Check telemetry from all agents

```bash
# View telemetry spans from all agents
tail -n 50 telemetry_spans.jsonl | jq '.[] | {agent_id, span_name, duration_ms}'

# Expected pattern (parallel execution):
# Agent 1 claims work at 10:00:00.001
# Agent 4 claims work at 10:00:00.002
# Agent 8 claims work at 10:00:00.003
# All claiming happens within milliseconds (concurrent!)
```

### 5c. View swarm dashboard

```bash
# Generate visual dashboard
make diagrams-dashboard

# Creates a Mermaid diagram showing:
# - 10-agent concurrent architecture
# - Team composition and specialization
# - Work distribution flow
# - Telemetry aggregation points
```

---

## Step 6: Verify Successful Multi-Agent Coordination

### 6a. Check zero-conflict guarantee

```bash
# Verify no work conflicts (nanosecond precision IDs)
./coordination_helper.sh verify-conflicts

# Expected output:
# Conflict Check: PASSED ✅
# Total work items: 4
# Duplicate claims: 0
# Concurrent overwrites: 0
# Timestamp collisions: 0
```

### 6b. Measure concurrent throughput

```bash
# Get team-level metrics
./coordination_helper.sh team-performance-report

# Expected output shows:
# migration_team:    claimed 2 items, 0 failed, avg time 2.3s
# integration_team:  claimed 1 item,  0 failed, avg time 1.8s
# performance_team:  claimed 1 item,  0 failed, avg time 1.5s
```

### 6c. Validate telemetry aggregation

```bash
# Check telemetry spans from all 10 agents
jq '.agent_id' telemetry_spans.jsonl | sort | uniq -c

# Expected: 1 for each agent (agent_1 through agent_10)
# Shows all agents generated telemetry
```

---

## What Just Happened?

You've successfully deployed and verified a **10-agent concurrent Claude code swarm**:

### Architecture Deployed
```
┌─────────────────────────────────────────────┐
│     10-Agent Concurrent Claude Code Swarm   │
├─────────────────────────────────────────────┤
│ Migration Team   │ Integration Team         │
│ ├─ Agent 1       │ ├─ Agent 4              │
│ ├─ Agent 2       │ ├─ Agent 5              │
│ └─ Agent 3       │ ├─ Agent 6              │
│                  │ └─ Agent 7              │
├─────────────────────────────────────────────┤
│ Performance Team  │ Coordinator             │
│ ├─ Agent 8       │ └─ Agent 10             │
│ └─ Agent 9       │                         │
├─────────────────────────────────────────────┤
│ Coordination Core (Zero-Conflict Guarantee) │
├─────────────────────────────────────────────┤
│ Observability: OpenTelemetry (1,500+ spans)│
└─────────────────────────────────────────────┘
```

### Key Metrics
- **Agents Deployed:** 10 ✅
- **Teams Formed:** 4 ✅
- **Work Items Claimed:** 4 ✅
- **Concurrent Operations:** Yes ✅
- **Conflicts Detected:** 0 ✅
- **System Health:** 98.5% ✅

### What's Now Running
- All 10 agents registered and healthy
- Port range 4001-4010 allocated
- Database instances created for each agent
- Worktrees isolated per team
- Real-time telemetry aggregation active
- Multi-agent coordination verified

---

## Next Steps

### Ready to run real work? ➜
See [How To: Distribute Work Across Specialized Agents](../MULTI-AGENT-COORDINATION.md#distributing-work)

### Want to customize? ➜
See [Agent Configuration Guide](../AGENT-CONFIGURATION-GUIDE.md)

### Need monitoring details? ➜
See [Agent Monitoring Dashboard](../AGENT-MONITORING-DASHBOARD.md)

### Questions about teams? ➜
See [Understanding Team Composition Strategies](../EXPLANATIONS.md#team-composition)

---

## Troubleshooting

### "Port already in use" error
```bash
# Check which process is using ports 4001-4010
lsof -i :4001-4010

# Change port range in config:
"ports_used": "5001-5010"
```

### Agents showing "unhealthy"
```bash
# Check agent-specific health
./coordination_helper.sh agent-health agent_1

# Review telemetry for that agent
grep "agent_1" telemetry_spans.jsonl | tail -20 | jq '.'
```

### Work not distributing across teams
```bash
# Verify team assignments
./coordination_helper.sh list-agents --by-team

# Check team policies
./coordination_helper.sh team-config --team migration_team
```

### Telemetry not aggregating
```bash
# Verify all agents generating telemetry
tail telemetry_spans.jsonl | jq '.agent_id' | sort | uniq

# Should show: agent_1, agent_2, ..., agent_10
```

See [Agent Troubleshooting Guide](../AGENT-TROUBLESHOOTING.md) for more solutions.

---

**Status:** ✅ Tutorial Complete
**Time Elapsed:** ~15 minutes
**Next:** Try [Tutorial: Multi-Agent Team Coordination](./MULTI-AGENT-COORDINATION.md)
