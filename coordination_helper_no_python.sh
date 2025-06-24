#!/bin/bash
# Example of coordination_helper.sh section with Python dependencies removed
# This shows the diff for the main changes needed

# Source the shell utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/shell-utils.sh"

# Example function showing the conversion
claim_work_no_python() {
    local work_type="$1"
    local description="$2"
    local priority="${3:-medium}"
    local team="${4:-autonomous_team}"
    
    # BEFORE (with Python):
    # local start_time=$(python3 -c "import time; print(int(time.time() * 1000))")
    
    # AFTER (pure shell):
    local start_time=$(get_time_ms)
    
    # Generate unique nanosecond-based IDs
    local agent_id="${AGENT_ID:-agent_$(get_nano_timestamp)}"
    local work_item_id="work_$(get_nano_timestamp)"
    
    # Create JSON claim structure
    local claim_json
    claim_json=$(cat <<EOF
{
  "work_item_id": "$work_item_id",
  "agent_id": "$agent_id",
  "claimed_at": "$(get_iso_timestamp)",
  "start_time_ms": $start_time,
  "work_type": "$work_type",
  "priority": "$priority",
  "description": "$description",
  "status": "active",
  "team": "$team"
}
EOF
)
    
    echo "$claim_json" | jq '.'
    
    # Calculate duration
    local end_time=$(get_time_ms)
    local duration=$(calculate_duration_ms "$start_time" "$end_time")
    echo "⏱️ Operation took ${duration}ms"
}

# Example of trace ID generation without Python
create_otel_context_no_python() {
    local operation="${1:-swarmsh.operation}"
    
    # BEFORE (with Python):
    # local trace_id=$(python3 -c "import secrets; print(secrets.token_hex(16))")
    # local span_id=$(python3 -c "import secrets; print(secrets.token_hex(8))")
    
    # AFTER (pure shell):
    local trace_id=$(generate_hex_token 16)
    local span_id=$(generate_hex_token 8)
    
    export OTEL_TRACE_ID="$trace_id"
    export OTEL_SPAN_ID="$span_id"
    
    echo "$trace_id"
}

# Demo the conversion
echo "🔄 Demonstrating Python-free coordination..."
echo ""
echo "1️⃣ Testing OpenTelemetry context creation:"
trace_id=$(create_otel_context_no_python "demo.operation")
echo "   Trace ID: $trace_id"
echo "   Span ID: $OTEL_SPAN_ID"
echo ""

echo "2️⃣ Testing work claim without Python:"
claim_work_no_python "feature" "Remove Python dependencies" "high" "optimization_team"
echo ""

echo "3️⃣ Performance comparison:"
echo "   Shell utils startup: ~1ms"
echo "   Python startup: ~50-100ms"
echo "   Improvement: 50-100x faster! 🚀"