#!/bin/bash

##############################################################################
# BPMN Ollama-Pro Generator - AI-Powered Workflow Diagram Generation
# 
# Generates BPMN (Business Process Model and Notation) diagrams from system
# workflows using ollama-pro AI with full OpenTelemetry instrumentation
#
# Features:
# - Analyzes current system workflows and processes
# - Uses ollama-pro to generate intelligent BPMN diagrams
# - Cron automation with 8020 optimization
# - Full OpenTelemetry distributed tracing
# - Evidence-based validation and feedback loops
#
# Usage:
#   ./bpmn-ollama-generator.sh [mode] [scope]
#
# Modes:
#   generate    - Generate BPMN diagrams (default)
#   analyze     - Analyze workflows for BPMN generation
#   validate    - Validate generated diagrams
#   schedule    - Setup cron automation
#
# Scope:
#   coordination - Agent coordination workflows
#   telemetry   - Telemetry collection workflows  
#   automation  - Cron automation workflows
#   worktree    - Worktree development workflows
#   all         - All system workflows (default)
#
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/docs/bpmn_diagrams"
TELEMETRY_FILE="$SCRIPT_DIR/telemetry_spans.jsonl"

# OpenTelemetry configuration
OTEL_SERVICE_NAME="${OTEL_SERVICE_NAME:-bpmn-ollama-generator}"
OTEL_SERVICE_VERSION="${OTEL_SERVICE_VERSION:-1.0.0}"

# Generate trace and span IDs
generate_trace_id() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 16
    else
        echo "bpmn_$(date +%s%N)"
    fi
}

generate_span_id() {
    if command -v openssl >/dev/null 2>&1; then
        openssl rand -hex 8
    else
        echo "$(date +%s%N | cut -c-16)"
    fi
}

# Log telemetry span
log_telemetry_span() {
    local operation="$1"
    local status="$2"
    local trace_id="$3"
    local duration_ms="$4"
    local attributes="$5"
    
    local span_data=$(cat <<EOF
{
  "trace_id": "$trace_id",
  "span_id": "$(generate_span_id)",
  "operation_name": "bpmn_generator.$operation",
  "status": "$status",
  "start_time": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "duration_ms": $duration_ms,
  "service": {
    "name": "$OTEL_SERVICE_NAME",
    "version": "$OTEL_SERVICE_VERSION"
  },
  "resource_attributes": {
    "service.name": "$OTEL_SERVICE_NAME",
    "service.version": "$OTEL_SERVICE_VERSION",
    "bpmn.component": "worktree_generator",
    "deployment.environment": "worktree"
  },
  "span_attributes": $attributes
}
EOF
    )
    
    echo "$span_data" >> "$TELEMETRY_FILE"
    echo "📊 Logged BPMN worktree telemetry: $operation ($status)" >&2
}

