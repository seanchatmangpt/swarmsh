# Real-Time Telemetry Dashboard

## Overview

This feature provides a comprehensive real-time monitoring dashboard for the SwarmSH coordination system. Built as a demonstration of the worktree development workflow, it showcases isolated feature development with full S2S coordination integration.

## Features

### 🔍 Real-Time Monitoring
- Live telemetry data visualization
- Automatic refresh every 5 seconds (configurable)
- Color-coded health indicators
- OpenTelemetry span generation for dashboard operations

### 📊 Key Metrics
- **Total Operations**: Complete count of telemetry spans
- **Operations/Hour**: Activity rate for the last hour
- **Operations/Min**: Recent activity rate
- **Error Rate**: Percentage of failed operations
- **Average Duration**: Mean operation completion time

### 🔥 Advanced Analytics
- **Top Operations**: Most frequent operations by count
- **Service Distribution**: Breakdown by service components
- **Recent Errors**: Latest error messages with timestamps
- **Coordination Status**: Active and completed work items

### 🎨 Visual Design
- Clean ASCII art interface with Unicode borders
- Color-coded status indicators (🟢🟡🔴)
- Real-time updating display
- Structured layout for easy reading

## Usage

### Basic Usage
```bash
# Start with default settings
./realtime_telemetry_dashboard.sh

# Custom telemetry file and refresh interval
./realtime_telemetry_dashboard.sh -f custom_telemetry.jsonl -i 2

# Using environment variables
REFRESH_INTERVAL=10 ./realtime_telemetry_dashboard.sh
```

### Command Line Options
- `-f, --file FILE`: Specify telemetry file (default: telemetry_spans.jsonl)
- `-i, --interval SEC`: Set refresh interval in seconds (default: 5)
- `-h, --help`: Show usage information

### Environment Variables
- `TELEMETRY_FILE`: Path to telemetry file
- `REFRESH_INTERVAL`: Refresh interval in seconds

## Integration with S2S Coordination

### OpenTelemetry Integration
The dashboard generates its own telemetry spans:
- `dashboard.stats_calculation`: Performance of metrics calculation
- `dashboard.dashboard_refresh`: Display rendering performance
- `dashboard.dashboard_start/stop`: Lifecycle events

### Worktree Isolation
- Operates independently within the telemetry-monitor worktree
- Uses isolated coordination directory for work tracking
- Generates separate telemetry data for testing

## Technical Implementation

### Performance Optimizations
- Efficient JSON processing with jq
- Minimal file I/O operations
- Optimized calculation algorithms
- Configurable refresh rates

### Error Handling
- Graceful handling of missing telemetry files
- Fallback values for calculation errors
- Signal handling for clean shutdown
- Input validation for all parameters

### Dependencies
- bash 4.0+
- jq (for JSON processing)
- openssl (for trace ID generation)
- Standard Unix utilities (awk, grep, sort)

## Example Output

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🔍 Real-Time Telemetry Dashboard                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 2025-06-24 15:09:17 UTC | Trace: 469e875c...                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

📊 Key Metrics
   Total Operations: 1229
   Operations/Hour:  45
   Operations/Min:   3
   Error Rate:       2% (25 errors)
   Avg Duration:     127ms

🔥 Top Operations
   156  work_claim_fast
   89   telemetry_validation
   67   coordination_helper
   45   8020_optimization
   23   agent_registration

🏗️  Service Distribution
   89   s2s-coordination
   67   telemetry-manager
   45   8020-optimizer
   23   health-monitor

❌ Recent Errors
   ✅ No recent errors

🤝 Coordination Status
   Work Items: Active: 1  Completed: 3

System Status: 🟢 HEALTHY
```

## Development Notes

### Worktree Implementation
This feature demonstrates the complete worktree development lifecycle:

1. **Creation**: `make worktree-create FEATURE=telemetry-monitor`
2. **Development**: Isolated implementation with coordination
3. **Testing**: Independent testing environment
4. **Integration**: Full S2S coordination support

### Future Enhancements
- Historical data visualization
- Alert thresholds and notifications
- Export functionality for reports
- Integration with external monitoring systems
- Web-based interface option

## Testing

```bash
# Generate test telemetry data
./test-essential.sh
./coordination_helper.sh claim 'test' 'Generate telemetry' 'high'

# Start dashboard
./realtime_telemetry_dashboard.sh

# Test with custom settings
./realtime_telemetry_dashboard.sh -f telemetry_spans.jsonl -i 1
```

## Contribution

This feature was developed using the SwarmSH worktree workflow:
- Isolated development environment
- Full S2S coordination integration
- Independent testing capabilities
- Clean merge path to main branch

**Work Item**: work_1750802887621941000  
**Progress**: 85% complete  
**Status**: Ready for review and merge