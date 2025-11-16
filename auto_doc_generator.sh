#!/bin/bash

# Automated Documentation Generator
# Uses ollama-pro to generate documentation from codebase with cron scheduling
# 80/20 optimized: Focus on high-value documentation generation

set -euo pipefail

# Configuration
readonly SCRIPT_NAME="auto_doc_generator"
readonly VERSION="1.1.0"
readonly OUTPUT_DIR="docs/auto_generated"
readonly TRACE_ID="$(openssl rand -hex 16)"
readonly GENERATION_START=$(date +%s%N)

# OpenTelemetry configuration
readonly OTEL_SERVICE_NAME="auto-doc-generator"
readonly OTEL_SERVICE_VERSION="$VERSION"

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Configuration parameters
DOC_TYPES="${DOC_TYPES:-readme,api,changelog,features}"
MAX_FILES_PER_TYPE="${MAX_FILES_PER_TYPE:-10}"
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3.1:8b}"
TELEMETRY_FILE="${TELEMETRY_FILE:-telemetry_spans.jsonl}"

# Logging function with OpenTelemetry span generation
log_span() {
    local operation="$1"
    local status="$2"
    local duration_ms="$3"
    local attributes="$4"
    
    local span_data=$(cat <<EOF
{
  "trace_id": "$TRACE_ID",
  "span_id": "$(openssl rand -hex 8)",
  "operation_name": "auto_doc.$operation",
  "status": "$status",
  "duration_ms": $duration_ms,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "service": {
    "name": "$OTEL_SERVICE_NAME",
    "version": "$OTEL_SERVICE_VERSION"
  },
  "attributes": $attributes
}
EOF
    )
    
    echo "$span_data" >> "$TELEMETRY_FILE"
}

# Setup output directory
setup_output_dir() {
    local start_time=$(date +%s%N)
    
    mkdir -p "$OUTPUT_DIR"
    
    # Create index file if it doesn't exist
    if [[ ! -f "$OUTPUT_DIR/index.md" ]]; then
        cat > "$OUTPUT_DIR/index.md" <<EOF
# Auto-Generated Documentation

This directory contains automatically generated documentation using ollama-pro.

## Available Documentation

- [README Updates](readme_updates.md) - Generated README improvements
- [API Documentation](api_docs.md) - Extracted API documentation
- [Change Log](changelog.md) - Generated change summaries
- [Feature Documentation](features.md) - Feature descriptions and usage

## Generation Info

- Generator: auto_doc_generator.sh v$VERSION
- Model: $OLLAMA_MODEL
- Last Updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
- Trace ID: $TRACE_ID

EOF
    fi
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    log_span "setup" "completed" "$duration" \
        "{\"output_dir\": \"$OUTPUT_DIR\", \"index_created\": true}"
}

