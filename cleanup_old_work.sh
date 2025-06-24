#!/bin/bash
# Clear work items older than 24 hours
# Removes outdated work claims to optimize system performance

set -euo pipefail

CLEANUP_ID="cleanup_$(date +%s)"
CLEANUP_TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "$(date +%s%N)")"

echo "🧹 WORK CLEANUP - 24 HOUR RETENTION"
echo "==================================="
echo "Cleanup ID: $CLEANUP_ID"
echo "Trace ID: $CLEANUP_TRACE_ID"
echo ""

# Create backup
cp work_claims.json "work_claims_backup_${CLEANUP_ID}.json"
echo "✅ Backup created: work_claims_backup_${CLEANUP_ID}.json"

# Calculate 24 hours ago timestamp
cutoff_timestamp=$(date -d '24 hours ago' -u +%s 2>/dev/null || date -v-24H -u +%s)
cutoff_iso=$(date -d "@$cutoff_timestamp" -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -r "$cutoff_timestamp" -u +%Y-%m-%dT%H:%M:%SZ)

echo "📅 Cutoff time: $cutoff_iso"

# Count items before cleanup
total_before=$(jq 'length' work_claims.json)
echo "📊 Work items before cleanup: $total_before"

# Filter out work older than 24 hours
jq --arg cutoff "$cutoff_iso" '
map(select(
    .claimed_at and (.claimed_at > $cutoff)
)) // []' work_claims.json > work_claims_filtered.json

# Count items after cleanup  
total_after=$(jq 'length' work_claims_filtered.json)
removed_count=$((total_before - total_after))

echo "📊 Work items after cleanup: $total_after"
echo "🗑️ Removed items: $removed_count"

# Replace original file
mv work_claims_filtered.json work_claims.json

# Create cleanup report
cat > "cleanup_report_${CLEANUP_ID}.json" <<EOF
{
  "cleanup_id": "$CLEANUP_ID",
  "trace_id": "$CLEANUP_TRACE_ID", 
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "cutoff_time": "$cutoff_iso",
  "items_before": $total_before,
  "items_after": $total_after,
  "items_removed": $removed_count,
  "backup_file": "work_claims_backup_${CLEANUP_ID}.json",
  "status": "completed"
}
EOF

# Add to telemetry
echo "{\"trace_id\":\"$CLEANUP_TRACE_ID\",\"operation\":\"work_cleanup_24h\",\"service\":\"cleanup\",\"items_removed\":$removed_count,\"status\":\"completed\"}" >> telemetry_spans.jsonl

echo ""
echo "🏆 CLEANUP COMPLETE"
echo "==================="
echo "✅ Removed $removed_count old work items"
echo "✅ System optimized"
echo "📄 Report saved: cleanup_report_${CLEANUP_ID}.json"