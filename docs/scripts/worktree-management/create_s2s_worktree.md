# create_s2s_worktree.sh

## Overview
Creates isolated git worktrees with full Scrum at Scale (S@S) coordination support.

## Purpose
- Create new development worktrees for feature isolation
- Set up S@S coordination infrastructure per worktree
- Configure agent deployment environment
- Enable parallel development workflows

## Usage
```bash
# Create new S@S worktree
./create_s2s_worktree.sh <worktree_name> <branch_name>

# Create with specific feature focus
./create_s2s_worktree.sh feature-auth auth-implementation

# Create for team development
./create_s2s_worktree.sh team-phoenix phoenix-migration
```

## Key Features
- **Git Worktree Creation**: Isolated git working directory
- **S@S Infrastructure**: Complete coordination setup per worktree
- **Agent Configuration**: Ready for agent deployment
- **Environment Isolation**: Separate databases, ports, and configurations

## Worktree Setup Process
1. **Git Worktree Creation**: Creates isolated git working directory
2. **Environment Setup**: Calls `worktree_environment_manager.sh`
3. **Coordination Infrastructure**: Sets up coordination directories and files
4. **Agent Configuration**: Prepares for agent deployment
5. **Integration Verification**: Tests all components work together

## Created Structure
```
worktrees/<worktree_name>/
├── .git                     # Git worktree link
├── coordination/            # S@S coordination files
│   ├── work_claims.json
│   ├── agent_status.json
│   └── coordination_log.json
├── config/                  # Worktree-specific config
│   ├── environment.exs
│   └── agent_config.json
└── logs/                    # Worktree logs
```

## Environment Configuration
- **Database**: Isolated database instance
- **Ports**: Unique port allocation
- **Coordination**: Separate coordination directory
- **Logging**: Worktree-specific log files

## Integration Points
- Uses `worktree_environment_manager.sh` for environment setup
- Integrates with `agent_swarm_orchestrator.sh` for agent deployment
- Compatible with `coordination_helper.sh` for work coordination
- Works with Phoenix app for full-stack development

## Examples
```bash
# Feature development
./create_s2s_worktree.sh user-authentication auth-feature

# Team collaboration  
./create_s2s_worktree.sh team-coordination coord-improvements

# Bug fixes
./create_s2s_worktree.sh bugfix-urgent hotfix-branch
```

## Verification Steps
After creation, verify the worktree is ready:
```bash
# Check worktree status
cd worktrees/<worktree_name>
git status

# Verify environment
./worktree_environment_manager.sh verify-isolation

# Test coordination
./coordination_helper.sh dashboard
```

## Cleanup
```bash
# Remove worktree when done
./manage_worktrees.sh cleanup <worktree_name>
```