# comprehensive_cleanup.sh

## Overview
Comprehensive cleanup utility that removes timestamped files, old backups, stale work results, and logs while preserving essential coordination files.

## Purpose
- Clean accumulated timestamped files and analysis artifacts
- Remove old backups while keeping recent ones
- Clear stale work results and logs
- Maintain system performance and disk space
- Preserve essential coordination and configuration files

## Usage
```bash
# Show what would be cleaned (dry run)
./comprehensive_cleanup.sh dry-run

# Perform actual cleanup
./comprehensive_cleanup.sh

# Get help
./comprehensive_cleanup.sh --help
```

## Key Features
- **Smart File Detection**: Identifies timestamped files and analysis artifacts
- **Backup Preservation**: Keeps recent backups, removes old ones
- **Safety Checks**: Protects essential files from deletion
- **OpenTelemetry Tracing**: Complete observability of cleanup operations
- **Dry Run Mode**: Preview changes before execution

## Cleanup Categories

### Timestamped Files
- `*_YYYYMMDD_HHMMSS.*` patterns
- Analysis output files with timestamps
- Temporary coordination files older than specified retention

### Old Backups
- Keeps most recent backups (configurable count)
- Removes outdated backup archives
- Preserves critical system state backups

### Stale Work Results
- Old work result files
- Temporary analysis outputs
- Cached coordination data

### Log Files
- Rotates large log files
- Removes old debug outputs
- Preserves recent operational logs

## Configuration
```bash
# Retention periods (days)
DAYS_TO_KEEP_TIMESTAMPED=7      # Timestamped files
DAYS_TO_KEEP_LOGS=14            # Log files
KEEP_RECENT_BACKUPS=5           # Number of recent backups

# Protected patterns (never deleted)
ESSENTIAL_PATTERNS=(
    "coordination_helper.sh"
    "agent_status.json"
    "work_claims.json"
    "*.md"
)
```

## Telemetry Integration
- **Master Trace**: Session-level tracing with unique trace ID
- **Operation Spans**: Individual cleanup operation tracking
- **Metrics**: Files processed, disk space freed, operation duration
- **Service**: `comprehensive-cleanup`

## Safety Features
- **Essential File Protection**: Never deletes core coordination files
- **Backup Creation**: Creates backups before major deletions
- **Atomic Operations**: Ensures consistency during cleanup
- **Error Recovery**: Graceful handling of permission issues

## Output Example
```
==================================
AGENT COORDINATION CLEANUP
Comprehensive file cleanup utility
==================================

🧹 Cleaning timestamped files older than 7 days...
✅ Cleaned 23 timestamped files, freed 2.3MB

🗂️ Cleaning old backups (keeping 5 most recent)...
✅ Cleaned 8 old backups, freed 15.2MB

📋 Cleaning stale work results...
✅ Cleaned 12 work result files, freed 1.1MB

📊 Summary:
   Total files cleaned: 43
   Disk space freed: 18.6MB
   Duration: 1.2 seconds
```

## Integration Points
- Called by `auto_cleanup.sh` for automated cleanup
- Works with coordination system file structure
- Integrates with OpenTelemetry monitoring
- Compatible with `benchmark_cleanup_script.sh`

## Dry Run Mode
```bash
# Preview cleanup without changes
./comprehensive_cleanup.sh dry-run

# Shows files that would be deleted
# No actual deletions performed
# Safe for testing and validation
```

## Scheduling
```bash
# Weekly comprehensive cleanup
0 1 * * 0 /path/to/comprehensive_cleanup.sh

# Monthly deep cleanup
0 2 1 * * /path/to/comprehensive_cleanup.sh --deep
```

## Troubleshooting
```bash
# Check what files would be cleaned
./comprehensive_cleanup.sh dry-run

# Verify recent telemetry
grep "comprehensive-cleanup" telemetry_spans.jsonl

# Monitor disk space impact
df -h before/after cleanup
```