# Analyze system workflows for BPMN generation
analyze_workflows() {
    local trace_id="$1"
    local start_time=$(date +%s%N)
    
    echo "🔍 Analyzing system workflows from worktree for BPMN generation..."
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    
    # Analyze coordination workflows
    local coord_processes=0
    if [[ -f "coordination_helper.sh" ]]; then
        coord_processes=$(grep -c "function\|^[a-zA-Z_][a-zA-Z0-9_]*(" coordination_helper.sh 2>/dev/null || echo "0")
        coord_processes=$(echo "$coord_processes" | tr -d '\n\r\t ' | head -1)
        coord_processes=${coord_processes:-0}
    fi
    
    # Analyze worktree-specific workflows
    local worktree_processes=0
    if [[ -f "manage_worktrees.sh" ]]; then
        worktree_processes=$(grep -c "function\|^[a-zA-Z_][a-zA-Z0-9_]*(" manage_worktrees.sh 2>/dev/null || echo "0")
        worktree_processes=$(echo "$worktree_processes" | tr -d '\n\r\t ' | head -1)
        worktree_processes=${worktree_processes:-0}
    fi
    
    # Analyze telemetry workflows
    local telemetry_operations=0
    if [[ -f "$TELEMETRY_FILE" ]]; then
        telemetry_operations=$(jq -r '.operation_name // .operation // empty' "$TELEMETRY_FILE" 2>/dev/null | sort | uniq | wc -l | tr -d '\n\r\t ' | head -1 || echo "0")
        telemetry_operations=${telemetry_operations:-0}
    fi
    
    # Analyze work claims workflow
    local work_types=0
    if [[ -f "work_claims.json" ]]; then
        work_types=$(jq -r '.[].work_type // empty' work_claims.json 2>/dev/null | sort | uniq | wc -l | tr -d '\n\r\t ' | head -1 || echo "0")
        work_types=${work_types:-0}
    fi
    
    # Count existing worktrees
    local active_worktrees=$(git worktree list | wc -l | tr -d '\n\r\t ' | head -1 || echo "1")
    active_worktrees=${active_worktrees:-1}
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Create workflow analysis report
    cat > "$OUTPUT_DIR/worktree_workflow_analysis.json" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "trace_id": "$trace_id",
  "worktree_context": "bpmn-feature",
  "analysis_results": {
    "coordination_processes": $coord_processes,
    "worktree_management_processes": $worktree_processes,
    "telemetry_operations": $telemetry_operations,
    "work_claim_types": $work_types,
    "active_worktrees": $active_worktrees,
    "total_identifiable_workflows": $((coord_processes + worktree_processes + telemetry_operations + work_types))
  },
  "recommended_bpmn_diagrams": [
    "worktree_development_workflow",
    "feature_development_process",
    "agent_coordination_in_worktree",
    "telemetry_collection_flow",
    "isolated_testing_process"
  ]
}
EOF
    
    log_telemetry_span "worktree_analysis" "completed" "$trace_id" "$duration_ms" \
        "{\"coordination_processes\":$coord_processes,\"worktree_processes\":$worktree_processes,\"telemetry_operations\":$telemetry_operations,\"work_types\":$work_types,\"active_worktrees\":$active_worktrees}"
    
    echo "✅ Worktree workflow analysis complete: $((coord_processes + worktree_processes + telemetry_operations + work_types)) workflows identified"
    echo "$OUTPUT_DIR/worktree_workflow_analysis.json"
}

