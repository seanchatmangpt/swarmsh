# Advanced Monitoring Guide

> Comprehensive guide to advanced monitoring, observability, and troubleshooting SwarmSH deployments.

---

## Table of Contents

1. [Monitoring Architecture](#monitoring-architecture)
2. [Metrics Collection](#metrics-collection)
3. [Log Aggregation](#log-aggregation)
4. [Trace Analysis](#trace-analysis)
5. [Alerting & Anomalies](#alerting--anomalies)
6. [Dashboards & Visualization](#dashboards--visualization)
7. [Debugging & Troubleshooting](#debugging--troubleshooting)

---

## Monitoring Architecture

### Three Pillars of Observability

```
Metrics        Logs           Traces
  ↓             ↓              ↓
 ┌─────────────────────────────┐
 │   OpenTelemetry Collector   │
 ├─────────────────────────────┤
 │ Processing & Aggregation    │
 └─────────────────────────────┘
      ↓            ↓            ↓
   Time Series  Log Storage  Trace Storage
   Database     (Loki/ELK)   (Jaeger)
      ↓            ↓            ↓
   Prometheus  Logs UI      Trace UI
   ↓
 Grafana Dashboard
```

### Monitoring Stack Setup

```yaml
# Docker Compose monitoring stack
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14250:14250"

  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml
      - loki_data:/loki

  promtail:
    image: grafana/promtail:latest
    volumes:
      - ./promtail-config.yaml:/etc/promtail/config.yml
      - /var/log:/var/log

  otel-collector:
    image: otel/opentelemetry-collector:latest
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
    ports:
      - "4317:4317"
      - "4318:4318"
    command:
      - --config=/etc/otel-collector-config.yaml
```

---

## Metrics Collection

### Key Metrics to Monitor

```bash
# View current metrics
make telemetry-stats

# Key metrics:
# - operation_latency_p50, p95, p99
# - operation_success_rate
# - agent_utilization
# - work_queue_size
# - coordination_conflicts
# - memory_usage
# - file_lock_contention
```

### Custom Metric Collection

```bash
# Define custom metrics
export CUSTOM_METRICS="
  agent.capacity.available
  work.queue.processing_time
  coordination.lock.wait_time
  telemetry.span.count
  system.memory.percent_used
"

# Enable metric collection
./scripts/collect_custom_metrics.sh

# View metric values
./scripts/show_metrics.sh | jq '.[] | select(.name|test("agent|work|coordination"))'
```

### Metric Retention & Aggregation

```bash
# Configure metric retention
export METRICS_RETENTION_DAYS=30
export METRICS_AGGREGATION_INTERVAL=60000  # 1 minute

# Archive old metrics
./scripts/archive_metrics.sh --older-than 7d

# Aggregate metrics by timeframe
./scripts/aggregate_metrics.sh --by hour
./scripts/aggregate_metrics.sh --by day
```

### Prometheus Queries

```promql
# Operation success rate (last 5 minutes)
rate(swarmsh_operations_total{status="success"}[5m])

# Average operation latency
histogram_quantile(0.95, rate(swarmsh_operation_duration_seconds_bucket[5m]))

# Agent utilization
avg(swarmsh_agent_capacity_used / swarmsh_agent_capacity_total)

# Work queue size over time
swarmsh_work_queue_size

# File lock contention
rate(swarmsh_flock_wait_seconds[5m])
```

---

## Log Aggregation

### Log Configuration

```bash
# Enable comprehensive logging
export LOG_ENABLED=1
export LOG_LEVEL="debug"  # debug, info, warn, error
export LOG_FORMAT="json"  # json, text
export LOG_DESTINATION="/var/log/swarmsh/swarmsh.log"

# Structured logging
export STRUCTURED_LOGGING=1
export LOG_INCLUDE_CONTEXT=1
export LOG_INCLUDE_PERFORMANCE=1
```

### Log Shipping with Promtail

```yaml
# promtail-config.yaml
clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: swarmsh
    static_configs:
      - labels:
          job: swarmsh
          __path__: /var/log/swarmsh/*.log
    pipeline_stages:
      - json:
          expressions:
            timestamp: timestamp
            level: level
            message: message
            work_id: work_id
      - timestamp:
          source: timestamp
          format: 2006-01-02T15:04:05Z07:00
      - labels:
          level:
          work_id:
```

### Log Queries

```bash
# Query logs for specific work item
{job="swarmsh"} | json | work_id = "12345"

# View error logs
{job="swarmsh"} | json | level = "error"

# See progress updates for work item
{job="swarmsh"} | json | work_id =~ ".*" | line_format "{{.timestamp}} {{.message}}"
```

---

## Trace Analysis

### OpenTelemetry Trace Configuration

```bash
# Configure trace sampling
export OTEL_TRACES_SAMPLER="parentbased_traceidratio"
export OTEL_TRACES_SAMPLER_ARG="0.1"  # 10% sampling

# Trace context propagation
export OTEL_PROPAGATORS="tracecontext,baggage"

# Export to Jaeger
export OTEL_EXPORTER_JAEGER_ENDPOINT="http://jaeger:14250"
```

### Analyzing Traces in Jaeger

```bash
# Access Jaeger UI
# http://localhost:16686

# Common trace queries:
# - Service: swarmsh
# - Operation: coordination_helper.claim
# - Tags: work_type=feature, priority=high
# - Time range: Last 24 hours
```

### Trace Instrumentation

```bash
# View detailed traces
./scripts/trace_operation.sh --operation claim --work-type feature

# Export trace in JSON
./scripts/export_trace.sh --trace-id abc123def | jq '.'

# Analyze trace critical path
./scripts/analyze_critical_path.sh --trace-id abc123def
```

---

## Alerting & Anomalies

### Alert Rules Configuration

```yaml
# prometheus-rules.yaml
groups:
  - name: swarmsh
    interval: 30s
    rules:
      - alert: HighOperationLatency
        expr: histogram_quantile(0.95, rate(swarmsh_operation_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        annotations:
          summary: "High operation latency detected (95th percentile > 500ms)"

      - alert: LowSuccessRate
        expr: rate(swarmsh_operations_total{status="success"}[5m]) < 0.9
        for: 2m
        annotations:
          summary: "Operation success rate below 90%"

      - alert: HighFileLockContention
        expr: rate(swarmsh_flock_wait_seconds[5m]) > 1
        for: 5m
        annotations:
          summary: "High file lock contention detected"

      - alert: WorkQueueBacklog
        expr: swarmsh_work_queue_size > 500
        for: 10m
        annotations:
          summary: "Work queue backlog detected (> 500 items)"

      - alert: MemoryUsageHigh
        expr: process_resident_memory_bytes / (1024*1024) > 2000
        for: 5m
        annotations:
          summary: "Memory usage above 2GB"
```

### Anomaly Detection

```bash
# Configure anomaly detection
export ANOMALY_DETECTION_ENABLED=1
export ANOMALY_DETECTION_SENSITIVITY="high"  # low, medium, high

# Run anomaly detection
./scripts/detect_anomalies.sh --metric operation_latency

# View detected anomalies
./scripts/list_anomalies.sh | jq '.[] | {time, metric, value, severity}'
```

### Alert Notification Integration

```bash
# Slack notifications
export ALERTMANAGER_SLACK_WEBHOOK="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# PagerDuty integration
export ALERTMANAGER_PAGERDUTY_KEY="YOUR_PAGERDUTY_KEY"

# Email notifications
export ALERTMANAGER_EMAIL_FROM="alerts@example.com"
export ALERTMANAGER_EMAIL_TO="ops@example.com"
```

---

## Dashboards & Visualization

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "SwarmSH System Dashboard",
    "panels": [
      {
        "title": "Operations Rate",
        "targets": [
          {
            "expr": "rate(swarmsh_operations_total[5m])",
            "legendFormat": "{{status}}"
          }
        ]
      },
      {
        "title": "Operation Latency (p95)",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(swarmsh_operation_duration_seconds_bucket[5m]))"
          }
        ]
      },
      {
        "title": "Active Agents",
        "targets": [
          {
            "expr": "count(swarmsh_agent_status{status='active'})"
          }
        ]
      },
      {
        "title": "Work Queue Size",
        "targets": [
          {
            "expr": "swarmsh_work_queue_size"
          }
        ]
      }
    ]
  }
}
```

### Real-Time Dashboard

```bash
# Start real-time dashboard
make monitor-24h

# View specific metrics dashboard
./scripts/dashboard_operation_metrics.sh
./scripts/dashboard_agent_status.sh
./scripts/dashboard_telemetry_health.sh

# Export dashboard as HTML
./scripts/export_dashboard.sh --format html > dashboard.html
```

### Custom Visualizations

```bash
# Generate metrics report
./scripts/generate_metrics_report.sh --format pdf > metrics_report.pdf

# Create performance timeline
./scripts/create_timeline_visualization.sh > timeline.svg

# Generate SLA report
./scripts/generate_sla_report.sh --sla 99.9 > sla_report.json
```

---

## Debugging & Troubleshooting

### Debug Mode

```bash
# Enable debug logging
export LOG_LEVEL="debug"
export DEBUG_MODE=1
export PRINT_STACK_TRACES=1

# Run with debug output
LOG_LEVEL=debug ./coordination_helper.sh claim "feature" "test" "high"
```

### Performance Analysis

```bash
# Profile operation
./scripts/profile_operation.sh --operation progress --iterations 1000

# Generate flame graph
./scripts/generate_flamegraph.sh --output flamegraph.html

# View performance hotspots
./scripts/analyze_hotspots.sh
```

### Health Diagnostics

```bash
# Run comprehensive diagnostics
./scripts/run_diagnostics.sh

# Check specific subsystem
./scripts/diagnose_coordination.sh
./scripts/diagnose_telemetry.sh
./scripts/diagnose_agents.sh

# Generate diagnostic report
./scripts/diagnostic_report.sh > diagnostics.json
```

### Log Analysis Tools

```bash
# Search logs for errors
grep "error\|fail" /var/log/swarmsh/swarmsh.log | jq '.'

# Tail logs with filtering
tail -f /var/log/swarmsh/swarmsh.log | grep "level:error"

# Analyze log patterns
./scripts/analyze_log_patterns.sh --period 24h

# Find slowest operations
./scripts/find_slowest_operations.sh --topn 10
```

---

## Monitoring Checklist

- [ ] Set up monitoring stack (Prometheus, Grafana, Jaeger, Loki)
- [ ] Configure metric collection
- [ ] Configure log aggregation
- [ ] Configure trace sampling
- [ ] Set up alerting rules
- [ ] Create dashboards
- [ ] Configure alert notifications
- [ ] Set up anomaly detection
- [ ] Document runbooks
- [ ] Test alert triggering
- [ ] Train team on monitoring

---

<div align="center">

**[Back to Deployment](../DEPLOYMENT_GUIDE.md)** • **[Telemetry Guide](TELEMETRY_GUIDE.md)** • **[Performance Tuning](PERFORMANCE_TUNING.md)**

</div>
