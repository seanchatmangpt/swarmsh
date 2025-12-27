# Diataxis Swarm - Quick Start Guide

> Get your 10-agent Diataxis swarm running in under 2 minutes

## 🚀 One-Command Setup

```bash
./diataxis_swarm_orchestrator.sh full-setup
```

This initializes, registers, and starts all 10 agents.

## 📊 View the Demo

Watch all 10 agents work concurrently:

```bash
./diataxis_agent_simulator.sh demo
```

## 🔍 Check Status

```bash
./diataxis_swarm_orchestrator.sh status
```

## 📈 View Architecture

```bash
./diataxis_swarm_orchestrator.sh diagram
cat diataxis_swarm_architecture.mmd
```

## 📚 Full Documentation

See [DIATAXIS_SWARM_README.md](DIATAXIS_SWARM_README.md) for complete documentation.

---

**Files Created:**
- `diataxis_swarm_config.json` - 10-agent configuration
- `diataxis_swarm_orchestrator.sh` - Main orchestration script
- `diataxis_agent_simulator.sh` - Demo simulator
- `diataxis_work_templates.json` - Work templates for each quadrant
- `DIATAXIS_SWARM_README.md` - Complete documentation
- `diataxis_coordination/` - Coordination data directory
