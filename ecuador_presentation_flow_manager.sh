#!/bin/bash

##############################################################################
# Ecuador Presentation Flow Manager - 20-Minute Demo Orchestration
##############################################################################
# Manages the precise timing and flow of the CiviqCore Ecuador Demo
# ensuring each segment delivers maximum impact within time constraints

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/otel-simple.sh" || true

# Demo configuration
DEMO_NAME="ecuador-demo"
TOTAL_DURATION=1200  # 20 minutes in seconds
LOG_FILE="$SCRIPT_DIR/logs/ecuador_presentation_flow.log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Presentation segments with timing
declare -A SEGMENTS=(
    ["opening_hook"]=120                    # 2 minutes
    ["current_state"]=180                   # 3 minutes
    ["solution_architecture"]=300           # 5 minutes
    ["efficiency_transformation"]=180       # 3 minutes
    ["implementation_roadmap"]=240          # 4 minutes
    ["geographic_impact"]=120               # 2 minutes
    ["investment_decision"]=60              # 1 minute
)

# Segment details
declare -A SEGMENT_TITLES=(
    ["opening_hook"]="Opening Hook: \$6.7B Opportunity"
    ["current_state"]="Current State Analysis"
    ["solution_architecture"]="CiviqCore Solution Architecture"
    ["efficiency_transformation"]="Efficiency Transformation Demo"
    ["implementation_roadmap"]="Implementation Roadmap"
    ["geographic_impact"]="Geographic Impact Visualization"
    ["investment_decision"]="Investment Decision Matrix"
)

# Key talking points per segment
declare -A TALKING_POINTS=(
    ["opening_hook"]="• \$5.2B fiscal deficit crisis\n• \$2B administrative overhead\n• 97% efficiency opportunity"
    ["current_state"]="• 75-day approval processes\n• 24 ministry silos\n• <1% digital adoption"
    ["solution_architecture"]="• Integrated digital platform\n• AI-powered automation\n• Real-time dashboards"
    ["efficiency_transformation"]="• 75 days → 2 hours\n• \$2,400 → \$85 per transaction\n• Live demonstration"
    ["implementation_roadmap"]="• 36-month phased approach\n• \$175M investment\n• Risk mitigation strategies"
    ["geographic_impact"]="• 24 provinces coverage\n• 221 cantons integration\n• National transformation"
    ["investment_decision"]="• \$450M ROI projection\n• 24-month payback\n• Clear next steps"
)

# Segment status tracking
declare -A SEGMENT_STATUS
declare -A SEGMENT_ACTUAL_TIME
CURRENT_SEGMENT=""
SEGMENT_START_TIME=0
PRESENTATION_START_TIME=0

# Initialize logging
mkdir -p "$(dirname "$LOG_FILE")"

# Initialize telemetry
init_telemetry() {
    local trace_id=$(generate_trace_id)
    local span_id=$(generate_span_id)
    
    export OTEL_TRACE_ID="$trace_id"
    export OTEL_SPAN_ID="$span_id"
    export OTEL_SERVICE_NAME="ecuador-presentation-flow"
}

# Log with timestamp
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Display timer
display_timer() {
    local elapsed="$1"
    local total="$2"
    local minutes=$((elapsed / 60))
    local seconds=$((elapsed % 60))
    local total_min=$((total / 60))
    local total_sec=$((total % 60))
    
    printf "\r⏱️  %02d:%02d / %02d:%02d" "$minutes" "$seconds" "$total_min" "$total_sec"
}

# Display progress bar
display_progress() {
    local current="$1"
    local total="$2"
    local width=50
    local progress=$((current * width / total))
    
    printf "\n["
    for ((i=0; i<width; i++)); do
        if ((i < progress)); then
            printf "█"
        else
            printf "░"
        fi
    done
    printf "] %d%%\n" $((current * 100 / total))
}

