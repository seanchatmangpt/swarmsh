# SwarmSH Technical Documentation

## Development Guidelines

### Shell Script Standards

All SwarmSH scripts follow strict standards for maintainability and AI comprehension:

1. **Sparse Priming Representation (SPR)**
   - Each script is self-contained and purpose-specific
   - Comprehensive header documentation with usage examples
   - Structured error handling and logging
   - OpenTelemetry span emission for observability

2. **Naming Conventions**
   - `[purpose]_[component].sh` for single-purpose scripts
   - `coordination_helper.sh` for the central coordination kernel
   - `real_agent_*` prefix for actual process execution scripts
   - `test_*` prefix for validation and testing scripts

3. **Error Handling**
   - Graceful degradation when dependencies unavailable
   - Fallback mechanisms for AI service failures
   - Comprehensive logging to operation logs
   - Exit codes that indicate specific failure modes

### JSON Data Structures

#### Work Claims Format
```json
{
  "id": "W1703875200123456789",
  "agent_id": "agent_1703875200123456789", 
  "work_type": "implementation",
  "description": "Optimize database queries",
  "priority": "high",
  "team": "backend_development",
  "status": "claimed",
  "claimed_at": "2024-12-29T15:20:00.123456789Z",
  "progress": 0,
  "estimated_effort": 8
}
```

#### Agent Status Format
```json
{
  "agent_id": "agent_1703875200123456789",
  "agent_role": "Developer_Agent", 
  "team": "backend_development",
  "capacity": 100,
  "status": "active",
  "registered_at": "2024-12-29T15:20:00.123456789Z",
  "last_seen": "2024-12-29T15:25:00.123456789Z",
  "completed_work": 5,
  "success_rate": 0.926
}
```

#### OpenTelemetry Span Format
```json
{
  "trace_id": "1234567890abcdef1234567890abcdef",
  "span_id": "1234567890abcdef",
  "parent_span_id": "fedcba0987654321",
  "operation_name": "coordination.claim_work",
  "start_time": "2024-12-29T15:20:00.123456789Z",
  "end_time": "2024-12-29T15:20:00.235678901Z", 
  "duration_ms": 112,
  "tags": {
    "agent_id": "agent_1703875200123456789",
    "work_type": "implementation",
    "success": true
  }
}
```

## Business Domain Information

### Scrum@Scale Implementation

SwarmSH implements a complete Scrum@Scale framework optimized for AI agent coordination:

#### Core Roles
- **Product Owner (PO)**: Represented by priority analysis algorithms and Claude AI
- **Scrum Master (SM)**: Implemented as coordination facilitation scripts
- **Development Team**: AI agents with specific capabilities and capacity
- **Scrum of Scrums Master (SoSM)**: Cross-team coordination automation

#### Ceremonies as Code
1. **Sprint Planning**: Automated capacity planning and work distribution
2. **Daily Scrum**: Real-time status synchronization via JSON state
3. **Sprint Review**: Automated velocity calculation and outcome analysis  
4. **Sprint Retrospective**: Performance metric analysis and improvement identification
5. **Scrum of Scrums**: Cross-team dependency resolution and impediment handling
6. **MetaScrum**: Strategic alignment and resource optimization
7. **PI Planning**: Portfolio-level coordination and quarterly planning

### Enterprise Portfolio Management

#### Portfolio Kanban
- **Epic Management**: Large work items spanning multiple teams
- **Feature Breakdown**: Decomposition into agent-executable tasks
- **Dependency Tracking**: Cross-team coordination requirements
- **Value Stream Mapping**: End-to-end delivery pipeline optimization

#### Metrics and KPIs
- **Velocity Tracking**: Story points completed per sprint/agent
- **Lead Time**: Time from work creation to completion
- **Cycle Time**: Time from work start to completion  
- **Throughput**: Work items completed per time period
- **Quality Metrics**: Success rate and defect escape rate

## Technical Implementation Details

### Atomic Operations

SwarmSH ensures coordination integrity through:

1. **File Locking**: Using `flock` for atomic JSON updates
2. **Nanosecond Timestamps**: Preventing ID collisions across concurrent agents
3. **JSON Schema Validation**: Ensuring data structure consistency
4. **Transaction Semantics**: All-or-nothing work claiming operations

### AI Integration Patterns

#### Claude API Integration
```bash
# Priority analysis with structured output
./claude-analyze-priorities.sh < work_claims.json

# Team formation recommendations  
./claude-team-analysis.sh < agent_status.json

# Health assessment and anomaly detection
./claude-health-analysis.sh < coordination_log.json
```

