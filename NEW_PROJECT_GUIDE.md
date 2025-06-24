# New Project Setup Guide

Complete guide for creating a new project with SwarmSH agent coordination.

## 🎯 Project Types

Choose the setup that matches your project:

### 1. **Simple Task Coordination** 
Basic work management for small teams
- 1-3 agents
- JSON-based coordination
- Perfect for: Personal projects, small teams

### 2. **Real Agent Swarm**
Production-grade distributed system
- 5+ concurrent agents  
- Atomic work claiming
- Perfect for: CI/CD, automated workflows

### 3. **Enterprise Integration**
Full-featured coordination with AI
- Multi-worktree environments
- Claude AI integration
- Perfect for: Large teams, complex projects

---

## 🚀 Setup Option 1: Simple Task Coordination

### Quick Setup
```bash
# Create new project
mkdir my_task_project
cd my_task_project

# Copy SwarmSH
git clone https://github.com/your-org/swarmsh.git .

# Initialize
./coordination_helper.sh init-simple
```

### Manual Setup
```bash
# 1. Initialize coordination files
echo "[]" > agent_status.json
echo "[]" > work_claims.json  
echo "[]" > coordination_log.json

# 2. Register yourself as an agent
./coordination_helper.sh register 100 "active" "dev_team"

# 3. Create your first task
TASK_ID=$(./coordination_helper.sh claim "setup" "Setup project structure" "high")

# 4. Start working
echo "Working on: $TASK_ID"
```

### Basic Workflow
```bash
# Daily workflow
./coordination_helper.sh dashboard               # Check status
./coordination_helper.sh claim "feature" "New API endpoint" "medium"
# ... do your work ...
./coordination_helper.sh complete "$WORK_ID" "success" 7
```

---

## ⚡ Setup Option 2: Real Agent Swarm

### Prerequisites Check
```bash
# Verify you have atomic locking support
if command -v flock >/dev/null 2>&1; then
    echo "✅ flock available - real coordination supported"
else
    echo "❌ Install flock first: brew install util-linux"
    exit 1
fi
```

### Quick Setup
```bash
# Create project with real agents
mkdir my_swarm_project
cd my_swarm_project

# Setup SwarmSH
git clone https://github.com/your-org/swarmsh.git .
chmod +x *.sh

# Initialize agent swarm system
./agent_swarm_orchestrator.sh init

# Quick start complete swarm
./quick_start_agent_swarm.sh

# Or start agents manually
for i in {1..3}; do
    nohup ./real_agent_worker.sh > logs/agent_$i.log 2>&1 &
done

# Monitor coordination
./agent_swarm_orchestrator.sh status
```

### Custom Agent Configuration
```bash
# Create custom agent behavior
cat > my_custom_agent.sh <<'EOF'
#!/bin/bash
AGENT_ID="custom_agent_$(date +%s%N)"

# Register agent
./coordination_helper.sh register 100 "active" "custom_team"

while true; do
    # Claim work using coordination helper
    WORK_ID=$(./coordination_helper.sh claim "custom_work" "Agent processing" "medium")
    
    if echo "$WORK_ID" | grep -q "work_"; then
        echo "Agent $AGENT_ID working on: $WORK_ID"
        
        # Do your custom work here
        sleep 5  # Simulate work
        
        # Complete work
        ./coordination_helper.sh complete "$WORK_ID" "success" 7
    else
        sleep 2  # Wait for work
    fi
done
EOF

chmod +x my_custom_agent.sh
```

---

## 🏢 Setup Option 3: Enterprise Integration

### Full Environment Setup
```bash
# Create enterprise project structure
mkdir enterprise_swarm_project
cd enterprise_swarm_project

# Clone with full features
git clone https://github.com/your-org/swarmsh.git .

# Run comprehensive setup
./quick_start_agent_swarm.sh
```

