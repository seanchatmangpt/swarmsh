# Scalability Guide

> Scaling SwarmSH for enterprise deployments with hundreds of agents and millions of operations.

---

## Table of Contents

1. [Scalability Architecture](#scalability-architecture)
2. [Vertical Scaling](#vertical-scaling)
3. [Horizontal Scaling](#horizontal-scaling)
4. [Data Sharding](#data-sharding)
5. [Load Balancing](#load-balancing)
6. [Capacity Planning](#capacity-planning)
7. [Monitoring at Scale](#monitoring-at-scale)
8. [Troubleshooting Scale Issues](#troubleshooting-scale-issues)

---

## Scalability Architecture

### Scaling Dimensions

SwarmSH can scale across multiple dimensions:

```
Agents (Vertical)     Work Items (Horizontal)     Throughput (Performance)
    ↓                        ↓                            ↓
  1 → 100           Small queue → Millions        10 ops/sec → 1000 ops/sec

Deployment Size
  ↓
Single machine → Cluster → Multi-region
```

### Current Scale Limits

| Dimension | Current Limit | Enterprise | Notes |
|-----------|---------------|-----------|-------|
| Concurrent Agents | 10+ | 1000+ | Per coordinator |
| Work Items | 10K | 1M+ | Per shard |
| Operations/sec | 23.6 | 1000+ | With sharding |
| Data Size | 100GB | 10TB+ | With archival |
| Regions | 1 | 10+ | With multi-region setup |

---

## Vertical Scaling

### Single Machine Scaling

```bash
# Maximum settings for single machine
export BATCH_SIZE=1000
export CONNECTION_POOL_SIZE=500
export CACHE_MAX_SIZE=100000
export PARALLEL_WORKERS=32

# Machine requirements
# CPU: 8-16 cores
# RAM: 32-64GB
# Disk: 1TB SSD

# Monitor single-machine limits
./scripts/monitor_scaling_limits.sh
```

### Resource Allocation

```bash
# CPU allocation
export CPU_LIMIT=16000m  # 16 CPU cores

# Memory allocation
export MEMORY_LIMIT=32Gi  # 32GB RAM

# Disk allocation
export DISK_LIMIT=1000Gi  # 1TB SSD

# Network bandwidth
export NETWORK_LIMIT=10Gbps
```

---

## Horizontal Scaling

### Multi-Coordinator Setup

```yaml
# Kubernetes StatefulSet for horizontal scaling
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: swarmsh-coordinator
spec:
  replicas: 5  # Scale this number
  serviceName: swarmsh
  selector:
    matchLabels:
      component: coordinator
  template:
    metadata:
      labels:
        component: coordinator
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: component
                      operator: In
                      values:
                        - coordinator
                topologyKey: kubernetes.io/hostname
              weight: 100
      containers:
      - name: coordinator
        image: swarmsh:v1.1.0
        resources:
          requests:
            cpu: "4"
            memory: "8Gi"
          limits:
            cpu: "8"
            memory: "16Gi"
```

### Coordinator Discovery

```bash
# Service discovery setup
export COORDINATOR_DISCOVERY="kubernetes"  # kubernetes, consul, etcd, static

# For static setup
export COORDINATORS="
  coordinator-1:4000
  coordinator-2:4000
  coordinator-3:4000
"

# Health check across coordinators
./scripts/check_coordinator_health.sh
```

### Coordinator Synchronization

```bash
# Enable cross-coordinator sync
export COORDINATOR_SYNC_ENABLED=1
export COORDINATOR_SYNC_INTERVAL=5000  # 5 seconds

# Conflict resolution
export CONFLICT_RESOLUTION="timestamp"  # timestamp, priority, random

# Monitor coordination conflicts
./scripts/monitor_conflicts.sh
```

---

## Data Sharding

### Work Queue Sharding

```bash
# Enable sharding
export SHARDING_ENABLED=1
export SHARD_COUNT=16  # Increase for larger deployments

# Shard key strategy
export SHARD_KEY="work_type"  # work_type, priority, agent_id, hash

# Distribution algorithm
export SHARD_DISTRIBUTION="consistent_hash"  # round_robin, consistent_hash, range

# Monitor sharding
./scripts/monitor_sharding.sh
```

### Shard Rebalancing

```bash
# Automatic rebalancing
export AUTO_REBALANCE_ENABLED=1
export REBALANCE_THRESHOLD=0.2  # Rebalance if imbalance > 20%

# Manual rebalancing
./scripts/rebalance_shards.sh

# Monitor shard distribution
./scripts/show_shard_distribution.sh
```

### Agent-Shard Affinity

```bash
# Agents preferentially use local shard
export SHARD_AFFINITY="local"

# Monitor shard access patterns
./scripts/analyze_shard_access.sh

# Optimize shard placement
./scripts/optimize_shard_placement.sh
```

---

## Load Balancing

### Coordinator Load Balancing

```bash
# Load balancing strategy
export LB_STRATEGY="least_connections"  # least_connections, round_robin, response_time

# Health check configuration
export HEALTH_CHECK_INTERVAL=10000  # 10 seconds
export HEALTH_CHECK_TIMEOUT=5000    # 5 seconds

# Load balancer configuration (Nginx example)
upstream swarmsh_coordinators {
  least_conn;
  server coordinator-1:4000 max_fails=3 fail_timeout=30s;
  server coordinator-2:4000 max_fails=3 fail_timeout=30s;
  server coordinator-3:4000 max_fails=3 fail_timeout=30s;

  check interval=10000 rise=2 fall=5 timeout=5000 type=http;
  check_http_send "GET /health HTTP/1.0\r\n\r\n";
  check_http_expect_alive http_2xx;
}

server {
  listen 4000;
  location / {
    proxy_pass http://swarmsh_coordinators;
  }
}
```

### Request Routing

```bash
# Route based on work type
export ROUTING_ENABLED=1
export ROUTING_KEY="work_type"

# Request routing rules
./scripts/configure_routing_rules.sh << 'EOF'
feature -> coordinator-1:4000
bug_fix -> coordinator-2:4000
documentation -> coordinator-3:4000
EOF

# Monitor routing distribution
./scripts/monitor_routing.sh
```

---

## Capacity Planning

### Resource Requirements

```bash
# Per-agent requirements
AGENT_MEMORY=25MB
AGENT_CPU=0.1 cores
AGENT_IO=1MB/s

# Per-coordinator requirements (10 agents)
COORDINATOR_MEMORY=500MB
COORDINATOR_CPU=1 core
COORDINATOR_IO=10MB/s

# Calculate requirements
agents=100
coordinators=$((agents / 10))
total_memory_mb=$((agents * AGENT_MEMORY + coordinators * COORDINATOR_MEMORY))
echo "Required memory: ${total_memory_mb}MB"
```

### Scaling Checklist

```bash
# Before scaling up:
./scripts/scaling_readiness_check.sh

# Checklist:
# - [ ] Database capacity sufficient
# - [ ] Network bandwidth sufficient
# - [ ] Storage capacity sufficient
# - [ ] Monitoring stack can handle load
# - [ ] Alerting rules configured
# - [ ] Runbooks prepared
# - [ ] Load testing completed
# - [ ] Deployment validated
```

### Gradual Scaling

```bash
# Incremental scaling plan
./scripts/plan_scaling.sh \
  --current-agents 10 \
  --target-agents 100 \
  --phases 5 \
  --phase-duration 1d

# Execute phase
./scripts/execute_scaling_phase.sh --phase 1

# Monitor progress
./scripts/monitor_scaling_progress.sh
```

---

## Monitoring at Scale

### High-Cardinality Metrics

```bash
# Limit metric cardinality to prevent OOM
export METRICS_CARDINALITY_LIMIT=50000

# High-cardinality alerts
# These can cause Prometheus memory issues:
alert_rule: 'count by (agent_id) (swarmsh_operations_total)'

# Better:
alert_rule: 'sum(swarmsh_operations_total) by (status)'
```

### Distributed Tracing at Scale

```bash
# Reduce trace verbosity at scale
export OTEL_TRACES_SAMPLER_ARG="0.01"  # 1% sampling at scale

# Sample critical operations 100%
export CRITICAL_OPERATIONS_SAMPLE_RATE=1.0

# Archive old traces
export TRACE_RETENTION_DAYS=7
```

### Log Aggregation at Scale

```bash
# Log sampling to reduce volume
export LOG_SAMPLE_RATE=0.1  # 10% of logs

# Log compression
export LOG_COMPRESSION=gzip
export LOG_COMPRESSION_LEVEL=6

# Log archival
./scripts/archive_logs.sh --older-than 30d
```

---

## Troubleshooting Scale Issues

### Scale Bottlenecks

```bash
# Identify bottleneck
./scripts/identify_bottleneck.sh

# Common bottlenecks:
# 1. File I/O contention
#    → Use sharding, batch operations
# 2. Memory pressure
#    → Reduce cache size, enable compression
# 3. Network bandwidth
#    → Use local coordinators, reduce telemetry
# 4. CPU saturation
#    → Horizontal scaling, optimize algorithms
```

### Performance Degradation

```bash
# Compare current vs baseline
./scripts/compare_vs_baseline.sh --metric operation_latency

# Identify regression cause
./scripts/find_regression_cause.sh

# Common causes:
# 1. Increased load → Add capacity
# 2. Resource leak → Investigate memory/disk
# 3. Contention increase → Increase shards
# 4. Configuration change → Revert or optimize
```

### Scaling Failure Recovery

```bash
# Rollback scaling
./scripts/rollback_scaling.sh --to-phase previous

# Resolve issues
./scripts/analyze_scale_failure.sh

# Resume scaling with caution
./scripts/execute_scaling_phase.sh --phase 1 --slow
```

---

## Enterprise Scale Configuration

```bash
# Example: 1000 agents, 1M work items/day

# Sharding
export SHARD_COUNT=64
export SHARD_KEY="hash"

# Coordinators
replicas: 20
resources.cpu: "8"
resources.memory: "16Gi"

# Agents per coordinator
export AGENTS_PER_COORDINATOR=50

# Batch settings
export BATCH_SIZE=1000
export BATCH_TIMEOUT=10000

# Caching
export CACHE_MAX_SIZE=1000000

# Monitoring
export METRICS_RETENTION_DAYS=30
export TRACE_SAMPLE_RATE=0.01
export LOG_SAMPLE_RATE=0.1

# Storage
DB: Multi-node cluster
Disk: 5TB+ SSD
Network: 100Mbps+ connectivity
```

---

<div align="center">

**[Back to Deployment](../DEPLOYMENT_GUIDE.md)** • **[Performance Tuning](PERFORMANCE_TUNING.md)** • **[Monitoring](MONITORING_ADVANCED.md)**

</div>