# Start presentation
start_presentation() {
    echo -e "${CYAN}🎬 Starting Ecuador Demo Presentation${NC}"
    echo "====================================="
    echo "Total Duration: 20 minutes"
    echo "Segments: ${#SEGMENTS[@]}"
    echo ""
    
    PRESENTATION_START_TIME=$(date +%s)
    
    # Initialize all segments
    for segment in "${!SEGMENTS[@]}"; do
        SEGMENT_STATUS[$segment]="pending"
        SEGMENT_ACTUAL_TIME[$segment]=0
    done
    
    # Create presentation session file
    local session_file="$SCRIPT_DIR/logs/presentation_session_$(date +%Y%m%d_%H%M%S).json"
    cat > "$session_file" <<EOF
{
    "session_id": "$(generate_trace_id)",
    "start_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "presenter": "${PRESENTER:-Executive}",
    "audience": "${AUDIENCE:-David Whitlock}",
    "segments": $(printf '%s\n' "${!SEGMENTS[@]}" | jq -Rs 'split("\n")[:-1]')
}
EOF
    
    log "INFO" "Presentation session started: $session_file"
}

# Start segment
start_segment() {
    local segment="$1"
    
    if [[ -n "$CURRENT_SEGMENT" ]]; then
        end_segment "$CURRENT_SEGMENT"
    fi
    
    CURRENT_SEGMENT="$segment"
    SEGMENT_START_TIME=$(date +%s)
    SEGMENT_STATUS[$segment]="active"
    
    # Create telemetry span
    local span_id=$(generate_span_id)
    start_span "$span_id" "segment_$segment" "$OTEL_SPAN_ID"
    
    # Clear screen and show segment info
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}▶ ${SEGMENT_TITLES[$segment]}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Duration:${NC} $((SEGMENTS[$segment] / 60)) minutes"
    echo ""
    echo -e "${YELLOW}Key Points:${NC}"
    echo -e "${TALKING_POINTS[$segment]}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Show commands for this segment
    case "$segment" in
        "opening_hook")
            echo -e "\n${CYAN}📊 Display Commands:${NC}"
            echo "  • Show ROI waterfall chart"
            echo "  • Display \$6.7B waste breakdown"
            echo "  • Highlight fiscal crisis metrics"
            ;;
        "efficiency_transformation")
            echo -e "\n${CYAN}🎯 Demo Commands:${NC}"
            echo "  • Start live process simulation"
            echo "  • Show 75-day → 2-hour transformation"
            echo "  • Display cost reduction metrics"
            ;;
        "investment_decision")
            echo -e "\n${CYAN}💼 Decision Commands:${NC}"
            echo "  • Show investment options matrix"
            echo "  • Display ROI calculations"
            echo "  • Present next steps checklist"
            ;;
    esac
    
    log "INFO" "Started segment: $segment"
}

# End segment
end_segment() {
    local segment="$1"
    local end_time=$(date +%s)
    local duration=$((end_time - SEGMENT_START_TIME))
    
    SEGMENT_STATUS[$segment]="completed"
    SEGMENT_ACTUAL_TIME[$segment]=$duration
    
    # Check timing
    local planned_duration="${SEGMENTS[$segment]}"
    local variance=$((duration - planned_duration))
    
    if [[ $variance -gt 30 ]]; then
        log "WARN" "Segment $segment ran long: ${duration}s (planned: ${planned_duration}s)"
        echo -e "\n${YELLOW}⚠️  Running ${variance}s over time${NC}"
    elif [[ $variance -lt -30 ]]; then
        log "WARN" "Segment $segment ran short: ${duration}s (planned: ${planned_duration}s)"
        echo -e "\n${YELLOW}⚠️  Running ${variance#-}s under time${NC}"
    else
        echo -e "\n${GREEN}✅ On schedule${NC}"
    fi
    
    # End telemetry span
    end_span "${segment}_span" "success"
}

