#!/bin/bash

# Simple S2S Worktree Creation Script
# Creates isolated worktrees with basic S@S coordination support

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKTREES_DIR="$SCRIPT_DIR/worktrees"
SHARED_COORDINATION_DIR="$SCRIPT_DIR/shared_coordination"

# Generate trace ID for worktree creation
generate_trace_id() {
    echo "$(openssl rand -hex 16)"
}

# Create shared coordination directory if it doesn't exist
setup_shared_coordination() {
    mkdir -p "$SHARED_COORDINATION_DIR"
    
    # Initialize shared coordination files
    [ ! -f "$SHARED_COORDINATION_DIR/worktree_registry.json" ] && echo "[]" > "$SHARED_COORDINATION_DIR/worktree_registry.json"
    [ ! -f "$SHARED_COORDINATION_DIR/cross_worktree_locks.json" ] && echo "{}" > "$SHARED_COORDINATION_DIR/cross_worktree_locks.json"
    [ ! -f "$SHARED_COORDINATION_DIR/shared_telemetry.jsonl" ] && touch "$SHARED_COORDINATION_DIR/shared_telemetry.jsonl"
}

# Log shared telemetry across all worktrees
log_shared_telemetry() {
    local operation="$1"
    local worktree_name="$2"
    local status="$3"
    local trace_id="$4"
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    local span_data=$(cat <<EOF
{
  "trace_id": "$trace_id",
  "span_id": "$(openssl rand -hex 8)",
  "operation": "$operation",
  "worktree": "$worktree_name", 
  "status": "$status",
  "timestamp": "$timestamp",
  "service": {
    "name": "s2s-worktree-management",
    "version": "1.1.0"
  }
}
EOF
    )
    
    echo "$span_data" >> "$SHARED_COORDINATION_DIR/shared_telemetry.jsonl"
}

# Register worktree in shared registry
register_worktree() {
    local worktree_name="$1"
    local branch_name="$2"
    local worktree_path="$3"
    local trace_id="$4"
    
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    local registration=$(cat <<EOF
{
  "worktree_name": "$worktree_name",
  "branch_name": "$branch_name", 
  "worktree_path": "$worktree_path",
  "created_at": "$timestamp",
  "trace_id": "$trace_id",
  "status": "active",
  "agents": [],
  "coordination_dir": "$worktree_path/agent_coordination"
}
EOF
    )
    
    # Add to registry using jq if available
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq ". += [$registration]" "$SHARED_COORDINATION_DIR/worktree_registry.json" > "$temp_file"
        mv "$temp_file" "$SHARED_COORDINATION_DIR/worktree_registry.json"
    else
        echo "⚠️ jq not available, skipping registry update"
    fi
}

# Create simple S@S worktree
create_simple_worktree() {
    local worktree_name="$1"
    local branch_name="${2:-$worktree_name}"
    local base_branch="${3:-main}"
    
    echo "🌟 CREATING SIMPLE S@S WORKTREE: $worktree_name"
    echo "============================================"
    
    # Generate trace ID for this operation
    local trace_id=$(generate_trace_id)
    echo "🔍 Trace ID: $trace_id"
    
    # Setup shared coordination
    setup_shared_coordination
    
    # Create worktrees directory
    mkdir -p "$WORKTREES_DIR"
    
    local worktree_path="$WORKTREES_DIR/$worktree_name"
    
    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        echo "❌ ERROR: Worktree $worktree_name already exists at $worktree_path"
        return 1
    fi
    
    # Log start of worktree creation
    log_shared_telemetry "worktree_create_start" "$worktree_name" "started" "$trace_id"
    
    # Create git worktree
    echo "📂 Creating git worktree..."
    cd "$SCRIPT_DIR"
    git worktree add "$worktree_path" -b "$branch_name" "$base_branch"
    
    # Create isolated agent coordination in worktree
    echo "🤖 Setting up agent coordination..."
    local worktree_coordination_dir="$worktree_path/agent_coordination"
    mkdir -p "$worktree_coordination_dir"
    
    # Copy coordination helper script to worktree
    cp "$SCRIPT_DIR/coordination_helper.sh" "$worktree_path/"
    
    # Initialize worktree-specific coordination files
    echo "[]" > "$worktree_coordination_dir/work_claims.json"
    echo "[]" > "$worktree_coordination_dir/agent_status.json"
    echo "[]" > "$worktree_coordination_dir/coordination_log.json"
    touch "$worktree_coordination_dir/telemetry_spans.jsonl"
    
    # Create worktree-specific configuration
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    cat > "$worktree_coordination_dir/worktree_config.json" <<EOF
{
  "worktree_name": "$worktree_name",
  "branch_name": "$branch_name",
  "base_branch": "$base_branch",
  "created_at": "$timestamp",
  "trace_id": "$trace_id",
  "coordination_dir": "$worktree_coordination_dir",
  "main_coordination_dir": "$SCRIPT_DIR/agent_coordination"
}
EOF
    
    # Copy essential scripts to worktree
    for script in test-essential.sh otel-quick-validate.sh; do
        [ -f "$SCRIPT_DIR/$script" ] && cp "$SCRIPT_DIR/$script" "$worktree_path/"
    done
    
    # Make scripts executable
    chmod +x "$worktree_path"/*.sh 2>/dev/null || true
    
    # Register worktree
    register_worktree "$worktree_name" "$branch_name" "$worktree_path" "$trace_id"
    
    # Log completion
    log_shared_telemetry "worktree_create_complete" "$worktree_name" "completed" "$trace_id"
    
    echo ""
    echo "✅ SUCCESS: Worktree '$worktree_name' created!"
    echo "📍 Location: $worktree_path"
    echo "🌿 Branch: $branch_name"
    echo "🔍 Trace ID: $trace_id"
    echo ""
    echo "📝 Next steps:"
    echo "  cd $worktree_path"
    echo "  ./coordination_helper.sh init-session"
    echo "  ./coordination_helper.sh claim 'feature' 'Your feature description' 'high'"
    echo ""
}

# Main execution
if [ $# -eq 0 ]; then
    echo "Usage: $0 <worktree_name> [branch_name] [base_branch]"
    echo ""
    echo "Examples:"
    echo "  $0 feature-auth"
    echo "  $0 feature-api api-v2"
    echo "  $0 hotfix-bug hotfix/critical main"
    exit 1
fi

create_simple_worktree "$@"