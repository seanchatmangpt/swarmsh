# Agent Monitoring Dashboard

> **Version:** 1.2.0 | **Last Updated:** December 27, 2025 | **Type:** Reference/How-To

## Quick Navigation
- **Getting started?** See [10-Agent Quickstart](./10-AGENT-QUICKSTART.md)
- **Need setup help?** See [Multi-Agent Coordination](./MULTI-AGENT-COORDINATION.md)
- **Configuration details?** See [Agent Configuration Reference](./AGENT-CONFIGURATION-REFERENCE.md)

---

## Monitoring Dashboard Commands

### Single-Agent Health Check

```bash
# Check health of one agent
./coordination_helper.sh agent-health agent_1

# Output:
# Agent: agent_1 (Schema Migrator)
# Status: HEALTHY ✅
# Load: 2/3 slots (66%)
# Last heartbeat: 2s ago
# Work in progress: 1
# Completed today: 12
# Success rate: 100%
# Response time: 45ms avg
```

### Team-Level Dashboard

```bash
# View entire team status
./coordination_helper.sh team-status migration_team

# Output:
# Migration Team Status
# ├─ Agent 1 (Schema Migrator):    HEALTHY [██████░░] 66%
# ├─ Agent 2 (Ash Phoenix Expert): HEALTHY [████████] 100%
# └─ Agent 3 (Data Converter):     HEALTHY [████░░░░] 40%
#
# Team Health: 97% (EXCELLENT)
# Work Queue: 2 items pending
# Throughput: 15 items/hour
# Avg response time: 1.2 seconds
```

### Multi-Team Swarm Dashboard

```bash
# View all teams and the entire swarm
./coordination_helper.sh swarm-status

# Output:
# ┌─────────────────────────────────────────┐
# │     10-AGENT CONCURRENT SWARM STATUS    │
# └─────────────────────────────────────────┘
#
# Migration Team (Agents 1-3)
# ├─ Health: 97% ✅
# ├─ Capacity: 3/3 slots active
# ├─ Throughput: 15 items/hour
# └─ Status: [██████░░] 66% loaded
#
# Integration Team (Agents 4-7)
# ├─ Health: 94% ⚠️
# ├─ Capacity: 4/4 slots active
# ├─ Throughput: 8 items/hour
# └─ Status: [████████] 100% loaded (BOTTLENECK)
#
# Performance Team (Agents 8-9)
# ├─ Health: 99% ✅
# ├─ Capacity: 2/2 slots active
# ├─ Throughput: 4 items/hour
# └─ Status: [██░░░░░░] 20% loaded
#
# Coordinator (Agent 10)
# ├─ Health: 100% ✅
# ├─ Load: 2/5 meta-tasks (40%)
# └─ Status: Routing work optimally
#
# ┌─────────────────────────────────────────┐
# │       SWARM SUMMARY                     │
# │ Overall Health: 96% (HEALTHY)           │
# │ Active Agents: 10/10                    │
# │ Total Throughput: 42 items/hour         │
# │ Key Issue: Integration team bottleneck  │
# └─────────────────────────────────────────┘
```

---

## Real-Time Monitoring

### Start Live Dashboard

```bash
# Monitor swarm for 24 hours with live updates
make monitor-24h

# Creates a live terminal dashboard updating every 5 seconds:
# ┌─────────────────────────────────────────────────────────┐
# │ SwarmSH Live Monitor - 2025-12-27 10:30:45              │
# ├─────────────────────────────────────────────────────────┤
# │ [A1: 100%] [A2: 50%] [A3: 25%] | [A4: 100%] [A5: 100%] │
# │ [A6: 75%] [A7: 50%] | [A8: 20%] [A9: 15%] | [A10: 40%] │
# │                                                          │
# │ Work Queue:                                              │
# │ ├─ Migration:   0 pending  2 claimed  (HEALTHY)          │
# │ ├─ Integration: 5 pending  4 claimed  (⚠️ BOTTLENECK)    │
# │ ├─ Performance: 0 pending  2 claimed  (✅ OPTIMAL)       │
# │                                                          │
# │ Events (last 5 min):                                     │
# │ 10:30: Agent 5 picked up task W_0847                    │
# │ 10:29: Agent 2 completed task W_0846 (2m 30s)           │
# │ 10:28: Escalation triggered - Integration backlog       │
# │                                                          │
# │ Telemetry: 1,547 spans generated | 50 spans/min         │
# └─────────────────────────────────────────────────────────┘
```

