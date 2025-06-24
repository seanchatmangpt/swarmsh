#!/usr/bin/env bash

# Minimal test to isolate the issue

set -x  # Debug mode
echo "Starting minimal test..."

# Test 1: Can we source the otel lib?
echo "Test 1: Sourcing otel-simple.sh"
if source ./otel-simple.sh; then
    echo "✓ OTEL library loaded"
else
    echo "✗ OTEL library failed"
    exit 1
fi

# Test 2: Can we call record_metric?
echo "Test 2: Recording metric"
if record_metric "test" "1" "count" "counter"; then
    echo "✓ Metric recorded"
else
    echo "✗ Metric failed"
fi

# Test 3: Can we run ollama-pro help?
echo "Test 3: Running ollama-pro --help"
timeout 5s bash -c './ollama-pro --help | head -5' || echo "Timeout/Error in ollama-pro"

echo "Minimal test complete"