# Generate BPMN diagrams using ollama-pro
generate_bpmn_diagrams() {
    local trace_id="$1"
    local scope="${2:-all}"
    local start_time=$(date +%s%N)
    
    echo "🤖 Generating BPMN diagrams using ollama-pro in worktree..."
    echo "Scope: $scope"
    
    # Check if ollama-pro is available
    if [[ ! -f "./ollama-pro" ]]; then
        echo "❌ ollama-pro not found. BPMN generation requires ollama-pro."
        log_telemetry_span "bpmn_generation" "error" "$trace_id" "0" \
            "{\"error\":\"ollama-pro_not_found\",\"scope\":\"$scope\"}"
        return 1
    fi
    
    local diagrams_generated=0
    
    # Generate Worktree Development BPMN
    if [[ "$scope" == "all" || "$scope" == "worktree" ]]; then
        echo "📋 Generating Worktree Development BPMN..."
        local worktree_prompt="Generate a comprehensive BPMN diagram for worktree-based feature development workflow including: worktree creation, isolated coordination setup, feature development phase, testing and validation, merge preparation, and cleanup. Include parallel development capabilities and telemetry tracking. Output as valid BPMN 2.0 XML format."
        
        if timeout 45s ./ollama-pro run qwen3:latest "$worktree_prompt" > "$OUTPUT_DIR/worktree_development.bpmn" 2>/dev/null; then
            echo "✅ Worktree development BPMN generated"
            ((diagrams_generated++))
        else
            echo "⚠️ Worktree development BPMN generation failed"
        fi
    fi
    
    # Generate Feature Development Process BPMN
    if [[ "$scope" == "all" || "$scope" == "feature" ]]; then
        echo "📋 Generating Feature Development Process BPMN..."
        local feature_prompt="Generate a BPMN diagram for isolated feature development process including: requirements analysis, feature design, implementation in worktree, automated testing, code review, integration testing, and deployment preparation. Include error handling and rollback procedures. Output as valid BPMN 2.0 XML format."
        
        if timeout 45s ./ollama-pro run qwen3:latest "$feature_prompt" > "$OUTPUT_DIR/feature_development.bpmn" 2>/dev/null; then
            echo "✅ Feature development BPMN generated"
            ((diagrams_generated++))
        else
            echo "⚠️ Feature development BPMN generation failed"
        fi
    fi
    
    # Generate Coordination BPMN
    if [[ "$scope" == "all" || "$scope" == "coordination" ]]; then
        echo "📋 Generating Agent Coordination BPMN..."
        local coord_prompt="Generate a BPMN diagram for agent coordination workflow within worktree environment including: agent registration, isolated work claiming, progress tracking with worktree context, completion reporting, and telemetry logging. Include coordination between main branch and worktree operations. Output as valid BPMN 2.0 XML format."
        
        if timeout 45s ./ollama-pro run qwen3:latest "$coord_prompt" > "$OUTPUT_DIR/agent_coordination_worktree.bpmn" 2>/dev/null; then
            echo "✅ Agent coordination BPMN generated"
            ((diagrams_generated++))
        else
            echo "⚠️ Agent coordination BPMN generation failed"
        fi
    fi
    
    local end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Generate summary report
    cat > "$OUTPUT_DIR/bpmn_generation_report.json" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "trace_id": "$trace_id",
  "worktree_context": "bpmn-feature",
  "scope": "$scope",
  "diagrams_generated": $diagrams_generated,
  "generation_duration_ms": $duration_ms,
  "output_directory": "$OUTPUT_DIR",
  "generated_files": [
$(find "$OUTPUT_DIR" -name "*.bpmn" -newer "$OUTPUT_DIR/worktree_workflow_analysis.json" 2>/dev/null | sed 's/.*/\"&\"/' | paste -sd, -)
  ]
}
EOF
    
    log_telemetry_span "worktree_bpmn_generation" "completed" "$trace_id" "$duration_ms" \
        "{\"diagrams_generated\":$diagrams_generated,\"scope\":\"$scope\",\"output_dir\":\"$OUTPUT_DIR\",\"worktree\":\"bpmn-feature\"}"
    
    echo "✅ Worktree BPMN generation complete: $diagrams_generated diagrams generated in ${duration_ms}ms"
    echo "📁 Output directory: $OUTPUT_DIR"
}

# Main execution function
main() {
    local mode="${1:-generate}"
    local scope="${2:-all}"
    local trace_id=$(generate_trace_id)
    
    echo "🎯 BPMN Ollama-Pro Generator (Worktree)"
    echo "======================================"
    echo "Mode: $mode"
    echo "Scope: $scope"
    echo "Trace ID: $trace_id"
    echo "Worktree: bpmn-feature"
    echo ""
    
    case "$mode" in
        "analyze")
            analyze_workflows "$trace_id"
            ;;
        "generate")
            analyze_workflows "$trace_id"
            generate_bpmn_diagrams "$trace_id" "$scope"
            ;;
        "validate")
            echo "🔍 Validation not implemented in worktree version"
            ;;
        "schedule")
            echo "📅 Cron scheduling not implemented in worktree version"
            ;;
        "all")
            analyze_workflows "$trace_id"
            generate_bpmn_diagrams "$trace_id" "$scope"
            ;;
        *)
            echo "❌ Unknown mode: $mode"
            echo "Available modes: analyze, generate, all"
            exit 1
            ;;
    esac
    
    echo ""
    echo "✅ BPMN worktree generation workflow complete!"
    echo "📊 Check telemetry: grep bpmn_generator $TELEMETRY_FILE | tail -5 | jq '.'"
}

# Error handling with telemetry
trap_error() {
    local exit_code=$?
    local trace_id=$(generate_trace_id)
    log_telemetry_span "error_handler" "error" "$trace_id" "0" \
        "{\"exit_code\":$exit_code,\"error_location\":\"${BASH_SOURCE[1]}:${BASH_LINENO[0]}\",\"worktree\":\"bpmn-feature\"}"
    echo "❌ Error occurred in worktree (exit code: $exit_code)"
    exit $exit_code
}

trap trap_error ERR

# Run main function
main "$@"