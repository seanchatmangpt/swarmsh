#!/usr/bin/env bash

# Telemetry Manager - 80/20 Optimized
# Automated telemetry file health management and cleanup
# Designed for cron execution with OpenTelemetry integration

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TRACE_ID="$(openssl rand -hex 16 2>/dev/null || echo "telemetry_mgr_$(date +%s%N)")"
readonly SPAN_ID="$(openssl rand -hex 8 2>/dev/null || echo "$(date +%s%N | cut -c-16)")"
readonly OPERATION_START=$(date +%s%N)

# Telemetry management configuration
readonly TELEMETRY_FILE="$SCRIPT_DIR/telemetry_spans.jsonl"
readonly MAX_FILE_SIZE=$((10 * 1024 * 1024))  # 10MB
readonly MAX_LINES=5000
readonly ARCHIVE_DIR="$SCRIPT_DIR/telemetry_archive"
readonly RETENTION_DAYS=30

# Performance and health thresholds
readonly MAX_DAILY_SPANS=1000
readonly WARN_FILE_SIZE=$((5 * 1024 * 1024))  # 5MB warning threshold

# Colors (for manual execution)
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log_info() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $msg"
}

log_warn() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN] $msg"
}

log_error() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $msg"
}

# Generate telemetry span for this operation
generate_telemetry_span() {
    local operation=$1
    local status=$2
    local metrics=$3
    local duration=${4:-0}
    
    local span="{\"trace_id\":\"$TRACE_ID\",\"span_id\":\"$SPAN_ID\",\"operation\":\"telemetry_manager.$operation\",\"service\":\"cron-telemetry-manager\",\"status\":\"$status\",\"duration_ms\":$duration,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"metrics\":$metrics}"
    
    # Write to telemetry file (avoiding infinite loop)
    if [[ "$operation" != "span_generation" ]]; then
        echo "$span" >> "$TELEMETRY_FILE"
    fi
    
    echo "$span"
}

