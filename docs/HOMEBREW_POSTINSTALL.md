# SwarmSH Homebrew Post-Installation Guide

> After installing SwarmSH v1.1.0 via Homebrew, follow this guide to get started.

---

## First Steps (5 minutes)

### 1. Verify Installation

```bash
# Check that swarmsh is available
swarmsh --version

# Check dependencies
swarmsh check-dependencies
```

Expected output should show all dependencies installed.

### 2. Initialize Your Project

```bash
# Create a directory for your project
mkdir my-swarmsh-project
cd my-swarmsh-project

# Initialize SwarmSH
swarmsh-init
```

This creates:
- `agent_coordination/` - Coordination logs
- `real_agents/` - Agent metrics
- `real_work_results/` - Completed work
- `Makefile` - Build and automation
- Configuration files

### 3. View Your Dashboard

```bash
# See the coordination dashboard
swarmsh-dashboard
```

This shows:
- Current system health
- Active agents
- Work items
- Recent operations

---

## Essential Commands

### Work Management

```bash
# Claim new work
swarmsh claim feature "Implement caching" high

# Update progress
swarmsh progress WORK_ID 50 "in_progress"

# Complete work
swarmsh complete WORK_ID "success" 8
```

### Monitoring & Health

```bash
# Quick health check
make telemetry-health

# Real-time monitoring (24 hours)
make monitor-24h

# Generate visual dashboard
make diagrams-dashboard

# View telemetry statistics
make telemetry-stats
```

### Testing & Validation

```bash
# Quick validation (< 1 minute)
make validate

# Essential tests
make test-essential

# Full test suite
make test
```

---

## Common Workflows

### Development Workflow

```bash
# Terminal 1: Start monitoring
make monitor-24h

# Terminal 2: Your work
make claim WORK_TYPE=feature DESC="Task description"
# ... do your work ...
make validate
make diagrams  # Update visuals
```

### Feature Development with Worktrees

```bash
# Create isolated feature branch
make worktree-create FEATURE=new-feature

# Work in isolation
cd worktrees/new-feature/
# ... develop feature ...
cd ../..

# Push for PR
make worktree-merge FEATURE=new-feature
```

### Production Monitoring

```bash
# Set up automation
make cron-install

# Check status
make cron-status

# Monitor health
make telemetry-health

# View real-time data
make monitor-24h

# Generate reports
make diagrams
```

---

## Configuration

### Environment Variables

Optional environment variables for customization:

```bash
# OpenTelemetry endpoint
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# Project name
export PROJECT_NAME="my-project"

# Coordination directory
export COORDINATION_DIR="$(pwd)/agent_coordination"

# Custom agent ID
export AGENT_ID="my_agent_$(date +%s%N)"
```

### Makefile Customization

Edit `Makefile` in your project to customize targets:

```makefile
# Add custom targets
my-command:
	@echo "Running my custom command"
	./my-script.sh
```

### System Configuration

Create `.swarmsh` file for project-specific settings:

```bash
# Optional: .swarmsh configuration
COORDINATION_MODE="atomic"  # or "simple"
TELEMETRY_ENABLED="true"
HEALTH_CHECK_INTERVAL="300"
```

---

## Automation Setup (Optional)

### Enable Cron Automation

```bash
# Install cron jobs (optional but recommended)
make cron-install

# Verify installation
make cron-status

# What gets automated:
# - Health monitoring every 15 minutes
# - Work queue optimization every 4 hours
# - Telemetry management every 4 hours
# - Performance collection every hour
```

### Monitor Automation

```bash
# Check recent automation runs
grep "8020_cron_log" telemetry_spans.jsonl | tail -5 | jq '.'

# View health reports
cat system_health_report.json | jq '.health_score'
```

---

## Telemetry & Monitoring

### Understanding Telemetry

All operations generate telemetry spans. View them:

```bash
# Last 20 operations
tail -20 telemetry_spans.jsonl | jq '.'

# Find errors
grep -i "error" telemetry_spans.jsonl | jq '.'

# Check specific operation
grep "work_claim" telemetry_spans.jsonl | jq '.duration_ms'
```

### Health Score Interpretation

```
85-100: System Healthy ✅ → Focus on new features
70-84:  System Good ✅ → Monitor for issues
50-69:  System Needs Attention ⚠️ → Fix issues first
0-49:   System Critical ❌ → Stop and troubleshoot
```

### Generate Reports

