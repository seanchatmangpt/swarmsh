# 🚀 SwarmSH v1.1.0 Quick Reference Card

> Last updated: November 16, 2025 | Version: 1.1.0

## ✨ v1.1.0 Highlights

- **Real Telemetry Dashboard** - Auto-generated live visualization
- **Worktree Development** - Parallel feature branches with coordination
- **80/20 Test Coverage** - 100% passing (69+ tests)
- **60+ Makefile Targets** - Comprehensive automation
- **Enhanced Documentation** - Auto-generated and maintained
- **Zero Breaking Changes** - Fully backward compatible with v1.0.0

## 🔍 Essential Monitoring Commands

### Check System Health (Do This First\!)
```bash
make telemetry-health         # Quick health check
make telemetry-stats          # Detailed statistics
cat system_health_report.json | jq '.health_score'
```

### Real-Time Monitoring
```bash
make monitor-24h              # Live monitor (24h window)
make monitor-7d               # Live monitor (7 days)
make monitor-all              # Live monitor (all data)
```

### Generate Visual Dashboards
```bash
make diagrams                 # All diagrams (24h default)
make diagrams-dashboard       # Just the dashboard
make diagrams-7d              # 7-day window
make diagrams-all             # All historical data
```

## 📊 Key Telemetry Commands

### Recent Operations
```bash
tail -20 telemetry_spans.jsonl | jq '.'
```

### Find Errors
```bash
grep -i "error\|fail" telemetry_spans.jsonl | tail -10 | jq '.'
```

### Check Specific Operation
```bash
grep "operation_name" telemetry_spans.jsonl | jq '.'
```

### Automation Status
```bash
make cron-status
grep "8020_cron_log" telemetry_spans.jsonl | tail -5 | jq '.'
```

## 🎯 8020 Decision Framework

### Health Score Guide
- **80-100**: System healthy ✅ → Focus on new features
- **60-79**: Needs attention ⚠️ → Fix issues first  
- **0-59**: Critical ❌ → Stop and troubleshoot

### Operation Rate Analysis
```bash
# Check current rate
./telemetry-timeframe-stats.sh | grep "Ops/Hour"

# Interpret:
# - Steady rate = Normal
# - Dropping = Check automation
# - Spiking = Monitor resources
```

## 🔧 Common Workflows

### Before Starting Work
```bash
make telemetry-stats          # Current state
make diagrams-dashboard       # Visual overview
./coordination_helper.sh dashboard
```

### During Development
```bash
# Terminal 1
make monitor-24h              

# Terminal 2 (your work)
# Make changes...
make validate
grep "your_operation" telemetry_spans.jsonl | jq '.'
```

## 🆕 v1.1.0 New Commands

### Worktree Development
```bash
# Create feature worktree
make worktree-create FEATURE=my-feature

# Manage worktrees
make worktree-list              # List all active worktrees
make worktree-status            # Show worktree status
make worktree-dashboard         # Quick overview
make worktree-merge FEATURE=my-feature  # Push for PR
make worktree-cleanup FEATURE=my-feature # Remove worktree
```

### Telemetry Dashboard
```bash
# Generate visual dashboards (auto-generated from live data)
make diagrams                   # All diagrams (24h default)
make diagrams-dashboard         # Live system dashboard
make diagrams-24h               # Last 24 hours
make diagrams-7d                # Last 7 days
make diagrams-flow              # System flow diagram
make diagrams-timeline          # Timeline visualization
```

### Documentation & References
```bash
# Quick references
make quick-ref                  # Show quick reference
make telemetry-guide            # Show telemetry analysis guide
cat CHANGELOG.md                # v1.1.0 release notes
cat TEST_COVERAGE_REPORT_v1.1.0.md  # Comprehensive test results
```

### After Changes
```bash
make diagrams                 # Update visuals
./compare-timeframes.sh       # See impact
```

## 📁 Key Files

| File | Purpose | Check Command |
|------|---------|---------------|
| `telemetry_spans.jsonl` | All operations | `wc -l telemetry_spans.jsonl` |
| `system_health_report.json` | Health score | `jq '.health_score' system_health_report.json` |
| `telemetry_performance_report.json` | Performance | `jq '.daily_span_rate' telemetry_performance_report.json` |
| `work_claims.json` | Active work | `jq length work_claims.json` |

## ⚡ Quick Health Check

```bash
# One-liner health check
echo "Health: $(jq '.health_score' system_health_report.json)/100 | Ops/24h: $(grep -c . telemetry_spans.jsonl | tail -1) | Cron: $(crontab -l 2>/dev/null | grep -c 8020)"
```

## 🚨 Troubleshooting

### No Recent Operations?
```bash
make cron-status              # Check automation
ps aux | grep cron            # Verify cron running
tail -f telemetry_spans.jsonl # Watch for new spans
```

### Low Health Score?
```bash
cat system_health_report.json | jq '.issue_breakdown'
./cron-health-monitor.sh      # Manual health check
```

### High Error Rate?
```bash
grep "error" telemetry_spans.jsonl | jq '.operation_name' | sort | uniq -c | sort -rn
```

## 💡 Remember

1. **Always check telemetry before making decisions**
2. **Default to 24h window for current state**
3. **Trust data, not assumptions**
4. **Monitor continuously during work**

---
*Keep this reference handy\! Update it as you learn more patterns.*
EOF < /dev/null