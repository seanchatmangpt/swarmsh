# Agent Configuration Reference

> **Version:** 1.2.0 | **Last Updated:** December 27, 2025 | **Type:** Reference Documentation

## Quick Navigation
- **Getting started?** See [10-Agent Quickstart](./10-AGENT-QUICKSTART.md)
- **How-to guides?** See [Multi-Agent Coordination](./MULTI-AGENT-COORDINATION.md)
- **Concepts?** See [Agent System Explanations](./AGENT-SYSTEM-EXPLANATIONS.md)

---

## Agent Configuration Schema

Complete reference for configuring individual agents in a 10-agent swarm.

### Agent Object Structure

```json
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
}
```

### Field Reference

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `agent_id` | string | Yes | Unique identifier combining number + specialization | `agent_001_migration` |
| `agent_number` | integer | Yes | Sequential number (1-10) for identification | `1` |
| `name` | string | Yes | Human-readable agent name | `Schema Migrator` |
| `specialization` | string | Yes | Primary domain of expertise | `schema_migration` |
| `team` | string | Yes | Team assignment for coordination | `migration_team` |
| `port` | integer | Yes | Unique port for agent web service (4001-4010) | `4001` |
| `database` | string | Yes | Isolated database for agent state | `swarmsh_agent_1` |
| `capacity` | integer | Yes | Total work capacity (1-150) | `100` |
| `max_concurrent_work` | integer | Yes | Max simultaneous work items | `3` |
| `worktree` | string | Yes | Git worktree for code isolation | `ash-phoenix-migration` |
| `capabilities` | array | Yes | List of specialized capabilities | `["database_analysis"]` |
| `status` | string | Yes | Current state of agent | `pending`, `active`, `scaling`, `unhealthy`, `shutdown` |

---

## Specialization Types

### Migration Specialization (Agents 1-3)

**Primary Domain:** Code framework migration, database schema conversion

```json
{
  "specialization": "schema_migration",
  "team": "migration_team",
  "capabilities": [
    "database_analysis",
    "schema_conversion",
    "validation",
    "rollback_planning"
  ],
  "tools": [
    "sql_parser",
    "orm_mapper",
    "migration_validator"
  ]
}
```

**Expected Work Patterns:**
- Analyze existing code/schemas
- Plan conversion strategy
- Execute conversion (atomic operations)
- Validate results
- Document changes

**Performance Targets:**
- 10-50 schema conversions per day
- Zero data loss (100% validation)
- Rollback capability always available

### Integration Specialization (Agents 4-7)

**Primary Domain:** External API integration, workflow automation

```json
{
  "specialization": "n8n_integration",
  "team": "integration_team",
  "capabilities": [
    "workflow_design",
    "api_discovery",
    "trigger_logic",
    "error_handling"
  ],
  "tools": [
    "n8n_client",
    "openapi_parser",
    "workflow_validator"
  ]
}
```

**Expected Work Patterns:**
- Discover external APIs
- Design integration workflows
- Implement triggers and actions
- Test integrations
- Monitor for failures

**Performance Targets:**
- 5-15 workflow integrations per day
- 99% uptime for critical integrations
- <5 minute integration setup time

### Performance Specialization (Agents 8-9)

**Primary Domain:** Code optimization, performance bottleneck detection

```json
{
  "specialization": "code_optimization",
  "team": "performance_team",
  "capabilities": [
    "performance_profiling",
    "bottleneck_detection",
    "optimization_strategy",
    "refactoring"
  ],
  "tools": [
    "profiler",
    "memory_analyzer",
    "latency_tracker"
  ]
}
```

**Expected Work Patterns:**
- Profile code execution
- Identify bottlenecks
- Develop optimization strategy
- Implement and validate
- Measure improvement

**Performance Targets:**
- 2-5 subsystems optimized per day
- Average 20-30% performance improvement
- Maintain backward compatibility

### Orchestration Specialization (Agent 10)

**Primary Domain:** Coordination, monitoring, escalation

```json
{
  "specialization": "orchestration",
  "team": "coordinator_team",
  "capacity": 150,
  "max_concurrent_work": 5,
  "capabilities": [
    "work_distribution",
    "health_monitoring",
    "conflict_resolution",
    "priority_adjustment",
    "team_coordination"
  ],
  "tools": [
    "coordinator",
    "health_monitor",
    "telemetry_aggregator"
  ]
}
```

