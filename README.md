# Agent Coordination System (SwarmSH)

Enterprise-grade coordination framework for autonomous AI agent swarms with dual coordination architectures for zero-conflict work execution.

## Quick Start

```bash
# Enterprise SAFe Coordination (JSON-based)
./coordination_helper.sh claim "implementation" "Your task" "high"
./coordination_helper.sh dashboard

# Real Agent Process Coordination (atomic locking)
./real_agent_coordinator.sh init
./real_agent_coordinator.sh monitor
```

## Core Components

### 🏢 Enterprise SAFe Coordination (`coordination_helper.sh`)
JSON-based coordination with 40+ commands, nanosecond-precision agent IDs, and AI analysis integration via ollama-pro.

```bash
./coordination_helper.sh register 100 "active" "backend_team"
./coordination_helper.sh claim "development" "Optimize queries" "high"
./coordination_helper.sh complete "$WORK_ID" "success" 8
```

### ⚡ Real Agent Process Coordination (`real_agent_coordinator.sh`)  
Distributed work queue with atomic claiming and real process execution.

```bash
./real_agent_coordinator.sh add "optimization" "high" "perf_test" "2500"
CLAIMED_WORK=$(./real_agent_coordinator.sh claim "$AGENT_ID" "$$")
./real_agent_coordinator.sh complete "$AGENT_ID" "$CLAIMED_WORK" "1250" "result.json"
```

## Dependencies

**Required**: `bash` 4.0+, `jq`, `python3`  
**Critical**: `flock` (atomic locking - install `util-linux` on macOS)  
**AI Integration**: `ollama-pro`, `ollama` (local LLM backend)

## Quick Troubleshooting

**"flock: command not found"** (macOS)
```bash
brew install util-linux
```

**Permission errors**
```bash
chmod +x *.sh && mkdir -p real_agents real_work_results
```

**AI integration setup**
```bash
# Test ollama-pro integration
./claude --print "test" --output-format json

# Run AI analysis
./coordination_helper.sh claude-analyze-priorities
```

**8020 Automation setup**
```bash
# Install high-impact automated monitoring (80/20 principle)
./8020_cron_automation.sh install

# Manual health check
./8020_cron_automation.sh health
```

## Performance
- **Sub-100ms coordination** operations with flock
- **Zero work conflicts** through atomic claiming  
- **1,400+ telemetry spans** with 100% success rate
- **5+ concurrent agents** supported
- **100/100 health scores** with 8020 automation (sub-50ms monitoring)

## Documentation

- 📖 **[API Reference](API_REFERENCE.md)** - Complete command reference
- 🚀 **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Installation & setup
- ⚙️ **[Configuration](CONFIGURATION_REFERENCE.md)** - All config options
- 🔧 **[Troubleshooting](TROUBLESHOOTING.md)** - Common issues & solutions
- 🏗️ **[Architecture](ARCHITECTURE.md)** - System design & data flows
- 👥 **[Contributing](CONTRIBUTING.md)** - Developer guide
- 🤖 **[8020 Automation Report](docs/8020_CRON_AUTOMATION_REPORT.md)** - Automated monitoring & optimization

## Integration

Compatible with OpenTelemetry, Phoenix LiveView, XAVOS, N8n workflows, and local AI intelligence via ollama-pro with response caching and timeout protection.

---
Part of the AI Self-Sustaining System enterprise coordination framework.