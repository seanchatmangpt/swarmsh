#!/bin/bash

##############################################################################
# SwarmSH JSON Output Framework
# 
# Provides standardized JSON output functions for all SwarmSH commands
# Implements modern API responses with schemas, templates, and validation
##############################################################################

# JSON output configuration
SWARMSH_JSON_MODE="${SWARMSH_OUTPUT_FORMAT:-text}"
SWARMSH_JSON_TEMPLATE="${SWARMSH_JSON_TEMPLATE:-standard}"
SWARMSH_JSON_VALIDATION="${SWARMSH_JSON_SCHEMA_VALIDATION:-false}"
SWARMSH_API_VERSION="1.0.0"

# Initialize JSON framework
initialize_json_framework() {
    # Set global variables for JSON output
    JSON_TRACE_ID="${TRACE_ID:-$(openssl rand -hex 16 2>/dev/null || echo "trace_$(date +%s%N)")}"
    JSON_REQUEST_ID="req_$(date +%s%N)"
    JSON_TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    JSON_AGENT_ID="${AGENT_ID:-unknown}"
    
    # Performance tracking
    JSON_START_TIME=$(date +%s%N)
}

##############################################################################
# Core JSON Response Functions
##############################################################################

# Generate base JSON response wrapper
json_response_wrapper() {
    local status_code="$1"
    local status_message="$2" 
    local data="$3"
    local operation="${4:-unknown}"
    local details="${5:-}"
    
    # Ensure JSON framework is initialized
    if [[ -z "${JSON_START_TIME:-}" ]]; then
        initialize_json_framework
    fi
    
    # Calculate execution time
    local end_time=$(date +%s%N)
    local execution_time_ms=$(( (end_time - JSON_START_TIME) / 1000000 ))
    
    cat <<EOF
{
  "swarmsh_api": {
    "version": "$SWARMSH_API_VERSION",
    "timestamp": "$JSON_TIMESTAMP",
    "trace_id": "$JSON_TRACE_ID",
    "request_id": "$JSON_REQUEST_ID"
  },
  "status": {
    "code": "$status_code",
    "message": "$status_message"$(if [[ -n "$details" ]]; then echo ","; echo "    \"details\": \"$details\""; fi)
  },
  "data": $data,
  "metadata": {
    "execution_time_ms": $execution_time_ms,
    "agent_id": "$JSON_AGENT_ID",
    "operation": "$operation",
    "performance": {
      "cpu_time_ms": $(get_cpu_time),
      "memory_usage_kb": $(get_memory_usage),
      "telemetry_spans": $(get_telemetry_span_count)
    }
  },
  "telemetry": {
    "spans_generated": $(get_spans_generated),
    "traces_active": $(get_active_traces),
    "coordination_events": $(get_coordination_events)
  }
}
EOF
}

# Success response helper
json_success() {
    local message="$1"
    local data="$2"
    local operation="${3:-success}"
    
    json_response_wrapper "success" "$message" "$data" "$operation"
}

# Error response helper
json_error() {
    local message="$1"
    local error_code="${2:-general_error}"
    local details="${3:-}"
    local operation="${4:-error}"
    
    # Ensure JSON framework is initialized
    if [[ -z "${JSON_TIMESTAMP:-}" ]]; then
        initialize_json_framework
    fi
    
    local error_data=$(cat <<EOF
{
  "error": {
    "code": "$error_code",
    "message": "$message",
    "details": "$details",
    "timestamp": "$JSON_TIMESTAMP",
    "trace_id": "$JSON_TRACE_ID"
  }
}
EOF
    )
    
    json_response_wrapper "error" "$message" "$error_data" "$operation" "$details"
}

# Warning response helper
json_warning() {
    local message="$1"
    local data="$2"
    local warning_details="${3:-}"
    local operation="${4:-warning}"
    
    json_response_wrapper "warning" "$message" "$data" "$operation" "$warning_details"
}

##############################################################################
# Command-Specific JSON Formatters
##############################################################################

# Work management JSON response
json_work_response() {
    local work_id="$1"
    local work_type="$2"
    local description="$3"
    local priority="$4"
    local status="$5"
    local agent_id="$6"
    local team="$7"
    local progress="${8:-0}"
    local velocity_points="${9:-0}"
    
    local work_data=$(cat <<EOF
{
  "work_item": {
    "id": "$work_id",
    "type": "$work_type", 
    "description": "$description",
    "priority": "$priority",
    "status": "$status",
    "agent_id": "$agent_id",
    "team": "$team",
    "created_at": "$JSON_TIMESTAMP",
    "updated_at": "$JSON_TIMESTAMP",
    "progress_percent": $progress,
    "velocity_points": $velocity_points,
    "estimated_completion": "$(calculate_estimated_completion "$priority" "$work_type")"
  },
  "coordination": {
    "conflicts_detected": $(get_work_conflicts),
    "work_queue_depth": $(get_queue_depth),
    "available_agents": $(get_available_agents),
    "team_capacity": $(get_team_capacity "$team")
  }
}
EOF
    )
    
    json_success "Work item processed successfully" "$work_data" "work_management"
}

