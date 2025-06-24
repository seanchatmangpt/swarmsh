#!/usr/bin/env bash

# Simplified OpenTelemetry for Bash - Focus on 80% Core Functionality
# Reliable trace and metrics generation

set -euo pipefail

# Configuration
readonly OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-ollama-pro}"
readonly OTEL_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
readonly OTEL_TRACE_ENABLED="${OTEL_TRACE_ENABLED:-true}"
readonly OTEL_METRICS_ENABLED="${OTEL_METRICS_ENABLED:-true}"

# Generate random hex ID
generate_hex_id() {
    local length=${1:-16}
    # Use a more reliable method for ID generation
    python3 -c "import secrets; print(secrets.token_hex($((length/2))))" 2>/dev/null || \
    dd if=/dev/urandom bs=1 count=$((length/2)) 2>/dev/null | xxd -p | tr -d '\n' || \
    echo "$(date +%s)$(( RANDOM ))$(( RANDOM ))" | md5sum | cut -c1-"$length" 2>/dev/null || \
    printf "%0${length}x" "$((RANDOM * RANDOM))"
}

# Get nanosecond timestamp
get_nano_time() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo $(($(date +%s) * 1000000000))
    else
        date +%s%N
    fi
}

# Simple span tracking
declare -g CURRENT_TRACE_ID=""
declare -g CURRENT_SPAN_ID=""
declare -A SPAN_TIMES

# Initialize trace
init_trace() {
    if [[ "$OTEL_TRACE_ENABLED" == "true" ]]; then
        CURRENT_TRACE_ID=$(generate_hex_id 32)
        echo "[TRACE_EVENT] trace_id=$CURRENT_TRACE_ID event=trace_start timestamp=$(get_nano_time)" >&2
    fi
}

# Start span - simplified for reliability
span_start() {
    local span_name=${1:-"unnamed"}
    
    if [[ "$OTEL_TRACE_ENABLED" != "true" ]]; then
        echo "noop"
        return
    fi
    
    local span_id=$(generate_hex_id 16)
    CURRENT_SPAN_ID="$span_id"
    SPAN_TIMES["$span_id"]=$(get_nano_time)
    
    echo "[TRACE_EVENT] span_id=$span_id span_name=$span_name event=span_start timestamp=${SPAN_TIMES[$span_id]} trace_id=$CURRENT_TRACE_ID" >&2
    echo "$span_id"
}

# End span
span_end() {
    local span_id=${1:-$CURRENT_SPAN_ID}
    local status=${2:-"OK"}
    
    if [[ "$OTEL_TRACE_ENABLED" != "true" ]] || [[ -z "$span_id" ]] || [[ "$span_id" == "noop" ]]; then
        return
    fi
    
    local end_time=$(get_nano_time)
    local start_time=${SPAN_TIMES[$span_id]:-$end_time}
    local duration=$((end_time - start_time))
    
    echo "[TRACE_EVENT] span_id=$span_id event=span_end timestamp=$end_time duration_ns=$duration status=$status trace_id=$CURRENT_TRACE_ID" >&2
    
    # Clean up
    unset SPAN_TIMES["$span_id"]
}

# Record metric - simplified
record_metric() {
    local name=$1
    local value=$2
    local unit=${3:-"1"}
    local type=${4:-"gauge"}
    
    if [[ "$OTEL_METRICS_ENABLED" == "true" ]]; then
        echo "[METRIC] name=$name value=$value unit=$unit type=$type timestamp=$(get_nano_time)" >&2
    fi
}

# Span event
span_event() {
    local event_name=$1
    local attributes=${2:-""}
    
    if [[ "$OTEL_TRACE_ENABLED" == "true" ]] && [[ -n "$CURRENT_SPAN_ID" ]]; then
        echo "[TRACE_EVENT] span_id=$CURRENT_SPAN_ID event=$event_name timestamp=$(get_nano_time) attributes=$attributes trace_id=$CURRENT_TRACE_ID" >&2
    fi
}

# Trace execution wrapper
trace_exec() {
    local span_name=$1
    shift
    
    local span_id=$(span_start "$span_name")
    local exit_code=0
    
    if "$@"; then
        span_end "$span_id" "OK"
    else
        exit_code=$?
        span_end "$span_id" "ERROR"
    fi
    
    return $exit_code
}

# Performance timing
time_operation() {
    local operation_name=$1
    shift
    
    local start_time=$(get_nano_time)
    local exit_code=0
    
    if "$@"; then
        local end_time=$(get_nano_time)
        local duration_ms=$(( (end_time - start_time) / 1000000 ))
        record_metric "${operation_name}.duration" "$duration_ms" "ms" "histogram"
        record_metric "${operation_name}.success" "1" "count" "counter"
    else
        exit_code=$?
        local end_time=$(get_nano_time)
        local duration_ms=$(( (end_time - start_time) / 1000000 ))
        record_metric "${operation_name}.duration" "$duration_ms" "ms" "histogram"
        record_metric "${operation_name}.error" "1" "count" "counter"
    fi
    
    return $exit_code
}

# Auto-initialize if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    init_trace
fi