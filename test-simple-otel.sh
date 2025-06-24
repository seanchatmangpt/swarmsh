#!/usr/bin/env bash

# Simple test of OTEL functions
echo "Testing basic OTEL functions..."

# Simple metric function
record_metric() {
    local name=$1
    local value=$2
    echo "[METRIC] name=$name value=$value timestamp=$(date +%s)" >&2
}

# Test it
echo "Before metric call"
record_metric "test" "42"
echo "After metric call"