**Expected Work Patterns:**
- Monitor all team health
- Route work to appropriate teams
- Detect and resolve conflicts
- Escalate critical issues
- Generate reports

**Performance Targets:**
- 99.9% uptime
- <100ms work routing latency
- Zero undetected conflicts

---

## Team Configuration Schema

### Team Object Structure

```json
{
  "team_id": "migration_team",
  "name": "Migration Team",
  "agent_count": 3,
  "agents": [1, 2, 3],
  "lead_agent": 1,
  "priority": "high",
  "dependencies": [],
  "work_category": "migration",
  "sla": {
    "response_time_seconds": 60,
    "availability_percent": 0.95
  }
}
```

### Team Configuration Reference

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| `team_id` | string | `migration_team`, `integration_team`, `performance_team`, `coordinator_team` | Unique team identifier |
| `name` | string | Any | Human-readable team name |
| `agent_count` | integer | 1-4 | Number of agents in team |
| `agents` | array | [1-10] | Agent numbers in this team |
| `lead_agent` | integer | 1-10 | Senior agent for decision-making |
| `priority` | string | `critical`, `high`, `medium`, `low` | Default priority for team's work |
| `dependencies` | array | Team IDs | Other teams this depends on |
| `work_category` | string | Any | Category of work team handles |
| `sla.response_time_seconds` | integer | 30-300 | Target response time |
| `sla.availability_percent` | float | 0.8-1.0 | Uptime requirement (80-100%) |

---

## Resource Allocation Schema

### Resource Allocation Configuration

```json
{
  "resource_allocation": {
    "total_agents": 10,
    "ports_used": "4001-4010",
    "total_capacity": 1050,
    "memory_per_agent": "512MB",
    "cpu_per_agent": "1.0 core",
    "total_memory": "5.5GB",
    "total_cpu": "10 cores",
    "max_concurrent_work": 30,
    "storage_per_agent": "1GB",
    "network_bandwidth": "100Mbps",
    "database_size_per_agent": "500MB"
  }
}
```

### Port Allocation Table

| Agent Number | Team | Port | Database | Status |
|--------------|------|------|----------|--------|
| 1 | migration_team | 4001 | swarmsh_agent_1 | Active |
| 2 | migration_team | 4002 | swarmsh_agent_2 | Active |
| 3 | migration_team | 4003 | swarmsh_agent_3 | Active |
| 4 | integration_team | 4004 | swarmsh_agent_4 | Active |
| 5 | integration_team | 4005 | swarmsh_agent_5 | Active |
| 6 | integration_team | 4006 | swarmsh_agent_6 | Active |
| 7 | integration_team | 4007 | swarmsh_agent_7 | Active |
| 8 | performance_team | 4008 | swarmsh_agent_8 | Active |
| 9 | performance_team | 4009 | swarmsh_agent_9 | Active |
| 10 | coordinator_team | 4010 | swarmsh_agent_10 | Active |

### Memory Allocation Breakdown

```
Total System: 5.5GB
├─ Agents (10 × 512MB): 5.0GB
│  ├─ Agent Runtime: 256MB
│  ├─ Database Instance: 128MB
│  ├─ Work Queue: 64MB
│  └─ Telemetry Buffer: 64MB
├─ Coordination Core: 256MB
├─ OpenTelemetry Collector: 128MB
└─ Monitoring Dashboard: 128MB
```

---

## Capability Matrix

### Complete Capability Reference

| Capability | Agents | Team | Purpose | Example |
|------------|--------|------|---------|---------|
| `schema_analysis` | 1 | migration | Analyze database schemas | Parse DDL, identify changes |
| `schema_conversion` | 1, 2, 3 | migration | Convert schema format | Ash v1 → Phoenix ORM |
| `data_migration` | 3 | migration | Move data safely | Bulk operations, validation |
| `workflow_design` | 4 | integration | Design N8n workflows | Define triggers, actions |
| `api_discovery` | 6 | integration | Find and catalog APIs | OpenAPI, REST analysis |
| `trigger_logic` | 5, 7 | integration | Implement workflow triggers | Event handling, scheduling |
| `error_handling` | 5, 7 | integration | Workflow error recovery | Retry logic, fallbacks |
| `performance_profiling` | 8 | performance | Profile code execution | Collect metrics, timings |
| `bottleneck_detection` | 8 | performance | Find performance issues | Identify slow operations |
| `optimization_strategy` | 9 | performance | Plan optimizations | Algorithm changes, caching |
| `work_distribution` | 10 | coordinator | Route work to agents | Queue management, routing |
| `health_monitoring` | 10 | coordinator | Monitor system health | Detect failures, alerts |
| `conflict_resolution` | 10 | coordinator | Resolve work conflicts | Atomic operations, mediation |

