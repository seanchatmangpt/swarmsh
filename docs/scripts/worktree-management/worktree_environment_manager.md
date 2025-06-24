# worktree_environment_manager.sh

## Overview
Handles database isolation, port allocation, and environment configuration for agent worktrees.

## Purpose
- Isolate database environments per worktree
- Allocate unique ports for each environment
- Configure environment variables
- Prevent conflicts between worktree environments

## Usage
```bash
# Setup environment for new worktree
./worktree_environment_manager.sh setup <worktree_name>

# Allocate ports for worktree
./worktree_environment_manager.sh allocate-ports <worktree_name>

# Verify environment isolation
./worktree_environment_manager.sh verify-isolation

# Cleanup environment
./worktree_environment_manager.sh cleanup <worktree_name>
```

## Key Features
- **Database Isolation**: Separate database instances per worktree
- **Port Management**: Automatic port allocation (4000-4999 range)
- **Environment Variables**: Worktree-specific configurations
- **Conflict Prevention**: Ensures no resource conflicts between environments

## Commands

### setup
```bash
./worktree_environment_manager.sh setup <worktree_name>
```
Creates isolated environment with database and port allocation.

### allocate-ports
```bash
./worktree_environment_manager.sh allocate-ports <worktree_name>
```
Assigns unique ports for HTTP, WebSocket, and database connections.

### verify-isolation
```bash
./worktree_environment_manager.sh verify-isolation
```
Validates that all worktree environments are properly isolated.

### cleanup
```bash
./worktree_environment_manager.sh cleanup <worktree_name>
```
Removes environment configuration and frees allocated resources.

## Port Allocation Strategy
- **Base Port**: 4000 + worktree_index
- **HTTP Server**: base_port
- **WebSocket**: base_port + 100
- **Database**: base_port + 200
- **Metrics**: base_port + 300

## Environment Variables Created
```bash
WORKTREE_NAME=<name>
WORKTREE_PORT=<allocated_port>
DATABASE_URL=<isolated_db_url>
COORDINATION_DIR=<worktree_specific_dir>
```

## Integration Points
- Used by `create_s2s_worktree.sh` for environment setup
- Coordinates with `manage_worktrees.sh` for resource tracking
- Integrates with Phoenix app for database isolation

## Examples
```bash
# Setup new environment
./worktree_environment_manager.sh setup "ash-phoenix-feature"

# Verify all environments
./worktree_environment_manager.sh verify-isolation

# Cleanup when done
./worktree_environment_manager.sh cleanup "ash-phoenix-feature"
```