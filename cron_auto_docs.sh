#!/bin/bash

# Cron Integration for Auto Documentation
# Integrates with existing cron-setup.sh for automated documentation generation

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$SCRIPT_DIR"
readonly CRON_SCRIPT_NAME="auto_doc_generator"
readonly TRACE_ID="$(openssl rand -hex 16)"

# Add documentation generation to cron schedule
add_to_cron() {
    echo "🔧 Adding auto-documentation to cron schedule..."
    
    # Check if cron-setup.sh exists
    if [[ ! -f "$PROJECT_ROOT/cron-setup.sh" ]]; then
        echo "❌ Error: cron-setup.sh not found in project root"
        return 1
    fi
    
    # Create a temporary cron entry file
    local temp_cron_file=$(mktemp)
    cat > "$temp_cron_file" <<EOF
# Auto Documentation Generation - 80/20 Optimized
# Generates documentation daily at 2 AM using ollama-pro
0 2 * * * cd $PROJECT_ROOT && ./auto_doc_generator.sh --types readme,features >> logs/auto_doc_cron.log 2>&1

# Auto Documentation Quick Update - Generate changelog only at 8 AM and 6 PM
0 8,18 * * * cd $PROJECT_ROOT && ./auto_doc_generator.sh --types changelog >> logs/auto_doc_changelog.log 2>&1
EOF
    
    # Add to crontab using the existing cron-setup.sh mechanism
    echo "📋 Auto-documentation cron schedule:"
    cat "$temp_cron_file"
    
    # Add the entries to current crontab
    (crontab -l 2>/dev/null || true; cat "$temp_cron_file") | crontab -
    
    # Cleanup
    rm "$temp_cron_file"
    
    echo "✅ Auto-documentation cron jobs added successfully"
}

# Remove documentation cron jobs
remove_from_cron() {
    echo "🗑️ Removing auto-documentation from cron schedule..."
    
    # Remove any lines containing auto_doc_generator.sh
    local temp_cron_file=$(mktemp)
    crontab -l 2>/dev/null | grep -v "auto_doc_generator.sh" > "$temp_cron_file" || true
    
    # Only update if there were changes
    if ! cmp -s <(crontab -l 2>/dev/null || true) "$temp_cron_file"; then
        crontab "$temp_cron_file"
        echo "✅ Auto-documentation cron jobs removed"
    else
        echo "ℹ️ No auto-documentation cron jobs found"
    fi
    
    rm "$temp_cron_file"
}

# Show current cron status for documentation
show_cron_status() {
    echo "📊 Auto-Documentation Cron Status"
    echo "================================="
    
    # Check if auto-documentation cron jobs exist
    local doc_jobs=$(crontab -l 2>/dev/null | grep "auto_doc_generator.sh" | wc -l || echo "0")
    
    if [[ $doc_jobs -gt 0 ]]; then
        echo "✅ Active auto-documentation cron jobs: $doc_jobs"
        echo ""
        echo "📋 Current schedule:"
        crontab -l 2>/dev/null | grep "auto_doc_generator.sh" || echo "None found"
    else
        echo "❌ No auto-documentation cron jobs found"
    fi
    
    echo ""
    echo "📁 Recent documentation updates:"
    if [[ -d "docs/auto_generated" ]]; then
        ls -la docs/auto_generated/*.md 2>/dev/null | head -5 || echo "No documentation files found"
    else
        echo "Documentation directory not found"
    fi
    
    echo ""
    echo "📊 Recent cron logs:"
    if [[ -f "logs/auto_doc_cron.log" ]]; then
        echo "Last 5 lines from auto_doc_cron.log:"
        tail -5 logs/auto_doc_cron.log
    else
        echo "No cron logs found"
    fi
}

# Test documentation generation
test_generation() {
    echo "🧪 Testing auto-documentation generation..."
    
    local start_time=$(date +%s)
    
    # Run a quick test with changelog only
    if ./auto_doc_generator.sh --types changelog; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo "✅ Test generation completed in ${duration}s"
        echo "📁 Generated files:"
        ls -la docs/auto_generated/ 2>/dev/null || echo "No files generated"
        
        # Check telemetry
        echo "🔍 Telemetry validation:"
        local recent_spans=$(grep "auto_doc" telemetry_spans.jsonl 2>/dev/null | tail -1 | jq -r '.trace_id // "none"' 2>/dev/null || echo "none")
        if [[ "$recent_spans" != "none" ]]; then
            echo "✅ OpenTelemetry integration working (latest trace: ${recent_spans:0:8}...)"
        else
            echo "⚠️ No auto-doc telemetry spans found"
        fi
    else
        echo "❌ Test generation failed"
        return 1
    fi
}

# Generate telemetry span for cron operations
log_cron_span() {
    local operation="$1"
    local status="$2"
    local duration_ms="$3"
    
    local span_data=$(cat <<EOF
{
  "trace_id": "$TRACE_ID",
  "span_id": "$(openssl rand -hex 8)",
  "operation_name": "auto_doc_cron.$operation",
  "status": "$status",
  "duration_ms": $duration_ms,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "service": {
    "name": "auto-doc-cron",
    "version": "1.1.0"
  },
  "attributes": {
    "cron_operation": "$operation",
    "script_path": "$SCRIPT_DIR"
  }
}
EOF
    )
    
    echo "$span_data" >> "${TELEMETRY_FILE:-telemetry_spans.jsonl}"
}

# Main execution
main() {
    echo "🤖 Auto-Documentation Cron Integration"
    echo "======================================"
    echo "Trace ID: $TRACE_ID"
    echo ""
    
    local start_time=$(date +%s%N)
    
    case "${1:-status}" in
        install|add)
            add_to_cron
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            log_cron_span "install" "completed" "$duration"
            ;;
        remove|uninstall)
            remove_from_cron
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            log_cron_span "remove" "completed" "$duration"
            ;;
        status)
            show_cron_status
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            log_cron_span "status" "completed" "$duration"
            ;;
        test)
            test_generation
            local end_time=$(date +%s%N)
            local duration=$(( (end_time - start_time) / 1000000 ))
            log_cron_span "test" "completed" "$duration"
            ;;
        *)
            echo "Usage: $0 {install|remove|status|test}"
            echo ""
            echo "Commands:"
            echo "  install  - Add auto-documentation to cron schedule"
            echo "  remove   - Remove auto-documentation from cron"
            echo "  status   - Show current cron status"
            echo "  test     - Test documentation generation"
            echo ""
            echo "Examples:"
            echo "  $0 install    # Set up automated documentation"
            echo "  $0 test       # Test the generation process"
            echo "  $0 status     # Check current configuration"
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"