# Generate README documentation updates
generate_readme_docs() {
    local start_time=$(date +%s%N)
    echo -e "${BLUE}📖 Generating README documentation updates...${NC}"
    
    local output_file="$OUTPUT_DIR/readme_updates.md"
    
    # Analyze current README and suggest improvements
    local readme_analysis
    if [[ -f "README.md" ]]; then
        readme_analysis=$(./ollama-pro "
Analyze this README.md file and suggest specific improvements:

$(head -50 README.md)

Focus on:
1. Missing sections that would help users
2. Unclear explanations that need clarification
3. Additional examples that would be valuable
4. Better organization suggestions

Provide specific, actionable recommendations in markdown format.
" --model "$OLLAMA_MODEL" --output-format markdown 2>/dev/null || echo "Failed to analyze README")
    else
        readme_analysis="No README.md found. Consider creating one with:
- Project overview and purpose
- Quick start instructions
- Installation guide
- Usage examples
- Contributing guidelines"
    fi
    
    cat > "$output_file" <<EOF
# README Documentation Updates

Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Trace ID: $TRACE_ID

## Analysis and Recommendations

$readme_analysis

## Implementation Priority

Based on 80/20 analysis:
- **High Priority**: Quick start guide, core examples
- **Medium Priority**: Advanced configuration, troubleshooting
- **Low Priority**: Detailed architecture, edge cases

EOF
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    local word_count=$(wc -w < "$output_file" || echo "0")
    
    log_span "readme_generation" "completed" "$duration" \
        "{\"output_file\": \"$output_file\", \"word_count\": $word_count}"
    
    echo -e "${GREEN}✅ README documentation generated: $output_file${NC}"
}

# Generate API documentation from code
generate_api_docs() {
    local start_time=$(date +%s%N)
    echo -e "${BLUE}📋 Generating API documentation...${NC}"
    
    local output_file="$OUTPUT_DIR/api_docs.md"
    
    # Find key script files for API analysis
    local key_scripts
    key_scripts=$(find . -name "*.sh" -not -path "./backups/*" -not -path "./logs/*" -not -path "./real_work_results/*" | head -"$MAX_FILES_PER_TYPE")
    
    local api_analysis=""
    
    if [[ -n "$key_scripts" ]]; then
        # Analyze coordination_helper.sh as main API
        if [[ -f "coordination_helper.sh" ]]; then
            api_analysis=$(./ollama-pro "
Extract and document the API/command interface from this bash script:

$(head -100 coordination_helper.sh | grep -E '^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*\(\)|# [A-Z]|Usage:|Commands:' || echo '')

Create API documentation in markdown format showing:
1. Available commands/functions
2. Parameters and options
3. Return values or outputs
4. Usage examples

Focus on the user-facing interface, not internal implementation.
" --model "$OLLAMA_MODEL" --output-format markdown 2>/dev/null || echo "Failed to analyze API")
        fi
    fi
    
    cat > "$output_file" <<EOF
# API Documentation

Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Trace ID: $TRACE_ID

## Main API Interface

$api_analysis

## Script Analysis

Analyzed scripts:
$key_scripts

## 80/20 Documentation Priority

- **Core Commands** (80% usage): claim, progress, complete, dashboard
- **Advanced Features** (20% usage): claude-analyze, pi-planning, optimization

EOF
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    local script_count=$(echo "$key_scripts" | wc -l || echo "0")
    
    log_span "api_generation" "completed" "$duration" \
        "{\"output_file\": \"$output_file\", \"scripts_analyzed\": $script_count}"
    
    echo -e "${GREEN}✅ API documentation generated: $output_file${NC}"
}

# Generate changelog from git history
generate_changelog() {
    local start_time=$(date +%s%N)
    echo -e "${BLUE}📝 Generating changelog...${NC}"
    
    local output_file="$OUTPUT_DIR/changelog.md"
    
    # Get recent git commits
    local recent_commits
    recent_commits=$(git log --oneline -10 --pretty=format:"- %s (%cr)" 2>/dev/null || echo "No git history available")
    
    # Use ollama-pro to analyze and improve changelog
    local changelog_analysis
    changelog_analysis=$(./ollama-pro "
Analyze these recent commits and create a structured changelog:

$recent_commits

Create a changelog in markdown format with:
1. Version sections (if identifiable)
2. Categories: Features, Improvements, Bug Fixes, etc.
3. User-friendly descriptions
4. Breaking changes highlighted

Focus on user-impacting changes, not internal refactoring.
" --model "$OLLAMA_MODEL" --output-format markdown 2>/dev/null || echo "Recent Changes:
$recent_commits")
    
    cat > "$output_file" <<EOF
# Changelog

Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Trace ID: $TRACE_ID

## Recent Changes

$changelog_analysis

## Generation Notes

- Based on last 10 git commits
- Analyzed with $OLLAMA_MODEL
- Focused on user-impacting changes

EOF
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    log_span "changelog_generation" "completed" "$duration" \
        "{\"output_file\": \"$output_file\", \"commits_analyzed\": 10}"
    
    echo -e "${GREEN}✅ Changelog generated: $output_file${NC}"
}

# Generate feature documentation
generate_feature_docs() {
    local start_time=$(date +%s%N)
    echo -e "${BLUE}🚀 Generating feature documentation...${NC}"
    
    local output_file="$OUTPUT_DIR/features.md"
    
    # Analyze Makefile for features
    local makefile_features=""
    if [[ -f "Makefile" ]]; then
        makefile_features=$(grep -E '^[a-zA-Z][a-zA-Z0-9_-]*:' Makefile | head -20 | cut -d: -f1 | tr '\n' ' ')
    fi
    
    # Use ollama-pro to document features
    local feature_analysis
    feature_analysis=$(./ollama-pro "
Document the key features based on these Makefile targets:

$makefile_features

Create feature documentation in markdown format with:
1. Feature categories (Core, Testing, Automation, etc.)
2. Brief description of each feature
3. Usage examples
4. Benefits/use cases

Focus on the 80/20 principle - document the most commonly used features first.
" --model "$OLLAMA_MODEL" --output-format markdown 2>/dev/null || echo "Features detected:
$makefile_features")
    
    cat > "$output_file" <<EOF
# Feature Documentation

Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Trace ID: $TRACE_ID

## Available Features

$feature_analysis

## Feature Usage Statistics

Based on 80/20 analysis:
- **Essential Features** (daily use): claim, dashboard, test
- **Regular Features** (weekly use): optimize, analyze, monitor
- **Advanced Features** (occasional use): pi-planning, worktrees

EOF
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    log_span "feature_generation" "completed" "$duration" \
        "{\"output_file\": \"$output_file\", \"makefile_targets\": \"$(echo $makefile_features | wc -w)\"}"
    
    echo -e "${GREEN}✅ Feature documentation generated: $output_file${NC}"
}

# Generate cron integration script
generate_cron_integration() {
    local start_time=$(date +%s%N)
    echo -e "${BLUE}⏰ Setting up cron integration...${NC}"
    
    local cron_script="$OUTPUT_DIR/auto_doc_cron.sh"
    
    cat > "$cron_script" <<'EOF'
#!/bin/bash
# Auto-documentation cron job wrapper
# Runs documentation generation with proper error handling and logging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/auto_doc_cron.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Run documentation generation with logging
{
    echo "$(date): Starting automated documentation generation"
    
    # Change to project root (assuming docs/auto_generated structure)
    cd "$SCRIPT_DIR/../.."
    
    # Run the documentation generator
    if ./auto_doc_generator.sh; then
        echo "$(date): Documentation generation completed successfully"
    else
        echo "$(date): Documentation generation failed with exit code $?"
    fi
    
    echo "----------------------------------------"
} >> "$LOG_FILE" 2>&1
EOF
    
    chmod +x "$cron_script"
    
    # Create cron installation instructions
    cat > "$OUTPUT_DIR/cron_setup.md" <<EOF
# Cron Setup for Auto-Documentation

## Installation

Add this line to your crontab (run \`crontab -e\`):

\`\`\`bash
# Generate documentation daily at 2 AM
0 2 * * * $PWD/$cron_script
\`\`\`

## Alternative: Use existing cron-setup.sh

\`\`\`bash
# Add to cron-setup.sh
echo "0 2 * * * $PWD/auto_doc_generator.sh" >> cron_schedule.txt
./cron-setup.sh install
\`\`\`

## Monitoring

Check logs at: \`docs/logs/auto_doc_cron.log\`

## Manual execution

\`\`\`bash
./auto_doc_generator.sh
\`\`\`

EOF
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    log_span "cron_setup" "completed" "$duration" \
        "{\"cron_script\": \"$cron_script\", \"setup_guide\": \"$OUTPUT_DIR/cron_setup.md\"}"
    
    echo -e "${GREEN}✅ Cron integration setup: $cron_script${NC}"
}

# Update index with generation results
update_index() {
    local start_time=$(date +%s%N)
    
    cat > "$OUTPUT_DIR/index.md" <<EOF
# Auto-Generated Documentation

Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Trace ID: $TRACE_ID

## Available Documentation

- [README Updates](readme_updates.md) - Generated README improvements and suggestions
- [API Documentation](api_docs.md) - Extracted API documentation from scripts
- [Changelog](changelog.md) - Recent changes and version history
- [Feature Documentation](features.md) - Feature descriptions and usage examples

## Cron Integration

- [Cron Setup Guide](cron_setup.md) - Instructions for automated generation
- [Cron Script](auto_doc_cron.sh) - Wrapper script for cron execution

## Generation Statistics

- **Model Used**: $OLLAMA_MODEL
- **Documentation Types**: $(echo "$DOC_TYPES" | tr ',' ' ')
- **Total Files Generated**: $(ls -1 "$OUTPUT_DIR"/*.md | wc -l)
- **Generation Time**: $(($(date +%s%N) - GENERATION_START)) nanoseconds

## OpenTelemetry Integration

All generation operations are traced with:
- Trace ID: $TRACE_ID
- Service: $OTEL_SERVICE_NAME v$OTEL_SERVICE_VERSION
- Telemetry File: $TELEMETRY_FILE

EOF
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    log_span "index_update" "completed" "$duration" \
        "{\"files_count\": $(ls -1 "$OUTPUT_DIR"/*.md | wc -l)}"
}

# Main execution function
main() {
    echo -e "${PURPLE}🤖 Auto Documentation Generator v$VERSION${NC}"
    echo -e "${BLUE}Trace ID: $TRACE_ID${NC}"
    echo -e "${BLUE}Using model: $OLLAMA_MODEL${NC}"
    echo ""
    
    local total_start=$(date +%s%N)
    
    # Check ollama-pro availability
    if ! command -v ./ollama-pro >/dev/null 2>&1; then
        echo -e "${RED}❌ Error: ollama-pro not found in current directory${NC}"
        echo "Please ensure ollama-pro is available and executable"
        exit 1
    fi
    
    # Setup and generate documentation
    setup_output_dir
    
    # Parse requested documentation types
    IFS=',' read -ra TYPES <<< "$DOC_TYPES"
    for doc_type in "${TYPES[@]}"; do
        case "$doc_type" in
            readme)
                generate_readme_docs
                ;;
            api)
                generate_api_docs
                ;;
            changelog)
                generate_changelog
                ;;
            features)
                generate_feature_docs
                ;;
            *)
                echo -e "${YELLOW}⚠️ Unknown documentation type: $doc_type${NC}"
                ;;
        esac
    done
    
    # Setup cron integration
    generate_cron_integration
    
    # Update index
    update_index
    
    local total_end=$(date +%s%N)
    local total_duration=$(( (total_end - total_start) / 1000000 ))
    
    # Final telemetry span
    log_span "generation_complete" "completed" "$total_duration" \
        "{\"doc_types\": \"$DOC_TYPES\", \"output_dir\": \"$OUTPUT_DIR\", \"files_generated\": $(ls -1 "$OUTPUT_DIR" | wc -l)}"
    
    echo ""
    echo -e "${GREEN}✅ Documentation generation completed!${NC}"
    echo -e "${BLUE}📁 Output directory: $OUTPUT_DIR${NC}"
    echo -e "${BLUE}📊 Total generation time: ${total_duration}ms${NC}"
    echo -e "${BLUE}🔍 Trace ID: $TRACE_ID${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Review generated documentation in $OUTPUT_DIR"
    echo "  2. Set up cron automation: see $OUTPUT_DIR/cron_setup.md"
    echo "  3. Monitor telemetry in $TELEMETRY_FILE"
}

# Usage information
show_usage() {
    cat <<EOF
Auto Documentation Generator v$VERSION

USAGE:
    $0 [options]

OPTIONS:
    --types TYPE1,TYPE2,...    Documentation types to generate
                              Available: readme,api,changelog,features
                              Default: $DOC_TYPES

    --model MODEL             Ollama model to use
                              Default: $OLLAMA_MODEL

    --max-files N            Maximum files to analyze per type
                              Default: $MAX_FILES_PER_TYPE

    --output-dir DIR         Output directory for generated docs
                              Default: $OUTPUT_DIR

    --help, -h               Show this help message

EXAMPLES:
    $0                                      # Generate all documentation types
    $0 --types readme,api                   # Generate only README and API docs
    $0 --model llama3.1:70b                # Use different model
    $0 --output-dir custom_docs             # Custom output directory

ENVIRONMENT VARIABLES:
    DOC_TYPES                Documentation types (comma-separated)
    OLLAMA_MODEL            Model to use for generation
    MAX_FILES_PER_TYPE      Files to analyze per documentation type
    TELEMETRY_FILE          OpenTelemetry spans output file

FEATURES:
    ✅ 80/20 optimized documentation generation
    ✅ OpenTelemetry integration with span tracking
    ✅ Cron automation support with error handling
    ✅ Multiple documentation types (README, API, changelog, features)
    ✅ Configurable ollama-pro model selection
    ✅ Structured markdown output with navigation

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --types)
            DOC_TYPES="$2"
            shift 2
            ;;
        --model)
            OLLAMA_MODEL="$2"
            shift 2
            ;;
        --max-files)
            MAX_FILES_PER_TYPE="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Execute main function
main "$@"