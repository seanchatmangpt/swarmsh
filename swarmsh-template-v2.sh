#!/bin/bash

##############################################################################
# SwarmSH Template Engine V2 - Simplified Architecture
# 
# A distributed template engine that uses ALL SwarmSH features but with
# a simpler parsing and rendering approach
##############################################################################

set -euo pipefail

# SwarmSH integration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SWARMSH_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Template engine configuration
TEMPLATE_CACHE_DIR="$SCRIPT_DIR/template_cache"
TEMPLATE_WORK_DIR="$SCRIPT_DIR/template_work"
TEMPLATE_METRICS_FILE="$SCRIPT_DIR/template_metrics.json"

# Initialize directories
mkdir -p "$TEMPLATE_CACHE_DIR" "$TEMPLATE_WORK_DIR"

# OpenTelemetry setup
OTEL_SERVICE_NAME="swarmsh-template-engine-v2"
OTEL_SERVICE_VERSION="2.0.0"

# Generate trace ID
generate_trace_id() {
    openssl rand -hex 16 2>/dev/null || echo "tpl_$(date +%s%N)"
}

# Log telemetry span  
log_span() {
    local operation="$1"
    local status="$2"
    local duration_ms="$3"
    
    # Ensure duration is numeric
    [[ -n "$duration_ms" ]] && [[ "$duration_ms" =~ ^[0-9]+$ ]] || duration_ms=0
    
    cat >> "$SWARMSH_ROOT/telemetry_spans.jsonl" <<EOF
{
  "trace_id": "$TRACE_ID",
  "span_id": "$(openssl rand -hex 8)",
  "operation_name": "template_engine.$operation",
  "status": "$status",
  "duration_ms": $duration_ms,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
}
EOF
}