# Agent status JSON response
json_agent_response() {
    local agent_id="$1"
    local role="$2"
    local team="$3"
    local status="$4"
    local capacity_current="${5:-0}"
    local capacity_max="${6:-10}"
    local specialization="${7:-general}"
    
    local utilization_percent=$(( capacity_current * 100 / capacity_max ))
    
    local agent_data=$(cat <<EOF
{
  "agent": {
    "id": "$agent_id",
    "role": "$role",
    "team": "$team", 
    "status": "$status",
    "capacity": {
      "current": $capacity_current,
      "maximum": $capacity_max,
      "utilization_percent": $utilization_percent
    },
    "specialization": "$specialization",
    "performance": {
      "tasks_completed": $(get_agent_task_count "$agent_id"),
      "success_rate": $(get_agent_success_rate "$agent_id"),
      "avg_completion_time_ms": $(get_agent_avg_time "$agent_id")
    },
    "registered_at": "$JSON_TIMESTAMP",
    "last_activity": "$(get_agent_last_activity "$agent_id")"
  }
}
EOF
    )
    
    json_success "Agent status retrieved successfully" "$agent_data" "agent_status"
}

# Dashboard JSON response
json_dashboard_response() {
    local health_score=$(get_system_health_score)
    local system_status=$(get_system_status)
    
    local dashboard_data=$(cat <<EOF
{
  "system": {
    "health_score": $health_score,
    "status": "$system_status",
    "uptime_seconds": $(get_system_uptime),
    "version": "3.0.0"
  },
  "agents": {
    "total": $(get_total_agents),
    "active": $(get_active_agents),
    "busy": $(get_busy_agents),
    "idle": $(get_idle_agents),
    "by_team": $(get_agents_by_team)
  },
  "work": {
    "total_items": $(get_total_work_items),
    "active": $(get_active_work_items),
    "completed": $(get_completed_work_items),
    "failed": $(get_failed_work_items),
    "queue_depth": $(get_queue_depth),
    "avg_completion_time_ms": $(get_avg_completion_time)
  },
  "telemetry": {
    "total_spans": $(get_total_telemetry_spans),
    "active_traces": $(get_active_traces),
    "success_rate": $(get_telemetry_success_rate),
    "spans_per_minute": $(get_spans_per_minute)
  },
  "performance": {
    "coordination_latency_ms": $(get_coordination_latency),
    "work_claim_conflicts": $(get_work_conflicts),
    "memory_usage_mb": $(get_system_memory_mb),
    "cpu_utilization": $(get_cpu_utilization)
  }
}
EOF
    )
    
    json_success "Dashboard data retrieved successfully" "$dashboard_data" "dashboard"
}

# Claude AI analysis JSON response
json_claude_response() {
    local analysis_type="$1"
    local confidence_score="$2"
    local model_used="$3"
    local analysis_duration_ms="$4"
    local recommendations_file="$5"
    
    local recommendations_json="{}"
    if [[ -f "$recommendations_file" ]]; then
        recommendations_json=$(cat "$recommendations_file")
    fi
    
    local claude_data=$(cat <<EOF
{
  "analysis": {
    "type": "$analysis_type",
    "confidence_score": $confidence_score,
    "model_used": "$model_used",
    "analysis_duration_ms": $analysis_duration_ms,
    "recommendations": $recommendations_json,
    "insights": {
      "bottlenecks": $(get_identified_bottlenecks),
      "opportunities": $(get_optimization_opportunities), 
      "risks": $(get_identified_risks)
    },
    "data_quality": {
      "completeness": $(get_data_completeness),
      "freshness_minutes": $(get_data_freshness),
      "reliability_score": $(get_data_reliability)
    }
  },
  "llm_metadata": {
    "tokens_used": $(get_tokens_used),
    "response_time_ms": $analysis_duration_ms,
    "cost_estimate": $(get_cost_estimate),
    "cache_hit": $(get_cache_hit_status)
  }
}
EOF
    )
    
    json_success "Claude AI analysis completed successfully" "$claude_data" "claude_analysis"
}

##############################################################################
# JSON Template System
##############################################################################

# Apply JSON template formatting
apply_json_template() {
    local json_data="$1"
    local template="${2:-$SWARMSH_JSON_TEMPLATE}"
    
    case "$template" in
        "compact")
            echo "$json_data" | jq -c 'del(.metadata.performance, .telemetry)'
            ;;
        "verbose")
            echo "$json_data" | jq '.'
            ;;
        "minimal")
            echo "$json_data" | jq -c '{status, data}'
            ;;
        "standard"|*)
            echo "$json_data" | jq '.'
            ;;
    esac
}

##############################################################################
# Output Mode Detection and Routing
##############################################################################

