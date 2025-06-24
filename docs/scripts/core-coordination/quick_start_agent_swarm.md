# quick_start_agent_swarm.sh

## Overview

One-command setup for complete S@S agent swarm with Claude Code integration. Provides automated 6-step deployment pipeline that initializes, deploys, and starts a fully functional agent swarm across isolated git worktrees.

## Purpose

- Rapid development environment setup
- Complete swarm deployment automation
- Environment verification and validation
- Initial intelligence analysis
- Quick access to all management commands

## Prerequisites

- **agent_swarm_orchestrator.sh** - Swarm management
- **coordination_helper.sh** - Coordination functionality
- **worktree_environment_manager.sh** - Environment isolation
- **Git** - Worktree support
- **Claude Code CLI** - Agent intelligence
- **jq** - JSON processing

## Usage

```bash
# Single command to start everything
./quick_start_agent_swarm.sh

# With debug output
DEBUG=1 ./quick_start_agent_swarm.sh
```

## Key Features

### 6-Step Automated Setup
1. **Initialize Swarm Coordination** - Create coordination system
2. **Deploy Agent Swarm** - Deploy agents to worktrees
3. **Verify Environment Isolation** - Ensure proper separation
4. **Start Coordinated Agents** - Launch all agents
5. **Run Initial Intelligence** - Execute Claude analysis
6. **Show Status and Next Steps** - Display access points

### Development Ready
- Complete swarm setup in under 2 minutes
- All agents started with proper coordination
- Access points configured and ready
- Management commands available

### Verification Built-in
- Environment isolation checks
- Agent startup validation
- Coordination system health
- Intelligence integration test

## Deployment Process

### Step 1: Initialize Swarm Coordination
```bash
# Creates coordination infrastructure
./agent_swarm_orchestrator.sh init
```
- Creates `swarm_config.json`
- Sets up coordination directories
- Initializes state tracking

### Step 2: Deploy Agent Swarm to Worktrees
```bash
# Deploys agents across worktrees
./agent_swarm_orchestrator.sh deploy
```
- Creates agent configuration files
- Generates startup scripts
- Sets up management interfaces

### Step 3: Verify Environment Isolation
```bash
# Validates worktree isolation
./worktree_environment_manager.sh verify-isolation
```
- Checks database separation
- Validates port allocation
- Confirms environment variables

### Step 4: Start Coordinated Agents
```bash
# Launches all agents
./agent_swarm_orchestrator.sh start
```
- Starts agents in parallel
- Establishes coordination links
- Begins work processing

### Step 5: Run Initial Intelligence Analysis
```bash
# Executes Claude analysis
./agent_swarm_orchestrator.sh intelligence performance
```
- Analyzes system performance
- Identifies optimization opportunities
- Provides initial recommendations

### Step 6: Show Status and Next Steps
- Displays active agents
- Shows access points
- Lists management commands
- Provides development instructions

## Output Information

### Active Agents Display
```
=== ACTIVE AGENTS ===
✓ Agent 1 (ash-phoenix-migration): Running on port 4000
✓ Agent 2 (ash-phoenix-migration): Running on port 4001
✓ Agent 1 (n8n-integration): Running on port 4002
✓ Agent 2 (n8n-integration): Running on port 4003
```

### Access Points
```
=== ACCESS POINTS ===
• Ash Phoenix Migration: http://localhost:4000-4001
• N8N Integration: http://localhost:4002-4003
• Coordination Dashboard: http://localhost:3000
```

### Management Commands
```
=== MANAGEMENT COMMANDS ===
# View swarm status
./agent_swarm_orchestrator.sh status

# Stop all agents
./agent_swarm_orchestrator.sh stop

# View logs
./agent_swarm_orchestrator.sh logs

# Run analysis
./agent_swarm_orchestrator.sh intelligence <type>
```

### Development Instructions
```
=== DEVELOPMENT INSTRUCTIONS ===
1. Navigate to worktree: cd worktrees/ash-phoenix
2. Make changes: Edit files as needed
3. Test changes: Run local tests
4. Coordinate work: Use coordination_helper.sh
5. Monitor progress: Check swarm status
```

## Configuration

### Default Swarm Configuration
The script creates a default configuration with:
- **2 worktrees**: ash-phoenix-migration, n8n-integration
- **2 agents per worktree**: Parallel processing
- **Port range**: 4000-4003 for HTTP access
- **Coordination**: Distributed strategy

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DEBUG` | Enable debug output | `false` |
| `SKIP_VERIFICATION` | Skip environment checks | `false` |
| `QUICK_MODE` | Minimal setup | `false` |

## Success Indicators

### ✅ Successful Deployment
- All 6 steps complete without errors
- All agents show "Running" status
- Access points respond to HTTP requests
- Intelligence analysis completes
- No coordination conflicts detected

### ⚠️ Partial Success
- Some agents fail to start
- Environment isolation warnings
- Intelligence analysis unavailable
- Port conflicts detected

### ❌ Failed Deployment
- Coordination system initialization fails
- No agents successfully deployed
- Worktree creation errors
- Critical dependency missing

## Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Check for conflicting processes
   lsof -i :4000-4003
   
   # Kill conflicting processes
   pkill -f "port 400"
   ```

2. **Worktree creation fails**
   ```bash
   # Ensure git repository is clean
   git status
   git stash
   
   # Retry deployment
   ./quick_start_agent_swarm.sh
   ```

3. **Claude Code unavailable**
   ```bash
   # Check Claude installation
   which claude
   
   # Install if missing
   curl -fsSL https://claude.ai/install.sh | sh
   ```

4. **Coordination conflicts**
   ```bash
   # Clean coordination directory
   rm -rf /tmp/s2s_coordination
   
   # Restart deployment
   ./quick_start_agent_swarm.sh
   ```

### Debug Mode
```bash
DEBUG=1 ./quick_start_agent_swarm.sh
```
Shows detailed output for each step.

### Log Files
- Deployment log: `./quick_start.log`
- Agent logs: `./worktrees/*/agent_*.log`
- Coordination logs: `/tmp/s2s_coordination/*.log`

## Performance Considerations

### Resource Usage
- **CPU**: ~2-4 cores for 4 agents
- **Memory**: ~1-2GB for full swarm
- **Disk**: ~500MB for worktrees and logs
- **Network**: Ports 3000-4003 required

### Optimization Tips
- Use SSD for better I/O performance
- Increase file descriptor limits
- Monitor system resources during deployment
- Adjust agent count based on hardware

## Integration Points

- Uses all core coordination scripts
- Creates worktree environments
- Integrates with Claude Code CLI
- Provides access to monitoring systems

## Examples

### Basic Quick Start
```bash
# Standard deployment
./quick_start_agent_swarm.sh

# Check everything is running
curl http://localhost:4000/health
```

### Custom Configuration
```bash
# Create custom config first
cp swarm_config.json my_config.json
vim my_config.json

# Deploy with custom config
SWARM_CONFIG=my_config.json ./quick_start_agent_swarm.sh
```

### Development Workflow
```bash
# Start swarm
./quick_start_agent_swarm.sh

# Work in specific worktree
cd worktrees/ash-phoenix
# ... make changes ...

# Test coordination
../../../coordination_helper.sh claim "test" "Testing changes" "medium" "phoenix"

# Monitor progress
../../../agent_swarm_orchestrator.sh status
```

## Related Scripts

- `agent_swarm_orchestrator.sh` - Core swarm management
- `coordination_helper.sh` - Work coordination
- `implement_real_agents.sh` - Agent process conversion
- `manage_worktrees.sh` - Worktree management
- `worktree_environment_manager.sh` - Environment isolation