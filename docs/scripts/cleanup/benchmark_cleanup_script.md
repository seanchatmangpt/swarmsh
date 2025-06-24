# benchmark_cleanup_script.sh

## Overview
Specialized cleanup script for removing stale benchmark test entries and implementing TTL (Time-To-Live) mechanisms to prevent test data accumulation.

## Purpose
- Clean up synthetic benchmark work items
- Prevent accumulation of test coordination data
- Implement TTL-based cleanup for benchmark entries
- Maintain coordination system performance during testing

## Usage
```bash
# Manual cleanup
./benchmark_cleanup_script.sh

# Automated cleanup (used by cron)
./benchmark_cleanup_script.sh --auto

# TTL validation and cleanup
./benchmark_cleanup_script.sh --ttl-check
```

## Key Features
- **Benchmark Detection**: Identifies synthetic test work items
- **TTL Implementation**: Time-based cleanup of stale entries
- **Performance Optimization**: Prevents test data from affecting production
- **Selective Cleanup**: Preserves legitimate work items

## Cleanup Targets

### Synthetic Work Items
- Benchmark test entries with specific patterns
- Load testing coordination data
- Performance testing artifacts
- Temporary test agent registrations

### TTL-Based Cleanup
- Work items older than configured TTL
- Stale agent status entries
- Expired coordination logs
- Old telemetry test data

## Configuration
```bash
# TTL settings
BENCHMARK_TTL_HOURS=24          # Benchmark item lifetime
TEST_PATTERN="benchmark_test_"   # Test item identifier
CLEANUP_THRESHOLD=1000          # Lines before optimization

# Test patterns to clean
BENCHMARK_PATTERNS=(
    "benchmark_test_*"
    "load_test_*"
    "performance_test_*"
    "synthetic_work_*"
)
```

## Operation Modes

### Manual Mode
```bash
./benchmark_cleanup_script.sh
```
- Interactive cleanup with user confirmation
- Detailed output of cleanup operations
- Safety prompts before bulk deletions

### Auto Mode
```bash
./benchmark_cleanup_script.sh --auto
```
- Silent operation for cron execution
- No user interaction required
- Optimized for automated scheduling

### TTL Check Mode
```bash
./benchmark_cleanup_script.sh --ttl-check
```
- Validates TTL implementation
- Reports on stale item accumulation
- Provides cleanup recommendations

## TTL Validation
- **Prevents Future Accumulation**: Implements time-based cleanup
- **Early Warning**: Alerts when test data accumulates
- **Automatic Triggers**: Cleanup when thresholds exceeded
- **Performance Monitoring**: Tracks cleanup effectiveness

## Integration Points
- Called by `auto_cleanup.sh` for scheduled cleanup
- Works with `coordination_helper.sh` TTL functions
- Integrates with `ttl_validation.sh` for validation
- Compatible with benchmark testing frameworks

## Cleanup Process
1. **Pattern Matching**: Identifies benchmark entries by pattern
2. **TTL Validation**: Checks timestamps against TTL thresholds
3. **Backup Creation**: Preserves data before deletion
4. **Selective Removal**: Removes only stale benchmark items
5. **Verification**: Confirms cleanup success

## Output Example
```
🧹 Starting benchmark cleanup...

📊 Found 45 benchmark test items
⏰ TTL threshold: 24 hours
🗑️ Removing 23 stale benchmark entries
💾 Creating backup: benchmark_backup_20250624_143022.json

✅ Cleanup completed:
   Items removed: 23
   Items preserved: 22
   Backup location: /backups/benchmark_backup_20250624_143022.json
```

## Performance Impact
- **Coordination Speedup**: Removes test data that slows operations
- **Storage Optimization**: Frees disk space used by test artifacts
- **Query Performance**: Improves JSON query speed
- **System Responsiveness**: Reduces coordination overhead

## Integration with Coordination Helper
```bash
# coordination_helper.sh calls this during TTL validation
if [ -f "$COORDINATION_DIR/ttl_validation.sh" ]; then
    "$COORDINATION_DIR/ttl_validation.sh" auto-cleanup
    "$COORDINATION_DIR/benchmark_cleanup_script.sh" --auto
fi
```

## Monitoring
```bash
# Check cleanup effectiveness
./benchmark_cleanup_script.sh --stats

# Monitor TTL compliance
./ttl_validation.sh validate

# Review cleanup history
tail cleanup_log.txt
```