### Advanced Configuration
```bash
# 1. Configure multiple worktrees
./create_s2s_worktree.sh backend_services
./create_s2s_worktree.sh frontend_apps  
./create_s2s_worktree.sh data_pipeline

# 2. Deploy specialized agents
./agent_swarm_orchestrator.sh deploy-to-worktree backend_services 2
./agent_swarm_orchestrator.sh deploy-to-worktree frontend_apps 2
./agent_swarm_orchestrator.sh deploy-to-worktree data_pipeline 1

# 3. Configure Claude AI (if available)
if command -v claude >/dev/null 2>&1; then
    export CLAUDE_INTEGRATION=true
    export CLAUDE_OUTPUT_FORMAT="json"
    ./coordination_helper.sh claude-health
fi

# 4. Start coordinated monitoring
./realtime_performance_monitor.sh &
```

### Enterprise Workflow
```bash
# Strategic planning
./coordination_helper.sh pi-planning

# Team coordination
./coordination_helper.sh sprint-planning "Sprint_42"

# AI-assisted priority analysis
./coordination_helper.sh claude-priorities

# Cross-team coordination
./coordination_helper.sh cross-team "backend_services" "frontend_apps"
```

---

## 🎮 Project Templates

### Template 1: CI/CD Integration
```bash
# .github/workflows/swarm-coordination.yml
name: SwarmSH Coordination
on: [push, pull_request]

jobs:
  coordinate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup SwarmSH
      run: |
        chmod +x *.sh
        ./coordination_helper.sh init-ci
    - name: Coordinate Build
      run: |
        TASK_ID=$(./coordination_helper.sh claim "build" "CI Build ${{ github.sha }}" "high")
        # Your build steps here
        ./coordination_helper.sh complete "$TASK_ID" "success" 9
```

### Template 2: Development Team
```bash
# setup_dev_team.sh
#!/bin/bash

# Initialize team coordination
./coordination_helper.sh init-team "awesome_dev_team"

# Create team roles
./coordination_helper.sh register 100 "active" "awesome_dev_team" "tech_lead"
./coordination_helper.sh register 80 "active" "awesome_dev_team" "senior_dev"  
./coordination_helper.sh register 60 "active" "awesome_dev_team" "developer"

# Setup sprint backlog
./coordination_helper.sh backlog-init "Sprint_1"
./coordination_helper.sh add-story "User Authentication" "epic" "critical"
./coordination_helper.sh add-story "API Development" "feature" "high"
./coordination_helper.sh add-story "Database Schema" "technical" "high"

echo "✅ Development team coordination setup complete!"
```

### Template 3: Performance Testing
```bash
# setup_performance_testing.sh
#!/bin/bash

# Initialize agent swarm for performance testing
./agent_swarm_orchestrator.sh init

# Add performance test work items using coordination helper
./coordination_helper.sh claim "load_test" "API endpoints load testing" "critical"
./coordination_helper.sh claim "stress_test" "Database query stress testing" "high" 
./coordination_helper.sh claim "benchmark" "Response time benchmarking" "medium"

# Start performance agents
for i in {1..5}; do
    nohup ./real_agent_worker.sh "perf_agent_$i" "performance" > logs/perf_agent_$i.log 2>&1 &
    echo "Started performance agent $i"
done

echo "✅ Performance testing swarm ready!"
```

---

## 🔧 Configuration Patterns

### Environment-Specific Configs

#### Development
```bash
# .env.development
COORDINATION_MODE="simple"
TELEMETRY_ENABLED=true
CLAUDE_INTEGRATION=false
LOG_LEVEL="debug"
AGENT_POOL_SIZE=3
```

#### Staging  
```bash
# .env.staging
COORDINATION_MODE="safe"
TELEMETRY_ENABLED=true
CLAUDE_INTEGRATION=true
LOG_LEVEL="info"
AGENT_POOL_SIZE=5
```

#### Production
```bash
# .env.production
COORDINATION_MODE="distributed"
TELEMETRY_ENABLED=true
CLAUDE_INTEGRATION=true
LOG_LEVEL="warn"
AGENT_POOL_SIZE=10
MAX_CONCURRENT_WORK=3
```

