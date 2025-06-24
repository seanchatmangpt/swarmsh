#!/bin/bash

##############################################################################
# Compare Timeframes
# 
# Shows the difference in telemetry data across different time windows
#
##############################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TELEMETRY_FILE="$SCRIPT_DIR/telemetry_spans.jsonl"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}        ${CYAN}📊 Telemetry Timeframe Comparison${NC}                      ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo

# Generate dashboards for different timeframes
echo -e "${YELLOW}Generating dashboards for different timeframes...${NC}"
echo

# 24h window
echo -e "${CYAN}1. Generating 24-hour window dashboard...${NC}"
./auto-generate-mermaid.sh dashboard 24h >/dev/null 2>&1
ops_24h=$(grep -o "Total Operations.*[0-9]\+" docs/auto_generated_diagrams/live_dashboard.md | grep -o "[0-9]\+" | tail -1)
echo -e "   Operations in last 24h: ${GREEN}${ops_24h}${NC}"

# 7d window
echo -e "${CYAN}2. Generating 7-day window dashboard...${NC}"
./auto-generate-mermaid.sh dashboard 7d >/dev/null 2>&1
ops_7d=$(grep -o "Total Operations.*[0-9]\+" docs/auto_generated_diagrams/live_dashboard.md | grep -o "[0-9]\+" | tail -1)
echo -e "   Operations in last 7d: ${GREEN}${ops_7d}${NC}"

# All data
echo -e "${CYAN}3. Generating all-data dashboard...${NC}"
./auto-generate-mermaid.sh dashboard all >/dev/null 2>&1
ops_all=$(grep -o "Total Operations.*[0-9]\+" docs/auto_generated_diagrams/live_dashboard.md | grep -o "[0-9]\+" | tail -1)
echo -e "   Operations total: ${GREEN}${ops_all}${NC}"

echo
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  24h window shows: ${GREEN}${ops_24h}${NC} operations"
echo -e "  7d window shows:  ${GREEN}${ops_7d}${NC} operations"  
echo -e "  All data shows:   ${GREEN}${ops_all}${NC} operations"
echo

# Show default behavior
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Default Behavior${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${YELLOW}./auto-generate-mermaid.sh dashboard${NC}    → Shows last 24h (${ops_24h} ops)"
echo -e "  ${YELLOW}./auto-generate-mermaid.sh all${NC}          → Shows last 24h (${ops_24h} ops)"
echo -e "  ${YELLOW}make diagrams${NC}                           → Shows last 24h (${ops_24h} ops)"
echo
echo -e "  To see more data, explicitly specify the timeframe:"
echo -e "  ${YELLOW}./auto-generate-mermaid.sh dashboard 7d${NC} → Shows last 7 days"
echo -e "  ${YELLOW}./auto-generate-mermaid.sh dashboard all${NC} → Shows all data"
echo -e "  ${YELLOW}make diagrams-7d${NC}                         → Shows last 7 days"
echo -e "  ${YELLOW}make diagrams-all${NC}                        → Shows all data"
echo

echo -e "${GREEN}✅ Comparison complete!${NC}"