#### Local LLM Integration (Ollama)
```bash
# Offline capability for air-gapped environments
echo "Analyze sprint velocity trends" | ollama run claude:latest

# Real-time decision support
./intelligent_completion_engine.sh --model ollama --prompt-file priority_analysis.txt
```

### Observability Architecture

#### Distributed Tracing
- **Trace Context Propagation**: W3C-compliant trace headers
- **Span Correlation**: Parent-child relationships across operations
- **Cross-Service Tracing**: Integration with XAVOS and Phoenix systems
- **Performance Analysis**: Operation timing and bottleneck identification

#### Metrics Collection
- **Operation Counters**: Success/failure rates by operation type
- **Latency Histograms**: Response time distributions
- **Resource Utilization**: Agent capacity and throughput metrics
- **Business Metrics**: Velocity, quality, and delivery predictability

### Integration Protocols

#### XAVOS System Integration
- **Phoenix LiveView**: Real-time dashboard integration
- **Ash Framework**: Resource and action integration patterns
- **Reactor Telemetry**: Middleware integration for request tracing
- **N8n Workflows**: Cross-system orchestration protocols

#### Git Worktree Management
- **Environment Isolation**: Agent-specific development environments
- **Port Allocation**: Dynamic port assignment for services
- **Configuration Management**: Environment-specific settings
- **Resource Cleanup**: Automated environment teardown

## Troubleshooting Guide

### Common Issues

#### File Locking Problems
**Symptom**: "flock: command not found" on macOS
**Solution**: 
```bash
# Install via Homebrew
brew install util-linux

# Alternative: Use simplified coordination mode
export COORDINATION_MODE="simple"
```

#### Claude AI Integration Failures
**Symptom**: 100% failure rate for Claude commands
**Root Cause**: API connectivity or authentication issues
**Mitigation**: System operates with fallback analysis algorithms

#### JSON Corruption
**Symptom**: Invalid JSON errors during coordination operations
**Recovery**:
```bash
# Backup corrupted files
cp work_claims.json work_claims.json.corrupted

# Initialize fresh coordination state  
./coordination_helper.sh init

# Manually recover valid work items from backup
```

#### Performance Degradation
**Symptom**: Slow coordination operations (>1s)
**Diagnosis**:
```bash
# Check file sizes
ls -lh *.json *.jsonl

# Monitor disk I/O
iotop -p $(pgrep coordination_helper)

# Analyze telemetry bottlenecks
./realtime_performance_monitor.sh
```

### Performance Optimization

#### Memory Management
- Limit concurrent agents based on system capacity
- Regular cleanup of telemetry files using `comprehensive_cleanup.sh`
- Monitor `real_work_results/` directory for size growth
- Implement log rotation for JSONL files

#### Coordination Optimization
- Verify `flock` availability for atomic operations
- Split large JSON files (>10MB) into archived segments
- Use SSD storage for coordination data files
- Optimize JSON parsing with `jq` compiled filters

### Monitoring and Alerting

#### Health Checks
```bash
# Coordination system health
./reality_verification_engine.sh --health-check

# Agent swarm status
./agent_swarm_orchestrator.sh status

# Performance monitoring
./realtime_performance_monitor.sh --dashboard
```

#### Key Metrics to Monitor
- **Coordination Success Rate**: Target >95%
- **Operation Latency**: Target <100ms for claim operations
- **Agent Utilization**: Target 70-90% capacity
- **Work Queue Depth**: Alert if >50 pending items
- **Telemetry Gap Detection**: Alert on missing spans

## Best Practices

### Agent Development
1. **Idempotent Operations**: Ensure agents can safely retry work
2. **Progress Reporting**: Regular status updates during long operations
3. **Resource Cleanup**: Proper cleanup on failure or completion
4. **Error Propagation**: Meaningful error messages in telemetry

### Coordination Patterns
1. **Work Decomposition**: Break large items into agent-sized chunks
2. **Dependency Management**: Explicit dependency declaration and tracking
3. **Capacity Planning**: Realistic effort estimation and capacity allocation
4. **Quality Gates**: Validation checkpoints before work completion

### System Administration
1. **Regular Backups**: Automated backup of coordination state
2. **Log Rotation**: Prevent unbounded growth of telemetry files
3. **Performance Monitoring**: Proactive monitoring of system health
4. **Version Control**: All coordination scripts under version control
5. **Documentation**: Keep technical documentation synchronized with code changes
