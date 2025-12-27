# SwarmSH Documentation Map

> Complete guide to SwarmSH documentation organized by the Diataxis framework and use cases.

---

## 🗺️ Quick Navigation

**First time here?** Start with [Getting Started Path](#getting-started-path)
**Already familiar?** Jump to [Reference](#reference-documentation)
**Building with SwarmSH?** See [Advanced Development](#advanced-development)
**Managing production?** Go to [Operations](#operations--deployment)

---

## 📚 Documentation Organized by Diataxis Framework

The SwarmSH documentation follows the **Diataxis framework**, which organizes content into four categories based on user needs:

### 🎓 TUTORIALS — Learning-Oriented

Tutorials teach you by guiding you through practical steps. Start here if you're new to SwarmSH.

| File | Purpose | Best For |
|------|---------|----------|
| **[README.md](README.md)** | Core tutorials 1-4 | Getting started from scratch |
| **[docs/QUICK_START.md](docs/QUICK_START.md)** | 10-minute hands-on | Impatient learners |
| **[GETTING_STARTED.md](GETTING_STARTED.md)** | Detailed setup guide | Complete setup walkthrough |
| **[docs/HOMEBREW_INSTALLATION.md](docs/HOMEBREW_INSTALLATION.md)** | macOS package install | Homebrew users |
| **[docs/MIGRATION_1.0_TO_1.1.md](docs/MIGRATION_1.0_TO_1.1.md)** | Upgrading from v1.0 | Existing users upgrading |

### 📖 HOW-TO GUIDES — Task-Oriented

How-to guides help you accomplish specific goals. Use these when you know what you want to do.

| File | Purpose | Best For |
|------|---------|----------|
| **[README.md](README.md)** | How-to guides 1-6 | Common tasks |
| **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** | Solving problems | When things break |
| **[CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)** | Configuration recipes | Setting things up |
| **[docs/WORKTREE_DEVELOPMENT_GUIDE.md](docs/WORKTREE_DEVELOPMENT_GUIDE.md)** | Git worktree workflow | Parallel development |
| **[docs/CRON_AUTOMATION_GUIDE.md](docs/CRON_AUTOMATION_GUIDE.md)** | Automation setup | Scheduling operations |
| **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** | Production deployment | Going to production |
| **[docs/INTEGRATION_PATTERNS.md](docs/INTEGRATION_PATTERNS.md)** | External system integration | Connecting other tools |
| **[docs/PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)** | Optimization recipes | Making it faster |

### 📋 REFERENCE — Information-Oriented

Reference documentation provides complete technical details. Use these to look up specific information.

| File | Purpose | Best For |
|------|---------|----------|
| **[README.md](README.md)** | Core command reference | Quick command lookup |
| **[API_REFERENCE.md](API_REFERENCE.md)** | Complete API documentation | All coordination_helper.sh commands |
| **[CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)** | All environment variables | Configuration details |
| **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** | One-page cheat sheet | CLI reference card |
| **[CLAUDE.md](CLAUDE.md)** | Development guidance | Development patterns |
| **[CHANGELOG.md](CHANGELOG.md)** | Version history | What changed |

### 🧠 EXPLANATIONS — Understanding-Oriented

Explanations provide conceptual knowledge and deep understanding. Read these to understand *why*.

| File | Purpose | Best For |
|------|---------|----------|
| **[README.md](README.md)** | Core concepts 1-8 | Foundational understanding |
| **[ARCHITECTURE.md](ARCHITECTURE.md)** | System design details | How the system works |
| **[docs/TELEMETRY_GUIDE.md](docs/TELEMETRY_GUIDE.md)** | Telemetry deep-dive | Understanding observability |
| **[AGENT_SWARM_OPERATIONS_GUIDE.md](AGENT_SWARM_OPERATIONS_GUIDE.md)** | Swarm management concepts | Agent coordination theory |
| **[SYSTEM_COMPOSITION_OVERVIEW.md](SYSTEM_COMPOSITION_OVERVIEW.md)** | Component overview | System organization |

---

## 🎯 Documentation by User Path

### Getting Started Path
*For first-time users learning SwarmSH*

1. **[README.md - Navigation Guide](README.md#navigation-guide)** (2 min)
   - Understand the documentation structure

2. **[README.md - Tutorial 1: Getting Started in 5 Minutes](README.md#tutorial-1-getting-started-in-5-minutes)** (5 min)
   - Basic installation and first commands

3. **[GETTING_STARTED.md](GETTING_STARTED.md)** (15 min)
   - Detailed setup for your platform

4. **[README.md - Tutorial 2: Your First Agent Coordination](README.md#tutorial-2-your-first-agent-coordination)** (10 min)
   - Register agents and claim work

5. **[README.md - Tutorial 3: Setting Up Telemetry Monitoring](README.md#tutorial-3-setting-up-telemetry-monitoring)** (10 min)
   - Monitor your system

6. **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** (5 min)
   - Command cheat sheet for reference

**Total Time: ~45 minutes to productivity**

### Agent Coordination Path
*For developers coordinating AI agents*

1. **[README.md - Tutorial 2](README.md#tutorial-2-your-first-agent-coordination)** - Agent basics
2. **[README.md - How-To 1](README.md#how-to-claim-and-complete-work-items)** - Claiming work
3. **[API_REFERENCE.md](API_REFERENCE.md)** - Complete command reference
4. **[AGENT_SWARM_OPERATIONS_GUIDE.md](AGENT_SWARM_OPERATIONS_GUIDE.md)** - Advanced concepts
5. **[README.md - Explanations](README.md#explanations)** - Understanding coordination

### Telemetry & Monitoring Path
*For operators monitoring system health*

1. **[README.md - Tutorial 3](README.md#tutorial-3-setting-up-telemetry-monitoring)** - Telemetry basics
2. **[README.md - How-To 2](README.md#how-to-monitor-system-health)** - Health monitoring
3. **[docs/TELEMETRY_GUIDE.md](docs/TELEMETRY_GUIDE.md)** - Advanced telemetry
4. **[CLAUDE.md - 8020 Automation](CLAUDE.md#8020-automation--telemetry-analysis)** - Automation patterns
5. **[docs/CRON_AUTOMATION_GUIDE.md](docs/CRON_AUTOMATION_GUIDE.md)** - Scheduling setup

### Worktree Development Path
*For developers using parallel feature development*

1. **[README.md - Tutorial 4](README.md#tutorial-4-creating-your-first-worktree)** - Worktree basics
2. **[docs/WORKTREE_DEVELOPMENT_GUIDE.md](docs/WORKTREE_DEVELOPMENT_GUIDE.md)** - Complete guide
3. **[README.md - How-To 1](README.md#how-to-claim-and-complete-work-items)** - Claiming work in worktrees
4. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution workflow

### Automation & 8020 Path
*For those implementing the 8020 principle*

1. **[README.md - How-To 3](README.md#how-to-set-up-8020-automation)** - Automation setup
2. **[AUTOMATION_GUIDE_8020.md](AUTOMATION_GUIDE_8020.md)** - Detailed guide
3. **[docs/CRON_AUTOMATION_GUIDE.md](docs/CRON_AUTOMATION_GUIDE.md)** - Cron setup
4. **[README.md - Explanations](README.md#understanding-the-8020-automation)** - Why 8020 works
5. **[docs/8020_CRON_FEATURES.md](docs/8020_CRON_FEATURES.md)** - Feature details

### Deployment Path
*For deploying SwarmSH to production*

1. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Deployment options
2. **[CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)** - All configuration options
3. **[docs/PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)** - Performance optimization
4. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues
5. **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture

### Integration Path
*For integrating SwarmSH with external systems*

1. **[README.md - How-To 6](README.md#how-to-integrate-with-external-systems)** - Integration basics
2. **[docs/INTEGRATION_PATTERNS.md](docs/INTEGRATION_PATTERNS.md)** - Integration patterns
3. **[API_REFERENCE.md](API_REFERENCE.md)** - API documentation
4. **[ARCHITECTURE.md - Integration Architecture](ARCHITECTURE.md#integration-architecture)** - Design

---

## 📂 Reference Documentation

### Core Reference
- **[API_REFERENCE.md](API_REFERENCE.md)** — All commands, parameters, return values
- **[CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)** — Environment variables, settings
- **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** — One-page command cheat sheet
- **[CHANGELOG.md](CHANGELOG.md)** — Version history and changes

### Technical Reference
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Complete system architecture
- **[CLAUDE.md](CLAUDE.md)** — Development patterns and best practices
- **[SYSTEM_COMPOSITION_OVERVIEW.md](SYSTEM_COMPOSITION_OVERVIEW.md)** — Component overview

### Configuration & Setup
- **[CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)** — Configuration guide
- **[docs/HOMEBREW_INSTALLATION.md](docs/HOMEBREW_INSTALLATION.md)** — macOS installation
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** — Production deployment

---

## 🔧 Advanced Development

### Advanced Topics
- **[docs/ADVANCED_INSTALLATION.md](docs/ADVANCED_INSTALLATION.md)** — Custom installations
- **[docs/PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)** — Optimization guide
- **[docs/SECURITY_ARCHITECTURE.md](docs/SECURITY_ARCHITECTURE.md)** — Security details
- **[docs/SCALABILITY_GUIDE.md](docs/SCALABILITY_GUIDE.md)** — Scaling SwarmSH

### Monitoring & Observability
- **[docs/TELEMETRY_GUIDE.md](docs/TELEMETRY_GUIDE.md)** — Telemetry analysis
- **[docs/MONITORING_ADVANCED.md](docs/MONITORING_ADVANCED.md)** — Advanced monitoring
- **[CLAUDE.md - Telemetry Analysis](CLAUDE.md#8020-automation--telemetry-analysis)** — Data-driven decisions

### Development Patterns
- **[AGENT_SWARM_OPERATIONS_GUIDE.md](AGENT_SWARM_OPERATIONS_GUIDE.md)** — Swarm patterns
- **[docs/INTEGRATION_PATTERNS.md](docs/INTEGRATION_PATTERNS.md)** — Integration patterns
- **[docs/WORKTREE_DEVELOPMENT_GUIDE.md](docs/WORKTREE_DEVELOPMENT_GUIDE.md)** — Worktree patterns

---

## 🚀 Operations & Deployment

### Installation
- **[GETTING_STARTED.md](GETTING_STARTED.md)** — Step-by-step setup
- **[docs/HOMEBREW_INSTALLATION.md](docs/HOMEBREW_INSTALLATION.md)** — Package manager
- **[docs/ADVANCED_INSTALLATION.md](docs/ADVANCED_INSTALLATION.md)** — Advanced options

### Running & Managing
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** — Deployment guide
- **[docs/CRON_AUTOMATION_GUIDE.md](docs/CRON_AUTOMATION_GUIDE.md)** — Automation setup
- **[AUTOMATION_GUIDE_8020.md](AUTOMATION_GUIDE_8020.md)** — 8020 automation

### Monitoring & Operations
- **[README.md - How-To 2](README.md#how-to-monitor-system-health)** — Health checks
- **[docs/TELEMETRY_GUIDE.md](docs/TELEMETRY_GUIDE.md)** — Telemetry monitoring
- **[docs/MONITORING_ADVANCED.md](docs/MONITORING_ADVANCED.md)** — Advanced monitoring

### Troubleshooting
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** — Common issues and solutions
- **[README.md - How-To 4](README.md#how-to-troubleshoot-common-issues)** — Quick solutions

### Performance & Scaling
- **[docs/PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)** — Optimization guide
- **[docs/SCALABILITY_GUIDE.md](docs/SCALABILITY_GUIDE.md)** — Scaling strategies
- **[CONFIGURATION_REFERENCE.md](CONFIGURATION_REFERENCE.md)** — Performance settings

---

## 🚀 10-Agent Concurrent Claude Code System (NEW)

**Complete Diataxis documentation for 10-agent concurrent systems using Claude code web VM agents.**

### 📚 TUTORIALS
- **[docs/agent-systems/10-AGENT-QUICKSTART.md](docs/agent-systems/10-AGENT-QUICKSTART.md)** — Launch your first 10-agent swarm in 15 minutes

### 🎯 HOW-TO GUIDES
- **[docs/agent-systems/MULTI-AGENT-COORDINATION.md](docs/agent-systems/MULTI-AGENT-COORDINATION.md)** — Practical multi-agent scenarios (work distribution, dependencies, bottlenecks, failures)

### 📖 REFERENCE
- **[docs/agent-systems/AGENT-CONFIGURATION-REFERENCE.md](docs/agent-systems/AGENT-CONFIGURATION-REFERENCE.md)** — Complete agent configuration schema, specializations, capabilities
- **[docs/agent-systems/AGENT-MONITORING-DASHBOARD.md](docs/agent-systems/AGENT-MONITORING-DASHBOARD.md)** — Monitoring, health scoring, alerting, historical analysis
- **[docs/agent-systems/examples/10-agent-team-config.json](docs/agent-systems/examples/10-agent-team-config.json)** — Ready-to-use 10-agent configuration

### 💡 EXPLANATIONS
- **[docs/agent-systems/AGENT-SYSTEM-EXPLANATIONS.md](docs/agent-systems/AGENT-SYSTEM-EXPLANATIONS.md)** — Theory & design: Why 10 agents? Coordination theory, team strategies, failure handling, scalability to 1000+ agents

### 📋 MASTER INDEX
- **[docs/agent-systems/10-AGENT-SYSTEM-OVERVIEW.md](docs/agent-systems/10-AGENT-SYSTEM-OVERVIEW.md)** — Complete index and quick reference for all agent system documentation

### Quick Path for 10-Agent Users

1. **[10-Agent Quickstart](docs/agent-systems/10-AGENT-QUICKSTART.md)** (15 min) — Get started
2. **[Multi-Agent Coordination](docs/agent-systems/MULTI-AGENT-COORDINATION.md)** (10 min per scenario) — Solve problems
3. **[Agent Configuration Reference](docs/agent-systems/AGENT-CONFIGURATION-REFERENCE.md)** (lookup) — Find details
4. **[Agent Monitoring Dashboard](docs/agent-systems/AGENT-MONITORING-DASHBOARD.md)** (5 min setup) — Monitor
5. **[Agent System Explanations](docs/agent-systems/AGENT-SYSTEM-EXPLANATIONS.md)** (30 min) — Deep understanding

---

## 🎨 Supporting Documentation

### Conceptual Guides
- **[SYSTEM_COMPOSITION_OVERVIEW.md](SYSTEM_COMPOSITION_OVERVIEW.md)** — Component overview
- **[AGENT_SWARM_OPERATIONS_GUIDE.md](AGENT_SWARM_OPERATIONS_GUIDE.md)** — Swarm concepts
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — System architecture
- **[docs/agent-systems/AGENT-SYSTEM-EXPLANATIONS.md](docs/agent-systems/AGENT-SYSTEM-EXPLANATIONS.md)** — 10-agent system theory & design (NEW)

### Migration & Upgrade
- **[docs/MIGRATION_1.0_TO_1.1.md](docs/MIGRATION_1.0_TO_1.1.md)** — Upgrading versions
- **[CHANGELOG.md](CHANGELOG.md)** — What changed

### Contributing
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — How to contribute
- **[CLAUDE.md](CLAUDE.md)** — Development patterns

---

## 📊 Documentation Statistics

| Aspect | Count |
|--------|-------|
| Total documentation files | 50+ |
| Tutorials | 7 (includes 10-agent quickstart) |
| How-To Guides | 9+ (includes multi-agent coordination) |
| Reference documents | 10 (includes agent-specific refs) |
| Advanced guides | 5+ |
| Installation guides | 3 |
| Agent system docs (NEW) | 5 files + examples |
| Total pages (estimated) | 2,000+ |
| Code examples | 250+ |
| Diagrams | 25+ |

---

## 🔍 Finding What You Need

### By Problem Type

**"I'm new and don't know where to start"**
→ [README.md Tutorials](README.md#tutorials)

**"I need to do X but don't know how"**
→ [README.md How-To Guides](README.md#how-to-guides) or [Troubleshooting](TROUBLESHOOTING.md)

**"I need to look up the API for command Y"**
→ [API_REFERENCE.md](API_REFERENCE.md)

**"I need to understand why Z works"**
→ [README.md Explanations](README.md#explanations) or [ARCHITECTURE.md](ARCHITECTURE.md)

**"Something is broken and I need help"**
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

**"I need to deploy to production"**
→ [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

**"I'm integrating SwarmSH with another system"**
→ [docs/INTEGRATION_PATTERNS.md](docs/INTEGRATION_PATTERNS.md)

**"I need to optimize performance"**
→ [docs/PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)

**"I need advanced monitoring"**
→ [docs/MONITORING_ADVANCED.md](docs/MONITORING_ADVANCED.md)

---

## 📖 Documentation Organization Principles

All SwarmSH documentation follows these principles:

### 1. **Diataxis Framework**
- **Tutorials**: Learning-oriented, step-by-step
- **How-To Guides**: Task-oriented, problem-solving
- **Reference**: Information-oriented, lookup
- **Explanations**: Understanding-oriented, conceptual

### 2. **Clear Navigation**
- Every document starts with a quick navigation guide
- Cross-references between related topics
- "Next steps" guidance at the end

### 3. **Practical Examples**
- Every concept includes working code examples
- Real-world scenarios
- Expected outputs

### 4. **Multiple Entry Points**
- Direct paths for common user journeys
- Alphabetical reference sections
- Cross-indexed topics

### 5. **Progressive Depth**
- Basic concepts first
- Advanced details later
- Links for deeper learning

---

## 🔗 External Resources

- **[OpenTelemetry Documentation](https://opentelemetry.io/docs/)** — Telemetry standards
- **[Git Worktrees Guide](https://git-scm.com/docs/git-worktree)** — Git worktree documentation
- **[Diataxis Framework](https://diataxis.fr/)** — Documentation philosophy
- **[Bash Best Practices](https://mywiki.wooledge.org/BashGuide)** — Shell scripting reference
- **[Prometheus Metrics](https://prometheus.io/docs/)** — Monitoring and alerting

---

## 📝 Keeping Documentation Updated

Documentation is updated whenever:
- New features are added (CHANGELOG.md, relevant guides)
- Configuration options change (CONFIGURATION_REFERENCE.md)
- Bugs are fixed with workarounds (TROUBLESHOOTING.md)
- New patterns emerge (relevant how-to guide)
- Version updates occur (docs/MIGRATION_*.md)

---

## 🤝 Providing Feedback

Documentation can always be improved. If you find:
- **Unclear sections** → [Open an issue](https://github.com/seanchatmangpt/swarmsh/issues)
- **Missing topics** → Suggest documentation additions
- **Outdated information** → Report it immediately
- **Better examples** → Contribute improvements

---

<div align="center">

**[Getting Started](GETTING_STARTED.md)** • **[API Reference](API_REFERENCE.md)** • **[Architecture](ARCHITECTURE.md)** • **[Troubleshooting](TROUBLESHOOTING.md)**

Start with the [README.md](README.md) for the best introduction.

</div>