# Check telemetry file health
check_file_health() {
    log_info "Checking telemetry file health..."
    
    local health_issues=0
    local metrics="{}"
    
    if [[ ! -f "$TELEMETRY_FILE" ]]; then
        log_warn "Telemetry file does not exist: $TELEMETRY_FILE"
        touch "$TELEMETRY_FILE"
        metrics='{"file_created":true,"size_bytes":0,"line_count":0}'
        generate_telemetry_span "health_check" "completed" "$metrics" 50
        return 0
    fi
    
    # Get file statistics
    local file_size=$(stat -f%z "$TELEMETRY_FILE" 2>/dev/null || stat -c%s "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local line_count=$(wc -l < "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local file_age_hours=$(( ($(date +%s) - $(stat -f%m "$TELEMETRY_FILE" 2>/dev/null || stat -c%Y "$TELEMETRY_FILE" 2>/dev/null || echo "0")) / 3600 ))
    
    metrics="{\"file_size_bytes\":$file_size,\"line_count\":$line_count,\"file_age_hours\":$file_age_hours,\"max_size_threshold\":$MAX_FILE_SIZE,\"max_lines_threshold\":$MAX_LINES}"
    
    log_info "File statistics: ${file_size} bytes, ${line_count} lines, ${file_age_hours}h old"
    
    # Check size threshold
    if [[ $file_size -gt $MAX_FILE_SIZE ]]; then
        log_warn "File size ($file_size bytes) exceeds maximum ($MAX_FILE_SIZE bytes)"
        ((health_issues++))
    elif [[ $file_size -gt $WARN_FILE_SIZE ]]; then
        log_warn "File size ($file_size bytes) approaching threshold"
    fi
    
    # Check line count threshold
    if [[ $line_count -gt $MAX_LINES ]]; then
        log_warn "Line count ($line_count) exceeds maximum ($MAX_LINES)"
        ((health_issues++))
    fi
    
    # Validate JSON structure (sample check)
    local malformed_lines=0
    if command -v jq >/dev/null 2>&1 && [[ $line_count -gt 0 ]]; then
        # Check last 10 lines for JSON validity
        tail -10 "$TELEMETRY_FILE" | while read -r line; do
            if [[ -n "$line" ]] && ! echo "$line" | jq empty 2>/dev/null; then
                ((malformed_lines++))
            fi
        done || true
        
        if [[ $malformed_lines -gt 0 ]]; then
            log_warn "Found $malformed_lines malformed JSON lines in recent entries"
            ((health_issues++))
        fi
    fi
    
    local health_status="healthy"
    if [[ $health_issues -gt 0 ]]; then
        health_status="needs_maintenance"
    fi
    
    metrics="{\"file_size_bytes\":$file_size,\"line_count\":$line_count,\"file_age_hours\":$file_age_hours,\"health_issues\":$health_issues,\"malformed_lines\":$malformed_lines,\"status\":\"$health_status\"}"
    
    generate_telemetry_span "health_check" "completed" "$metrics" 100
    
    echo "$health_issues"
}

# Archive old telemetry data
archive_telemetry() {
    log_info "Archiving telemetry data..."
    
    if [[ ! -f "$TELEMETRY_FILE" ]] || [[ ! -s "$TELEMETRY_FILE" ]]; then
        log_info "No telemetry data to archive"
        return 0
    fi
    
    # Create archive directory
    mkdir -p "$ARCHIVE_DIR"
    
    local file_size=$(stat -f%z "$TELEMETRY_FILE" 2>/dev/null || stat -c%s "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local line_count=$(wc -l < "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    
    # Determine if archival is needed
    local needs_archival=false
    if [[ $file_size -gt $MAX_FILE_SIZE ]] || [[ $line_count -gt $MAX_LINES ]]; then
        needs_archival=true
    fi
    
    if [[ "$needs_archival" == "false" ]]; then
        log_info "No archival needed (size: ${file_size}, lines: ${line_count})"
        generate_telemetry_span "archive" "skipped" "{\"reason\":\"thresholds_not_exceeded\",\"file_size\":$file_size,\"line_count\":$line_count}" 25
        return 0
    fi
    
    # Create archive file with timestamp
    local archive_timestamp=$(date +%Y%m%d_%H%M%S)
    local archive_file="$ARCHIVE_DIR/telemetry_${archive_timestamp}.jsonl"
    
    # Copy current telemetry to archive
    cp "$TELEMETRY_FILE" "$archive_file"
    
    # Keep only recent entries in active file (last 1000 lines)
    local keep_lines=1000
    tail -$keep_lines "$TELEMETRY_FILE" > "${TELEMETRY_FILE}.tmp"
    mv "${TELEMETRY_FILE}.tmp" "$TELEMETRY_FILE"
    
    local new_size=$(stat -f%z "$TELEMETRY_FILE" 2>/dev/null || stat -c%s "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local new_line_count=$(wc -l < "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    local archived_lines=$((line_count - new_line_count))
    
    log_info "Archived $archived_lines lines to $archive_file"
    log_info "Active file reduced from $line_count to $new_line_count lines"
    
    local metrics="{\"archived_lines\":$archived_lines,\"archive_file\":\"$archive_file\",\"original_size\":$file_size,\"new_size\":$new_size,\"size_reduction_percent\":$(( (file_size - new_size) * 100 / file_size ))}"
    
    generate_telemetry_span "archive" "completed" "$metrics" 200
    
    echo "$archived_lines"
}

# Clean old archives
cleanup_old_archives() {
    log_info "Cleaning old archives (retention: ${RETENTION_DAYS} days)..."
    
    if [[ ! -d "$ARCHIVE_DIR" ]]; then
        log_info "No archive directory found"
        return 0
    fi
    
    local removed_count=0
    local total_size_removed=0
    
    # Find and remove old archives
    while IFS= read -r -d '' file; do
        local file_age_days=$(( ($(date +%s) - $(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo "0")) / 86400 ))
        if [[ $file_age_days -gt $RETENTION_DAYS ]]; then
            local file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            rm -f "$file"
            ((removed_count++))
            total_size_removed=$((total_size_removed + file_size))
            log_info "Removed old archive: $(basename "$file") (${file_age_days} days old)"
        fi
    done < <(find "$ARCHIVE_DIR" -name "telemetry_*.jsonl" -print0 2>/dev/null || true)
    
    local metrics="{\"files_removed\":$removed_count,\"total_size_removed\":$total_size_removed,\"retention_days\":$RETENTION_DAYS}"
    
    generate_telemetry_span "cleanup" "completed" "$metrics" 150
    
    log_info "Removed $removed_count old archives, freed $total_size_removed bytes"
    echo "$removed_count"
}

# Generate performance report
generate_performance_report() {
    log_info "Generating telemetry performance report..."
    
    local report_file="$SCRIPT_DIR/telemetry_performance_report.json"
    local current_time=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # Get current file statistics
    local file_size=0
    local line_count=0
    local recent_spans=0
    
    if [[ -f "$TELEMETRY_FILE" ]]; then
        file_size=$(stat -f%z "$TELEMETRY_FILE" 2>/dev/null || stat -c%s "$TELEMETRY_FILE" 2>/dev/null || echo "0")
        line_count=$(wc -l < "$TELEMETRY_FILE" 2>/dev/null || echo "0")
        
        # Count spans from last 24 hours
        local yesterday=$(date -d "24 hours ago" +%Y-%m-%d 2>/dev/null || date -v-24H +%Y-%m-%d 2>/dev/null || echo "1970-01-01")
        recent_spans=$(grep -c "$yesterday\|$(date +%Y-%m-%d)" "$TELEMETRY_FILE" 2>/dev/null || echo "0")
    fi
    
    # Count archive files
    local archive_count=0
    local archive_total_size=0
    if [[ -d "$ARCHIVE_DIR" ]]; then
        archive_count=$(find "$ARCHIVE_DIR" -name "telemetry_*.jsonl" | wc -l)
        archive_total_size=$(find "$ARCHIVE_DIR" -name "telemetry_*.jsonl" -exec stat -f%z {} + 2>/dev/null | awk '{sum+=$1} END {print sum+0}' || echo "0")
    fi
    
    # Calculate health score
    local health_score=100
    if [[ $file_size -gt $WARN_FILE_SIZE ]]; then
        health_score=$((health_score - 20))
    fi
    if [[ $line_count -gt $((MAX_LINES * 80 / 100)) ]]; then
        health_score=$((health_score - 15))
    fi
    if [[ $recent_spans -gt $MAX_DAILY_SPANS ]]; then
        health_score=$((health_score - 10))
    fi
    
    # Generate report
    cat > "$report_file" <<EOF
{
    "timestamp": "$current_time",
    "trace_id": "$TRACE_ID",
    "telemetry_health": {
        "active_file_size_bytes": $file_size,
        "active_file_lines": $line_count,
        "recent_24h_spans": $recent_spans,
        "health_score": $health_score,
        "max_size_threshold": $MAX_FILE_SIZE,
        "max_lines_threshold": $MAX_LINES
    },
    "archive_statistics": {
        "archive_files": $archive_count,
        "archive_total_size_bytes": $archive_total_size,
        "retention_days": $RETENTION_DAYS
    },
    "performance_indicators": {
        "daily_span_rate": $recent_spans,
        "max_daily_threshold": $MAX_DAILY_SPANS,
        "size_efficiency": $(( file_size / (line_count + 1) )),
        "archive_compression_ratio": $(( archive_total_size / (file_size + 1) ))
    },
    "recommendations": $(if [[ $health_score -lt 80 ]]; then echo '["Consider reducing telemetry volume", "Enable more frequent archival"]'; else echo '["Telemetry health is good"]'; fi)
}
EOF
    
    local metrics="{\"health_score\":$health_score,\"active_size\":$file_size,\"archive_count\":$archive_count,\"recent_spans\":$recent_spans}"
    
    generate_telemetry_span "performance_report" "completed" "$metrics" 100
    
    log_info "Performance report generated: $report_file"
    echo "$report_file"
}

# Main execution
main() {
    local command="${1:-maintain}"
    
    case "$command" in
        "maintain")
            log_info "Starting telemetry maintenance (cron mode)"
            
            local health_issues=$(check_file_health)
            local archived_lines=$(archive_telemetry)
            local removed_archives=$(cleanup_old_archives)
            local report_file=$(generate_performance_report)
            
            local operation_end=$(date +%s%N)
            local duration_ms=$(( (operation_end - OPERATION_START) / 1000000 ))
            
            local final_metrics="{\"health_issues\":$health_issues,\"archived_lines\":$archived_lines,\"removed_archives\":$removed_archives,\"duration_ms\":$duration_ms,\"report_file\":\"$(basename "$report_file")\"}"
            
            generate_telemetry_span "maintenance_complete" "completed" "$final_metrics" "$duration_ms"
            
            log_info "Telemetry maintenance completed in ${duration_ms}ms"
            ;;
        "health")
            check_file_health
            ;;
        "archive")
            archive_telemetry
            ;;
        "cleanup")
            cleanup_old_archives
            ;;
        "report")
            generate_performance_report
            cat "$(generate_performance_report)" | jq '.' 2>/dev/null || cat "$(generate_performance_report)"
            ;;
        "help")
            cat <<EOF
Telemetry Manager - 80/20 Optimized Cron Automation

Usage: $0 [command]

Commands:
  maintain    - Full maintenance cycle (default, for cron)
  health      - Check telemetry file health only
  archive     - Archive large telemetry files only
  cleanup     - Clean old archives only
  report      - Generate performance report
  help        - Show this help

Cron Integration:
  # Run maintenance every 4 hours
  0 */4 * * * $SCRIPT_DIR/cron-telemetry-manager.sh maintain

Configuration:
  Max file size: $MAX_FILE_SIZE bytes
  Max lines: $MAX_LINES
  Retention: $RETENTION_DAYS days
  Archive dir: $ARCHIVE_DIR
EOF
            ;;
        *)
            log_error "Unknown command: $command"
            $0 help
            exit 1
            ;;
    esac
}

# Ensure required directories exist
mkdir -p "$ARCHIVE_DIR"

# Run with error handling
if ! main "$@"; then
    local operation_end=$(date +%s%N)
    local duration_ms=$(( (operation_end - OPERATION_START) / 1000000 ))
    generate_telemetry_span "maintenance_failed" "error" "{\"duration_ms\":$duration_ms}" "$duration_ms"
    exit 1
fi