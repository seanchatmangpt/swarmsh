# CLAUDE.md — Development Guidance for SwarmSH

> Guidance for developers and AI assistants working with the SwarmSH codebase.
>
> **See also:** [DOCUMENTATION_MAP.md](DOCUMENTATION_MAP.md) for complete documentation index.

**Current Version:** v1.1.0 | **Release Date:** November 16, 2025 | **Last Updated:** November 16, 2025

## Core Principles

- ✅ **ONLY TRUST THE OPEN TELEMETRY** - Verify all changes with telemetry data
- ✅ **Verify all changes with test results and benchmarks** - 80/20 test coverage required
- ✅ **Use telemetry data to validate operation success** - Every operation generates spans
- ✅ **Zero-conflict guarantee through atomic operations** - Nanosecond precision IDs
- ✅ **Performance targets validated** - 42.3ms avg, <100ms target, 92.6% success rate

---

## 📚 Documentation Resources

SwarmSH documentation is organized using the **Diataxis Framework**, making it easy to find what you need:

| Need | Document | Format |
|------|----------|--------|
| **Learning/Tutorials** | [README.md Tutorials](README.md#tutorials) | 4 step-by-step guides |
| **How to solve problems** | [README.md How-To Guides](README.md#how-to-guides) | 6 task-oriented guides |
| **Look up commands/APIs** | [API_REFERENCE.md](API_REFERENCE.md) | Complete reference |
| **Understand concepts** | [README.md Explanations](README.md#explanations) | 8 deep-dive concepts |
| **Find anything** | [DOCUMENTATION_MAP.md](DOCUMENTATION_MAP.md) | Navigation index |

### Key Advanced Guides
- **[ADVANCED_INSTALLATION.md](docs/ADVANCED_INSTALLATION.md)** — Custom, container, Kubernetes deployments
- **[PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)** — Optimization and benchmarking
- **[INTEGRATION_PATTERNS.md](docs/INTEGRATION_PATTERNS.md)** — External system integration
- **[MONITORING_ADVANCED.md](docs/MONITORING_ADVANCED.md)** — Observability deep-dive
- **[SCALABILITY_GUIDE.md](docs/SCALABILITY_GUIDE.md)** — Enterprise scaling

---

## Project Overview

This is a **Bash-based Agent Coordination System** for managing autonomous AI agent swarms using Scrum at Scale (S@S) methodology. The system provides dual coordination architectures with zero-conflict guarantees through nanosecond-precision IDs and atomic file operations.

---

## ⚠️ IMPLEMENTATION STATUS (v1.1.1 Update)

**IMPORTANT:** Read this section to understand what's working vs. what requires setup.

### ✅ FULLY WORKING (No setup required)
- **Work Coordination** — Claim, progress, complete fully functional
- **Telemetry & OpenTelemetry** — 1,572+ real OTEL spans flowing
- **Agent Management** — Registration and tracking working
- **Dashboard & Reporting** — All reports generating correctly
- **Core Tests** — 100% pass rate on coordination tests
- **Nanosecond IDs** — Zero conflict guarantee verified

### ⚠️ REQUIRES SETUP (Scripts ready, deployable)
- **AI/Claude Intelligence** — Install ollama: `brew install ollama` (macOS)
- **Worktree Development** — Deploy 3 ready-made worktrees: `git worktree add ...`
- **8020 Cron Automation** — Install cron: `./cron-setup.sh install` (production)
- **Real Agent Coordination** — See `real_agent_coordinator.sh` (delegates to coordination_helper.sh)

### 📚 Setup Documentation
**See:** [PROJECT_STATUS_AND_NEXT_STEPS.md](PROJECT_STATUS_AND_NEXT_STEPS.md) for detailed setup
**See:** [8020_AUTOMATION_SETUP.md](8020_AUTOMATION_SETUP.md) for automation configuration

---

## v1.1.0-1.1.1 Major Features

### ✅ Fully Implemented & Working
- **Automated Documentation Generation** - ✓ Scripts auto-generate docs in docs/auto_generated/
- **Real Telemetry Dashboard** - ✓ Live visualization with Mermaid diagrams working
- **Enhanced OTEL Integration** - ✓ Trace correlation and distributed tracing verified (1,572+ spans)
- **60+ Makefile Targets** - ✓ 77% functional (70 of 91 targets working)
- **Comprehensive Test Coverage** - ✓ 80/20 optimized, 100% pass on core tests

### ⚠️ Ready But Requires Deployment
- **Git Worktree Workflow** - Scripts ready, 3 worktrees created (deploy complete in v1.1.1)
- **8020 Cron Automation** - Scripts ready, needs `./cron-setup.sh install` in production
- **Claude AI Analysis** - Scripts ready, needs `brew install ollama`

### Key Improvements (v1.1.0 → v1.1.1)
- Documentation accuracy improved (closed gap between promise and implementation)
- Implementation status clearly documented
- real_agent_coordinator.sh created for compatibility
- 8020 automation setup documented for sandbox and production
- Worktrees deployed (3 of 3 ready)
- Clear setup checklist for remaining features

## Key Commands

### Testing (80/20 Optimized)
```bash
# Quick validation (< 1 minute) - RECOMMENDED
make validate

# Essential tests only (80% coverage, 20% complexity)
make test-essential

# Full test suite with telemetry
make test

# Test specific components
make test-unit
make test-integration
make test-performance

# Verify system health and telemetry
make verify

# Real-time monitoring during tests
make monitor-24h

# View test coverage report
cat TEST_COVERAGE_REPORT_v1.1.0.md
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
# Enterprise SAFe Coordination (40+ commands)
./coordination_helper.sh help
./coordination_helper.sh dashboard
./coordination_helper.sh claim "feature" "Description" "priority"

# Real Agent Process Coordination
./real_agent_coordinator.sh init
./real_agent_coordinator.sh monitor

# Worktree Development (NEW in v1.1.0)
make worktree-create FEATURE=feature-name
make worktree-list
make worktree-dashboard
make worktree-merge FEATURE=feature-name

# Telemetry & Monitoring (NEW in v1.1.0)
make telemetry-health          # Quick health check
make diagrams-dashboard        # Live visualization
make monitor-24h              # Real-time monitoring
make telemetry-stats          # Comprehensive stats

# Automated Cron Operations
make cron-install
make cron-status
make cron-test
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

### AI Integration
- **ollama-pro** (Local AI analysis backend)
- **ollama** (LLM inference engine)
- **claude wrapper** (Compatibility layer for Claude CLI calls)

### Platform Notes
- **macOS**: `flock` not available by default (install via `brew install util-linux`)
- **Linux**: Full `flock` support available
- Set `COORDINATION_MODE="simple"` as fallback without `flock`

### AI Configuration
```bash
# Environment variables for AI integration
export OLLAMA_MODEL="qwen3"              # Default model for analysis
export CLAUDE_TIMEOUT="30"              # Timeout in seconds for AI requests
export OLLAMA_HOST="http://localhost:11434"  # Ollama server endpoint

# Test AI integration
./claude --print "test" --output-format json
```

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

### AI Analysis Commands
```bash
# Priority analysis with ollama-pro backend
./coordination_helper.sh claude-analyze-priorities

# Team analysis and optimization
./coordination_helper.sh claude-team-analysis

# System health monitoring
./coordination_helper.sh claude-health-analysis

# AI intelligence dashboard
./coordination_helper.sh claude-dashboard
```

**AI Performance Features**:
- **Response caching** for improved performance (5-minute TTL)
- **30-second timeout** protection with graceful fallbacks
- **Context-aware responses** based on coordination state
- **JSON and stream format** support for structured analysis

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

## 8020 Automation & Telemetry Analysis

### CRITICAL: Data-Driven Decision Making

**ALWAYS use telemetry data to guide your work**. The system generates comprehensive telemetry spans for every operation. Use these commands to understand system behavior:

```bash
# View telemetry statistics across timeframes
./telemetry-timeframe-stats.sh

# Real-time monitoring (defaults to 24h window)
make monitor-24h      # Monitor last 24 hours
make monitor-7d       # Monitor last 7 days
make monitor-all      # Monitor all data

# Generate visual dashboards from live data
make diagrams         # Generate all diagrams (24h default)
make diagrams-24h     # Last 24 hours
make diagrams-7d      # Last 7 days
make diagrams-all     # All available data

# Check specific telemetry data
tail -n 100 telemetry_spans.jsonl | jq '.'
```

### 8020 Principle Implementation

The system implements the Pareto Principle (80/20 rule) for maximum efficiency:

1. **Tier 1 Operations (5% effort, 60% value)**:
   - Health monitoring (every 15 min)
   - Work queue optimization (every 4h)
   - Telemetry management (every 4h)

2. **Tier 2 Operations (15% effort, 20% value)**:
   - Performance metrics collection
   - Agent status synchronization
   - Automated cleanup routines

3. **Intelligent Scheduling**:
   - Frequency adjusts based on system health
   - Lower health scores trigger more frequent checks
   - All decisions logged in telemetry

### Using Telemetry to Guide Work

**Before making any changes or claims**:

1. **Check Current System State**:
   ```bash
   # View live dashboard
   ./auto-generate-mermaid.sh dashboard
   
   # Check health status
   cat system_health_report.json | jq '.'
   
   # Monitor active operations
   ./realtime-telemetry-monitor.sh 24h 60  # Update every 60s
   ```

2. **Analyze Recent Activity**:
   ```bash
   # What operations are most frequent?
   ./telemetry-timeframe-stats.sh
   
   # Are there any failures?
   grep -i "error\|fail" telemetry_spans.jsonl | tail -20 | jq '.'
   
   # What's the current operation rate?
   # High rate = system busy, Low rate = possible issues
   ```

3. **Make Data-Driven Decisions**:
   - If health < 70: Focus on fixing issues first
   - If operation rate drops: Check automation status
   - If telemetry shows errors: Investigate root cause

### Automation Status Verification

**Always verify automation is running correctly**:

```bash
# Check cron jobs
make cron-status

# Verify recent automation runs
grep "8020_cron_log" telemetry_spans.jsonl | tail -10 | jq '.'

# Check automation health
./cron-health-monitor.sh

# View automation performance report
cat telemetry_performance_report.json | jq '.'
```

### Key Files to Monitor

- **`telemetry_spans.jsonl`** - All system operations (filter by timeframe)
- **`system_health_report.json`** - Current health score and issues
- **`telemetry_performance_report.json`** - Performance metrics
- **`work_claims.json`** - Active work items
- **`docs/auto_generated_diagrams/`** - Visual system state

### Best Practices

1. **Trust Only Verified Data**:
   - Never assume operations succeeded
   - Always check telemetry spans
   - Validate with `grep`, `jq`, and monitoring tools

2. **Use Time Windows Effectively**:
   - Default to 24h for current state
   - Use 7d for trend analysis
   - Use 'all' only when investigating historical issues

3. **Monitor Before Acting**:
   - Run `make telemetry-stats` before major changes
   - Check `make diagrams-dashboard` for visual overview
   - Use `make monitor-24h` during active development

4. **Validate Automation**:
   - Ensure cron jobs are active: `crontab -l | grep 8020`
   - Check recent runs: `ls -la *_report.json`
   - Monitor span generation rate

### Example Workflow

```bash
# 1. Start your work session
make telemetry-stats          # Understand current state
make diagrams-dashboard       # Visual overview

# 2. Monitor while working
make monitor-24h              # In another terminal

# 3. Before claiming work
./coordination_helper.sh dashboard
./coordination_helper.sh list-work

# 4. After making changes
make validate                 # Run tests
grep "your_operation" telemetry_spans.jsonl | jq '.'  # Verify

# 5. Generate reports
make diagrams                 # Update all visualizations
```

### Performance Optimization Indicators

Watch for these patterns in telemetry:

- **Healthy System**: 80+ health score, steady operation rate
- **Needs Attention**: 60-79 health, fluctuating rates
- **Critical**: <60 health, dropping operation counts
- **Overloaded**: Very high operation rates, increasing errors

Remember: **Every decision should be backed by telemetry data!**

## Additional Resources

- **[Quick Reference Card](docs/QUICK_REFERENCE.md)** - Essential commands for daily use
- **[Telemetry Guide](docs/TELEMETRY_GUIDE.md)** - Deep dive into telemetry analysis
- **[8020 Cron Features](docs/8020_CRON_FEATURES.md)** - Automation documentation
- **[8020 Gantt Charts](docs/8020_CRON_GANTT.md)** - Visual timeline planning

## Start Here

When beginning work on this codebase, ALWAYS run these commands first:

```bash
# 1. Understand system state
make telemetry-stats

# 2. Check health
cat system_health_report.json | jq '.health_score'

# 3. View dashboard
make diagrams-dashboard

# 4. Start monitoring (in separate terminal)
make monitor-24h
```

Only proceed with work after understanding the current system state from telemetry!