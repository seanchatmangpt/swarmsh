# Worktree Development Guide

## Overview

This guide explains how to use git worktrees for parallel feature development in the SwarmSH coordination system. Worktrees enable complete isolation between different development efforts, allowing multiple Claude Code instances or developers to work simultaneously without conflicts.

## Core Concepts

### What are Worktrees?
Git worktrees allow you to have multiple working directories attached to the same repository. Each worktree can have a different branch checked out, enabling parallel development workflows.

### SwarmSH Worktree Architecture
```
/Users/sac/dev/swarmsh/              # Main repository
├── agent_coordination/              # Main coordination directory
├── worktrees/                       # Isolated worktree directory
│   ├── feature-auth/               # Authentication feature
│   ├── feature-api-v2/             # API v2 development
│   └── fix-telemetry/              # Telemetry bug fixes
└── shared_coordination/             # Cross-worktree coordination
    ├── worktree_registry.json      # Active worktrees tracking
    └── shared_telemetry.jsonl      # Unified telemetry
```

## Creating a New Feature Worktree

### Basic Workflow

1. **Create a new worktree for your feature:**
```bash
# Using the S2S worktree creator
./create_s2s_worktree.sh feature-name

# Or with Make
make worktree-create FEATURE=feature-name
```

2. **Navigate to your worktree:**
```bash
cd worktrees/feature-name
```

3. **Start development with isolated coordination:**
```bash
# Each worktree has its own coordination
./coordination_helper.sh init-session
./coordination_helper.sh claim "feature" "Implement new feature" "high"
```

### Advanced Options

```bash
# Create with specific branch
./create_s2s_worktree.sh feature-name feature-branch main

# Create from existing remote branch
./create_s2s_worktree.sh hotfix-prod hotfix/critical-bug origin/hotfix/critical-bug
```

## Worktree Management

### List All Worktrees
```bash
# Using management script
./manage_worktrees.sh list

# Or with Make
make worktree-list
```

### Check Worktree Status
```bash
# Detailed status of specific worktree
./manage_worktrees.sh status feature-name

# Or check all worktrees
make worktree-status
```

### Remove Completed Worktrees
```bash
# Mark for removal
./manage_worktrees.sh remove feature-name

# Execute cleanup
./manage_worktrees.sh cleanup

# Or use Make
make worktree-cleanup FEATURE=feature-name
```

## Environment Isolation

Each worktree receives:
- **Isolated agent_coordination/** directory
- **Separate work_claims.json** and **agent_status.json**
- **Independent telemetry collection**
- **Unique trace IDs** for operations

### For Phoenix Projects
The worktree_environment_manager.sh provides additional isolation:
- Unique ports (4000, 4001, 4002...)
- Isolated databases per worktree
- Separate build directories
- Environment-specific configurations

## Best Practices

### 1. One Feature Per Worktree
Create a dedicated worktree for each feature or bug fix to maintain clear separation.

### 2. Use Descriptive Names
```bash
# Good
./create_s2s_worktree.sh feature-user-authentication
./create_s2s_worktree.sh fix-telemetry-memory-leak
./create_s2s_worktree.sh refactor-coordination-helper

# Avoid
./create_s2s_worktree.sh work1
./create_s2s_worktree.sh temp
```

### 3. Regular Cleanup
Remove worktrees after merging to prevent clutter:
```bash
# After feature is merged
make worktree-cleanup FEATURE=feature-name
```

### 4. Coordinate Across Worktrees
Use the shared coordination system to prevent duplicate work:
```bash
# Check cross-worktree status
./manage_worktrees.sh cross
```

## Integration with Claude Code

### Adding Your Own Features

1. **Create a feature worktree:**
```bash
make worktree-create FEATURE=claude-enhancement
```

2. **Navigate and initialize:**
```bash
cd worktrees/claude-enhancement
./coordination_helper.sh init-session
```

3. **Claim your work:**
```bash
./coordination_helper.sh claim "enhancement" "Add Claude Code feature X" "high"
```

4. **Develop with full coordination:**
- Use isolated telemetry for debugging
- Leverage separate agent coordination
- Test without affecting main branch

5. **Complete and merge:**
```bash
# From worktree
git add .
make commit  # Uses git automation

# From main directory
make worktree-merge FEATURE=claude-enhancement
```

## Workflow Example: Adding a New Feature

```bash
# 1. Create worktree for new telemetry visualization
make worktree-create FEATURE=telemetry-viz

# 2. Enter worktree
cd worktrees/telemetry-viz

# 3. Initialize coordination
./coordination_helper.sh init-session

# 4. Claim the work
./coordination_helper.sh claim "feature" "Add real-time telemetry visualization" "high"

# 5. Develop your feature
vim telemetry_visualizer.sh
# ... implement feature ...

# 6. Test with isolation
./test-essential.sh
make otel-validate

# 7. Commit changes
make commit

# 8. Create PR and merge
gh pr create --title "Add telemetry visualization feature"

# 9. Cleanup after merge
cd ../..
make worktree-cleanup FEATURE=telemetry-viz
```

## Troubleshooting

### Worktree Already Exists
```bash
# Remove the existing worktree
git worktree remove worktrees/feature-name --force

# Recreate
make worktree-create FEATURE=feature-name
```

### Port Conflicts (Phoenix projects)
The environment manager automatically allocates unique ports. If conflicts occur:
```bash
# Check allocated ports
cat shared_coordination/environment_registry.json

# Force cleanup and reallocate
./worktree_environment_manager.sh cleanup feature-name
```

### Coordination Issues
```bash
# Reset worktree coordination
cd worktrees/feature-name
rm -rf agent_coordination
./coordination_helper.sh init-session
```

## Advanced Features

### Cross-Worktree Communication
```bash
# Share work items across worktrees
./manage_worktrees.sh cross

# View unified telemetry
tail -f shared_coordination/shared_telemetry.jsonl | jq '.'
```

### Parallel Testing
```bash
# Run tests in all worktrees
for wt in worktrees/*/; do
    echo "Testing in $wt"
    (cd "$wt" && make test-essential)
done
```

### Worktree Templates
Create specialized worktrees for common patterns:
```bash
# Ash Phoenix migration worktree
./create_ash_phoenix_worktree.sh

# Performance optimization worktree
./create_s2s_worktree.sh perf-optimization
```

## Summary

Worktrees provide a powerful mechanism for parallel development with complete isolation. By following this guide, you can:
- Develop multiple features simultaneously
- Maintain clean separation between efforts
- Leverage full S2S coordination per worktree
- Prevent conflicts between parallel work
- Enable multiple Claude Code instances to collaborate effectively

The worktree workflow is essential for scaling development efforts while maintaining system integrity.