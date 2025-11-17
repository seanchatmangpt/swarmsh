# Integration Patterns Guide

> Patterns and recipes for integrating SwarmSH with external systems, services, and tools.

---

## Table of Contents

1. [Integration Architecture](#integration-architecture)
2. [OpenTelemetry Integration](#opentelemetry-integration)
3. [Metrics & Monitoring Integration](#metrics--monitoring-integration)
4. [Work Queue Integration](#work-queue-integration)
5. [Agent Integration](#agent-integration)
6. [API Integration](#api-integration)
7. [Event-Driven Integration](#event-driven-integration)
8. [Custom Integrations](#custom-integrations)

---

## Integration Architecture

### Integration Points

SwarmSH provides multiple integration points:

```
┌─────────────────────────────────────────┐
│         External Systems                │
├─────────────────────────────────────────┤
│  • Work Queues (Kafka, RabbitMQ, etc)  │
│  • Monitoring (Prometheus, Grafana)     │
│  • Logging (ELK, Datadog, etc)         │
│  • CI/CD (GitHub Actions, Jenkins)      │
│  • Orchestration (Kubernetes, Docker)   │
└─────────────────────────────────────────┘
          ↕ Integration APIs ↕
┌─────────────────────────────────────────┐
│         SwarmSH Core                    │
├─────────────────────────────────────────┤
│  • File-based APIs                      │
│  • JSON data formats                    │
│  • OpenTelemetry spans                  │
│  • Shell command interface              │
│  • HTTP endpoints (optional)            │
└─────────────────────────────────────────┘
```

### Integration Layers

**Layer 1: Data Interfaces**
- JSON files for work items
- Telemetry streams
- Configuration files

**Layer 2: API Interfaces**
- Shell command API (`coordination_helper.sh`)
- HTTP REST endpoints
- gRPC interfaces (optional)

**Layer 3: Event Interfaces**
- OpenTelemetry spans
- File system events
- Message queue events

---

## OpenTelemetry Integration

### Basic OTEL Integration

```bash
# Configure OpenTelemetry export
export OTEL_EXPORTER_OTLP_ENDPOINT="http://collector.example.com:4317"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer YOUR_TOKEN"
export OTEL_EXPORTER_OTLP_TIMEOUT="30000"

# Enable OTEL integration
export OTEL_ENABLED=1

# Verify OTEL connectivity
./scripts/verify_otel_connection.sh
```

### OTEL Collector Configuration

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    send_batch_size: 1024
    timeout: 5s
  attributes:
    actions:
      - key: service.name
        value: swarmsh
        action: upsert
      - key: deployment.environment
        value: production
        action: upsert

exporters:
  jaeger:
    endpoint: "http://jaeger:14250"
  prometheus:
    endpoint: "0.0.0.0:8888"
  logging:
    loglevel: info

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch, attributes]
      exporters: [jaeger, logging]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus, logging]
```

### Span Context Propagation

```bash
# Enable trace context propagation
export OTEL_PROPAGATORS="tracecontext,baggage"

# Set service name
export OTEL_SERVICE_NAME="swarmsh"

# Set resource attributes
export OTEL_RESOURCE_ATTRIBUTES="service.version=1.1.0,deployment.environment=prod"
```

---

## Metrics & Monitoring Integration

### Prometheus Integration

```bash
# Enable Prometheus metrics export
export PROMETHEUS_ENABLED=1
export PROMETHEUS_PORT=9090

# Configure Prometheus scrape config
cat >> prometheus.yml << EOF
scrape_configs:
  - job_name: 'swarmsh'
    static_configs:
      - targets: ['localhost:9090']
    scrape_interval: 15s
    scrape_timeout: 10s
EOF

# Start Prometheus
docker run -d \
  -p 9090:9090 \
  -v $(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

### Grafana Dashboard Integration

```bash
# Add Prometheus data source
curl -X POST http://localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "SwarmSH",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true
  }'

# Import dashboard
curl -X POST http://localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @./dashboards/swarmsh-dashboard.json
```

### Custom Metrics Export

```bash
# Export metrics in Prometheus format
./coordination_helper.sh metrics prometheus > metrics.txt

# Export in JSON format
./coordination_helper.sh metrics json > metrics.json

# Export in CSV format
./coordination_helper.sh metrics csv > metrics.csv
```

---

## Work Queue Integration

### Kafka Integration

```bash
# Configure Kafka topic
export KAFKA_BROKER="kafka:9092"
export KAFKA_TOPIC="swarmsh-work"

# Enable Kafka work queue source
export WORK_QUEUE_SOURCE="kafka"
export KAFKA_CONSUMER_GROUP="swarmsh-group"

# Producer configuration
export KAFKA_COMPRESSION_TYPE="snappy"
export KAFKA_BATCH_SIZE=100
export KAFKA_LINGER_MS=10

# Listen for work items
kafka-console-consumer --bootstrap-server kafka:9092 \
  --topic swarmsh-work \
  --from-beginning
```

### RabbitMQ Integration

```bash
# Configure RabbitMQ
export RABBITMQ_HOST="rabbitmq"
export RABBITMQ_PORT="5672"
export RABBITMQ_QUEUE="swarmsh.work"
export RABBITMQ_EXCHANGE="swarmsh"

# Enable RabbitMQ integration
export WORK_QUEUE_SOURCE="rabbitmq"

# Listen for messages
rabbitmqctl list_queues

# Verify connection
./scripts/verify_rabbitmq_connection.sh
```

### Work Queue Bridge

```bash
# Bridge external work queue to SwarmSH
./scripts/work_queue_bridge.sh \
  --source kafka \
  --broker kafka:9092 \
  --topic work-items \
  --destination swarmsh

# Monitor bridge health
./scripts/monitor_work_queue_bridge.sh
```

---

## Agent Integration

### Process-Based Agents

```bash
# Integrate system processes as agents
./scripts/register_process_agent.sh \
  --pid $PID \
  --role "background_worker" \
  --capacity 100

# Monitor process agent
./scripts/monitor_process_agent.sh --pid $PID
```

### Container Agents

```bash
# Register containerized agents
./scripts/register_container_agent.sh \
  --container-id abc123def \
  --image "agent:latest" \
  --role "ml_worker" \
  --resources.cpu 4 \
  --resources.memory 8GB

# Health check container agent
./scripts/check_container_agent_health.sh --container-id abc123def
```

### Remote Agents

```bash
# Register remote agents (SSH-based)
./scripts/register_remote_agent.sh \
  --host "agent1.example.com" \
  --user "agent" \
  --role "compute_worker" \
  --capacity 50 \
  --ssh-key ~/.ssh/agent_key

# Verify remote agent connectivity
./scripts/verify_remote_agent.sh --host "agent1.example.com"
```

---

## API Integration

### REST API Integration

```bash
# Enable HTTP REST API
export API_ENABLED=1
export API_PORT=8080
export API_BIND="0.0.0.0"

# Start API server
./scripts/start_rest_api.sh

# API endpoints
GET    /api/v1/agents               # List agents
POST   /api/v1/agents               # Register agent
GET    /api/v1/work                 # List work items
POST   /api/v1/work                 # Create work item
PUT    /api/v1/work/{id}/progress   # Update progress
POST   /api/v1/work/{id}/complete   # Complete work

# Example: Claim work via REST
curl -X POST http://localhost:8080/api/v1/work \
  -H "Content-Type: application/json" \
  -d '{
    "type": "feature",
    "description": "Implement feature X",
    "priority": "high"
  }'
```

### gRPC Integration

```bash
# Enable gRPC API
export GRPC_ENABLED=1
export GRPC_PORT=50051

# Start gRPC server
./scripts/start_grpc_api.sh

# Define service (swarmsh.proto)
service CoordinationService {
  rpc ClaimWork(ClaimWorkRequest) returns (ClaimWorkResponse);
  rpc UpdateProgress(UpdateProgressRequest) returns (UpdateProgressResponse);
  rpc CompleteWork(CompleteWorkRequest) returns (CompleteWorkResponse);
}

# Generate gRPC client
grpcurl -plaintext localhost:50051 list
```

### GraphQL Integration

```bash
# Enable GraphQL API
export GRAPHQL_ENABLED=1
export GRAPHQL_PORT=8081

# Start GraphQL server
./scripts/start_graphql_api.sh

# Query example
query {
  agents {
    id
    status
    capacity
  }
  workItems {
    id
    type
    priority
    progress
  }
}
```

---

## Event-Driven Integration

### Webhook Integration

```bash
# Configure webhooks
export WEBHOOK_URL="https://api.example.com/webhooks/swarmsh"
export WEBHOOK_EVENTS="work.claimed,work.completed,agent.registered"

# Verify webhook endpoint
curl -X POST $WEBHOOK_URL \
  -H "Content-Type: application/json" \
  -d '{
    "event": "ping",
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }'

# Listen for webhook events
./scripts/webhook_listener.sh
```

### Event Stream Integration

```bash
# Enable event stream export
export EVENT_STREAM_ENABLED=1
export EVENT_STREAM_ENDPOINT="http://event-broker:8080"

# Subscribe to events
curl -s http://localhost:8080/events \
  | jq '.[] | select(.type=="work.claimed")'
```

### Pub/Sub Integration

```bash
# Configure pub/sub
export PUBSUB_PROVIDER="google"  # google, aws, azure
export PUBSUB_TOPIC="swarmsh-events"

# Publish event to pub/sub
./scripts/publish_event.sh \
  --event "work.completed" \
  --data '{"work_id":"123","status":"success"}'

# Subscribe to events
./scripts/subscribe_events.sh --topic swarmsh-events
```

---

## Custom Integrations

### Custom Integration Template

```bash
#!/bin/bash
# custom_integration.sh - Template for custom integration

INTEGRATION_NAME="my_integration"
INTEGRATION_VERSION="1.0.0"

# Initialize integration
init_integration() {
    log "Initializing $INTEGRATION_NAME v$INTEGRATION_VERSION"

    # Load configuration
    source ./config/${INTEGRATION_NAME}.conf

    # Verify connectivity
    verify_external_service

    # Start event listener
    start_event_listener
}

# Handle work item claimed
on_work_claimed() {
    local work_id=$1
    local work_type=$2

    # Custom logic
    notify_external_system "work_claimed" "$work_id" "$work_type"

    # Log event
    log "Work $work_id claimed via $INTEGRATION_NAME"
}

# Handle work completed
on_work_completed() {
    local work_id=$1
    local status=$2

    # Custom logic
    sync_external_system "$work_id" "$status"

    # Log event
    log "Work $work_id completed via $INTEGRATION_NAME"
}

# Main integration loop
main() {
    init_integration

    # Listen for SwarmSH events
    while true; do
        # Poll for events
        event=$(get_next_event)

        case "$event" in
            work.claimed)
                on_work_claimed "$work_id" "$work_type"
                ;;
            work.completed)
                on_work_completed "$work_id" "$status"
                ;;
        esac
    done
}

main "$@"
```

### Integration Testing

```bash
# Test integration connectivity
./scripts/test_integration.sh --integration $INTEGRATION_NAME

# Run integration tests
make test-integration INTEGRATION=$INTEGRATION_NAME

# Generate integration report
./scripts/integration_report.sh --integration $INTEGRATION_NAME
```

---

## Integration Checklist

- [ ] Identify integration requirements
- [ ] Choose integration pattern
- [ ] Configure external system
- [ ] Set up authentication
- [ ] Test connectivity
- [ ] Enable telemetry
- [ ] Monitor integration health
- [ ] Set up error handling
- [ ] Document integration
- [ ] Create integration tests

---

<div align="center">

**[Back to Architecture](../ARCHITECTURE.md)** • **[API Reference](../API_REFERENCE.md)** • **[Deployment](../DEPLOYMENT_GUIDE.md)**

</div>
