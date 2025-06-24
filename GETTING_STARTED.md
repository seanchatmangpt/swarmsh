# Getting Started with SwarmSH

A simple guide for installing SwarmSH on a new computer and starting your first project.

## 🚀 Quick Installation (New Computer)

### 1. Check Prerequisites
```bash
# Check if you have the basics
bash --version    # Need 4.0+
jq --version      # JSON processor
python3 --version # Need 3.8+
git --version     # Need 2.30+
```

### 2. Install Missing Dependencies

#### macOS
```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install bash jq python3 git util-linux coreutils
```

#### Ubuntu/Linux
```bash
# Update and install
sudo apt update
sudo apt install -y bash jq python3 git bc util-linux
```

### 3. Clone SwarmSH
```bash
# Clone to your preferred location
git clone https://github.com/your-org/swarmsh.git
cd swarmsh

# Make scripts executable
chmod +x *.sh
```

### 4. Quick Test
```bash
# Test basic functionality
./coordination_helper.sh generate-id
```

If you see a generated ID, you're ready! 🎉

---

## 🏗️ Starting a New Project

### Option 1: Quick Start (Recommended)
```bash
# One command to set everything up
./quick_start_agent_swarm.sh
```
This creates a complete swarm with 3 agents and monitoring.

### Option 2: Manual Setup (Step by Step)

#### Step 1: Initialize Your Project
```bash
# Create project structure
mkdir -p my_swarm_project
cd my_swarm_project

# Copy SwarmSH into your project
cp -r /path/to/swarmsh/* .

# Initialize coordination system
echo "[]" > agent_status.json
echo "[]" > work_claims.json
echo "[]" > coordination_log.json
```

#### Step 2: Configure Your Environment
```bash
# Create basic config
cat > .env <<EOF
# Basic Configuration
AGENT_ID_PREFIX="my_agent"
COORDINATION_MODE="safe"
TELEMETRY_ENABLED=true

# Optional Claude AI (requires claude CLI)
CLAUDE_INTEGRATION=false
EOF

# Source the config
source .env
```

#### Step 3: Test the System
```bash
# Check system health
./coordination_helper.sh dashboard

# Create your first work item
./coordination_helper.sh claim "setup" "Initialize my swarm project" "high"
```

---

## 🎯 Basic Usage Patterns

### Working with Tasks
```bash
# Claim work
WORK_ID=$(./coordination_helper.sh claim "development" "Build new feature" "high")

# Update progress
./coordination_helper.sh progress "$WORK_ID" 50 "in_progress"

# Complete work
./coordination_helper.sh complete "$WORK_ID" "success" 8
```

### Monitoring Your Swarm
```bash
# View dashboard
./coordination_helper.sh dashboard

# Check agent status
./coordination_helper.sh list-agents

# View telemetry
tail -f telemetry_spans.jsonl | jq '.'
```

### Real Agent Coordination
```bash
# Initialize agent swarm system
./agent_swarm_orchestrator.sh init

# Add work using coordination helper
./coordination_helper.sh claim "optimization" "Performance test optimization" "high"

# Monitor with dashboard
./coordination_helper.sh dashboard
```

---

## 🔧 Common Setup Issues

### "flock: command not found" (macOS)
```bash
# Install util-linux package
brew install util-linux

# Alternative: use simple coordination mode
export COORDINATION_MODE="simple"
```

### Permission Denied
```bash
# Fix script permissions
chmod +x *.sh

# Create required directories
mkdir -p real_agents real_work_results logs metrics backups
```

### "jq: command not found"
```bash
# macOS
brew install jq

# Ubuntu/Linux
sudo apt install jq
```

### Scripts won't run
```bash
# Ensure you're using bash 4.0+
bash --version

# macOS: update bash if needed
brew install bash
```

---

## 📁 Project Structure

After setup, your project will have:

```
my_swarm_project/
├── coordination_helper.sh      # Main coordination system
├── agent_status.json          # Active agents
├── work_claims.json           # Current work items
├── telemetry_spans.jsonl      # Distributed tracing
├── real_agents/               # Agent process data
└── logs/                      # System logs
```

---

## 🎮 What to Try Next

### 1. Multi-Agent Coordination
```bash
# Start multiple real agents
for i in {1..3}; do
    nohup ./real_agent_worker.sh > logs/agent_$i.log 2>&1 &
done

# Monitor coordination
watch -n 5 './coordination_helper.sh dashboard'
```

### 2. Advanced Features
```bash
# Create specialized worktrees
./create_s2s_worktree.sh my_feature_branch

# Run optimization loops
./8020_analyzer.sh

# Test system performance
./test_coordination_helper.sh
```

### 3. Integrate with Your Workflow
- Add SwarmSH commands to your CI/CD pipeline
- Use coordination for team task management
- Integrate telemetry with monitoring systems

---

## 📚 Next Steps

Once you're comfortable with the basics:

1. **[Configuration Reference](CONFIGURATION_REFERENCE.md)** - Customize your setup
2. **[API Reference](API_REFERENCE.md)** - Learn all commands
3. **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Production deployment
4. **[Architecture Guide](ARCHITECTURE.md)** - Understand the system

---

## 🆘 Getting Help

- **Quick issues**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Command help**: Run `./coordination_helper.sh help`
- **System status**: Run `./coordination_helper.sh dashboard`

Happy swarming! 🐝