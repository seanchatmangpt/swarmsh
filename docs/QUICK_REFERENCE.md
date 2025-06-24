# SwarmSH Quick Reference Guide

## 🚀 Getting Started (5 Minutes)

### 1. Start Agent Swarm
```bash
# One command to start everything
./quick_start_agent_swarm.sh

# Check status
./coordination_helper.sh dashboard
```

### 2. Basic Work Coordination
```bash
# Claim work
./coordination_helper.sh claim "feature" "Add user login" "high" "dev-team"

# Check progress
./coordination_helper.sh list-work

# Complete work
./coordination_helper.sh complete "work_item_id" "success" 8
```

### 3. Use AI Intelligence
```bash
# Analyze priorities
./claude/claude-analyze-priorities

# Health check
./claude/claude-health-analysis

# Real-time insights
./claude/claude-stream performance 60
```

## 📋 Essential Commands

### Core Coordination
```bash
./coordination_helper.sh claim <type> <description> [priority] [team]
./coordination_helper.sh claim-fast <type> <description> [priority] [team]  # 🚀 57x faster
./coordination_helper.sh progress <work_id> <percent> [status]
./coordination_helper.sh complete <work_id> [result] [points]
./coordination_helper.sh list-work              # Traditional listing
./coordination_helper.sh list-work-fast         # 🚀 Fast-path listing
./coordination_helper.sh dashboard              # Show status
./coordination_helper.sh dashboard-fast         # ⚡ Fast-path dashboard (best for large datasets)
```

### Agent Management
```bash
./implement_real_agents.sh                      # Start real agents
./real_agent_worker.sh <agent_id> <work_type>   # Manual agent
pgrep -af real_agent_worker                     # Check agents
pkill -f real_agent_worker                      # Stop agents
```

### Worktree Management
```bash
./create_s2s_worktree.sh <name> <branch>        # New worktree
./manage_worktrees.sh list                      # List worktrees
./manage_worktrees.sh cleanup                   # Clean unused
```

### Claude AI
```bash
./claude/claude-analyze-priorities              # Priority analysis
./claude/claude-health-analysis                 # System health
./claude/claude-optimize-assignments            # Load balancing
./claude/claude-stream <focus> <duration>       # Real-time stream
```

### Main Tools
```bash
./ollama-pro chat llama2                        # AI chat
./ollama-pro vision llava image.jpg "analyze"   # Vision analysis
./tdd-swarm start --feature "user-auth"         # TDD workflow
```

### Cleanup & Maintenance
```bash
./auto_cleanup.sh                               # Daily cleanup
./comprehensive_cleanup.sh                      # Deep cleanup
./benchmark_cleanup_script.sh                   # Remove test data
./8020_cron_automation.sh install               # 🤖 Install 80/20 automation
```

## 🔧 Common Workflows

### Daily Development
```bash
# 1. Start development environment
./quick_start_agent_swarm.sh

# 2. Create feature worktree
./create_s2s_worktree.sh user-auth auth-feature

# 3. Claim work
./coordination_helper.sh claim "feature" "User authentication" "high" "auth-team"

# 4. Monitor progress
./claude/claude-stream performance 300 &

# 5. Use AI assistance
./ollama-pro chat codellama
```

### Team Coordination
```bash
# Check team status
./coordination_helper.sh dashboard

# Analyze team performance
./claude/claude-health-analysis | jq '.component_health'

# Optimize assignments
./claude/claude-optimize-assignments auth-team

# Run team ceremony
./coordination_helper.sh scrum-of-scrums
```

### System Maintenance
```bash
# Daily cleanup (add to cron)
0 3 * * * /path/to/auto_cleanup.sh

# Weekly deep clean
./comprehensive_cleanup.sh

# Monitor system health
./claude/claude-health-analysis | jq '.health_score'
```

## 🎯 80/20 Priority Commands

### High-Impact (20% effort, 80% value)
1. `./quick_start_agent_swarm.sh` - Start everything
2. `./coordination_helper.sh claim-fast` - 🚀 57x faster work coordination
3. `./claude/claude-analyze-priorities` - AI insights
4. `./create_s2s_worktree.sh` - Development isolation
5. `./ollama-pro chat` - AI assistance

### 🚀 Performance Optimizations
```bash
# Fast-path work claiming (57x faster for all dataset sizes)
./coordination_helper.sh claim-fast "feature" "description" "high" "team"

# Fast-path work listing
./coordination_helper.sh list-work-fast

# Fast-path dashboard (optimized for large datasets)
./coordination_helper.sh dashboard-fast

# Performance measurement
time ./coordination_helper.sh claim "test" "baseline"     # Traditional: ~1.2s
time ./coordination_helper.sh claim-fast "test" "fast"    # Fast-path: ~21ms

# 80/20 Optimization Learning:
# - claim-fast: Always faster (57x improvement)
# - dashboard-fast: Better for large datasets (50+ agents, 20+ work items)
# - Small datasets: Traditional jq parsing may be faster due to optimization overhead
```