# Interactive flow control
run_interactive_flow() {
    start_presentation
    
    local segment_order=("opening_hook" "current_state" "solution_architecture" 
                        "efficiency_transformation" "implementation_roadmap" 
                        "geographic_impact" "investment_decision")
    
    echo "Press ENTER to start the presentation..."
    read -r
    
    for segment in "${segment_order[@]}"; do
        start_segment "$segment"
        
        # Segment timer
        local segment_duration="${SEGMENTS[$segment]}"
        local elapsed=0
        
        while [[ $elapsed -lt $segment_duration ]]; do
            display_timer "$elapsed" "$segment_duration"
            
            # Check for early advance
            if read -t 1 -n 1 key; then
                case "$key" in
                    "")  # Enter pressed
                        echo -e "\n${YELLOW}Advancing to next segment...${NC}"
                        break
                        ;;
                    "p")  # Pause
                        echo -e "\n${YELLOW}PAUSED - Press any key to continue${NC}"
                        read -n 1
                        ;;
                    "q")  # Quit
                        echo -e "\n${RED}Presentation terminated${NC}"
                        end_presentation
                        exit 0
                        ;;
                esac
            fi
            
            elapsed=$((elapsed + 1))
        done
        
        # Auto-advance warning
        if [[ $elapsed -ge $segment_duration ]]; then
            echo -e "\n${YELLOW}⏰ Time's up! Moving to next segment...${NC}"
            sleep 2
        fi
        
        end_segment "$segment"
    done
    
    end_presentation
}

# Rehearsal mode with analytics
run_rehearsal_mode() {
    echo -e "${CYAN}🎭 Rehearsal Mode${NC}"
    echo "================="
    echo "Full presentation run-through with timing analytics"
    echo ""
    
    start_presentation
    
    # Simulate full presentation
    local segment_order=("opening_hook" "current_state" "solution_architecture" 
                        "efficiency_transformation" "implementation_roadmap" 
                        "geographic_impact" "investment_decision")
    
    for segment in "${segment_order[@]}"; do
        echo -e "\n${GREEN}▶ ${SEGMENT_TITLES[$segment]}${NC}"
        echo "Simulating segment (${SEGMENTS[$segment]}s)..."
        
        SEGMENT_STATUS[$segment]="active"
        local start_time=$(date +%s)
        
        # Progress bar
        local duration="${SEGMENTS[$segment]}"
        for ((i=0; i<=duration; i+=5)); do
            display_progress "$i" "$duration"
            sleep 0.1  # Fast simulation
        done
        
        local end_time=$(date +%s)
        SEGMENT_ACTUAL_TIME[$segment]=$((end_time - start_time))
        SEGMENT_STATUS[$segment]="completed"
    done
    
    # Generate rehearsal report
    generate_rehearsal_report
}

# Generate rehearsal report
generate_rehearsal_report() {
    local total_actual=0
    local report_file="$SCRIPT_DIR/logs/rehearsal_report_$(date +%Y%m%d_%H%M%S).json"
    
    echo -e "\n${CYAN}📊 Rehearsal Analytics${NC}"
    echo "====================="
    
    # Calculate totals
    for segment in "${!SEGMENTS[@]}"; do
        total_actual=$((total_actual + SEGMENT_ACTUAL_TIME[$segment]))
    done
    
    # Timing analysis
    echo -e "\n${YELLOW}Timing Analysis:${NC}"
    printf "%-30s %10s %10s %10s\n" "Segment" "Planned" "Actual" "Variance"
    printf "%-30s %10s %10s %10s\n" "-------" "-------" "------" "--------"
    
    for segment in "${!SEGMENTS[@]}"; do
        local planned="${SEGMENTS[$segment]}"
        local actual="${SEGMENT_ACTUAL_TIME[$segment]}"
        local variance=$((actual - planned))
        local variance_str
        
        if [[ $variance -gt 0 ]]; then
            variance_str="+${variance}s"
        else
            variance_str="${variance}s"
        fi
        
        printf "%-30s %10ss %10ss %10s\n" \
            "${SEGMENT_TITLES[$segment]}" \
            "$planned" \
            "$actual" \
            "$variance_str"
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "%-30s %10ss %10ss %10ss\n" \
        "TOTAL" \
        "$TOTAL_DURATION" \
        "$total_actual" \
        "$((total_actual - TOTAL_DURATION))"
    
    # Recommendations
    echo -e "\n${YELLOW}Recommendations:${NC}"
    if [[ $total_actual -gt $TOTAL_DURATION ]]; then
        local overage=$((total_actual - TOTAL_DURATION))
        echo "⚠️  Presentation is ${overage}s over target"
        echo "   Consider trimming content or practicing transitions"
    else
        echo "✅ Presentation timing is within target"
    fi
    
    # Save report
    cat > "$report_file" <<EOF
{
    "rehearsal_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "total_planned": $TOTAL_DURATION,
    "total_actual": $total_actual,
    "segments": [
$(for segment in "${!SEGMENTS[@]}"; do
    echo "        {"
    echo "            \"name\": \"$segment\","
    echo "            \"title\": \"${SEGMENT_TITLES[$segment]}\","
    echo "            \"planned\": ${SEGMENTS[$segment]},"
    echo "            \"actual\": ${SEGMENT_ACTUAL_TIME[$segment]},"
    echo "            \"variance\": $((SEGMENT_ACTUAL_TIME[$segment] - SEGMENTS[$segment]))"
    echo "        },"
done | sed '$ s/,$//')
    ],
    "recommendation": "$(if [[ $total_actual -gt $TOTAL_DURATION ]]; then echo "Reduce content"; else echo "Ready for presentation"; fi)"
}
EOF
    
    echo -e "\nReport saved: $report_file"
}

