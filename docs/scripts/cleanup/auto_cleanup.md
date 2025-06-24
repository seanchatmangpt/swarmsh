# auto_cleanup.sh

## Overview
Automatic cleanup script designed for cron execution with OpenTelemetry tracing integration.

## Purpose
- Automated scheduled cleanup of coordination files
- Cron-compatible operation with minimal output
- OpenTelemetry tracing for cleanup operations
- System maintenance without manual intervention

## Usage
```bash
# Manual execution
./auto_cleanup.sh

# Cron scheduling (daily at 3 AM)
0 3 * * * /path/to/auto_cleanup.sh >> /var/log/cleanup.log 2>&1
```

## Key Features
- **Cron Optimized**: Silent operation suitable for automated scheduling
- **OpenTelemetry Integration**: Full tracing of cleanup operations
- **Error Handling**: Graceful failure with proper exit codes
- **Log Integration**: Writes to centralized cleanup logs

## Execution Flow
1. **Telemetry Setup**: Generates trace ID for cleanup session
2. **Environment Check**: Verifies coordination directory access
3. **Cleanup Execution**: Runs `benchmark_cleanup_script.sh --auto`
4. **Result Logging**: Records success/failure with telemetry
5. **Exit**: Returns appropriate exit code for cron monitoring

## Telemetry Data
- **Service Name**: `auto-cleanup`
- **Trace Context**: Complete trace for monitoring cleanup operations
- **Metrics**: Duration, success/failure rates, files processed
- **Spans**: Individual cleanup operation tracking

## Configuration
```bash
# Environment variables
COORDINATION_DIR="/path/to/coordination"  # Coordination directory
OTEL_SERVICE_NAME="auto-cleanup"         # Service identifier
```

## Cron Integration
```bash
# Daily cleanup at 3 AM
0 3 * * * /path/to/auto_cleanup.sh

# Weekly deep cleanup on Sunday
0 2 * * 0 /path/to/auto_cleanup.sh --deep
```

## Monitoring
- Check exit codes: `0` = success, `1` = failure
- Review telemetry spans in `telemetry_spans.jsonl`
- Monitor cleanup logs for patterns

## Integration Points
- Calls `benchmark_cleanup_script.sh` for actual cleanup
- Integrates with OpenTelemetry collectors
- Compatible with system monitoring tools
- Works with cron and systemd timers

## Troubleshooting
```bash
# Test manual execution
./auto_cleanup.sh

# Check last execution
tail /var/log/cleanup.log

# Verify telemetry
grep "auto_cleanup" telemetry_spans.jsonl
```