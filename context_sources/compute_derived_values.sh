#!/bin/bash
# Compute derived values from existing context
input_context="$1"

# Extract base values
total_ops=$(jq -r '.metrics.total_operations // 0' "$input_context")
success_rate=$(jq -r '.metrics.success_rate // 0' "$input_context")

# Compute derived metrics
failure_count=$(echo "scale=0; $total_ops * (100 - $success_rate) / 100" | bc -l 2>/dev/null || echo 0)
efficiency_score=$(echo "scale=1; $success_rate * 0.4 + (100 - $(jq -r '.live.cpu_usage // 50' "$input_context")) * 0.6" | bc -l 2>/dev/null || echo 85.5)

echo "{"
echo "  \"computed\": {"
echo "    \"failure_count\": $failure_count,"
echo "    \"efficiency_score\": $efficiency_score,"
echo "    \"performance_tier\": \"$(if (( $(echo "$efficiency_score > 90" | bc -l 2>/dev/null || echo 0) )); then echo "excellent"; elif (( $(echo "$efficiency_score > 75" | bc -l 2>/dev/null || echo 0) )); then echo "good"; else echo "needs_attention"; fi)\","
echo "    \"computed_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "  }"
echo "}"