---

## Coordination Settings Schema

### Coordination Configuration

```json
{
  "coordination_settings": {
    "strategy": "priority_based",
    "conflict_resolution": "atomic_with_claude_mediation",
    "health_check_interval": 30,
    "health_check_timeout": 60,
    "failure_threshold": 3,
    "failure_recovery": "automatic",
    "telemetry_aggregation": "realtime",
    "work_claiming_strategy": "fifo_within_priority",
    "escalation_threshold": 0.7,
    "max_retry_attempts": 3,
    "retry_backoff_seconds": 5
  }
}
```

### Coordination Settings Reference

| Setting | Type | Default | Range | Description |
|---------|------|---------|-------|-------------|
| `strategy` | string | `priority_based` | N/A | Work distribution strategy |
| `conflict_resolution` | string | `atomic_with_claude_mediation` | N/A | How conflicts are resolved |
| `health_check_interval` | integer | 30 | 5-300 seconds | Time between health checks |
| `health_check_timeout` | integer | 60 | 10-600 seconds | Max wait for health response |
| `failure_threshold` | integer | 3 | 1-10 | Failed checks before unhealthy |
| `failure_recovery` | string | `automatic` | `automatic`, `manual` | Recovery approach |
| `telemetry_aggregation` | string | `realtime` | `realtime`, `batch` | Telemetry collection mode |
| `work_claiming_strategy` | string | `fifo_within_priority` | N/A | Work claiming order |
| `escalation_threshold` | float | 0.7 | 0.5-0.95 | Health score for escalation |
| `max_retry_attempts` | integer | 3 | 1-10 | Max work retries |
| `retry_backoff_seconds` | integer | 5 | 1-60 | Delay between retries |

---

## Monitoring Configuration Schema

### Monitoring Settings

```json
{
  "monitoring": {
    "enabled": true,
    "dashboard_port": 3000,
    "metrics_retention_days": 30,
    "aggregation_level": "realtime",
    "alert_thresholds": {
      "agent_health": 0.7,
      "team_health": 0.75,
      "system_health": 0.8,
      "work_queue_depth": 10,
      "response_time_ms": 5000
    },
    "alert_channels": ["log", "email", "dashboard"],
    "log_level": "INFO"
  }
}
```

### Alert Thresholds

| Alert | Green | Yellow | Red | Action |
|-------|-------|--------|-----|--------|
| Agent Health | >0.9 | 0.7-0.9 | <0.7 | Monitor / Reassign work / Escalate |
| Team Health | >0.85 | 0.75-0.85 | <0.75 | Inform / Boost capacity / Escalate |
| System Health | >0.9 | 0.8-0.9 | <0.8 | Investigate / Scale / Emergency |
| Work Queue | <5 | 5-10 | >10 | Healthy / Warning / Bottleneck |
| Response Time | <1s | 1-5s | >5s | Healthy / Slow / Critical |

---

## Status States

### Agent Status Lifecycle

```
pending → active → scaling → active → degraded → unhealthy → recovering → active → shutdown
```

| Status | Description | Recovery | Auto-Recovery |
|--------|-------------|----------|----------------|
| `pending` | Agent created but not started | Manual start | No |
| `active` | Agent operational and healthy | N/A | N/A |
| `scaling` | Agent handling increased load | Monitor | Yes (5-10s) |
| `degraded` | Agent experiencing issues but operational | Monitor | Yes (30s) |
| `unhealthy` | Agent unable to accept work | Restart / Replace | Yes (60s) |
| `recovering` | Agent restarting after failure | Monitor | Yes (30-60s) |
| `shutdown` | Agent intentionally stopped | Manual restart | No |

### Work Status States

```
pending → claimed → in_progress → completed
              ↓            ↓
           blocked    → failed → retrying
              ↑_____________↑
```

| Status | Meaning | Owner | Next State |
|--------|---------|-------|-----------|
| `pending` | Waiting to be claimed | Coordinator | `claimed` |
| `blocked` | Waiting for dependency | Coordinator | `claimed` (when dependency resolves) |
| `claimed` | Agent claimed the work | Agent | `in_progress` |
| `in_progress` | Agent actively working | Agent | `completed` or `failed` |
| `completed` | Work finished successfully | Agent | (archive) |
| `failed` | Work failed, will retry | Agent | `retrying` |
| `retrying` | Attempting work again | Agent | `completed` or `failed` |

