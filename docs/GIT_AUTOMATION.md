# Git Automation Guide

## Overview

The SwarmSH Makefile now includes automated git commands for streamlined version control workflow.

## Commands

### `make commit`
Automatically performs git add, commit, and push with an intelligently generated commit message based on the actual changes.

```bash
make commit
```

Features:
- Checks for changes before committing
- Generates commit message from git diff statistics
- Includes file change counts and names
- Adds Claude Code attribution
- Pushes to remote automatically

### `make quick-commit MSG="your message"`
Quick commit with a custom message.

```bash
make quick-commit MSG="Fix telemetry validation bug"
```

### `make git-status`
Shows current git status and recent commits.

```bash
make git-status
```

## Example Workflow

```bash
# Make your changes
vim coordination_helper.sh

# Check status
make git-status

# Commit with auto-generated message
make commit

# Or commit with custom message
make quick-commit MSG="Add 80/20 optimization to coordination helper"
```

## Benefits

1. **Consistency**: All commits follow the same format with Claude Code attribution
2. **Speed**: Single command for add, commit, and push
3. **Intelligence**: Auto-generated messages based on actual changes
4. **Safety**: Checks for changes before attempting commit

## Commit Message Format

Auto-generated messages follow this pattern:
```
Update:
- X files changed, Y insertions(+), Z deletions(-)
- file1.sh
- file2.md
- ...

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```