### Monitor by Team

```bash
# Focus on one team only
./coordination_helper.sh monitor --team integration_team --interval 5

# Shows:
# Integration Team Real-Time Monitor
# [10:30:45] Agent 4 (lead):  claimed W_0850 (complex_workflow_design)
# [10:30:46] Agent 5:         working on W_0847 (api_discovery) - 45% complete
# [10:30:47] Agent 6:         claimed W_0851 (trigger_logic)
# [10:30:48] Agent 7:         claimed W_0852 (error_handling)
# [10:30:49] Agent 5:         working on W_0847 (api_discovery) - 50% complete
# [10:30:50] Agent 4:         working on W_0850 - 15% complete
```

### Monitor with Telemetry Overlay

```bash
# Real-time metrics from telemetry
make monitor-24h --with-telemetry

# Adds live performance metrics:
# ┌─────────────────────────────────────────┐
# │ Telemetry Metrics (Last 5 Min)          │
# │                                          │
# │ Total Spans: 247                        │
# │ Span Generation Rate: 49 spans/min      │
# │                                          │
# │ Per Agent:                              │
# │ Agent 1: 28 spans | Response: 42ms avg  │
# │ Agent 2: 31 spans | Response: 48ms avg  │
# │ Agent 3: 22 spans | Response: 38ms avg  │
# │ Agent 4: 35 spans | Response: 156ms avg │
# │ Agent 5: 38 spans | Response: 198ms avg │
# │                                          │
# │ Slow Operations (>500ms):                │
# │ - Agent 4: api_discovery (2.3s)         │
# │ - Agent 5: trigger_logic (1.8s)         │
# │ - Agent 7: workflow_design (3.1s)       │
# └─────────────────────────────────────────┘
```

---

## Performance Metrics

### Throughput Analysis

```bash
# Get detailed throughput metrics
./coordination_helper.sh throughput-report --period 24h

# Output:
# Throughput Report (Last 24 hours)
#
# Migration Team (Agents 1-3):
#   Total items: 180
#   Rate: 7.5 items/hour
#   Avg time: 8 minutes
#   Success rate: 100%
#
# Integration Team (Agents 4-7):
#   Total items: 96
#   Rate: 4.0 items/hour
#   Avg time: 15 minutes
#   Success rate: 98% (2 retries)
#
# Performance Team (Agents 8-9):
#   Total items: 48
#   Rate: 2.0 items/hour
#   Avg time: 30 minutes
#   Success rate: 100%
#
# Coordinator:
#   Total routing decisions: 324
#   Conflicts detected: 0
#   Escalations: 1
#
# System Totals:
#   Work items completed: 324
#   Total time: 24 hours
#   Avg items/hour: 13.5
#   System efficiency: 94%
```

### Latency Analysis

```bash
# Analyze response times
./coordination_helper.sh latency-report

# Output:
# Latency Analysis
#
# Work Claiming (Agent → Coordinator → Agent)
#   p50: 12ms
#   p95: 45ms
#   p99: 120ms
#   Max: 312ms (spike due to lock contention)
#
# Progress Reporting (Agent → Telemetry)
#   p50: 8ms
#   p95: 25ms
#   p99: 80ms
#   Max: 150ms
#
# Health Checking (Coordinator → Agent)
#   p50: 5ms
#   p95: 15ms
#   p99: 35ms
#   Max: 90ms
#
# Work Completion Reporting
#   p50: 18ms
#   p95: 50ms
#   p99: 150ms
#   Max: 450ms
```

