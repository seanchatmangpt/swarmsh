# Getting Started with SwarmSH

> **Start here:** Comprehensive platform-specific installation and setup guide for SwarmSH.
>
> **New to SwarmSH?** Start with [README.md Tutorials](README.md#tutorials) for a quick introduction.
> **Already familiar?** Jump to [platform-specific setup](#platform-specific-setup) below.

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

## 📋 Installation Paths

Choose your path based on your experience level:

| Path | Time | Best For |
|------|------|----------|
| **[Quick Install](#quick-install-automated)** | 5 min | Most users |
| **[Step-by-Step](#step-by-step-manual-setup)** | 15 min | Understanding setup |
| **[Custom Install](docs/ADVANCED_INSTALLATION.md)** | 30+ min | Custom deployments |
| **[Container Setup](docs/ADVANCED_INSTALLATION.md#container-deployment)** | 10 min | Docker/Kubernetes |

---

## 🚀 Quick Install (Automated)

The fastest way to get started:

```bash
# Download and run install script
curl -fsSL https://install.swarmsh.io | bash

# Verify installation
swarmsh --version

# Start interactive setup
swarmsh init
```

After this, jump to [Your First Project](#your-first-project) below.

---

## 🏗️ Step-by-Step Manual Setup

For full control and understanding of your installation:

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

## 🎯 Your First Project

Now that SwarmSH is installed, follow these tutorials:

1. **[README Tutorial 1: Getting Started in 5 Minutes](README.md#tutorial-1-getting-started-in-5-minutes)**
   - Basic setup and first commands

2. **[README Tutorial 2: Your First Agent Coordination](README.md#tutorial-2-your-first-agent-coordination)**
   - Register agents and claim work items

3. **[README Tutorial 3: Setting Up Telemetry Monitoring](README.md#tutorial-3-setting-up-telemetry-monitoring)**
   - Monitor your system health

4. **[README Tutorial 4: Creating Your First Worktree](README.md#tutorial-4-creating-your-first-worktree)**
   - Parallel development setup

---

## 🔧 Platform-Specific Setup

### Platform-Specific Setup

### macOS-Specific Notes

**Install with Homebrew (Recommended)**
```bash
brew tap seanchatmangpt/swarmsh
brew install swarmsh

# Verify installation
swarmsh --version
```

**Missing flock command**
```bash
brew install util-linux

# Verify flock is available
which flock
```

**Using M1/M2 Mac**
```bash
# Most dependencies work fine, but verify:
arch  # Should show arm64 for M1/M2
uname -m

# If issues, install universal binaries
brew install --universal jq python3
```

### Linux-Specific Notes

**Ubuntu/Debian**
```bash
sudo apt update
sudo apt install -y bash jq python3 git bc util-linux

# Verify versions
bash --version     # Should be 4.0+
jq --version
python3 --version  # Should be 3.8+
```

**CentOS/RHEL**
```bash
sudo yum install bash jq python3 git util-linux

# Additional tools
sudo yum install bc openssl
```

**Alpine Linux (Container)**
```bash
apk add --no-cache bash jq python3 git util-linux bc
```

### Docker Setup

**Pre-built Container**
```bash
docker pull swarmsh:latest

docker run -d \
  --name swarmsh \
  -v swarmsh_data:/var/lib/swarmsh \
  -p 4000:4000 \
  swarmsh:latest

docker exec swarmsh coordination_helper.sh dashboard
```

**Build Your Own**
```bash
docker build -t my-swarmsh:latest .

docker run -d \
  --name my-swarmsh \
  -v $(pwd)/data:/var/lib/swarmsh \
  -p 4000:4000 \
  my-swarmsh:latest
```

---

## 🆘 Troubleshooting Installation

### Common Issues and Solutions

For detailed troubleshooting, see **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**

**Quick Fixes:**

| Issue | Solution |
|-------|----------|
| `command not found: flock` | `brew install util-linux` (macOS) |
| `command not found: jq` | `brew install jq` (macOS) or `apt install jq` (Linux) |
| `Permission denied` | `chmod +x *.sh` |
| `bash: ./script.sh: /bin/bash: bad interpreter` | Update bash: `brew install bash` |
| `python3 not found` | Install Python 3.8+: `brew install python3` |

**Verify Installation**
```bash
./scripts/verify_installation.sh
```

This runs a comprehensive check of all dependencies and configurations.

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

After completing the tutorials and basic setup, explore:

### Learn More
- **[README.md](README.md)** - Full documentation roadmap
- **[DOCUMENTATION_MAP.md](DOCUMENTATION_MAP.md)** - Complete documentation index
- **[Architecture](ARCHITECTURE.md)** - How SwarmSH works

### Configure & Customize
- **[Configuration Reference](CONFIGURATION_REFERENCE.md)** - All settings
- **[docs/ADVANCED_INSTALLATION.md](docs/ADVANCED_INSTALLATION.md)** - Custom installations
- **[docs/PERFORMANCE_TUNING.md](docs/PERFORMANCE_TUNING.md)** - Optimize for your workload

### Use Cases
- **[Worktree Development](docs/WORKTREE_DEVELOPMENT_GUIDE.md)** - Parallel feature development
- **[8020 Automation](docs/CRON_AUTOMATION_GUIDE.md)** - Automatic maintenance
- **[Integration Patterns](docs/INTEGRATION_PATTERNS.md)** - Connect with other systems

### Operations
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Production deployment
- **[Monitoring](docs/MONITORING_ADVANCED.md)** - Advanced monitoring
- **[Scalability](docs/SCALABILITY_GUIDE.md)** - Scale to thousands of agents

---

## 🆘 Getting Help

| Need | Resource |
|------|----------|
| Installation issues | [Troubleshooting](TROUBLESHOOTING.md) |
| Command reference | [API Reference](API_REFERENCE.md) |
| Configuration help | [Configuration Reference](CONFIGURATION_REFERENCE.md) |
| System status | `./coordination_helper.sh dashboard` |
| Documentation map | [DOCUMENTATION_MAP.md](DOCUMENTATION_MAP.md) |

---

<div align="center">

**[Quick Start](README.md#tutorials)** • **[API Reference](API_REFERENCE.md)** • **[Documentation Map](DOCUMENTATION_MAP.md)** • **[Troubleshooting](TROUBLESHOOTING.md)**

Ready to start? Follow [README.md Tutorials](README.md#tutorials)

</div>