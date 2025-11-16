# 📊 Telemetry-Driven Development Guide (v1.1.0)

> **Version:** 1.1.0 | **Last Updated:** November 16, 2025

## Why Telemetry Matters

This system generates detailed telemetry for EVERY operation. With v1.1.0, telemetry is now more comprehensive with:
- **Auto-generated dashboards** - Visual representation of live data
- **Enhanced trace correlation** - Better distributed tracing
- **Real-time health monitoring** - Continuous system observation
- **Comprehensive test coverage** - 100% test pass rate with 80/20 strategy

As Claude Code, you should:
- ✅ **Never trust assumptions** - Always verify with telemetry
- ✅ **Make data-driven decisions** - Let metrics guide your work
- ✅ **Monitor continuously** - Keep telemetry visible while working
- ✅ **Use auto-generated visuals** - Refer to dashboards for insights
- ✅ **Track test coverage** - Refer to TEST_COVERAGE_REPORT_v1.1.0.md

## Quick Start Checklist

When you begin working on this codebase:

### 1. First Commands (Run These!)
```bash
# Get system overview
make telemetry-stats

# Check health
cat system_health_report.json | jq '.'

# See recent activity  
tail -20 telemetry_spans.jsonl | jq '.operation_name'

# Generate visual dashboard
make diagrams-dashboard
```

### 2. Understand the Current State

Look for these key indicators:

**Health Score**:
- 90-100: Excellent ✅
- 70-89: Good ✅
- 50-69: Warning ⚠️
- 0-49: Critical ❌

**Operation Rate** (from telemetry-stats):
- Normal: 10-50 ops/hour
- High: 50+ ops/hour (check resources)
- Low: <10 ops/hour (check automation)

### 3. Monitor While Working

Keep a monitoring terminal open:
```bash
# Choose based on your task duration
make monitor-24h    # For regular work
make monitor-7d     # For long investigations
```

## Common Patterns to Recognize

### Pattern 1: Healthy Automation
```json
{
  "operation": "8020_cron_log",
  "status": "completed",
  "health_score": 85
}
```
✅ This is good - automation running smoothly

### Pattern 2: System Under Stress
```json
{
  "operation": "health_monitor",
  "status": "warning",
  "resource_issues": 1
}
```
⚠️ Address resource issues before adding load

### Pattern 3: Failed Operations
```json
{
  "operation": "work_optimization",
  "status": "error",
  "error": "file_locked"
}
```
❌ Investigate immediately - may indicate race conditions

## Telemetry-Based Workflows

### Investigating Issues
```bash
# 1. Find when issues started
grep -i error telemetry_spans.jsonl | jq '.timestamp' | sort | head -5

# 2. Identify problematic operations
grep -i error telemetry_spans.jsonl | jq '.operation_name' | sort | uniq -c

# 3. Check error patterns
grep -i error telemetry_spans.jsonl | jq '{op:.operation_name, err:.error}' | sort | uniq
```

### Performance Analysis
```bash
# 1. Compare timeframes
./compare-timeframes.sh

# 2. Find slow operations
jq 'select(.duration_ms > 1000)' telemetry_spans.jsonl | jq '{op:.operation_name, ms:.duration_ms}'

# 3. Check operation frequency
jq '.operation_name' telemetry_spans.jsonl | sort | uniq -c | sort -rn | head -10
```

### Validating Changes
```bash
# Before making changes
BEFORE_COUNT=$(wc -l < telemetry_spans.jsonl)

# Make your changes...

# After changes
AFTER_COUNT=$(wc -l < telemetry_spans.jsonl)
NEW_SPANS=$((AFTER_COUNT - BEFORE_COUNT))

# Check new spans
tail -n $NEW_SPANS telemetry_spans.jsonl | jq '.'
```

## Advanced Telemetry Queries

### Find All Operations by a Specific Service
```bash
jq 'select(.service.name == "s2s-coordination")' telemetry_spans.jsonl
```

### Operations in Last Hour
```bash
HOUR_AGO=$(date -u -d "1 hour ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-1H +%Y-%m-%dT%H:%M:%SZ)
jq --arg ts "$HOUR_AGO" 'select(.timestamp >= $ts)' telemetry_spans.jsonl
```

### Health Score Trends
```bash
grep "health_score" telemetry_spans.jsonl | jq '.health_score' | tail -20
```

### Error Rate Calculation
```bash
TOTAL=$(wc -l < telemetry_spans.jsonl)
ERRORS=$(grep -c '"status":"error"' telemetry_spans.jsonl)
echo "Error rate: $(( ERRORS * 100 / TOTAL ))%"
```

## Creating Your Own Telemetry

When adding new features, always add telemetry:

```bash
# In your scripts
log_telemetry() {
    local operation="$1"
    local status="$2"
    local metrics="$3"
    
    echo "{\"operation\":\"$operation\",\"status\":\"$status\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"metrics\":$metrics}" >> telemetry_spans.jsonl
}

# Usage
log_telemetry "my_feature" "completed" '{"items_processed":42}'
```

## Red Flags in Telemetry

Watch for these warning signs:

1. **Sudden drop in operation count** - Automation may have stopped
2. **Increasing error rates** - System degradation
3. **Missing recent timestamps** - Cron jobs may be failing
4. **Health score below 70** - Immediate attention needed
5. **Very high operation rates** - Possible infinite loops

## Best Practices

1. **Start every session** with `make telemetry-stats`
2. **Check health** before making system changes
3. **Monitor continuously** with `make monitor-24h`
4. **Validate with telemetry** after every change
5. **Trust the data**, not your assumptions

## Emergency Commands

If things go wrong:

```bash
# Check what's happening NOW
tail -f telemetry_spans.jsonl | jq '.'

# Find recent errors
grep error telemetry_spans.jsonl | tail -20 | jq '.'

# Emergency health check
./cron-health-monitor.sh

# Stop all automation
make cron-remove

# Archive telemetry and start fresh
mv telemetry_spans.jsonl telemetry_backup_$(date +%s).jsonl
```

Remember: **The telemetry never lies!** Use it to guide every decision.