### Resource Utilization

```bash
# Check resource usage
./coordination_helper.sh resource-report

# Output:
# Resource Utilization Report
#
# Memory Usage:
#   Agent 1: 187MB / 512MB (36%)
#   Agent 2: 204MB / 512MB (40%)
#   Agent 3: 156MB / 512MB (30%)
#   ...
#   Total: 4.2GB / 5.5GB (76%)
#
# CPU Usage (4-hour window):
#   Peak: 8.2 cores / 10 cores (82%)
#   Average: 6.4 cores / 10 cores (64%)
#   Current: 7.1 cores / 10 cores (71%)
#
# Database Size:
#   Agent 1 DB: 156MB / 500MB (31%)
#   Agent 2 DB: 201MB / 500MB (40%)
#   ...
#   Total: 3.8GB / 5GB (76%)
#
# Network Bandwidth:
#   Inbound: 2.3 Mbps / 100 Mbps
#   Outbound: 1.8 Mbps / 100 Mbps
#   Total: 4.1 Mbps / 100 Mbps (4%)
```

---

## Health Score Calculation

### Agent Health Score Formula

```
Agent Health = (100 - failures)
             × (1 - response_time_factor)
             × (1 - queue_depth_factor)

Where:
  failures = count of recent failures (0-100)
  response_time_factor = (avg_response_time - 50ms) / 1000ms  [0-1]
  queue_depth_factor = queue_depth / max_queue  [0-1]

Example calculation for Agent 5:
  Failures: 2 in last hour → 2% penalty
  Avg response time: 198ms → (198-50)/1000 = 0.148 factor
  Queue depth: 2/5 max → 0.4 factor

  Health = (100 - 2) × (1 - 0.148) × (1 - 0.4)
         = 98 × 0.852 × 0.6
         = 50.04 → 50% (DEGRADED ⚠️)
```

### Health Score Interpretation

| Score | Status | Action | Color |
|-------|--------|--------|-------|
| 90-100 | EXCELLENT | Monitor | 🟢 Green |
| 80-90 | HEALTHY | Monitor | 🟢 Green |
| 70-80 | ACCEPTABLE | Watch closely | 🟡 Yellow |
| 60-70 | DEGRADED | Investigate | 🟡 Yellow |
| 50-60 | POOR | Escalate | 🔴 Red |
| <50 | CRITICAL | Emergency response | 🔴 Red |

### Team Health Score

Team health = Average of all member agents' health scores

```
Migration Team Health = (Health of Agent 1 + 2 + 3) / 3
                     = (97 + 85 + 92) / 3
                     = 91% (HEALTHY)
```

### Swarm Health Score

Swarm health = Weighted average of team scores

```
Swarm Health = (Migration 91% × 0.3 [3/10 agents]
              + Integration 72% × 0.4 [4/10 agents]
              + Performance 95% × 0.2 [2/10 agents]
              + Coordinator 100% × 0.1 [1/10 agents])
             = 84% (HEALTHY)
```

---

## Alerting Rules

### Critical Alerts

These require immediate action:

```
IF agent.health < 0.5 THEN
  ALERT "CRITICAL: Agent {id} unhealthy"
  ACTION "Reassign work to backup agent"
  SEVERITY "CRITICAL"
  TEAM "On-call engineer"

IF coordinator.response_time > 1000ms THEN
  ALERT "CRITICAL: Coordinator slow"
  ACTION "Check coordinator load, restart if needed"
  SEVERITY "CRITICAL"
  TEAM "Infrastructure"

IF swarm.health < 0.6 THEN
  ALERT "CRITICAL: System degraded"
  ACTION "Pause new work, investigate failure"
  SEVERITY "CRITICAL"
  TEAM "Engineering lead"
```

### Warning Alerts

These need investigation within 15 minutes:

