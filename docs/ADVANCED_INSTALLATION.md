# Advanced Installation Guide

> Custom installation procedures, environment-specific configurations, and troubleshooting for SwarmSH deployments.

---

## Table of Contents

1. [Custom Source Installation](#custom-source-installation)
2. [Container Deployment](#container-deployment)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [Environment-Specific Setup](#environment-specific-setup)
5. [Dependency Management](#dependency-management)
6. [Performance Optimization](#performance-optimization)
7. [Security Hardening](#security-hardening)
8. [Troubleshooting Installation](#troubleshooting-installation)

---

## Custom Source Installation

### Installation from Source (Advanced)

For production deployments or custom configurations:

```bash
# 1. Clone specific version
git clone --branch v1.1.0 https://github.com/seanchatmangpt/swarmsh.git
cd swarmsh

# 2. Verify dependencies
./scripts/verify_dependencies.sh

# 3. Install to system path
sudo make install

# 4. Verify installation
swarmsh --version

# 5. Initialize configuration
swarmsh init --config-path /etc/swarmsh/config.yaml
```

### Custom Paths and Permissions

```bash
# Install to custom location
export SWARMSH_HOME=/opt/swarmsh
export SWARMSH_DATA=/var/lib/swarmsh
export SWARMSH_CONFIG=/etc/swarmsh

make install \
  PREFIX=$SWARMSH_HOME \
  DATA_DIR=$SWARMSH_DATA \
  CONFIG_DIR=$SWARMSH_CONFIG

# Set permissions
sudo chown -R swarmsh:swarmsh $SWARMSH_DATA
sudo chmod 750 $SWARMSH_DATA
```

### Building from Source with Custom Options

```bash
# Build with specific features
make build \
  ENABLE_OTEL=1 \
  ENABLE_PROMETHEUS=1 \
  ENABLE_AI_INTEGRATION=1 \
  FEATURE_FLAGS="telemetry,automation,worktrees"

# Optimize for performance
make build-optimized \
  OPTIMIZATION_LEVEL=3 \
  ENABLE_CACHING=1

# Create distribution package
make dist
ls -la dist/swarmsh-*.tar.gz
```

---

## Container Deployment

### Docker Image Build

```dockerfile
# Dockerfile for SwarmSH
FROM bash:5.2

# Install dependencies
RUN apk add --no-cache \
    jq \
    python3 \
    python3-dev \
    git \
    util-linux \
    curl

# Install SwarmSH
RUN git clone https://github.com/seanchatmangpt/swarmsh.git /opt/swarmsh
WORKDIR /opt/swarmsh
RUN chmod +x *.sh

# Create data directories
RUN mkdir -p /var/lib/swarmsh/{agent_coordination,real_agents,metrics,logs} \
    && chmod 755 /var/lib/swarmsh

# Set environment
ENV PATH="/opt/swarmsh:${PATH}"
ENV SWARMSH_DATA="/var/lib/swarmsh"
ENV TELEMETRY_ENABLED="true"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ./coordination_helper.sh health || exit 1

ENTRYPOINT ["/opt/swarmsh/coordination_helper.sh"]
CMD ["dashboard"]
```

### Docker Compose Setup

```yaml
version: '3.8'

services:
  swarmsh:
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      TELEMETRY_ENABLED: "true"
      OTEL_EXPORTER_OTLP_ENDPOINT: "http://otel-collector:4317"
      COORDINATION_MODE: "atomic"
      LOG_LEVEL: "info"
    volumes:
      - swarmsh_data:/var/lib/swarmsh
      - swarmsh_config:/etc/swarmsh
    ports:
      - "4000:4000"
    networks:
      - swarmsh_network
    healthcheck:
      test: ["CMD", "bash", "-c", "coordination_helper.sh health"]
      interval: 30s
      timeout: 10s
      retries: 3

  otel-collector:
    image: otel/opentelemetry-collector:latest
    volumes:
      - ./otel-collector-config.yaml:/etc/otel-collector-config.yaml
    command:
      - "--config=/etc/otel-collector-config.yaml"
    ports:
      - "4317:4317"
    networks:
      - swarmsh_network

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - swarmsh_network

volumes:
  swarmsh_data:
  swarmsh_config:
  prometheus_data:

networks:
  swarmsh_network:
    driver: bridge
```

### Building Container Images

```bash
# Build Docker image
docker build -t swarmsh:v1.1.0 .

# Run container
docker run -d \
  --name swarmsh \
  -v swarmsh_data:/var/lib/swarmsh \
  -e TELEMETRY_ENABLED=true \
  -e COORDINATION_MODE=atomic \
  -p 4000:4000 \
  swarmsh:v1.1.0

# Verify running
docker logs swarmsh
docker exec swarmsh coordination_helper.sh dashboard
```

---

## Kubernetes Deployment

### Helm Chart Setup

```bash
# Add SwarmSH Helm repository
helm repo add swarmsh https://charts.swarmsh.io
helm repo update

# Install SwarmSH release
helm install swarmsh swarmsh/swarmsh \
  --namespace swarmsh \
  --create-namespace \
  --values custom-values.yaml

# Upgrade release
helm upgrade swarmsh swarmsh/swarmsh \
  --namespace swarmsh \
  --values custom-values.yaml

# Check status
helm status swarmsh -n swarmsh
kubectl get pods -n swarmsh
```

### Custom Kubernetes Manifests

```yaml
# StatefulSet for SwarmSH Coordinator
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: swarmsh-coordinator
  namespace: swarmsh
spec:
  serviceName: swarmsh
  replicas: 3
  selector:
    matchLabels:
      app: swarmsh
      component: coordinator
  template:
    metadata:
      labels:
        app: swarmsh
        component: coordinator
    spec:
      serviceAccountName: swarmsh
      containers:
      - name: coordinator
        image: swarmsh:v1.1.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 4000
          name: coordination
        - containerPort: 9090
          name: metrics
        env:
        - name: TELEMETRY_ENABLED
          value: "true"
        - name: COORDINATION_MODE
          value: "atomic"
        - name: OTEL_EXPORTER_OTLP_ENDPOINT
          value: "http://otel-collector:4317"
        resources:
          requests:
            cpu: "500m"
            memory: "512Mi"
          limits:
            cpu: "2"
            memory: "2Gi"
        volumeMounts:
        - name: data
          mountPath: /var/lib/swarmsh
        - name: config
          mountPath: /etc/swarmsh
        livenessProbe:
          exec:
            command: ["bash", "-c", "coordination_helper.sh health"]
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          exec:
            command: ["bash", "-c", "coordination_helper.sh health"]
          initialDelaySeconds: 5
          periodSeconds: 10
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: fast-ssd
      resources:
        requests:
          storage: 10Gi
  - metadata:
      name: config
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: standard
      resources:
        requests:
          storage: 1Gi

---
# Service
apiVersion: v1
kind: Service
metadata:
  name: swarmsh
  namespace: swarmsh
spec:
  clusterIP: None
  selector:
    app: swarmsh
  ports:
  - port: 4000
    name: coordination
  - port: 9090
    name: metrics
```

---

## Environment-Specific Setup

### Development Environment

```bash
# Development setup with debugging
export SWARMSH_ENV="development"
export LOG_LEVEL="debug"
export TELEMETRY_ENABLED="true"
export COORDINATION_MODE="simple"  # Use simple mode for easier debugging
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# Initialize with test data
make dev-init
make seed-test-agents
make seed-test-work

# Run with hot reload
make dev-watch
```

### Staging Environment

```bash
# Staging setup with production-like config
export SWARMSH_ENV="staging"
export LOG_LEVEL="info"
export TELEMETRY_ENABLED="true"
export COORDINATION_MODE="atomic"
export FLOCK_TIMEOUT="30"
export CACHE_TTL="5"

# Deploy with monitoring
docker-compose -f docker-compose.staging.yml up -d
make verify-staging
```

### Production Environment

```bash
# Production hardened setup
export SWARMSH_ENV="production"
export LOG_LEVEL="warn"
export TELEMETRY_ENABLED="true"
export COORDINATION_MODE="atomic"
export FLOCK_TIMEOUT="60"
export CACHE_TTL="10"
export HEALTH_CRITICAL_THRESHOLD="60"

# High availability
helm install swarmsh swarmsh/swarmsh \
  --namespace swarmsh-prod \
  --values production-values.yaml \
  --set replicas=5 \
  --set resources.limits.cpu=4 \
  --set resources.limits.memory=8Gi

# Post-deployment validation
make validate-production
```

---

## Dependency Management

### Dependency Resolution

```bash
# Check all dependencies
./scripts/check_dependencies.sh

# Install missing dependencies
./scripts/install_dependencies.sh

# Verify specific dependency
./scripts/verify_single_dep.sh jq
```

### Custom Dependency Versions

```bash
# Pin specific versions
export BASH_VERSION="5.2"
export JQ_VERSION="1.7"
export PYTHON_VERSION="3.11"

# Install specific versions
make install-deps-pinned \
  BASH_VERSION=$BASH_VERSION \
  JQ_VERSION=$JQ_VERSION \
  PYTHON_VERSION=$PYTHON_VERSION
```

### Offline Installation

For environments without internet access:

```bash
# 1. Download all dependencies on internet-connected machine
make download-deps-offline
tar czf swarmsh-offline-deps.tar.gz offline_deps/

# 2. Transfer to offline environment
scp swarmsh-offline-deps.tar.gz user@offline-server:/tmp/

# 3. Install offline
tar xzf /tmp/swarmsh-offline-deps.tar.gz
make install-offline-deps
```

---

## Performance Optimization

### System-Level Tuning

```bash
# Kernel tuning for high concurrency
cat >> /etc/sysctl.conf << EOF
# File descriptors
fs.file-max = 2097152
fs.nr_open = 2097152

# Network tuning
net.core.somaxconn = 32768
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 1024 65535

# Connection handling
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
EOF

sudo sysctl -p
```

### Application Tuning

```bash
# File locking optimization
export FLOCK_TIMEOUT=60
export FLOCK_RETRIES=3
export FLOCK_BACKOFF_MS=100

# Batch processing
export BATCH_SIZE=200
export BATCH_TIMEOUT=5000

# Memory management
export CACHE_TTL=15
export CACHE_MAX_SIZE=1000
```

### I/O Optimization

```bash
# Enable write-ahead logging
export WAL_ENABLED=1
export WAL_SYNC_INTERVAL=5000

# Connection pooling
export CONNECTION_POOL_SIZE=50
export CONNECTION_POOL_TIMEOUT=30000
```

---

## Security Hardening

### File System Security

```bash
# Restrict permissions
sudo chmod 750 /opt/swarmsh
sudo chmod 640 /etc/swarmsh/config.yaml
sudo chmod 700 /var/lib/swarmsh

# SELinux (if enabled)
sudo semanage fcontext -a -t bin_t "/opt/swarmsh(/.*)?"
sudo restorecon -Rv /opt/swarmsh
```

### Credential Management

```bash
# Use external secret management
export CLAUDE_API_KEY=$(vault kv get -field=key secret/swarmsh/claude)
export OLLAMA_API_KEY=$(vault kv get -field=key secret/swarmsh/ollama)

# Secure credential file
echo "CLAUDE_API_KEY=$CLAUDE_API_KEY" > ~/.swarmsh/credentials
chmod 600 ~/.swarmsh/credentials

# Use in scripts
source ~/.swarmsh/credentials
```

### Network Security

```bash
# Restrict network access
sudo ufw allow from 10.0.0.0/8 to any port 4000
sudo ufw allow from 192.168.0.0/16 to any port 9090

# Enable HTTPS for external APIs
export OTEL_EXPORTER_OTLP_CERTIFICATE="/path/to/ca.pem"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer TOKEN"
```

### Audit & Compliance

```bash
# Enable audit logging
export AUDIT_ENABLED=1
export AUDIT_LOG_PATH=/var/log/swarmsh/audit.log
export AUDIT_RETENTION_DAYS=90

# Compliance validation
make validate-compliance
./scripts/audit_report.sh
```

---

## Troubleshooting Installation

### Installation Verification

```bash
# Comprehensive verification
./scripts/verify_installation.sh

# Check specific components
swarmsh --version
swarmsh verify-components
swarmsh test-connectivity
```

### Common Installation Issues

**Issue: "jq: command not found"**
```bash
# macOS
brew install jq

# Linux
sudo apt install jq

# Manual
wget https://github.com/stedolan/jq/releases/download/jq-1.7/jq-linux-amd64
sudo mv jq-linux-amd64 /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq
```

**Issue: "flock: command not found"**
```bash
# macOS
brew install util-linux

# Linux (usually pre-installed)
sudo apt install util-linux

# Fallback: use simple mode
export COORDINATION_MODE="simple"
```

**Issue: Permission denied errors**
```bash
# Check file permissions
ls -la /opt/swarmsh
ls -la /var/lib/swarmsh

# Fix ownership
sudo chown -R $USER:$USER /opt/swarmsh
sudo chown -R $USER:$USER /var/lib/swarmsh

# Or use proper service user
sudo useradd -r -s /bin/false swarmsh
sudo chown -R swarmsh:swarmsh /var/lib/swarmsh
```

### Post-Installation Testing

```bash
# Run test suite
make test-installation

# Verify all components
./scripts/verify_installation.sh

# Test core functionality
./coordination_helper.sh register 100 "active" "test"
./coordination_helper.sh claim "test" "verification" "high"
./coordination_helper.sh dashboard
```

---

## Installation Scripts

Pre-built scripts for common scenarios:

```bash
# Quick install (recommended)
curl -fsSL https://install.swarmsh.io | bash

# Install specific version
curl -fsSL https://install.swarmsh.io | bash -s v1.1.0

# Install to custom location
INSTALL_PATH=/opt/custom/swarmsh \
curl -fsSL https://install.swarmsh.io | bash

# Docker install
docker run -d swarmsh:latest
```

---

<div align="center">

**[Back to Installation](../GETTING_STARTED.md)** • **[Configuration](../CONFIGURATION_REFERENCE.md)** • **[Deployment](../DEPLOYMENT_GUIDE.md)**

</div>