---

## Environment Variables

### Agent Environment Configuration

| Variable | Type | Default | Example | Purpose |
|----------|------|---------|---------|---------|
| `AGENT_ID` | string | N/A | `agent_001_migration` | Unique agent identifier |
| `AGENT_PORT` | integer | N/A | `4001` | Web service port |
| `AGENT_DB` | string | N/A | `swarmsh_agent_1` | Database name |
| `AGENT_CAPACITY` | integer | 100 | 100 | Work capacity |
| `AGENT_SPECIALIZATION` | string | N/A | `schema_migration` | Agent specialty |
| `TEAM_ID` | string | N/A | `migration_team` | Team assignment |
| `WORK_DIR` | string | `/tmp` | `/home/user/swarmsh` | Working directory |
| `TELEMETRY_ENABLED` | boolean | true | true | Enable OpenTelemetry |
| `HEALTH_CHECK_INTERVAL` | integer | 30 | 30 | Health check frequency |
| `LOG_LEVEL` | string | INFO | INFO, DEBUG, WARN | Logging level |

---

## Configuration Files

### Required Configuration Files

| File | Location | Purpose | Format |
|------|----------|---------|--------|
| `10-agent-team-config.json` | Project root | Main team configuration | JSON |
| `agent_specializations.json` | `shared_coordination/` | Capability definitions | JSON |
| `team_coordination.json` | `shared_coordination/` | Team relationships | JSON |
| `resource_limits.json` | `shared_coordination/` | Resource constraints | JSON |

### Example Configuration Loading

```bash
# Load team configuration
TEAM_CONFIG=$(cat 10-agent-team-config.json)

# Extract agent count
AGENT_COUNT=$(echo "$TEAM_CONFIG" | jq '.agent_count')

# Get coordinator port
COORDINATOR_PORT=$(echo "$TEAM_CONFIG" | jq '.agents[-1].port')

# List all agents
echo "$TEAM_CONFIG" | jq '.agents[] | .agent_id'
```

---

## Default Values

### Recommended Defaults for New Teams

```json
{
  "new_agent_defaults": {
    "capacity": 100,
    "max_concurrent_work": 3,
    "health_check_interval": 30,
    "health_check_timeout": 60,
    "failure_threshold": 3,
    "port_start": 4001,
    "memory_per_agent": "512MB",
    "cpu_per_agent": 1.0
  },

  "new_team_defaults": {
    "priority": "medium",
    "sla_response_time": 60,
    "sla_availability": 0.95
  },

  "system_defaults": {
    "max_agents": 10,
    "telemetry_retention": 30,
    "health_check_interval": 30,
    "escalation_threshold": 0.7,
    "retry_attempts": 3
  }
}
```

---

## Advanced Configuration

### Custom Agent Specialization

To define a new specialization:

```json
{
  "custom_specialization": {
    "name": "custom_specialization",
    "description": "Description of this specialization",
    "capabilities": [
      "capability_1",
      "capability_2"
    ],
    "tools": [
      "tool_1",
      "tool_2"
    ],
    "training": {
      "model": "claude-opus",
      "prompts": ["prompt_1.txt"],
      "context_window": 8000
    },
    "performance_targets": {
      "items_per_day": 10,
      "success_rate": 0.95,
      "avg_time_minutes": 30
    }
  }
}
```

### Custom Team Configuration

To add a custom team:

```json
{
  "custom_team": {
    "team_id": "custom_team",
    "name": "Custom Team",
    "agent_count": 2,
    "agents": [1, 2],
    "lead_agent": 1,
    "priority": "medium",
    "specialization": "custom_specialization",
    "work_category": "custom_work"
  }
}
```

---

## See Also

- **Quickstart:** [10-Agent Quickstart](./10-AGENT-QUICKSTART.md)
- **Coordination:** [Multi-Agent Coordination](./MULTI-AGENT-COORDINATION.md)
- **Monitoring:** [Agent Monitoring Dashboard](./AGENT-MONITORING-DASHBOARD.md)
- **Troubleshooting:** [Agent Troubleshooting](./AGENT-TROUBLESHOOTING.md)

---

**Status:** ✅ Reference Complete
**Format:** Complete JSON schema with examples
**Last Validated:** December 27, 2025