```
IF team.health < 0.75 THEN
  ALERT "WARNING: Team performance degraded"
  ACTION "Check team status, consider load balancing"
  SEVERITY "WARNING"
  TEAM "Team lead"

IF work_queue_depth > 10 THEN
  ALERT "WARNING: Work queue building up"
  ACTION "Increase capacity or debug bottleneck"
  SEVERITY "WARNING"
  TEAM "Team lead"

IF agent.response_time_p95 > 500ms THEN
  ALERT "WARNING: Agent response time high"
  ACTION "Check agent load, consider rebalancing"
  SEVERITY "WARNING"
  TEAM "Team lead"
```

### Informational Alerts

These are for tracking and reporting:

```
IF work_item.completed THEN
  ALERT "INFO: Work completed"
  TELEMETRY "span_generated"
  DASHBOARD "update metrics"

IF agent.status_changed THEN
  ALERT "INFO: Agent status change"
  TELEMETRY "agent_status_change"
  DASHBOARD "update agent indicator"
```

---

## Historical Analysis

### Compare Performance Over Time

```bash
# Compare last 24h vs last 7 days
./coordination_helper.sh performance-comparison --window 24h-7d

# Output:
# Performance Comparison (24h vs 7d average)
#
# Throughput:
#   24h: 324 items
#   7d avg: 287 items (+13%)
#   Trend: Improving ✅
#
# Success Rate:
#   24h: 99.7%
#   7d avg: 98.9%
#   Trend: Improving ✅
#
# Response Time:
#   24h: 45ms avg
#   7d avg: 52ms avg (-13%)
#   Trend: Getting faster ✅
#
# Key Insight: System performance improving steadily
```

### Identify Trends

```bash
# Multi-day trend analysis
./coordination_helper.sh trend-analysis --days 30

# Output:
# 30-Day Trend Analysis
#
# Week 1: System ramping up
#   Health: 70% → 80% (improving)
#   Throughput: 150 → 200 items/day (scaling)
#
# Week 2: Stable operations
#   Health: 85% ± 3% (steady)
#   Throughput: 280 ± 20 items/day (consistent)
#
# Week 3: Performance plateau
#   Health: 88% → 82% (degrading)
#   Throughput: 290 → 250 items/day (declining)
#   Root cause: Integration team bottleneck (see 12/24)
#
# Week 4: Recovery
#   Health: 82% → 94% (improving)
#   Throughput: 250 → 320 items/day (recovering)
#
# Overall trend: Healthy system with predictable scaling
```

---

## Dashboard Customization

### Create Custom Dashboard

```bash
# Create dashboard showing only migration team
./coordination_helper.sh create-dashboard --team migration_team --metrics ["health", "throughput", "response_time"]

# Create dashboard showing bottleneck analysis
./coordination_helper.sh create-dashboard --focus bottlenecks --update-interval 5s

# Create dashboard for performance analysis
./coordination_helper.sh create-dashboard --team performance_team --metrics ["optimizations_completed", "avg_improvement", "code_quality"]
```

### Export Metrics

```bash
# Export all metrics as JSON
./coordination_helper.sh export-metrics --format json > metrics.json

# Export as CSV for analysis
./coordination_helper.sh export-metrics --format csv > metrics.csv

# Export as Prometheus format
./coordination_helper.sh export-metrics --format prometheus > prometheus.txt
```

---

## Related Documentation

- **Quickstart:** [10-Agent Quickstart](./10-AGENT-QUICKSTART.md)
- **Configuration:** [Agent Configuration Reference](./AGENT-CONFIGURATION-REFERENCE.md)
- **Coordination:** [Multi-Agent Coordination](./MULTI-AGENT-COORDINATION.md)
- **Troubleshooting:** [Agent Troubleshooting](./AGENT-TROUBLESHOOTING.md)

---

**Status:** ✅ Monitoring Reference Complete
**Dashboard Types:** Single-agent, team-level, swarm-level
**Real-Time Updates:** Every 5 seconds
**Historical Data:** 30-day retention
**Last Validated:** December 27, 2025
