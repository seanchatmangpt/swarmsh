# Performance Tuning Guide

> Comprehensive guide to optimizing SwarmSH for maximum throughput, minimal latency, and resource efficiency.

---

## Table of Contents

1. [Performance Baseline](#performance-baseline)
2. [Throughput Optimization](#throughput-optimization)
3. [Latency Reduction](#latency-reduction)
4. [Memory Optimization](#memory-optimization)
5. [I/O Performance](#io-performance)
6. [Telemetry Tuning](#telemetry-tuning)
7. [Profiling & Analysis](#profiling--analysis)
8. [Benchmarking](#benchmarking)

---

## Performance Baseline

### Current Performance (v1.1.0)

SwarmSH has been tuned and tested to achieve:

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Operation Success Rate | 90%+ | 92.6% | ✅ |
| Average Operation Time | <100ms | 42.3ms | ✅ |
| Throughput | 20+ ops/sec | 23.6 ops/sec | ✅ |
| Agent Concurrency | 10+ | 10+ | ✅ |
| Memory per Agent | <50MB | 25MB avg | ✅ |
| Telemetry Overhead | <10% | ~5% | ✅ |

### Establishing Your Baseline

```bash
# Measure current performance
./scripts/benchmark_baseline.sh

# Capture metrics
make telemetry-stats > baseline_metrics.json

# Document system specs
cat > baseline_system.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "system": {
    "os": "$(uname -s)",
    "kernel": "$(uname -r)",
    "cpu_count": $(nproc),
    "memory_gb": $(free -g | awk 'NR==2 {print $2}'),
    "disk_gb": $(df -BG / | awk 'NR==2 {print $2}')
  },
  "swarmsh": {
    "version": "$(./coordination_helper.sh --version)",
    "agents": "$(cat agent_coordination/agents.json | jq 'length')",
    "active_work": "$(cat agent_coordination/work_claims.json | jq 'length')"
  }
}
EOF

# Compare against target
jq '.' baseline_metrics.json
```

---

## Throughput Optimization

### Batch Processing Configuration

```bash
# Increase batch size for higher throughput
export BATCH_SIZE=500          # Default: 100
export BATCH_TIMEOUT=10000     # 10 seconds

# Enable batch mode explicitly
export BATCH_MODE=1
export BATCH_FLUSH_INTERVAL=5000

# Verify batch configuration
./coordination_helper.sh config show | grep -i batch
```

### Connection Pooling

```bash
# Enable connection pooling
export CONNECTION_POOL_SIZE=100
export CONNECTION_POOL_TIMEOUT=60000
export CONNECTION_REUSE_ENABLED=1

# Monitor pool usage
./scripts/monitor_connection_pool.sh
```

### Parallel Operations

```bash
# Enable parallel processing
export PARALLEL_JOBS=8
export PARALLEL_WORKERS=16

# Claim multiple work items in parallel
for i in {1..10}; do
  ./coordination_helper.sh claim "feature" "task_$i" "medium" &
done
wait
```

### Queue Optimization

```bash
# Optimize work queue performance
export WORK_QUEUE_SHARDING=4  # Split into 4 shards
export WORK_QUEUE_INDEX_ENABLED=1

# Rebuild work queue index
./scripts/rebuild_work_queue_index.sh

# Verify optimization
./coordination_helper.sh queue-stats
```

---

## Latency Reduction

### File Locking Tuning

```bash
# Reduce lock contention
export FLOCK_TIMEOUT=30        # Timeout in seconds
export FLOCK_RETRIES=3         # Number of retries
export FLOCK_BACKOFF_MS=50     # Backoff between retries

# Use adaptive locking
export ADAPTIVE_LOCKING=1
export LOCK_RETRY_MULTIPLIER=2
```

### Network Optimization

```bash
# Reduce network latency
export TCP_NODELAY=1
export TCP_KEEPALIVE=60
export SOCKET_BUFFER_SIZE=65536

# DNS caching
export DNS_CACHE_TTL=300
export DNS_CACHE_SIZE=1000
```

### Caching Strategy

```bash
# Enable aggressive caching
export CACHE_ENABLED=1
export CACHE_TTL=30            # 30 seconds
export CACHE_MAX_SIZE=10000    # 10000 entries
export CACHE_COMPRESSION=1

# Monitor cache hit rate
./scripts/monitor_cache_stats.sh
```

### Asynchronous Operations

```bash
# Enable async processing
export ASYNC_OPERATIONS=1
export ASYNC_BUFFER_SIZE=1000
export ASYNC_FLUSH_INTERVAL=5000

# Use fire-and-forget for non-critical operations
./coordination_helper.sh progress "$WORK_ID" 50 "in_progress" --async

# Monitor async queue
./scripts/monitor_async_queue.sh
```

---

## Memory Optimization

### Memory Profiling

```bash
# Profile memory usage
./scripts/profile_memory.sh

# Show memory usage per process
ps aux | grep coordination_helper | awk '{print $6}' | tail -1

# Monitor memory over time
watch -n 1 'ps aux | grep coordination_helper | awk "{print \$6}"'
```

### Garbage Collection Tuning

```bash
# Optimize garbage collection
export GC_ENABLED=1
export GC_INTERVAL=300000      # 5 minutes
export GC_THRESHOLD_MB=100
export GC_AGGRESSIVE=0         # Set to 1 if memory-constrained
```

### Data Structure Optimization

```bash
# Enable memory pooling
export MEMORY_POOL_ENABLED=1
export MEMORY_POOL_SIZE=100

# Reduce JSON object overhead
export JSON_COMPRESSION=1

# Use delta encoding for telemetry
export TELEMETRY_DELTA_ENCODING=1
```

### Memory Limit Configuration

```bash
# Set memory limits
export PROCESS_MEMORY_LIMIT_MB=2048

# Enable memory warnings
export MEMORY_WARNING_THRESHOLD_PCT=80
export MEMORY_CRITICAL_THRESHOLD_PCT=90

# Monitor memory usage
./scripts/monitor_memory_usage.sh
```

---

## I/O Performance

### File System Optimization

```bash
# Use write-ahead logging
export WAL_ENABLED=1
export WAL_SYNC_INTERVAL=5000

# Enable direct I/O
export DIRECT_IO=1

# Buffer size optimization
export IO_BUFFER_SIZE=131072   # 128KB

# Use memory-mapped files
export MMAP_ENABLED=1
```

### Disk I/O Tuning

```bash
# Check current I/O scheduler
cat /sys/block/sda/queue/scheduler

# Change to deadline scheduler (better for database workloads)
echo "deadline" | sudo tee /sys/block/sda/queue/scheduler

# Increase I/O queue depth
echo 128 | sudo tee /sys/block/sda/queue/nr_requests
```

### Compression Configuration

```bash
# Enable compression for telemetry
export TELEMETRY_COMPRESSION=gzip

# Compression level (1-9, 9 = highest compression, slowest)
export COMPRESSION_LEVEL=6

# Compression threshold (only compress if larger)
export COMPRESSION_MIN_SIZE=1024
```

### Journal Management

```bash
# Optimize telemetry journal
export JOURNAL_ROTATION_MB=100
export JOURNAL_RETENTION_DAYS=30
export JOURNAL_COMPRESSION_AGE_DAYS=7

# Archive old journals
./scripts/archive_old_journals.sh

# Verify journal performance
./scripts/check_journal_performance.sh
```

---

## Telemetry Tuning

### Span Sampling

```bash
# Sample telemetry spans to reduce overhead
export TELEMETRY_SAMPLE_RATE=0.1  # 10% sampling
export OTEL_TRACES_SAMPLER="parentbased_traceidratio"
export OTEL_TRACES_SAMPLER_ARG="0.1"

# Always sample critical operations
export SAMPLING_CRITICAL_ALWAYS=1
```

### Batch Span Export

```bash
# Configure span batching
export OTEL_BLRP_SCHEDULE_DELAY=5000     # 5 seconds
export OTEL_BLRP_MAX_EXPORT_BATCH_SIZE=1000
export OTEL_BLRP_MAX_QUEUE_SIZE=10000

# Use async export
export OTEL_EXPORTER_ASYNC=1
```

### Telemetry Metrics

```bash
# Reduce metric cardinality
export METRICS_ENABLED=1
export METRICS_CARDINALITY_LIMIT=1000

# Aggregate metrics
export METRICS_AGGREGATION_ENABLED=1
export METRICS_AGGREGATION_INTERVAL=60000
```

### Storage Optimization

```bash
# Compress stored telemetry
export TELEMETRY_COMPRESSION=1

# Reduce telemetry retention
export TELEMETRY_RETENTION_DAYS=7  # Default: 30

# Archive threshold
export TELEMETRY_ARCHIVE_LINES=10000  # Archive at line count
export TELEMETRY_ARCHIVE_AGE_DAYS=1
```

---

## Profiling & Analysis

### CPU Profiling

```bash
# Profile CPU usage
./scripts/profile_cpu.sh --duration 30

# Analyze profiling results
./scripts/analyze_cpu_profile.sh

# Generate CPU flamegraph
make profile-cpu-flame

# View results
open profile_cpu_flamegraph.html
```

### I/O Profiling

```bash
# Profile I/O operations
./scripts/profile_io.sh --duration 30

# Show I/O latency histogram
./scripts/analyze_io_profile.sh

# Monitor I/O in real-time
./scripts/monitor_io_realtime.sh
```

### Trace Analysis

```bash
# Collect detailed traces
export LOG_LEVEL=trace
make test-performance

# Analyze traces
./scripts/analyze_traces.sh

# Generate trace visualization
./scripts/visualize_traces.sh --format mermaid > trace_diagram.md
```

### Performance Regression Detection

```bash
# Compare current vs baseline
./scripts/detect_regressions.sh \
  --baseline baseline_metrics.json \
  --current current_metrics.json \
  --threshold 10  # Alert if >10% regression

# Generate regression report
./scripts/regression_report.sh > regressions.json
```

---

## Benchmarking

### Standard Benchmark Suite

```bash
# Run comprehensive benchmark
make benchmark

# Benchmark specific operations
./scripts/benchmark_operation.sh claim 1000
./scripts/benchmark_operation.sh progress 1000
./scripts/benchmark_operation.sh complete 1000

# Show results
./scripts/benchmark_results.sh
```

### Stress Testing

```bash
# Stress test with increasing load
./scripts/stress_test.sh \
  --agents 5 \
  --duration 300 \
  --ramp-up 30

# Stress test specific scenario
./scripts/stress_test_scenario.sh "high_concurrency"
```

### Load Testing

```bash
# Gradual load increase
./scripts/load_test.sh \
  --start-ops 10 \
  --max-ops 100 \
  --step 10 \
  --duration 60

# Find breaking point
./scripts/find_max_throughput.sh

# Generate load report
./scripts/load_test_report.sh
```

### Comparison Benchmarks

```bash
# Compare configurations
./scripts/compare_configs.sh \
  --config1 "BATCH_SIZE=100" \
  --config2 "BATCH_SIZE=500"

# A/B benchmark
./scripts/ab_benchmark.sh \
  --version-a "1.0.0" \
  --version-b "1.1.0"
```

---

## Performance Tuning Checklist

- [ ] Establish baseline performance
- [ ] Enable batch processing
- [ ] Enable connection pooling
- [ ] Tune file locking parameters
- [ ] Enable caching
- [ ] Optimize memory usage
- [ ] Enable WAL
- [ ] Configure telemetry sampling
- [ ] Run benchmark suite
- [ ] Monitor for regressions
- [ ] Document configuration changes
- [ ] Test under load

---

## Performance Monitoring Dashboard

```bash
# Start comprehensive monitoring
./scripts/performance_dashboard.sh

# Watch key metrics
watch -n 5 'make telemetry-stats | jq ".performance_metrics"'

# Real-time performance graph
./scripts/performance_graph.sh --realtime
```

---

<div align="center">

**[Back to Installation](../GETTING_STARTED.md)** • **[Configuration](../CONFIGURATION_REFERENCE.md)** • **[Monitoring](MONITORING_ADVANCED.md)**

</div>