# Determine if JSON output should be used
should_use_json_output() {
    # Check command line flags
    for arg in "$@"; do
        case "$arg" in
            --json|--output-json)
                return 0
                ;;
            --text|--output-text|--legacy)
                return 1
                ;;
        esac
    done
    
    # Check environment variable
    if [[ "$SWARMSH_JSON_MODE" == "json" ]]; then
        return 0
    fi
    
    # Default to text output for backwards compatibility
    return 1
}

# Main output function - routes to JSON or text
swarmsh_output() {
    local output_type="$1"  # success|error|warning
    local message="$2"
    local data="$3"
    shift 3
    
    if should_use_json_output "$@"; then
        # JSON output mode
        initialize_json_framework
        
        case "$output_type" in
            "success")
                apply_json_template "$(json_success "$message" "$data")"
                ;;
            "error")
                apply_json_template "$(json_error "$message" "${4:-general_error}" "${5:-}")"
                ;;
            "warning")
                apply_json_template "$(json_warning "$message" "$data")"
                ;;
        esac
    else
        # Traditional text output mode
        case "$output_type" in
            "success")
                echo "✅ $message"
                ;;
            "error")
                echo "❌ $message" >&2
                ;;
            "warning")
                echo "⚠️ $message" >&2
                ;;
        esac
    fi
}

##############################################################################
# Helper Functions for Data Retrieval
##############################################################################

# System metrics helpers (placeholder implementations)
get_cpu_time() { echo "45"; }
get_memory_usage() { echo "1024"; }
get_telemetry_span_count() { 
    if [[ -f "telemetry_spans.jsonl" ]]; then
        wc -l < telemetry_spans.jsonl 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}
get_spans_generated() { echo "2"; }
get_active_traces() { echo "5"; }
get_coordination_events() { echo "1"; }

# Work management helpers
get_work_conflicts() { echo "0"; }
get_queue_depth() { echo "5"; }
get_available_agents() { echo "8"; }
get_team_capacity() { echo "50"; }
calculate_estimated_completion() { 
    local priority="$1"
    local work_type="$2"
    # Simple estimation based on priority
    case "$priority" in
        "critical") echo "$(date -d '+5 minutes' -u +%Y-%m-%dT%H:%M:%SZ)" ;;
        "high") echo "$(date -d '+15 minutes' -u +%Y-%m-%dT%H:%M:%SZ)" ;;
        "medium") echo "$(date -d '+1 hour' -u +%Y-%m-%dT%H:%M:%SZ)" ;;
        *) echo "$(date -d '+4 hours' -u +%Y-%m-%dT%H:%M:%SZ)" ;;
    esac
}

# Agent performance helpers
get_agent_task_count() { echo "156"; }
get_agent_success_rate() { echo "98.7"; }
get_agent_avg_time() { echo "450"; }
get_agent_last_activity() { echo "$(date -d '-1 minute' -u +%Y-%m-%dT%H:%M:%SZ)"; }

# Dashboard data helpers
get_system_health_score() { echo "85"; }
get_system_status() { echo "healthy"; }
get_system_uptime() { echo "86400"; }
get_total_agents() { echo "12"; }
get_active_agents() { echo "10"; }
get_busy_agents() { echo "2"; }
get_idle_agents() { echo "8"; }
get_agents_by_team() {
    echo '{"parser_team": 3, "render_team": 4, "cache_team": 2, "coordination_team": 3}'
}

# Work item helpers
get_total_work_items() { echo "45"; }
get_active_work_items() { echo "12"; }
get_completed_work_items() { echo "30"; }
get_failed_work_items() { echo "3"; }
get_avg_completion_time() { echo "350"; }

# Telemetry helpers
get_total_telemetry_spans() { echo "15847"; }
get_telemetry_success_rate() { echo "99.2"; }
get_spans_per_minute() { echo "24"; }

# Performance helpers
get_coordination_latency() { echo "45"; }
get_system_memory_mb() { echo "256"; }
get_cpu_utilization() { echo "35"; }

# Claude AI helpers
get_identified_bottlenecks() { echo '["template_parsing", "agent_coordination"]'; }
get_optimization_opportunities() { echo '["cache_optimization", "parallel_processing"]'; }
get_identified_risks() { echo '["capacity_limits", "single_point_failure"]'; }
get_data_completeness() { echo "0.98"; }
get_data_freshness() { echo "2"; }
get_data_reliability() { echo "0.94"; }
get_tokens_used() { echo "1847"; }
get_cost_estimate() { echo "0.0023"; }
get_cache_hit_status() { echo "false"; }

##############################################################################
# JSON Schema Validation
##############################################################################

# Validate JSON output against schema
validate_json_schema() {
    local json_data="$1"
    local schema_type="$2"
    
    if [[ "$SWARMSH_JSON_VALIDATION" != "true" ]]; then
        return 0
    fi
    
    # Simple validation using jq
    if echo "$json_data" | jq empty 2>/dev/null; then
        return 0
    else
        echo "❌ JSON validation failed for schema: $schema_type" >&2
        return 1
    fi
}

##############################################################################
# Export Functions for Use in coordination_helper.sh
##############################################################################

# These functions will be sourced by coordination_helper.sh
# to provide JSON output capabilities