### Custom Agent Types
```bash
# Create specialized agent
cat > build_agent.sh <<'EOF'
#!/bin/bash
# Specialized build agent

AGENT_TYPE="build_agent"
AGENT_ID="${AGENT_TYPE}_$(date +%s%N)"

while true; do
    # Only claim build-related work
    WORK=$(./coordination_helper.sh claim-by-type "build" "$AGENT_ID")
    
    if [ "$WORK" != "null" ]; then
        # Custom build logic here
        run_build_pipeline
        
        ./coordination_helper.sh complete "$WORK" "success" 8
    else
        sleep 10
    fi
done
EOF
```

---

## 📊 Monitoring Your Project

### Basic Monitoring
```bash
# Check system health
./coordination_helper.sh dashboard

# Monitor telemetry in real-time
tail -f telemetry_spans.jsonl | jq '.operation' 

# View active work
jq '.[] | select(.status == "active")' work_claims.json
```

### Advanced Monitoring
```bash
# Performance dashboard
./realtime_performance_monitor.sh

# Agent health analysis
./coordination_helper.sh claude-health

# Cross-agent coordination metrics
./8020_analyzer.sh
```

### Custom Dashboards
```bash
# Create custom monitoring script
cat > project_dashboard.sh <<'EOF'
#!/bin/bash
clear
echo "=== My Project Dashboard ==="
echo "Agents: $(jq 'length' agent_status.json)"
echo "Active Work: $(jq '[.[] | select(.status == "active")] | length' work_claims.json)"
echo "Completed Today: $(jq --arg today "$(date +%Y-%m-%d)" '[.[] | select(.completed_at and (.completed_at | startswith($today)))] | length' coordination_log.json)"
echo "Performance: $(./coordination_helper.sh performance-summary)"
EOF

# Run it
chmod +x project_dashboard.sh && ./project_dashboard.sh
```

---

## 🎯 Best Practices

### 1. Start Small
- Begin with simple task coordination
- Add real agents as you grow
- Scale to enterprise features gradually

### 2. Use Meaningful Work Types
```bash
# Good work types
./coordination_helper.sh claim "frontend_bug_fix" "Fix responsive layout issue" "high"
./coordination_helper.sh claim "api_development" "Create user endpoint" "medium"
./coordination_helper.sh claim "performance_optimization" "Optimize database queries" "high"

# Avoid generic types  
./coordination_helper.sh claim "work" "do stuff" "medium"  # ❌
```

### 3. Regular Cleanup
```bash
# Add to crontab for daily cleanup
0 2 * * * cd /path/to/project && ./cleanup_old_work.sh
```

### 4. Monitor and Optimize
```bash
# Weekly optimization
./8020_analyzer.sh
./8020_optimizer.sh
./8020_feedback_loop.sh
```

---

## 🆘 Troubleshooting New Projects

### Common Setup Issues

**Scripts not executable**
```bash
find . -name "*.sh" -exec chmod +x {} \;
```

**Missing directories**
```bash
mkdir -p logs metrics backups real_agents real_work_results
```

**JSON file corruption**
```bash
# Reset to clean state
echo "[]" > agent_status.json
echo "[]" > work_claims.json
echo "[]" > coordination_log.json
```

**flock issues (macOS)**
```bash
# Install util-linux
brew install util-linux

# Or use simple mode
export COORDINATION_MODE="simple"
```

---

## 🎉 Success Checklist

Your project is ready when you can:

- [ ] Create and claim work items
- [ ] See agents in dashboard  
- [ ] Complete work successfully
- [ ] View telemetry data
- [ ] Run coordination tests

```bash
# Final verification
./test_coordination_helper.sh basic
```

Congratulations! Your SwarmSH project is ready for productive agent coordination! 🐝

---

## 📚 What's Next?

- **Scale up**: Add more agents and worktrees
- **Integrate**: Connect with your existing tools
- **Optimize**: Use 80/20 optimization loops
- **Monitor**: Set up performance dashboards
- **Automate**: Create custom agent behaviors

Ready to swarm? 🚀