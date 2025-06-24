#!/bin/bash
# Automatic cleanup script for cron with OpenTelemetry tracing

set -euo pipefail

# Source OpenTelemetry library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/otel-bash.sh" 2>/dev/null || true

# Fallback functions if OTEL library not available
generate_trace_id() { openssl rand -hex 16 2>/dev/null || echo "$(date +%s%N)"; }
generate_span_id() { openssl rand -hex 8 2>/dev/null || echo "$(date +%s%N | cut -c-16)"; }

# Generate trace for this cleanup operation
TRACE_ID=$(generate_trace_id)
SPAN_ID=$(generate_span_id)

# Start telemetry span
start_time=$(date +%s%N)
echo "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"operation\":\"auto_cleanup\",\"service\":\"auto-cleanup\",\"start_time\":$(date -u +%s),\"status\":\"started\"}" >> telemetry_spans.jsonl

# Navigate to coordination directory
cd "/Users/sac/dev/ai-self-sustaining-system/agent_coordination"

# Execute cleanup with telemetry
if bash benchmark_cleanup_script.sh --auto >> "/Users/sac/dev/ai-self-sustaining-system/agent_coordination/logs/auto_cleanup.log" 2>&1; then
    status="success"
    exit_code=0
else
    status="error"
    exit_code=$?
fi

# End telemetry span
end_time=$(date +%s%N)
duration_ms=$(( (end_time - start_time) / 1000000 ))
echo "{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"operation\":\"auto_cleanup\",\"service\":\"auto-cleanup\",\"duration_ms\":$duration_ms,\"status\":\"$status\",\"exit_code\":$exit_code}" >> "${SCRIPT_DIR}/telemetry_spans.jsonl"

exit $exit_code
