# SwarmSH Deployment & Installation Guide

This guide provides comprehensive instructions for deploying and installing the SwarmSH agent coordination system.

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Prerequisites](#prerequisites)
3. [Quick Start Installation](#quick-start-installation)
4. [Manual Installation](#manual-installation)
5. [Configuration](#configuration)
6. [Deployment Options](#deployment-options)
7. [Production Deployment](#production-deployment)
8. [Scaling Considerations](#scaling-considerations)
9. [Security Setup](#security-setup)
10. [Verification & Testing](#verification--testing)

---

## System Requirements

### Minimum Requirements
- **OS**: macOS 10.15+, Ubuntu 20.04+, or compatible Linux distribution
- **CPU**: 4 cores minimum (8+ recommended for multi-agent deployments)
- **RAM**: 8GB minimum (16GB+ recommended)
- **Storage**: 20GB free space for worktrees and agent data
- **Network**: Stable internet connection for Claude AI integration

### Software Dependencies
- **Required**:
  - Bash 4.0 or higher
  - Git 2.30+
  - jq 1.6+
  - Python 3.8+
  - PostgreSQL 13+ (for database-dependent features)

- **Optional**:
  - Docker 20.10+ (for containerized deployments)
  - flock utility (for atomic file locking - Linux)
  - Claude CLI (for AI intelligence features)
  - OpenSSL (for trace ID generation)
  - bc (for mathematical calculations)

---

## Prerequisites

### 1. Install Core Dependencies

#### macOS
```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install bash git jq python@3.11 postgresql@14 coreutils

# Install flock (optional but recommended)
brew install util-linux
```

#### Ubuntu/Debian
```bash
# Update package lists
sudo apt update

# Install dependencies
sudo apt install -y bash git jq python3 python3-pip postgresql postgresql-contrib bc

# flock is included in util-linux (pre-installed on most Linux systems)
```

### 2. Clone Repository
```bash
# Clone the SwarmSH repository
git clone https://github.com/your-org/swarmsh.git
cd swarmsh

# Make all scripts executable
chmod +x *.sh
chmod +x claude/*
chmod +x lib/*
```

### 3. Database Setup (Optional)
```bash
# For database-dependent features
sudo -u postgres createuser --interactive swarmsh
sudo -u postgres createdb swarmsh_development

# Set password
sudo -u postgres psql -c "ALTER USER swarmsh PASSWORD 'your_secure_password';"
```

---

## Quick Start Installation

### One-Command Setup
```bash
# Quick start with default configuration
./quick_start_agent_swarm.sh
```

This command will:
1. Initialize swarm coordination
2. Deploy agents to worktrees
3. Verify environment isolation
4. Start coordinated agents
5. Run initial intelligence analysis
6. Display status and access points

### What Gets Installed
- Agent coordination system
- 3 default worktrees (Ash Phoenix, N8n, Performance)
- Environment isolation configuration
- Claude AI integration setup
- OpenTelemetry tracing
- Monitoring dashboards

---

## Manual Installation

### Step 1: Initialize Coordination System
```bash
# Create necessary directories
mkdir -p agent_coordination
mkdir -p worktrees
mkdir -p shared_coordination
mkdir -p logs
mkdir -p metrics
mkdir -p backups

# Initialize agent status and work claims
echo "[]" > agent_status.json
echo "[]" > work_claims.json
echo "[]" > coordination_log.json
```

### Step 2: Configure Environment
```bash
# Create environment configuration
cat > .env <<EOF
# Core Configuration
AGENT_ID_PREFIX="agent"
COORDINATION_MODE="safe"
TELEMETRY_ENABLED=true
CLAUDE_INTEGRATION=true

# Database Configuration
POSTGRES_USER="swarmsh"
POSTGRES_PASSWORD="your_secure_password"
POSTGRES_HOST="localhost"
POSTGRES_PORT="5432"
POSTGRES_DB="swarmsh_development"

# OpenTelemetry Configuration
OTEL_SERVICE_NAME="s2s-agent-swarm"
OTEL_SERVICE_VERSION="1.1.0"
OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"

# Claude Configuration
CLAUDE_OUTPUT_FORMAT="json"
CLAUDE_STRUCTURED_RESPONSE="true"
CLAUDE_AGENT_CONTEXT="s2s_coordination"
EOF

# Source environment
source .env
```

### Step 3: Initialize Swarm
```bash
# Initialize the agent swarm orchestrator
./agent_swarm_orchestrator.sh init

# This creates:
# - shared_coordination/swarm_config.json
# - shared_coordination/swarm_state.json
# - Initial agent configurations
```

### Step 4: Deploy Agents
```bash
# Deploy agents to worktrees
./agent_swarm_orchestrator.sh deploy

# Start the agents
./agent_swarm_orchestrator.sh start
```

### Step 5: Verify Installation
```bash
# Check swarm status
./agent_swarm_orchestrator.sh status

# Verify worktree creation
./manage_worktrees.sh list

# Test coordination
./test_coordination_helper.sh basic
```

---

## Configuration

### Swarm Configuration File
Location: `shared_coordination/swarm_config.json`

```json
{
  "swarm_id": "swarm_1750009123456789",
  "coordination_strategy": "distributed_consensus",
  "claude_integration": {
    "output_format": "json",
    "intelligence_mode": "structured",
    "coordination_context": "s2s_swarm"
  },
  "worktrees": [
    {
      "name": "ash-phoenix-migration",
      "agent_count": 2,
      "specialization": "ash_migration",
      "focus_areas": ["schema_migration", "action_conversion", "testing"]
    }
  ],
  "coordination_rules": {
    "max_concurrent_work_per_agent": 3,
    "cross_team_collaboration": true,
    "automatic_load_balancing": true,
    "conflict_resolution": "claude_mediated"
  }
}
```

### Agent Configuration
Each agent gets its own configuration file in the worktree:

```json
{
  "agent_id": "agent_ash_migration_1_1750009123456789",
  "specialization": "ash_migration",
  "worktree": "ash-phoenix-migration",
  "claude_context": {
    "focus_areas": ["ash_migration"],
    "output_format": "json",
    "coordination_mode": "s2s_swarm"
  }
}
```

### Environment Isolation
Each worktree gets isolated resources:

```bash
# Port allocations
Main App: 4000
Worktree 1: 4001
Worktree 2: 4002
Worktree 3: 4003

# Database isolation
Main DB: swarmsh_development
Worktree 1 DB: swarmsh_ash_phoenix
Worktree 2 DB: swarmsh_n8n
Worktree 3 DB: swarmsh_performance
```

---

## Deployment Options

### 1. Local Development Deployment
```bash
# Simple local deployment for development
./quick_start_agent_swarm.sh

# Access points:
# - Main app: http://localhost:4000
# - Monitoring: http://localhost:4000/dashboard
# - Telemetry: http://localhost:4318
```

### 2. Docker Deployment
```bash
# Build Docker image
docker build -t swarmsh:latest .

# Run with Docker Compose
docker-compose up -d

# Scale agents
docker-compose scale agent=5
```

### 3. Kubernetes Deployment
```yaml
# swarmsh-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: swarmsh-coordinator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: swarmsh-coordinator
  template:
    metadata:
      labels:
        app: swarmsh-coordinator
    spec:
      containers:
      - name: coordinator
        image: swarmsh:latest
        command: ["./coordination_helper.sh", "serve"]
        env:
        - name: COORDINATION_MODE
          value: "distributed"
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: swarmsh-agents
spec:
  serviceName: swarmsh-agents
  replicas: 5
  selector:
    matchLabels:
      app: swarmsh-agent
  template:
    metadata:
      labels:
        app: swarmsh-agent
    spec:
      containers:
      - name: agent
        image: swarmsh:latest
        command: ["./real_agent_worker.sh"]
```

### 4. Cloud Deployment (AWS Example)
```bash
# Deploy to AWS ECS
aws ecs create-cluster --cluster-name swarmsh-cluster

# Create task definition
aws ecs register-task-definition \
  --family swarmsh-coordinator \
  --container-definitions file://task-definition.json

# Create service
aws ecs create-service \
  --cluster swarmsh-cluster \
  --service-name swarmsh-coordinator \
  --task-definition swarmsh-coordinator:1 \
  --desired-count 1
```

---

## Production Deployment

### 1. System Preparation
```bash
# Create dedicated user
sudo useradd -m -s /bin/bash swarmsh

# Set up directories with proper permissions
sudo mkdir -p /opt/swarmsh
sudo chown -R swarmsh:swarmsh /opt/swarmsh

# Clone repository as swarmsh user
sudo -u swarmsh git clone https://github.com/your-org/swarmsh.git /opt/swarmsh
```

### 2. Systemd Service Setup
```bash
# Create systemd service for coordinator
sudo tee /etc/systemd/system/swarmsh-coordinator.service <<EOF
[Unit]
Description=SwarmSH Coordinator Service
After=network.target postgresql.service

[Service]
Type=simple
User=swarmsh
WorkingDirectory=/opt/swarmsh
ExecStart=/opt/swarmsh/coordination_helper.sh serve
Restart=always
RestartSec=10
Environment="COORDINATION_MODE=production"

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for agents
sudo tee /etc/systemd/system/swarmsh-agent@.service <<EOF
[Unit]
Description=SwarmSH Agent %i
After=network.target swarmsh-coordinator.service

[Service]
Type=simple
User=swarmsh
WorkingDirectory=/opt/swarmsh
ExecStart=/opt/swarmsh/real_agent_worker.sh
Restart=always
RestartSec=10
Environment="AGENT_ID=agent_%i"

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable swarmsh-coordinator
sudo systemctl start swarmsh-coordinator

# Start multiple agents
for i in {1..5}; do
    sudo systemctl enable swarmsh-agent@$i
    sudo systemctl start swarmsh-agent@$i
done
```

### 3. Nginx Reverse Proxy
```nginx
# /etc/nginx/sites-available/swarmsh
server {
    listen 80;
    server_name swarm.example.com;

    location / {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /telemetry {
        proxy_pass http://localhost:4318;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

### 4. Monitoring Setup
```bash
# Install Prometheus node exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvf node_exporter-1.5.0.linux-amd64.tar.gz
sudo cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/

# Configure Prometheus scraping
cat >> /etc/prometheus/prometheus.yml <<EOF
  - job_name: 'swarmsh'
    static_configs:
    - targets: ['localhost:9090']
    - targets: ['localhost:4318']  # OpenTelemetry metrics
EOF
```

---

## Scaling Considerations

### Horizontal Scaling
```bash
# Scale agents dynamically
./agent_swarm_orchestrator.sh scale ash-phoenix-migration 5

# Add new worktree for scaling
./create_s2s_worktree.sh feature-scaling
./agent_swarm_orchestrator.sh deploy-to-worktree feature-scaling 3
```

### Resource Limits
```bash
# Set resource limits per agent
export AGENT_MEMORY_LIMIT="2G"
export AGENT_CPU_LIMIT="1.0"
export MAX_CONCURRENT_WORK=3

# Configure in swarm config
jq '.coordination_rules.resource_limits = {
  "memory_per_agent": "2G",
  "cpu_per_agent": 1.0,
  "max_concurrent_work": 3
}' shared_coordination/swarm_config.json > tmp.json && mv tmp.json shared_coordination/swarm_config.json
```

### Database Connection Pooling
```bash
# Configure connection pooling
export POSTGRES_MAX_CONNECTIONS=100
export POSTGRES_POOL_SIZE=20
export POSTGRES_POOL_TIMEOUT=30
```

---

## Security Setup

### 1. File Permissions
```bash
# Secure sensitive files
chmod 600 .env
chmod 600 shared_coordination/swarm_config.json
chmod 700 *.sh
```

### 2. Secrets Management
```bash
# Use environment variables for secrets
export POSTGRES_PASSWORD_FILE="/run/secrets/db_password"
export CLAUDE_API_KEY_FILE="/run/secrets/claude_api_key"

# Or use a secrets manager
export SECRETS_PROVIDER="aws_secrets_manager"
export SECRETS_REGION="us-east-1"
```

### 3. Network Security
```bash
# Configure firewall rules
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS
sudo ufw allow 4000:4010/tcp # SwarmSH ports
sudo ufw enable
```

### 4. SSL/TLS Setup
```bash
# Generate self-signed certificate for testing
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/swarmsh.key \
  -out /etc/ssl/certs/swarmsh.crt

# Configure in Nginx
ssl_certificate /etc/ssl/certs/swarmsh.crt;
ssl_certificate_key /etc/ssl/private/swarmsh.key;
```

---

## Verification & Testing

### 1. Basic Health Checks
```bash
# Test coordination system
./test_coordination_helper.sh all

# Verify OpenTelemetry
./test_otel_integration.sh

# Check worktree gaps
./test_worktree_gaps.sh
```

### 2. Agent Verification
```bash
# Verify agent registration
jq '.[] | select(.status == "active")' agent_status.json

# Check work claims
jq '.[] | select(.status == "in_progress")' work_claims.json

# Monitor telemetry
tail -f telemetry_spans.jsonl | jq '.'
```

### 3. Performance Testing
```bash
# Run performance benchmarks
./test_coordination_helper.sh performance

# Stress test with multiple agents
for i in {1..10}; do
    ./real_agent_worker.sh &
done

# Monitor resource usage
./realtime_performance_monitor.sh
```

### 4. Integration Testing
```bash
# Test Claude AI integration
./demo_claude_intelligence.sh

# Test cross-worktree coordination
./test_xavos_commands.sh

# Verify E2E traces
./enhance_trace_correlation.sh
```

---

## Post-Installation Steps

1. **Configure Claude CLI** (if using AI features):
   ```bash
   claude auth login
   claude config set output_format json
   ```

2. **Set up monitoring dashboards**:
   - Access Grafana at http://localhost:3000
   - Import SwarmSH dashboard templates

3. **Configure backup strategy**:
   ```bash
   # Set up automated backups
   crontab -e
   # Add: 0 2 * * * /opt/swarmsh/backup_swarm_data.sh
   ```

4. **Review security settings**:
   - Rotate default passwords
   - Configure firewall rules
   - Set up SSL certificates

5. **Performance tuning**:
   - Adjust agent counts based on workload
   - Configure database connection pooling
   - Set appropriate resource limits

---

## Troubleshooting Installation

### Common Issues

1. **"command not found" errors**:
   - Ensure all dependencies are installed
   - Check PATH includes script directory
   - Verify script permissions (chmod +x)

2. **Database connection failures**:
   - Verify PostgreSQL is running
   - Check credentials in .env
   - Ensure database exists

3. **Port conflicts**:
   - Check for existing services on ports 4000-4010
   - Modify port allocations in environment config

4. **Claude integration failures**:
   - Verify Claude CLI is installed and authenticated
   - Check CLAUDE_* environment variables
   - Review Claude API quotas

For detailed troubleshooting, see the [Troubleshooting Guide](./TROUBLESHOOTING.md).

---

This deployment guide provides comprehensive instructions for installing and deploying the SwarmSH system in various environments. For questions or issues, consult the troubleshooting guide or open an issue in the repository.