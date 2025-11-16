# 8020 Automation Implementation

This file documents how 8020 automation is configured in SwarmSH.

## Production Setup (with crontab)

In production environments with `crontab`, the following jobs are installed:

```bash
# Health monitoring every 2 hours
0 */2 * * * /home/user/swarmsh/cron-health-monitor.sh

# Telemetry management every 4 hours
0 */4 * * * /home/user/swarmsh/cron-telemetry-manager.sh maintain

# Work queue optimization daily at 3 AM
0 3 * * * /home/user/swarmsh/8020_cron_automation.sh

# Performance collection every 6 hours
0 */6 * * * /home/user/swarmsh/cron-performance-collector.sh
```

**To install in production:**
```bash
./cron-setup.sh install
crontab -l | grep swarmsh  # Verify
```

## Sandbox/Development Alternative

In environments without crontab (sandboxes, containers), use manual execution:

```bash
# Health check
./cron-health-monitor.sh

# Telemetry maintenance
./cron-telemetry-manager.sh maintain

# Work optimization
./8020_cron_automation.sh

# Performance collection
./cron-performance-collector.sh
```

## Docker/Container Setup

For containerized deployments, use supervisor or a custom entrypoint:

```yaml
services:
  swarmsh:
    image: swarmsh:latest
    entrypoint: /entrypoint.sh
    # entrypoint.sh runs cron daemon and keeps container alive
```

## Manual Automation Loop (for testing/development)

Run this to test 8020 automation without crontab:

```bash
#!/bin/bash
# Manual 8020 automation loop (for development)

while true; do
  echo "[$(date)] Running 8020 health check..."
  ./cron-health-monitor.sh

  echo "[$(date)] Running telemetry management..."
  ./cron-telemetry-manager.sh maintain

  echo "[$(date)] Running performance collection..."
  ./cron-performance-collector.sh

  echo "[$(date)] Sleeping 4 hours..."
  sleep 14400  # 4 hours
done
```

## Current Status

- **Production (with crontab):** Ready to install with `./cron-setup.sh install`
- **Development (without crontab):** Can run scripts manually or with bash loop
- **Docker:** Use provided container setup or custom entrypoint
- **Verified:** 8020 scripts exist and work when executed

## Key 8020 Operations

These operations run automatically (in production) or manually (in development):

1. **Health Monitoring** (every 2 hours)
   - Checks system health
   - Records issues
   - Alerts if health < 70

2. **Telemetry Management** (every 4 hours)
   - Archives old telemetry
   - Manages disk space
   - Maintains performance

3. **Work Queue Optimization** (daily at 3 AM)
   - Archives completed work
   - Optimizes active work queue
   - Improves performance

4. **Performance Collection** (every 6 hours)
   - Collects performance metrics
   - Analyzes trends
   - Generates reports

## Testing Automation

To verify automation is working:

```bash
# Test individual scripts
./cron-health-monitor.sh
./cron-telemetry-manager.sh health
./8020_cron_automation.sh --test

# Check telemetry for automation events
grep "8020_cron_log\|8020.cron" telemetry_spans.jsonl | tail -20 | jq '.'

# Monitor in real-time
tail -f telemetry_spans.jsonl | grep "8020_cron"
```