```bash
# Performance metrics
make telemetry-stats

# Visual dashboard
make diagrams-dashboard

# Timeline view
make diagrams-timeline

# System flow
make diagrams-flow
```

---

## Troubleshooting

### Issue: "make: command not found"

Solution: Install GNU Make:
```bash
brew install make
```

### Issue: "Command not found: swarmsh"

Solution: Add Homebrew to PATH:
```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

### Issue: "jq not found"

Solution: Install jq:
```bash
brew install jq
```

### Issue: Telemetry not generating

Solution: Verify telemetry file:
```bash
# Check if telemetry file exists
ls -la telemetry_spans.jsonl

# Check permissions
chmod 644 telemetry_spans.jsonl

# Test operation
swarmsh check-dependencies
```

### Issue: "Permission denied"

Solution: Fix file permissions:
```bash
chmod +x *.sh
chmod 755 agent_coordination/
```

---

## Best Practices

### 1. **Always Monitor Before Work**

```bash
# Start monitoring first
make monitor-24h

# Then do your work in another terminal
```

### 2. **Use Telemetry to Guide Decisions**

```bash
# Check health before starting major work
make telemetry-health

# Analyze performance impact
make telemetry-stats
```

### 3. **Test Before Claiming Work**

```bash
# Validate your environment
make validate

# Then claim work
make claim WORK_TYPE=feature DESC="Task"
```

### 4. **Regular Backups**

```bash
# Backup coordination data
cp -r agent_coordination/ agent_coordination.backup.$(date +%s)
```

### 5. **Keep Logs Clean**

```bash
# Archive old logs (optional)
make cleanup

# Or specifically
make cleanup-synthetic  # Remove test data
```

---

## Advanced Features

### Git Worktree Development

Create isolated feature branches:

```bash
# Create feature
make worktree-create FEATURE=feature-name

# List all
make worktree-list

# View status
make worktree-status FEATURE=feature-name

# Merge changes
make worktree-merge FEATURE=feature-name

# Cleanup
make worktree-cleanup FEATURE=feature-name
```

### Automated Documentation

SwarmSH can auto-generate documentation:

```bash
# Generate docs
./auto_doc_generator.sh

# Schedule automatic updates
make cron-install
```

### Performance Analysis

```bash
# 80/20 analysis
make analyze

# Performance optimization
make optimize

# Real-time metrics
make realtime_performance_monitor.sh
```

---

## Updating SwarmSH

### Check for Updates

```bash
# See what's new
brew outdated

# Get version details
brew info swarmsh
```

### Update to Latest

```bash
# Update SwarmSH
brew upgrade swarmsh

# Verify update
swarmsh --version
```

### Update All Homebrew Packages

```bash
# Update everything
brew update
brew upgrade

# Clean up old versions
brew cleanup
```

---

## Uninstallation

### Remove SwarmSH

```bash
# Uninstall
brew uninstall swarmsh

# Remove tap (optional)
brew untap seanchatmangpt/swarmsh

# Clean up
brew cleanup

# Remove project directory (if desired)
rm -rf my-swarmsh-project/
```

---

## Getting Help

### Documentation

```bash
# In your project directory
make help              # All available commands
make quick-ref        # Quick reference card
make telemetry-guide  # Telemetry analysis guide
```

### Command Help

```bash
# Help for coordination helper
swarmsh help

# Check specific command
swarmsh claim --help  # If available
```

### Resources

- **GitHub:** https://github.com/seanchatmangpt/swarmsh
- **README:** `brew --prefix swarmsh`/README.md
- **CHANGELOG:** `brew --prefix swarmsh`/CHANGELOG.md
- **Quick Start:** `make quick-ref`

---

## Next Steps

1. **[Quick Reference](../docs/QUICK_REFERENCE.md)** - Essential commands
2. **[Development Guide](../CLAUDE.md)** - Development patterns
3. **[Telemetry Guide](../docs/TELEMETRY_GUIDE.md)** - Monitoring setup
4. **[API Reference](../API_REFERENCE.md)** - Complete API documentation
5. **[Worktree Guide](../docs/WORKTREE_DEVELOPMENT_GUIDE.md)** - Parallel development

---

## Version Info

- **SwarmSH:** v1.1.0
- **Release Date:** November 16, 2025
- **Homebrew Support:** Latest
- **Status:** Stable - Production Ready

---

**Ready to start?** Run `make dashboard` to see your first coordinated system! 🚀
