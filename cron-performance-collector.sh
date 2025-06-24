#!/usr/bin/env bash
# Simple performance collector for cron
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "perf_$(date +%s%N)")"

case "${1:-collect}" in
    "collect")
        # Basic performance metrics collection
        WORK_COUNT=$(jq 'length' "$SCRIPT_DIR/work_claims.json" 2>/dev/null || echo "0")
        TELEMETRY_SIZE=$(stat -f%z "$SCRIPT_DIR/telemetry_spans.jsonl" 2>/dev/null || echo "0")
        ACTIVE_AGENTS=$(jq '[.[] | select(.status == "active")] | length' "$SCRIPT_DIR/agent_status.json" 2>/dev/null || echo "0")
        
        METRICS="{\"work_items\":$WORK_COUNT,\"telemetry_size\":$TELEMETRY_SIZE,\"active_agents\":$ACTIVE_AGENTS,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
        
        echo "{\"trace_id\":\"$TRACE_ID\",\"operation\":\"performance_collection\",\"service\":\"cron-performance-collector\",\"status\":\"completed\",\"metrics\":$METRICS}" >> "$SCRIPT_DIR/telemetry_spans.jsonl"
        ;;
esac
