#!/usr/bin/env bash

# OpenTelemetry Bash Library
# Provides tracing capabilities for bash scripts

set -euo pipefail

# OpenTelemetry Configuration
readonly OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-ollama-pro}"
readonly OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
readonly OTEL_EXPORTER_OTLP_TRACES_ENDPOINT="${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT:-${OTEL_EXPORTER_OTLP_ENDPOINT}/v1/traces}"
readonly OTEL_TRACE_ENABLED="${OTEL_TRACE_ENABLED:-true}"
readonly OTEL_METRICS_ENABLED="${OTEL_METRICS_ENABLED:-true}"

# Trace context (compatible with older bash versions)
TRACE_ID=""
SPAN_ID=""
PARENT_SPAN_ID=""
declare -A ACTIVE_SPANS 2>/dev/null || true
declare -A SPAN_START_TIMES 2>/dev/null || true

# Generate random hex string
generate_id() {
    local length=${1:-16}
    od -An -tx1 -N"$length" /dev/urandom | tr -d ' \n'
}

# Get current time in nanoseconds
get_time_nano() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        echo $(($(date +%s) * 1000000000))
    else
        # Linux
        date +%s%N
    fi
}

# Initialize trace context
init_trace() {
    TRACE_ID=$(generate_id 16)
    export OTEL_TRACE_ID="$TRACE_ID"
}

# Create a new span
span_start() {
    local span_name=$1
    local span_kind=${2:-"INTERNAL"}  # CLIENT, SERVER, INTERNAL, PRODUCER, CONSUMER
    
    if [[ "$OTEL_TRACE_ENABLED" != "true" ]]; then
        return
    fi
    
    local span_id=$(generate_id 8)
    local start_time=$(get_time_nano)
    
    # Set parent span
    if [[ -n "$SPAN_ID" ]]; then
        PARENT_SPAN_ID="$SPAN_ID"
    fi
    
    SPAN_ID="$span_id"
    ACTIVE_SPANS["$span_id"]="$span_name"
    SPAN_START_TIMES["$span_id"]="$start_time"
    
    # Export for child processes
    export OTEL_SPAN_ID="$SPAN_ID"
    export OTEL_PARENT_SPAN_ID="$PARENT_SPAN_ID"
    
    echo "$span_id"
}

# End a span and send to collector
span_end() {
    local span_id=${1:-$SPAN_ID}
    local status_code=${2:-"OK"}  # OK, ERROR
    local status_message=${3:-""}
    
    if [[ "$OTEL_TRACE_ENABLED" != "true" ]]; then
        return
    fi
    
    if [[ -z "$span_id" ]] || [[ -z "${ACTIVE_SPANS[$span_id]:-}" ]]; then
        return
    fi
    
    local span_name="${ACTIVE_SPANS[$span_id]}"
    local start_time="${SPAN_START_TIMES[$span_id]}"
    local end_time=$(get_time_nano)
    local duration=$((end_time - start_time))
    
    # Create span data
    local span_data=$(cat <<EOF
{
    "resourceSpans": [{
        "resource": {
            "attributes": [{
                "key": "service.name",
                "value": {"stringValue": "$OTEL_SERVICE_NAME"}
            }]
        },
        "scopeSpans": [{
            "scope": {
                "name": "ollama-pro-instrumentation",
                "version": "1.0.0"
            },
            "spans": [{
                "traceId": "$TRACE_ID",
                "spanId": "$span_id",
                "parentSpanId": "${PARENT_SPAN_ID:-}",
                "name": "$span_name",
                "kind": 1,
                "startTimeUnixNano": "$start_time",
                "endTimeUnixNano": "$end_time",
                "attributes": [
                    {
                        "key": "duration_ms",
                        "value": {"intValue": "$((duration / 1000000))"}
                    }
                ],
                "status": {
                    "code": $([ "$status_code" = "OK" ] && echo 1 || echo 2),
                    "message": "$status_message"
                }
            }]
        }]
    }]
}
EOF
)
    
    # Send to collector
    if command -v curl &>/dev/null; then
        curl -X POST \
            -H "Content-Type: application/json" \
            -d "$span_data" \
            "$OTEL_EXPORTER_OTLP_TRACES_ENDPOINT" \
            --silent --fail --show-error \
            2>/dev/null || true
    fi
    
    # Clean up
    unset ACTIVE_SPANS["$span_id"]
    unset SPAN_START_TIMES["$span_id"]
    
    # Restore parent context
    if [[ "$span_id" == "$SPAN_ID" ]]; then
        SPAN_ID="$PARENT_SPAN_ID"
        PARENT_SPAN_ID=""
    fi
}

# Add span event
span_event() {
    local event_name=$1
    local attributes=${2:-"{}"}
    
    if [[ "$OTEL_TRACE_ENABLED" != "true" ]] || [[ -z "$SPAN_ID" ]]; then
        return
    fi
    
    # Log event (simplified - would need to track and send with span)
    echo "[TRACE_EVENT] span_id=$SPAN_ID event=$event_name attributes=$attributes" >&2
}

# Record metric
record_metric() {
    local metric_name=$1
    local value=$2
    local unit=${3:-"1"}
    local metric_type=${4:-"gauge"}  # gauge, counter, histogram
    
    if [[ "$OTEL_METRICS_ENABLED" != "true" ]]; then
        return
    fi
    
    local timestamp=$(get_time_nano)
    
    # Simplified metric recording - in production would batch and send to collector
    echo "[METRIC] name=$metric_name value=$value unit=$unit type=$metric_type timestamp=$timestamp" >&2
}

# Trace wrapped command execution
trace_exec() {
    local span_name=$1
    shift
    
    local span_id=$(span_start "$span_name" "INTERNAL")
    local exit_code=0
    
    # Execute command
    if "$@"; then
        span_end "$span_id" "OK"
    else
        exit_code=$?
        span_end "$span_id" "ERROR" "Command failed with exit code $exit_code"
    fi
    
    return $exit_code
}

# Context propagation helpers
export_trace_context() {
    if [[ -n "$TRACE_ID" ]]; then
        export TRACEPARENT="00-${TRACE_ID}-${SPAN_ID:-0000000000000000}-01"
    fi
}

import_trace_context() {
    if [[ -n "${TRACEPARENT:-}" ]]; then
        # Parse W3C traceparent format
        IFS='-' read -r version trace_id span_id flags <<< "$TRACEPARENT"
        TRACE_ID="$trace_id"
        PARENT_SPAN_ID="$span_id"
    fi
}

# Automatic instrumentation for common commands
instrumented_curl() {
    local url=""
    for arg in "$@"; do
        if [[ "$arg" =~ ^https?:// ]]; then
            url="$arg"
            break
        fi
    done
    
    local span_id=$(span_start "http.request" "CLIENT")
    span_event "http.request.start" "{\"url\": \"$url\"}"
    
    local exit_code=0
    if curl "$@"; then
        span_end "$span_id" "OK"
    else
        exit_code=$?
        span_end "$span_id" "ERROR" "HTTP request failed"
    fi
    
    return $exit_code
}

# Initialize on source
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced
    init_trace
    import_trace_context
fi