# Simple template renderer
render_template() {
    local template_file="$1"
    local context_file="$2"
    local output_file="$3"
    local start_time=$(date +%s%N)
    
    # Load context
    local context=$(cat "$context_file")
    
    # Process the template
    > "$output_file"
    
    while IFS= read -r line; do
        local processed_line="$line"
        
        # Handle conditionals {% if ... %}
        if [[ "$line" =~ \{%[[:space:]]*if[[:space:]]+(.+)[[:space:]]*%\} ]]; then
            local condition="${BASH_REMATCH[1]}"
            local eval_result=$(evaluate_condition "$condition" "$context")
            
            if [[ "$eval_result" == "true" ]]; then
                # Read until endif, capturing content
                local in_if=true
                while IFS= read -r if_line && [[ "$in_if" == "true" ]]; do
                    if [[ "$if_line" =~ \{%[[:space:]]*endif[[:space:]]*%\} ]]; then
                        in_if=false
                    else
                        # Process variables in the line
                        process_line "$if_line" "$context" >> "$output_file"
                    fi
                done
            else
                # Skip until endif
                local in_if=true
                while IFS= read -r if_line && [[ "$in_if" == "true" ]]; do
                    if [[ "$if_line" =~ \{%[[:space:]]*endif[[:space:]]*%\} ]]; then
                        in_if=false
                    fi
                done
            fi
            continue
        fi
        
        # Handle loops {% for ... %}
        if [[ "$line" =~ \{%[[:space:]]*for[[:space:]]+([^[:space:]]+)[[:space:]]+in[[:space:]]+(.+)[[:space:]]*%\} ]]; then
            local item_var="${BASH_REMATCH[1]}"
            local items_expr="${BASH_REMATCH[2]}"
            
            # Collect loop body
            local loop_body=""
            local in_loop=true
            while IFS= read -r loop_line && [[ "$in_loop" == "true" ]]; do
                if [[ "$loop_line" =~ \{%[[:space:]]*endfor[[:space:]]*%\} ]]; then
                    in_loop=false
                else
                    loop_body+="$loop_line"$'\n'
                fi
            done
            
            # Execute loop
            local items=$(echo "$context" | jq -r --arg expr "$items_expr" '.[$expr] // empty')
            if [[ -n "$items" ]]; then
                echo "$items" | jq -c '.[]' | while IFS= read -r item; do
                    # Create loop context
                    local loop_context=$(echo "$context" | jq --argjson item "$item" --arg var "$item_var" '.[$var] = $item')
                    
                    # Process loop body with loop context
                    echo -n "$loop_body" | while IFS= read -r body_line; do
                        process_line "$body_line" "$loop_context" >> "$output_file"
                    done
                done
            fi
            continue
        fi
        
        # Handle includes {% include ... %}
        if [[ "$line" =~ \{%[[:space:]]*include[[:space:]]+\"([^\"]+)\"[[:space:]]*%\} ]]; then
            local include_file="${BASH_REMATCH[1]}"
            if [[ -f "$include_file" ]]; then
                while IFS= read -r inc_line; do
                    process_line "$inc_line" "$context" >> "$output_file"
                done < "$include_file"
            fi
            continue
        fi
        
        # Regular line - process variables
        process_line "$line" "$context" >> "$output_file"
        
    done < "$template_file"
    
    # Log telemetry
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    log_span "render" "completed" "$duration_ms"
}

# Process a single line (variable substitution)
process_line() {
    local line="$1"
    local context="$2"
    
    # Replace variables {{ var }}
    while [[ "$line" =~ \{\{[[:space:]]*([^}|]+)([^}]*)[[:space:]]*\}\} ]]; do
        local full_match="${BASH_REMATCH[0]}"
        local var_name=$(echo "${BASH_REMATCH[1]}" | xargs)
        local filters="${BASH_REMATCH[2]}"
        
        # Get value from context
        local value=$(echo "$context" | jq -r --arg var "$var_name" '.[$var] // ""')
        
        # Apply filters
        if [[ "$filters" =~ \|[[:space:]]*upper ]]; then
            value=$(echo "$value" | tr '[:lower:]' '[:upper:]')
        elif [[ "$filters" =~ \|[[:space:]]*lower ]]; then
            value=$(echo "$value" | tr '[:upper:]' '[:lower:]')
        elif [[ "$filters" =~ \|[[:space:]]*length ]]; then
            value="${#value}"
        elif [[ "$filters" =~ \|[[:space:]]*default:[[:space:]]*\"([^\"]+)\" ]]; then
            local default_val="${BASH_REMATCH[1]}"
            [[ -z "$value" ]] && value="$default_val"
        fi
        
        # Replace in line
        line="${line//$full_match/$value}"
    done
    
    echo "$line"
}

# Evaluate condition
evaluate_condition() {
    local condition="$1"
    local context="$2"
    
    # Simple variable check
    if [[ "$condition" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        local value=$(echo "$context" | jq -r --arg var "$condition" '.[$var] // empty')
        [[ -n "$value" && "$value" != "null" && "$value" != "false" ]] && echo "true" || echo "false"
        return
    fi
    
    # Comparison operators
    if [[ "$condition" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*(==|!=|>|<|>=|<=)[[:space:]]*(.+)$ ]]; then
        local var="${BASH_REMATCH[1]}"
        local op="${BASH_REMATCH[2]}"
        local compare_val="${BASH_REMATCH[3]//\"/}"
        
        local var_val=$(echo "$context" | jq -r --arg var "$var" '.[$var] // empty')
        
        case "$op" in
            "==") [[ "$var_val" == "$compare_val" ]] && echo "true" || echo "false" ;;
            "!=") [[ "$var_val" != "$compare_val" ]] && echo "true" || echo "false" ;;
            ">")  
                if [[ "$var_val" =~ ^[0-9]+$ ]] && [[ "$compare_val" =~ ^[0-9]+$ ]]; then
                    [[ "$var_val" -gt "$compare_val" ]] && echo "true" || echo "false"
                else
                    [[ "$var_val" > "$compare_val" ]] && echo "true" || echo "false"
                fi
                ;;
            "<")  
                if [[ "$var_val" =~ ^[0-9]+$ ]] && [[ "$compare_val" =~ ^[0-9]+$ ]]; then
                    [[ "$var_val" -lt "$compare_val" ]] && echo "true" || echo "false"
                else
                    [[ "$var_val" < "$compare_val" ]] && echo "true" || echo "false"
                fi
                ;;
            ">=")
                if [[ "$var_val" =~ ^[0-9]+$ ]] && [[ "$compare_val" =~ ^[0-9]+$ ]]; then
                    [[ "$var_val" -ge "$compare_val" ]] && echo "true" || echo "false"
                else
                    [[ "$var_val" > "$compare_val" || "$var_val" == "$compare_val" ]] && echo "true" || echo "false"
                fi
                ;;
            "<=")
                if [[ "$var_val" =~ ^[0-9]+$ ]] && [[ "$compare_val" =~ ^[0-9]+$ ]]; then
                    [[ "$var_val" -le "$compare_val" ]] && echo "true" || echo "false"
                else
                    [[ "$var_val" < "$compare_val" || "$var_val" == "$compare_val" ]] && echo "true" || echo "false"
                fi
                ;;
        esac
        return
    fi
    
    echo "false"
}

# Main command interface
main() {
    local cmd="${1:-help}"
    shift || true
    
    case "$cmd" in
        render)
            local template="$1"
            local context="${2:-context.json}"
            local output="${3:-/dev/stdout}"
            TRACE_ID=$(generate_trace_id)
            
            echo "🎨 SwarmSH Template Engine V2" >&2
            echo "Trace ID: $TRACE_ID" >&2
            
            render_template "$template" "$context" "$output"
            ;;
        help|*)
            echo "SwarmSH Template Engine V2 - Simplified Architecture"
            echo ""
            echo "Usage:"
            echo "  $0 render <template> [context] [output]"
            echo "  $0 help"
            ;;
    esac
}

main "$@"