# End presentation
end_presentation() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - PRESENTATION_START_TIME))
    
    echo -e "\n${GREEN}🎬 Presentation Complete${NC}"
    echo "======================="
    echo "Total time: $((total_duration / 60))m $((total_duration % 60))s"
    
    # Save session summary
    local summary_file="$SCRIPT_DIR/logs/presentation_summary_$(date +%Y%m%d_%H%M%S).json"
    cat > "$summary_file" <<EOF
{
    "end_time": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "total_duration": $total_duration,
    "segments_completed": $(printf '%s\n' "${!SEGMENT_STATUS[@]}" | grep -c "completed"),
    "on_time": $(if [[ $total_duration -le $TOTAL_DURATION ]]; then echo "true"; else echo "false"; fi)
}
EOF
}

# Quick segment practice
practice_segment() {
    local segment="${1:-opening_hook}"
    
    if [[ ! "${SEGMENTS[$segment]+exists}" ]]; then
        echo -e "${RED}Error: Unknown segment '$segment'${NC}"
        echo "Available segments: ${!SEGMENTS[*]}"
        return 1
    fi
    
    echo -e "${CYAN}🎯 Practicing: ${SEGMENT_TITLES[$segment]}${NC}"
    echo "Target duration: $((SEGMENTS[$segment] / 60)) minutes"
    echo ""
    
    start_segment "$segment"
    
    # Practice timer
    local duration="${SEGMENTS[$segment]}"
    local elapsed=0
    
    echo "Press ENTER when complete..."
    while read -t 1 -n 1 key; do
        display_timer "$elapsed" "$duration"
        elapsed=$((elapsed + 1))
        
        if [[ -n "$key" ]]; then
            break
        fi
    done
    
    end_segment "$segment"
    
    echo -e "\nPractice time: ${elapsed}s (target: ${duration}s)"
}

# Main execution
case "${1:-help}" in
    "start")
        run_interactive_flow
        ;;
    "rehearse")
        run_rehearsal_mode
        ;;
    "practice")
        practice_segment "${2:-opening_hook}"
        ;;
    "timing")
        echo -e "${CYAN}📋 Presentation Timing Guide${NC}"
        echo "============================"
        echo "Total: 20 minutes"
        echo ""
        for segment in opening_hook current_state solution_architecture efficiency_transformation implementation_roadmap geographic_impact investment_decision; do
            printf "%-35s %2d minutes\n" "${SEGMENT_TITLES[$segment]}:" "$((SEGMENTS[$segment] / 60))"
        done
        ;;
    *)
        echo "Ecuador Presentation Flow Manager"
        echo ""
        echo "Usage: $0 [command] [options]"
        echo ""
        echo "Commands:"
        echo "  start     - Start interactive presentation flow"
        echo "  rehearse  - Run full rehearsal with analytics"
        echo "  practice [segment] - Practice specific segment"
        echo "  timing    - Show presentation timing guide"
        echo ""
        echo "Segments:"
        for segment in "${!SEGMENTS[@]}"; do
            echo "  $segment - ${SEGMENT_TITLES[$segment]}"
        done
        echo ""
        echo "Controls during presentation:"
        echo "  ENTER - Advance to next segment"
        echo "  p     - Pause presentation"
        echo "  q     - Quit presentation"
        ;;
esac