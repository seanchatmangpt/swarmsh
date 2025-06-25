# SwarmSH Troubleshooting Guide

This guide provides comprehensive troubleshooting steps, common issues, debugging techniques, and solutions for the SwarmSH agent coordination system.

## Table of Contents

1. [Quick Diagnostics](#quick-diagnostics)
2. [Common Issues](#common-issues)
3. [Agent Coordination Problems](#agent-coordination-problems)
4. [Worktree Management Issues](#worktree-management-issues)
5. [Claude AI Integration Problems](#claude-ai-integration-problems)
6. [Database and Persistence Issues](#database-and-persistence-issues)
7. [OpenTelemetry and Monitoring Issues](#opentelemetry-and-monitoring-issues)
8. [Performance Problems](#performance-problems)
9. [Network and Connectivity Issues](#network-and-connectivity-issues)
10. [Security and Permissions Issues](#security-and-permissions-issues)
11. [Debug Mode and Logging](#debug-mode-and-logging)
12. [Recovery Procedures](#recovery-procedures)

---

## Quick Diagnostics

### System Health Check
Run this comprehensive health check first:

```bash
# Quick system status
./agent_swarm_orchestrator.sh status

# Run basic tests
./test_coordination_helper.sh basic

# Check dependencies
./check_dependencies.sh

# View recent errors
tail -n 50 logs/*.log | grep -E "(ERROR|FATAL|error|failed)"
```

### Environment Verification
```bash
# Check core environment variables
echo "AGENT_ID: $AGENT_ID"
echo "COORDINATION_MODE: $COORDINATION_MODE"
echo "TELEMETRY_ENABLED: $TELEMETRY_ENABLED"
echo "CLAUDE_INTEGRATION: $CLAUDE_INTEGRATION"

# Verify file permissions
ls -la *.sh | head -10

# Check process status
pgrep -f coordination_helper
pgrep -f agent_swarm
```

---

## Common Issues

### 1. "Command not found" Errors

**Symptoms:**
```
./coordination_helper.sh: command not found
bash: ./agent_swarm_orchestrator.sh: Permission denied
```

**Solutions:**
```bash
# Fix permissions
chmod +x *.sh
chmod +x claude/*
chmod +x lib/*

# Verify PATH
echo $PATH
export PATH="$PATH:$(pwd)"

# Check file existence
ls -la coordination_helper.sh
```

### 2. JSON Parsing Errors

**Symptoms:**
```
jq: error: Invalid JSON at line 15, column 8
parse error: Expected separator ':' at line 23, column 5
```

**Solutions:**
```bash
# Validate JSON files
jq empty work_claims.json
jq empty agent_status.json
jq empty shared_coordination/swarm_config.json

# Fix JSON syntax
jq empty work_claims.json > /dev/null

# Reset corrupted files
cp work_claims.json.backup work_claims.json
echo "[]" > work_claims.json  # Emergency reset
```

### 3. Lock File Issues

**Symptoms:**
```
ERROR: Cannot acquire lock on work_claims.json.lock
Work claim operation timed out after 30 seconds
```

**Solutions:**
```bash
# Check for stale locks
ls -la *.lock
find . -name "*.lock" -mtime +1  # Find old locks

# Remove stale locks (be careful!)
rm -f work_claims.json.lock
rm -f agent_status.json.lock

# Check for hanging processes
ps aux | grep coordination_helper
pkill -f coordination_helper  # If needed
```

### 4. Agent Registration Failures

**Symptoms:**
```
Agent registration failed: capacity exceeded
ERROR: Agent ID already exists
Invalid specialization type
```

**Solutions:**
```bash
# Check current agent count
jq length agent_status.json

# Find duplicate agent IDs
jq -r '.[].agent_id' agent_status.json | sort | uniq -d

# Reset agent registry
./coordination_helper.sh clean-stale-agents

# Manual cleanup
jq 'map(select(.status == "active"))' agent_status.json > tmp.json
mv tmp.json agent_status.json
```

---

## Agent Coordination Problems

### Work Claim Conflicts

**Problem:** Multiple agents claiming the same work

**Diagnosis:**
```bash
# Find duplicate work claims
jq '.[] | .work_item_id' work_claims.json | sort | uniq -d

# Check work claim history
jq '.[] | select(.work_item_id == "work_123")' work_claims.json
```

**Solutions:**
```bash
# Resolve conflicts automatically
./coordination_helper.sh resolve-conflicts

# Manual resolution
./coordination_helper.sh reassign-work --from agent_1 --to agent_2 --work work_123

# Clear duplicate claims
jq 'group_by(.work_item_id) | map(.[0])' work_claims.json > tmp.json
mv tmp.json work_claims.json
```

### Agent Heartbeat Failures

**Problem:** Agents not reporting heartbeats

**Diagnosis:**
```bash
# Check agent heartbeats
jq '.[] | select(.last_heartbeat < (now - 300))' agent_status.json

# Find unresponsive agents
./coordination_helper.sh health-check --stale-only
```

**Solutions:**
```bash
# Restart specific agent
./coordination_helper.sh restart-agent --agent-id agent_123

# Mark agents as inactive
./coordination_helper.sh mark-inactive --stale-threshold 300

# Force agent re-registration
export FORCE_AGENT_REGISTRATION=true
./coordination_helper.sh register 100 "active" "backend_development"
```

### Work Distribution Imbalances

**Problem:** Uneven work distribution across agents

**Diagnosis:**
```bash
# Check workload distribution
jq 'group_by(.team) | map({team: .[0].team, agents: length, total_workload: map(.current_workload) | add})' agent_status.json

# Analyze work types
jq '.[] | .work_type' work_claims.json | sort | uniq -c
```

**Solutions:**
```bash
# Trigger rebalancing
./coordination_helper.sh rebalance-workload

# Use Claude for optimization
./coordination_helper.sh claude-optimize-assignments

# Manual reassignment
./coordination_helper.sh bulk-reassign --from-team overloaded_team --to-team available_team
```

---

## Worktree Management Issues

### Worktree Creation Failures

**Problem:** Cannot create or access worktrees

**Diagnosis:**
```bash
# Check worktree status
git worktree list
./manage_worktrees.sh list

# Verify git configuration
git config --list | grep worktree
```

**Solutions:**
```bash
# Clean up broken worktrees
git worktree prune

# Remove and recreate
./manage_worktrees.sh cleanup ash-phoenix-migration
./create_ash_phoenix_worktree.sh

# Fix permissions
chmod -R 755 worktrees/
chown -R $USER:$USER worktrees/
```

### Environment Isolation Conflicts

**Problem:** Port or database conflicts between worktrees

**Diagnosis:**
```bash
# Check port allocations
./worktree_environment_manager.sh list
netstat -tulpn | grep :400[0-9]

# Verify database isolation
psql -l | grep swarmsh
```

**Solutions:**
```bash
# Fix port conflicts
./worktree_environment_manager.sh reallocate-ports ash-phoenix-migration

# Resolve database conflicts
./worktree_environment_manager.sh recreate-database ash-phoenix-migration

# Full environment reset
./worktree_environment_manager.sh cleanup ash-phoenix-migration
./worktree_environment_manager.sh setup ash-phoenix-migration worktrees/ash-phoenix-migration
```

### Worktree Synchronization Issues

**Problem:** Worktrees out of sync with main branch

**Diagnosis:**
```bash
# Check git status in each worktree
for worktree in worktrees/*; do
    echo "=== $worktree ==="
    cd "$worktree" && git status && cd - > /dev/null
done
```

**Solutions:**
```bash
# Sync all worktrees
./manage_worktrees.sh sync-all

# Update specific worktree
cd worktrees/ash-phoenix-migration
git fetch origin
git merge origin/main

# Reset worktree if needed
git reset --hard origin/main
```

---

## Claude AI Integration Problems

### Claude CLI Not Available

**Problem:** Claude command not found or not authenticated

**Diagnosis:**
```bash
# Check Claude CLI
which claude
claude --version

# Test authentication
claude auth status
```

**Solutions:**
```bash
# Install Claude CLI
curl -sSf https://install.claude.ai | sh

# Authenticate
claude auth login

# Configure for SwarmSH
export CLAUDE_OUTPUT_FORMAT="json"
export CLAUDE_STRUCTURED_RESPONSE="true"
```

### Claude Response Parsing Errors

**Problem:** Cannot parse Claude AI responses

**Diagnosis:**
```bash
# Test Claude integration
./demo_claude_intelligence.sh

# Check recent Claude responses
grep -A 20 "Claude response:" logs/*.log | tail -50
```

**Solutions:**
```bash
# Fix output format
export CLAUDE_OUTPUT_FORMAT="json"
./coordination_helper.sh claude-analyze-priorities

# Fallback to structured prompts
./coordination_helper.sh claude-structured-query "Analyze agent priorities"

# Disable Claude integration temporarily
export CLAUDE_INTEGRATION=false
```

### Claude API Timeouts

**Problem:** Claude requests timing out

**Diagnosis:**
```bash
# Check API response times
grep "Claude timeout" logs/*.log
curl -w "%{time_total}" https://api.anthropic.com/v1/health
```

**Solutions:**
```bash
# Increase timeout
export CLAUDE_TIMEOUT_SECONDS=60

# Use async mode
export CLAUDE_ASYNC_MODE=true

# Implement retries
export CLAUDE_RETRY_ATTEMPTS=3
export CLAUDE_RETRY_DELAY=2000
```

---

## Database and Persistence Issues

### Database Connection Failures

**Problem:** Cannot connect to PostgreSQL

**Diagnosis:**
```bash
# Test database connection
psql "postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB" -c "SELECT 1;"

# Check PostgreSQL service
systemctl status postgresql
sudo -u postgres pg_lsclusters
```

**Solutions:**
```bash
# Start PostgreSQL
sudo systemctl start postgresql

# Create database and user
sudo -u postgres createdb swarmsh_development
sudo -u postgres createuser swarmsh
sudo -u postgres psql -c "ALTER USER swarmsh PASSWORD 'secure_password';"

# Fix connection string
export DATABASE_URL="postgresql://swarmsh:secure_password@localhost:5432/swarmsh_development"
```

### JSON File Corruption

**Problem:** Corrupted JSON data files

**Diagnosis:**
```bash
# Check for corruption
jq empty work_claims.json agent_status.json coordination_log.json

# Find the corrupted line using jq
if jq empty work_claims.json 2>/dev/null; then
    echo "Valid JSON"
else
    echo "Invalid JSON - use 'jq .' to see detailed error"
    jq . work_claims.json
fi
```

**Solutions:**
```bash
# Restore from backup
cp backups/work_claims_$(date +%Y%m%d).json work_claims.json

# Emergency recovery
echo "[]" > work_claims.json
echo "[]" > agent_status.json

# Recreate from logs
./coordination_helper.sh rebuild-from-logs
```

### Data Consistency Issues

**Problem:** Inconsistent data between files

**Diagnosis:**
```bash
# Check data consistency
./test_coordination_helper.sh data-consistency

# Find orphaned work claims
jq -r '.[] | select(.agent_id as $aid | [inputs | .[] | .agent_id] | index($aid) | not) | .work_item_id' work_claims.json agent_status.json
```

**Solutions:**
```bash
# Run consistency repair
./coordination_helper.sh repair-data-consistency

# Clean orphaned records
./coordination_helper.sh clean-orphaned-data

# Full data rebuild
./coordination_helper.sh backup-data
./coordination_helper.sh reset-data
./coordination_helper.sh restore-data
```

---

## OpenTelemetry and Monitoring Issues

### Telemetry Export Failures

**Problem:** Traces not being exported

**Diagnosis:**
```bash
# Check telemetry configuration
env | grep OTEL_

# Test OTLP endpoint
curl -X POST "$OTEL_EXPORTER_OTLP_ENDPOINT/v1/traces" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Check local telemetry files
ls -la telemetry_spans.jsonl
tail -5 telemetry_spans.jsonl
```

**Solutions:**
```bash
# Fix OTLP endpoint
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"

# Use file exporter as fallback
export OTEL_TRACES_EXPORTER="file"
export OTEL_FILE_PATH="telemetry_spans.jsonl"

# Test telemetry generation
./test_otel_integration.sh
```

### Missing Trace Correlation

**Problem:** Traces not properly correlated

**Diagnosis:**
```bash
# Check trace correlation
./enhance_trace_correlation.sh

# Find orphaned spans
grep -v "parent_span_id" telemetry_spans.jsonl | wc -l
```

**Solutions:**
```bash
# Fix trace correlation
export FORCE_TRACE_ID="$(openssl rand -hex 16)"
./coordination_helper.sh claim "test" "test" "low"

# Rebuild trace relationships
./enhance_trace_correlation.sh --rebuild

# Enable debug tracing
export OTEL_LOG_LEVEL="debug"
```

---

## Performance Problems

### Slow Coordination Operations

**Problem:** Coordination operations taking too long

**Diagnosis:**
```bash
# Time operations
time ./coordination_helper.sh claim "test" "test" "low"

# Check system resources
top -p $(pgrep -f coordination_helper)
iostat -x 1 5

# Analyze bottlenecks
strace -c -p $(pgrep -f coordination_helper)
```

**Solutions:**
```bash
# Enable faster locking
export COORDINATION_MODE="simple"

# Reduce JSON file sizes
./coordination_helper.sh archive-old-data

# Use memory-based operations
export USE_MEMORY_CACHE=true
export CACHE_SIZE_MB=100
```

### High Memory Usage

**Problem:** Excessive memory consumption

**Diagnosis:**
```bash
# Check memory usage
ps aux | grep -E "(coordination|agent)" | awk '{sum+=$6} END {print sum/1024 " MB"}'

# Monitor memory leaks
valgrind --leak-check=full ./coordination_helper.sh dashboard
```

**Solutions:**
```bash
# Limit agent count
./agent_swarm_orchestrator.sh scale-down 3

# Clean up temporary files
./cleanup_synthetic_work.sh
./comprehensive_cleanup.sh

# Restart services
./agent_swarm_orchestrator.sh restart
```

### CPU Utilization Issues

**Problem:** High CPU usage

**Diagnosis:**
```bash
# Check CPU usage per process
top -o %CPU | head -20

# Profile CPU usage
perf record -g ./coordination_helper.sh dashboard
perf report
```

**Solutions:**
```bash
# Reduce polling frequency
export HEARTBEAT_INTERVAL=120
export MONITOR_INTERVAL=60

# Use efficient JSON processing
export JQ_OPTIMIZE=true

# Implement caching
export ENABLE_RESULT_CACHE=true
```

---

## Network and Connectivity Issues

### Port Conflicts

**Problem:** Required ports already in use

**Diagnosis:**
```bash
# Check port usage
netstat -tulpn | grep -E ":400[0-9]"
lsof -i :4000-4010

# Find conflicting processes
fuser 4000/tcp
```

**Solutions:**
```bash
# Kill conflicting processes
sudo fuser -k 4000/tcp

# Use alternative ports
export PORT_ALLOCATION_START=5000
./worktree_environment_manager.sh reallocate-all

# Configure port ranges
jq '.worktrees[].resource_allocation.port_range = [5001, 5005]' shared_coordination/swarm_config.json > tmp.json
mv tmp.json shared_coordination/swarm_config.json
```

### DNS Resolution Issues

**Problem:** Cannot resolve hostnames

**Diagnosis:**
```bash
# Test DNS resolution
nslookup localhost
dig localhost

# Check /etc/hosts
cat /etc/hosts | grep localhost
```

**Solutions:**
```bash
# Use IP addresses
export POSTGRES_HOST="127.0.0.1"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://127.0.0.1:4318"

# Fix /etc/hosts
echo "127.0.0.1 localhost" | sudo tee -a /etc/hosts
```

---

## Security and Permissions Issues

### File Permission Errors

**Problem:** Cannot read/write configuration files

**Diagnosis:**
```bash
# Check file permissions
ls -la *.json *.sh
find . -name "*.json" ! -readable

# Check directory permissions
ls -ld . worktrees/ shared_coordination/
```

**Solutions:**
```bash
# Fix file permissions
chmod 644 *.json
chmod 755 *.sh
chmod 755 worktrees/ shared_coordination/

# Fix ownership
chown -R $USER:$USER .
```

### Secret Management Issues

**Problem:** Secrets not properly configured

**Diagnosis:**
```bash
# Check environment variables
env | grep -E "(PASSWORD|SECRET|KEY)" | sed 's/=.*/=***/'

# Verify secret files
ls -la /run/secrets/
```

**Solutions:**
```bash
# Set environment variables
export POSTGRES_PASSWORD="secure_password"
export CLAUDE_API_KEY="your_api_key"

# Use secret files
export POSTGRES_PASSWORD_FILE="/run/secrets/db_password"
```

---

## Debug Mode and Logging

### Enable Debug Mode

```bash
# Enable comprehensive debugging
export DEBUG=true
export LOG_LEVEL="debug"
export VERBOSE=true

# Enable script debugging
export BASH_DEBUG=true
set -x  # In shell scripts

# Enable component-specific debugging
export COORDINATION_DEBUG=true
export AGENT_DEBUG=true
export TELEMETRY_DEBUG=true
```

### Advanced Logging

```bash
# Tail all logs in real-time
tail -f logs/*.log &

# Filter for errors
tail -f logs/*.log | grep -E "(ERROR|FATAL|error|failed)"

# JSON log parsing
tail -f telemetry_spans.jsonl | jq '.operation_name, .status, .duration_ms'

# Structured log analysis
jq -r 'select(.level == "ERROR") | "\(.timestamp) \(.message)"' logs/coordination.log
```

### Trace Debugging

```bash
# Force specific trace ID
export FORCE_TRACE_ID="debug123456789abcdef"

# Enable trace debugging
export OTEL_LOG_LEVEL="debug"
export TRACE_DEBUG=true

# Follow trace across components
grep "debug123456789abcdef" logs/*.log telemetry_spans.jsonl
```

---

## Recovery Procedures

### Emergency System Recovery

```bash
#!/bin/bash
# emergency_recovery.sh

echo "🚨 EMERGENCY SWARMSH RECOVERY"
echo "=============================="

# 1. Stop all processes
echo "Stopping all SwarmSH processes..."
pkill -f coordination_helper
pkill -f agent_swarm
pkill -f real_agent

# 2. Backup current state
echo "Backing up current state..."
mkdir -p emergency_backup_$(date +%s)
cp *.json emergency_backup_*/
cp -r shared_coordination emergency_backup_*/

# 3. Clean up lock files
echo "Cleaning lock files..."
rm -f *.lock

# 4. Reset to known good state
echo "Resetting to known good state..."
cp backups/work_claims_$(date +%Y%m%d).json work_claims.json 2>/dev/null || echo "[]" > work_claims.json
cp backups/agent_status_$(date +%Y%m%d).json agent_status.json 2>/dev/null || echo "[]" > agent_status.json

# 5. Reinitialize system
echo "Reinitializing system..."
./agent_swarm_orchestrator.sh init

# 6. Start with minimal configuration
echo "Starting minimal configuration..."
./agent_swarm_orchestrator.sh deploy --minimal

echo "✅ Emergency recovery complete"
echo "Run './agent_swarm_orchestrator.sh status' to verify"
```

### Data Recovery

```bash
# Recover from telemetry logs
./coordination_helper.sh recover-from-telemetry telemetry_spans.jsonl

# Rebuild from git history
git log --oneline --since="1 day ago" | while read commit; do
    echo "Checking commit: $commit"
    # Analyze commit for coordination data
done

# Restore from backup
latest_backup=$(ls -t backups/ | head -1)
echo "Restoring from: $latest_backup"
cp "backups/$latest_backup" work_claims.json
```

### Health Restoration

```bash
# Full system health restoration
./test_coordination_helper.sh all
./test_otel_integration.sh
./test_worktree_gaps.sh

# Verify all components
./agent_swarm_orchestrator.sh status
./coordination_helper.sh dashboard
./manage_worktrees.sh list
```

---

## Getting Help

### Log Information for Support

When reporting issues, please include:

```bash
# System information
uname -a
cat /etc/os-release

# SwarmSH version and configuration
git rev-parse HEAD
env | grep -E "(AGENT|COORDINATION|OTEL|CLAUDE)" | sort

# Recent logs
tail -100 logs/*.log > support_logs.txt

# System status
./agent_swarm_orchestrator.sh status > status_output.txt
```

### Debug Data Collection

```bash
#!/bin/bash
# collect_debug_info.sh

DEBUG_DIR="debug_$(date +%s)"
mkdir -p "$DEBUG_DIR"

# Collect configuration
cp *.json "$DEBUG_DIR/"
cp .env "$DEBUG_DIR/" 2>/dev/null
cp -r shared_coordination "$DEBUG_DIR/"

# Collect logs
cp -r logs "$DEBUG_DIR/"

# Collect system info
uname -a > "$DEBUG_DIR/system_info.txt"
ps aux | grep -E "(coordination|agent)" > "$DEBUG_DIR/processes.txt"
netstat -tulpn | grep :400 > "$DEBUG_DIR/ports.txt"

# Create archive
tar -czf "${DEBUG_DIR}.tar.gz" "$DEBUG_DIR"
echo "Debug info collected in: ${DEBUG_DIR}.tar.gz"
```

---

This troubleshooting guide covers the most common issues and their solutions. For complex issues not covered here, enable debug mode, collect logs, and consult the development team or open an issue in the repository.