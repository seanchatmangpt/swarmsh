#!/bin/bash

# Demo: Worktree Workflow for Claude Code Feature Development
# This demonstrates how to add a new feature using isolated worktrees

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Worktree Development Workflow Demo ===${NC}"
echo ""

# Example feature name
FEATURE_NAME="telemetry-dashboard"
FEATURE_DESC="Add real-time telemetry dashboard"

echo -e "${GREEN}Step 1: Create a feature worktree${NC}"
echo "Command: make worktree-create FEATURE=${FEATURE_NAME}"
echo ""

# Show what would happen (don't actually create)
echo -e "${YELLOW}This would:${NC}"
echo "  - Create worktrees/${FEATURE_NAME}/"
echo "  - Set up isolated agent_coordination/"
echo "  - Initialize new git branch"
echo "  - Configure OpenTelemetry tracing"
echo ""

echo -e "${GREEN}Step 2: Navigate to worktree${NC}"
echo "Command: cd worktrees/${FEATURE_NAME}"
echo ""

echo -e "${GREEN}Step 3: Initialize coordination${NC}"
echo "Commands:"
echo "  ./coordination_helper.sh init-session"
echo "  ./coordination_helper.sh claim 'feature' '${FEATURE_DESC}' 'high'"
echo ""

echo -e "${GREEN}Step 4: Develop your feature${NC}"
echo "Example implementation:"
cat << 'EOF'
#!/bin/bash
# telemetry_dashboard.sh - Real-time telemetry visualization

show_dashboard() {
    echo "📊 Real-Time Telemetry Dashboard"
    echo "================================"
    
    # Show recent operations
    tail -10 telemetry_spans.jsonl | jq -r '
        "\(.timestamp) | \(.operation_name // .operation) | \(.status) | \(.duration_ms)ms"
    '
    
    # Show operation counts by service
    jq -s '
        group_by(.service) | 
        map({service: .[0].service, count: length}) | 
        sort_by(-.count)
    ' telemetry_spans.jsonl
}

# Main loop
while true; do
    clear
    show_dashboard
    sleep 5
done
EOF
echo ""

echo -e "${GREEN}Step 5: Test in isolation${NC}"
echo "Commands:"
echo "  make test-essential"
echo "  make otel-validate"
echo ""

echo -e "${GREEN}Step 6: Commit and push${NC}"
echo "Commands:"
echo "  make commit"
echo "  # or"
echo "  make quick-commit MSG='Add telemetry dashboard feature'"
echo ""

echo -e "${GREEN}Step 7: Create pull request${NC}"
echo "Command: make worktree-merge FEATURE=${FEATURE_NAME}"
echo ""

echo -e "${GREEN}Step 8: Cleanup after merge${NC}"
echo "Command: make worktree-cleanup FEATURE=${FEATURE_NAME}"
echo ""

echo -e "${BLUE}=== Benefits of Worktree Workflow ===${NC}"
echo "✅ Complete isolation between features"
echo "✅ Parallel development without conflicts"
echo "✅ Independent coordination and telemetry"
echo "✅ Clean git history per feature"
echo "✅ Easy cleanup after completion"
echo ""

echo -e "${YELLOW}Try it yourself:${NC}"
echo "make worktree-create FEATURE=my-awesome-feature"