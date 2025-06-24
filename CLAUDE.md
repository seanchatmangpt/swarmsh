# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Principles

- ONLY TRUST THE OPEN TELEMETRY
- Verify all changes with test results and benchmarks
- Use telemetry data to validate operation success

## Project Overview

This is a **Bash-based Agent Coordination System** for managing autonomous AI agent swarms using Scrum at Scale (S@S) methodology. The system provides dual coordination architectures with zero-conflict guarantees through nanosecond-precision IDs and atomic file operations.

## Key Commands

### Testing
```bash
# Run full test suite
make test

# Run with verbose output
make test-verbose

# Run specific test types
make test-unit
make test-integration 
make test-performance

# Run BATS test suite
bats coordination_helper.bats

# Run individual test scripts
./test_coordination_helper.sh
./test_otel_integration.sh
```

### Build & Lint
```bash
# Lint with shellcheck
make lint

# Format scripts
make format

# Check formatting
make format-check

# Full CI pipeline
make ci
```

### Core System Operations
```bash
# Enterprise SAFe Coordination
./coordination_helper.sh help
./coordination_helper.sh dashboard

# Real Agent Process Coordination
./real_agent_coordinator.sh init
./real_agent_coordinator.sh monitor

# Start coordinated agents
nohup ../coordinated_real_agent_worker.sh > /tmp/agent.log 2>&1 &
```

## Architecture

### Core Scripts
- **`coordination_helper.sh`** - Enterprise SAFe coordination with 40+ commands
- **`real_agent_coordinator.sh`** - Real process coordination with atomic claiming
- **`agent_swarm_orchestrator.sh`** - Multi-agent orchestration
- **`quick_start_agent_swarm.sh`** - Rapid swarm deployment

### Data Architecture
- **JSON-based coordination** with atomic file locking using `flock`
- **Nanosecond-precision agent IDs** for mathematical conflict prevention
- **OpenTelemetry distributed tracing** for all operations
- **Dual coordination systems**: Enterprise SAFe and Real Process

### Key Directories
- `agent_coordination/` - Coordination logs and operations data
- `real_agents/` - Agent metrics and execution results
- `real_work_results/` - Completed work outputs
- `docs/` - Comprehensive script documentation (40+ scripts organized by category)
- `metrics/` - Performance metrics data
- `logs/` - System and automation logs

## Dependencies

### Required
- `bash` 4.0+ (shell execution)
- `jq` (JSON processing)
- `python3` (timestamp calculations)

### Optional but Important
- `flock` (atomic file locking - **required for real coordination**)
- `openssl` (trace ID generation)
- `bc` (mathematical calculations)

### Platform Notes
- **macOS**: `flock` not available by default (install via `brew install util-linux`)
- **Linux**: Full `flock` support available
- Set `COORDINATION_MODE="simple"` as fallback without `flock`

## Development Patterns

### Testing Strategy
- Use **BATS (Bash Automated Testing System)** for comprehensive testing
- Test scripts generate **OpenTelemetry traces** for validation
- Individual test scripts for specific components
- Performance validation through real telemetry data

### Coordination Patterns
```bash
# Agent registration with nanosecond ID
export AGENT_ID="agent_$(date +%s%N)"
export AGENT_ROLE="Developer_Agent"

# Work claiming with atomic operations
./coordination_helper.sh claim "implementation" "task_description" "priority"

# Progress tracking with telemetry
./coordination_helper.sh progress "$WORK_ID" 75 "in_progress"
```

### OpenTelemetry Integration
All coordination operations generate distributed traces compatible with:
- Phoenix LiveView dashboard
- XAVOS system monitoring
- N8n workflow orchestration
- Reactor middleware telemetry

## Performance Characteristics

**Measured Performance**:
- **92.6% operation success rate** (validated through telemetry)
- **Sub-100ms coordination operations** (with `flock`)
- **Zero work conflicts** through atomic claiming
- **1,400+ telemetry spans** generated with 100% success rate

**Key Metrics to Monitor**:
- Coordination operation duration
- Work claim conflicts (should be zero)
- Agent capacity utilization
- Telemetry span generation success