### Daily Operations
1. `./coordination_helper.sh dashboard` - Check status
2. `./claude/claude-health-analysis` - System health
3. `./manage_worktrees.sh list` - Environment status
4. `./auto_cleanup.sh` - Maintenance
5. `pgrep -af real_agent_worker` - Agent status

### 🤖 80/20 Cron Automation
```bash
# Install automated monitoring and optimization (80/20 high-impact tasks)
./8020_cron_automation.sh install

# Manual execution of automation features
./8020_cron_automation.sh health     # System health monitoring
./8020_cron_automation.sh optimize   # Work queue optimization  
./8020_cron_automation.sh metrics    # Performance metrics collection
./8020_cron_automation.sh status     # Check automation status

# Automated schedule (after install):
# - Health monitoring: Every 15 minutes (prevents failures)
# - Work optimization: Every hour (maintains performance)
# - Metrics collection: Every 30 minutes (provides visibility)
# - Daily cleanup: 3 AM (maintenance)
```

### 📊 OpenTelemetry Integration
```bash
# OTEL traces are automatically generated for all operations
# Trace data validation:
tail -5 /Users/sac/dev/swarmsh/telemetry_spans.jsonl

# OTEL features validated:
# ✅ Proper trace IDs (32 hex characters)
# ✅ Span IDs (16 hex characters)  
# ✅ Duration measurements
# ✅ Operation naming conventions
# ✅ Status tracking (OK, ERROR)
# ✅ Structured telemetry data
```

## 🚨 Emergency Commands

### System Issues
```bash
# Stop all agents
pkill -f real_agent_worker

# Emergency cleanup
./comprehensive_cleanup.sh

# Health check
./claude/claude-health-analysis | jq '.alerts'

# Restart coordination
./quick_start_agent_swarm.sh
```

### Performance Issues
```bash
# Check work queue
./coordination_helper.sh list-work | wc -l

# Optimize performance
./coordination_helper.sh optimize

# Clean stale data
./benchmark_cleanup_script.sh
```

## 📊 Monitoring

### Real-time Status
```bash
# System dashboard
./coordination_helper.sh dashboard

# Agent status
pgrep -af real_agent_worker | wc -l

# Work queue size
jq 'length' work_claims.json

# Health score
./claude/claude-health-analysis | jq '.health_score'
```

### Performance Metrics
```bash
# Response times
./claude/claude-stream performance 60

# Completion rates
grep "completed" coordination_log.json | wc -l

# Error rates
./claude/claude-health-analysis | jq '.component_health'
```

## 🔗 Quick Links

### Documentation
- **Main README**: `/docs/README.md`
- **Core Scripts**: `/docs/scripts/core-coordination/`
- **Agent Management**: `/docs/scripts/agent-management/`
- **Claude Integration**: `/docs/scripts/claude-integration/`

### Key Files
- **Work Queue**: `work_claims.json`
- **Agent Status**: `agent_status.json`
- **Coordination Log**: `coordination_log.json`
- **Telemetry**: `telemetry_spans.jsonl`

### Access Points
- **Default Ports**: 4000-4003 (worktree environments)
- **Coordination Dir**: `/tmp/s2s_coordination`
- **Logs**: Various per-script locations

## 💡 Tips & Tricks

### Productivity Boosters
```bash
# Alias for quick access
alias coord='./coordination_helper.sh'
alias claude-ai='./claude/claude-analyze-priorities'
alias health='./claude/claude-health-analysis'

# Monitor in real-time
watch -n 5 './coordination_helper.sh dashboard'

# Background analysis
./claude/claude-stream performance 3600 >> insights.log &
```

### Development Efficiency
```bash
# Quick worktree setup
function new-feature() {
    ./create_s2s_worktree.sh "$1" "feature/$1"
    cd "worktrees/$1"
}

# Auto-claim work
function claim-work() {
    ./coordination_helper.sh claim "$1" "$2" "medium" "$USER-team"
}
```

## 🎓 Learning Path

### Beginner (Day 1)
1. Run `./quick_start_agent_swarm.sh`
2. Learn `./coordination_helper.sh` basics
3. Try `./claude/claude-analyze-priorities`

### Intermediate (Week 1)
1. Create custom worktrees
2. Use Claude streaming insights
3. Implement basic TDD workflows

### Advanced (Month 1)
1. Customize agent configurations
2. Integrate with CI/CD
3. Build custom coordination workflows

---

**Need Help?** Check `/docs/README.md` for complete documentation or run any script with `--help`.