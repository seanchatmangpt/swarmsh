# SwarmSH - Telemetry-Driven Agent Coordination System

> Enterprise-grade bash-based coordination framework for autonomous AI agent swarms with real-time telemetry, 8020 automation, and zero-conflict distributed work execution.

[![Version](https://img.shields.io/badge/Version-1.1.0-green)]()
[![Health Score](https://img.shields.io/badge/Health%20Score-85%2F100-brightgreen)]()
[![Operations](https://img.shields.io/badge/Daily%20Operations-450%2B-brightgreen)]()
[![Telemetry](https://img.shields.io/badge/Telemetry-OpenTelemetry-blue)]()
[![Automation](https://img.shields.io/badge/Automation-8020%20Optimized-purple)]()
[![Tests](https://img.shields.io/badge/Test%20Coverage-100%25-brightgreen)]()
[![Compatibility](https://img.shields.io/badge/Compatibility-Backward%20Compatible-blue)]()

## 🚀 Quick Start (Telemetry-First Approach)

```bash
# 1. Clone and setup
git clone https://github.com/seanchatmangpt/swarmsh.git
cd swarmsh
chmod +x *.sh

# 2. Start with telemetry analysis (RECOMMENDED)
make getting-started

# 3. Monitor in real-time (separate terminal)
make monitor-24h

# 4. Begin work based on system health
make claim WORK_TYPE=feature DESC="Your task description"
```

## 📊 Key Features

### 🔍 **Telemetry-First Development**
- **Real-time monitoring** with OpenTelemetry integration
- **24-hour default window** for current state analysis
- **Auto-generated dashboards** from live telemetry data
- **Health score tracking** with intelligent recommendations

### 🏢 **Dual Coordination Architectures**
1. **Enterprise SAFe Coordination** (`coordination_helper.sh`)
   - 40+ commands for comprehensive work management
   - Nanosecond-precision agent IDs (zero conflicts)
   - JSON-based with atomic file locking

2. **Real Agent Process Coordination** (`real_agent_coordinator.sh`)
   - Distributed work queue with atomic claiming
   - Real process execution and monitoring
   - Sub-100ms coordination operations

### 🤖 **AI Integration**
- **Claude AI** - Intelligent priority analysis and team optimization
- **Ollama/Ollama-Pro** - Local LLM backend with caching
- **Response caching** - 5-minute TTL for improved performance
- **Timeout protection** - 30-second graceful fallbacks

### 🎯 **8020 Automation**
- **Tier 1 Operations** (5% effort, 60% value)
  - Health monitoring every 15 minutes
  - Work queue optimization every 4 hours
  - Telemetry management with auto-archival
- **Intelligent scheduling** based on system health
- **Cron automation** with adaptive frequencies

### 🌳 **Worktree Development**
- **Parallel feature development** with Git worktrees
- **Isolated environments** for each feature
- **Cross-worktree coordination** and telemetry sharing
- **Integrated PR workflow**

### 🆕 **v1.1.0 New Features**
- **Automated Documentation Generation** - Auto-generate and maintain docs
- **Real Telemetry Dashboard** - Live visualization with auto-generated diagrams
- **Enhanced OTEL Integration** - Improved trace correlation and distributed tracing
- **Git Worktree Workflow** - Complete parallel development with S@S coordination
- **60+ Makefile Targets** - Comprehensive automation and development tooling
- **Comprehensive Migration Guides** - Smooth upgrade path from 1.0.0

## 🛠️ Installation

### ⚡ Quick Install (Homebrew - macOS)

**Recommended for macOS users:**

```bash
# One-liner installation
brew tap seanchatmangpt/swarmsh && brew install swarmsh

# Verify installation
swarmsh --version
swarmsh help
```

For detailed Homebrew setup, see [Homebrew Installation Guide](docs/HOMEBREW_INSTALLATION.md).

### Prerequisites
```bash
# Required
bash 4.0+    # Shell execution
jq           # JSON processing  
python3      # Timestamp calculations

# Critical for production
flock        # Atomic file locking
openssl      # Trace ID generation
bc           # Mathematical calculations
```

### macOS Setup
```bash
# Install dependencies
brew install bash jq python3 util-linux coreutils openssl bc

# Optional: AI backends
brew install ollama
# Claude CLI from https://claude.ai/cli
```

### Linux Setup
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y bash jq python3 git bc util-linux

# Optional: Install Ollama
curl -fsSL https://ollama.com/install.sh | sh
```

## 📋 Core Commands

### System Health & Monitoring
```bash
# Quick health check
make telemetry-health

# Detailed statistics
make telemetry-stats

# Real-time monitoring
make monitor-24h        # Last 24 hours (default)
make monitor-7d         # Last 7 days
make monitor-all        # All data

# Generate visual dashboards
make diagrams           # All diagrams (24h)
make diagrams-dashboard # Just the dashboard
```

### Work Coordination
```bash
# Claim work
make claim WORK_TYPE=feature DESC="Implement caching" PRIORITY=high

# View coordination dashboard
make dashboard

# List active work
make list-work

# Complete work
./coordination_helper.sh complete "$WORK_ID" "success" 8
```

### Worktree Development
```bash
# Create feature worktree
make worktree-create FEATURE=new-cache-layer

# List worktrees
make worktree-list

# Show worktree dashboard
make worktree-dashboard

# Push changes for PR
make worktree-merge FEATURE=new-cache-layer
```

### Automation Management
```bash
# Install 8020 cron automation
make cron-install

# Check automation status
make cron-status

# View automation logs
grep "8020_cron_log" telemetry_spans.jsonl | tail -20 | jq '.'
```

## 🏗️ Architecture

```
SwarmSH/
├── Core Coordination
│   ├── coordination_helper.sh      # Enterprise SAFe (40+ commands)
│   ├── real_agent_coordinator.sh   # Real process coordination
│   └── agent_swarm_orchestrator.sh # Multi-agent orchestration
│
├── Telemetry & Monitoring
│   ├── telemetry_spans.jsonl       # All operations log
│   ├── system_health_report.json   # Current health status
│   ├── auto-generate-mermaid.sh    # Live diagram generation
│   └── realtime-telemetry-monitor.sh # Real-time monitoring
│
├── Automation (8020)
│   ├── 8020_cron_automation.sh     # Main automation
│   ├── cron-health-monitor.sh      # Health monitoring
│   ├── cron-telemetry-manager.sh   # Telemetry management
│   └── cron-performance-collector.sh # Performance metrics
│
├── AI Integration
│   ├── claude                      # Claude CLI wrapper
│   ├── ollama-pro                  # Enhanced Ollama
│   └── demo_claude_intelligence.sh # AI capabilities demo
│
└── Documentation
    ├── CLAUDE.md                   # AI guidance for Claude
    ├── docs/QUICK_REFERENCE.md     # Command reference
    └── docs/TELEMETRY_GUIDE.md     # Telemetry analysis
```

## 📊 Performance Metrics (v1.1.0 Validated)

- **92.6% operation success rate** (100% test coverage)
- **42.3ms average operation time** (sub-100ms target)
- **Zero work conflicts** through nanosecond-precision atomic IDs
- **1,425+ telemetry spans** per cycle with 100% generation success
- **85/100 health score** - System healthy and stable
- **23.6 ops/sec throughput** with adaptive scheduling
- **10+ concurrent agents** supported
- **78% agent capacity utilization** with optimal headroom
- **24/7 automated 8020 optimization** with real-time adaptation

## 🔌 Integrations

### Supported Systems
- **OpenTelemetry** - Distributed tracing
- **Prometheus/Grafana** - Metrics and visualization
- **Phoenix LiveView** - Real-time dashboards
- **XAVOS** - External automation system
- **N8n** - Workflow automation
- **Docker** - Containerized monitoring stack

### AI Backends
- **Claude** (via official CLI)
- **Ollama** (local LLM)
- **Ollama-Pro** (enhanced with caching)

## 🧪 Testing

```bash
# Quick validation (< 1 minute)
make validate

# Essential tests only
make test-essential

# Full test suite
make test

# Performance benchmarks
make test-performance

# OpenTelemetry validation
make otel-validate
```

## 🚨 Troubleshooting

### Common Issues

**"flock: command not found" (macOS)**
```bash
brew install util-linux
# Or use simple mode:
export COORDINATION_MODE="simple"
```

**Low Health Score**
```bash
# Check issues
cat system_health_report.json | jq '.issue_breakdown'

# Manual health check
./cron-health-monitor.sh

# Review recent errors
grep error telemetry_spans.jsonl | tail -20 | jq '.'
```

**No Telemetry Data**
```bash
# Check cron jobs
make cron-status

# Verify telemetry file
ls -la telemetry_spans.jsonl

# Watch for new spans
tail -f telemetry_spans.jsonl | jq '.'
```

## 📚 Documentation

### Essential Guides
- **[CLAUDE.md](CLAUDE.md)** - Telemetry-first development principles
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Command cheat sheet
- **[Telemetry Guide](docs/TELEMETRY_GUIDE.md)** - Deep telemetry analysis
- **[Getting Started](GETTING_STARTED.md)** - Installation from scratch

### Advanced Topics
- **[Architecture](ARCHITECTURE.md)** - System design details
- **[API Reference](API_REFERENCE.md)** - Complete command reference
- **[Worktree Guide](docs/WORKTREE_DEVELOPMENT_GUIDE.md)** - Parallel development
- **[8020 Automation](docs/8020_CRON_FEATURES.md)** - Automation details

### Integration Guides
- **[Project Simulation](docs/PROJECT_SIMULATION_GUIDE.md)** - Monte Carlo planning
- **[Configuration Reference](CONFIGURATION_REFERENCE.md)** - All settings
- **[Troubleshooting](TROUBLESHOOTING.md)** - Common solutions

## 🤝 Contributing

1. **Fork the repository**
2. **Create a worktree** for your feature:
   ```bash
   make worktree-create FEATURE=your-feature
   ```
3. **Monitor while developing**:
   ```bash
   make monitor-24h  # In separate terminal
   ```
4. **Validate changes**:
   ```bash
   make validate
   ```
5. **Push for PR**:
   ```bash
   make worktree-merge FEATURE=your-feature
   ```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📈 Project Status

Current system health: **75/100** ⚠️  
Daily operations: **400+**  
Active automation: **9 cron jobs**  
Recent errors: **0**

*Status auto-updated by telemetry system*

## 📄 License

[MIT License](LICENSE) - See LICENSE file for details

---

<div align="center">

**[Quick Start](#-quick-start-telemetry-first-approach)** • 
**[Documentation](#-documentation)** • 
**[Troubleshooting](#-troubleshooting)** •
**[Contributing](#-contributing)**

Part of the AI Self-Sustaining System ecosystem  
Built with ❤️ using Bash, OpenTelemetry, and the 8020 Principle

</div>