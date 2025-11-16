# SwarmSH API Reference - v1.1.0

> **Version:** 1.1.0 | **Last Updated:** November 16, 2025 | **Compatibility:** Fully backward compatible with v1.0.0

## Overview

This document provides comprehensive API documentation for all shell scripts and commands in the SwarmSH agent coordination system.

### v1.1.0 Enhancements
- Enhanced telemetry tracking in all operations
- New worktree management commands
- Improved error handling and reporting
- Better integration with OpenTelemetry
- Comprehensive test coverage (100% pass rate)

## Table of Contents

1. [Core Coordination Scripts](#core-coordination-scripts)
2. [Agent Management Scripts](#agent-management-scripts)
3. [Worktree Management Scripts](#worktree-management-scripts)
4. [Intelligence & Analysis Scripts](#intelligence--analysis-scripts)
5. [Testing & Validation Scripts](#testing--validation-scripts)
6. [Deployment Scripts](#deployment-scripts)
7. [Data Structures](#data-structures)
8. [Environment Variables](#environment-variables)
9. [Exit Codes](#exit-codes)

---

## Core Coordination Scripts

### coordination_helper.sh

Main coordination script for S@S (Scrum at Scale) agent swarm management with 40+ commands.

#### Basic Commands

##### register
Register a new agent with the coordination system.

```bash
./coordination_helper.sh register [capacity] [status] [specialization]
```

**Parameters:**
- `capacity` (integer): Agent work capacity (0-100)
- `status` (string): Initial status (active/inactive)
- `specialization` (string): Agent specialization type

**Example:**
```bash
./coordination_helper.sh register 100 "active" "backend_development"
```

##### claim
Claim a new work item for an agent.

```bash
./coordination_helper.sh claim [work_type] [description] [priority] [team]
```

**Parameters:**
- `work_type` (string): Type of work to claim
- `description` (string): Work item description
- `priority` (string): Priority level (low/medium/high/critical)
- `team` (string): Team assignment (optional)

**Returns:** Work item ID (nanosecond-precision timestamp)

##### progress
Update progress on a work item.

```bash
./coordination_helper.sh progress [work_id] [progress_percentage] [status]
```

**Parameters:**
- `work_id` (string): Work item identifier
- `progress_percentage` (integer): Progress 0-100
- `status` (string): Current status (pending/in_progress/completed)

##### complete
Mark a work item as completed.

```bash
./coordination_helper.sh complete [work_id] [status] [story_points]
```

**Parameters:**
- `work_id` (string): Work item identifier
- `status` (string): Completion status (success/failed/blocked)
- `story_points` (integer): Story points earned

#### Dashboard & Monitoring Commands

##### dashboard
Display comprehensive coordination dashboard.

```bash
./coordination_helper.sh dashboard
```

**Output:** Real-time agent status, work claims, and performance metrics

##### health-check
Check health status of all agents.

```bash
./coordination_helper.sh health-check [--all-agents]
```

##### monitor
Monitor coordination activities in real-time.

```bash
./coordination_helper.sh monitor
```

#### Claude AI Intelligence Commands

##### claude-analyze-priorities
Get AI-powered priority analysis.

```bash
./coordination_helper.sh claude-analyze-priorities
```

**Output:** JSON-formatted priority recommendations

##### claude-optimize-assignments
Optimize work assignments using Claude AI.

```bash
./coordination_helper.sh claude-optimize-assignments [team]
```

**Parameters:**
- `team` (string): Team name (optional, defaults to all teams)

##### claude-health-analysis
Analyze system health using Claude AI.

```bash
./coordination_helper.sh claude-health-analysis
```

##### claude-team-analysis
Analyze team performance and dynamics.

```bash
./coordination_helper.sh claude-team-analysis [team_name]
```

#### Scrum Ceremony Commands

##### pi-planning
Run PI (Program Increment) planning session.

```bash
./coordination_helper.sh pi-planning
```

##### retrospective
Conduct team retrospective.

```bash
./coordination_helper.sh retrospective [team_name]
```

##### daily-standup
Run daily standup meeting.

```bash
./coordination_helper.sh daily-standup [team_name]
```

---

## Agent Management Scripts

### agent_swarm_orchestrator.sh

Main orchestrator for multi-agent swarm deployment and management.

#### Commands

##### init
Initialize agent swarm coordination.

```bash
./agent_swarm_orchestrator.sh init
```

**Creates:**
- Swarm configuration file
- Shared coordination directory
- Initial swarm state

##### deploy
Deploy agents to worktrees.

```bash
./agent_swarm_orchestrator.sh deploy
```

**Actions:**
- Creates worktrees if needed
- Deploys agents per configuration
- Sets up Claude integration

##### start
Start all agents in the swarm.

```bash
./agent_swarm_orchestrator.sh start
```

##### stop
Stop all agents gracefully.

```bash
./agent_swarm_orchestrator.sh stop
```

##### status
Display swarm status and metrics.

```bash
./agent_swarm_orchestrator.sh status
```

##### scale
Scale agents up or down.

```bash
./agent_swarm_orchestrator.sh scale [worktree] [agent_count]
```

### real_agent_worker.sh

Worker script for individual agent execution.

```bash
./real_agent_worker.sh
```

**Environment Variables Required:**
- `AGENT_ID`: Unique agent identifier
- `AGENT_ROLE`: Agent's role in the system
- `AGENT_TEAM`: Team assignment

### autonomous_decision_engine.sh

Autonomous decision-making engine for agents.

```bash
./autonomous_decision_engine.sh [decision_type] [context_file]
```

**Parameters:**
- `decision_type`: Type of decision needed
- `context_file`: JSON file with decision context

---

## Worktree Management Scripts

### create_s2s_worktree.sh

Create a new S@S-enabled worktree.

```bash
./create_s2s_worktree.sh [worktree_name] [base_branch]
```

**Parameters:**
- `worktree_name`: Name for the new worktree
- `base_branch`: Base branch to create from (optional)

**Creates:**
- Git worktree
- Environment configuration
- Agent management scripts

### create_ash_phoenix_worktree.sh

Specialized script for Ash Phoenix migration worktrees.

```bash
./create_ash_phoenix_worktree.sh
```

**Creates:**
- Ash Phoenix migration worktree
- Database configuration
- Migration-specific tooling

### manage_worktrees.sh

Comprehensive worktree management tool.

#### Commands

##### list
List all worktrees and their status.

```bash
./manage_worktrees.sh list
```

##### status
Get detailed status of a worktree.

```bash
./manage_worktrees.sh status [worktree_name]
```

##### cleanup
Clean up a worktree and its resources.

```bash
./manage_worktrees.sh cleanup [worktree_name]
```

##### monitor
Monitor worktree resources.

```bash
./manage_worktrees.sh monitor
```

### worktree_environment_manager.sh

Manage isolated environments for worktrees.

#### Commands

##### setup
Set up environment for a worktree.

```bash
./worktree_environment_manager.sh setup [worktree_name] [worktree_path]
```

##### list
List all environment allocations.

```bash
./worktree_environment_manager.sh list
```

##### cleanup
Clean up worktree environment.

```bash
./worktree_environment_manager.sh cleanup [worktree_name]
```

---

## Intelligence & Analysis Scripts

### intelligent_completion_engine.sh

AI-powered work completion engine.

```bash
./intelligent_completion_engine.sh [work_type] [completion_strategy]
```

**Parameters:**
- `work_type`: Type of work to complete
- `completion_strategy`: Strategy to use (auto/guided/collaborative)

### demo_claude_intelligence.sh

Demonstrate Claude AI integration capabilities.

```bash
./demo_claude_intelligence.sh
```

### claude_code_headless.sh

Run Claude Code in headless mode for automation.

```bash
./claude_code_headless.sh [command] [parameters]
```

---

## Testing & Validation Scripts

### test_coordination_helper.sh

Test suite for coordination system.

```bash
./test_coordination_helper.sh [test_suite]
```

**Test Suites:**
- `basic`: Basic functionality tests
- `integration`: Integration tests
- `performance`: Performance benchmarks
- `all`: Run all tests

### test_otel_integration.sh

Test OpenTelemetry integration.

```bash
./test_otel_integration.sh
```

### test_worktree_gaps.sh

Validate worktree gap resolutions.

```bash
./test_worktree_gaps.sh
```

### reality_verification_engine.sh

Verify real vs synthetic work metrics.

```bash
./reality_verification_engine.sh [verification_type]
```

---

## Deployment Scripts

### quick_start_agent_swarm.sh

One-command agent swarm deployment.

```bash
./quick_start_agent_swarm.sh
```

**Actions:**
1. Initialize swarm coordination
2. Deploy agents to worktrees
3. Verify environment isolation
4. Start coordinated agents
5. Run initial intelligence analysis
6. Display status

### deploy_xavos_complete.sh

Complete XAVOS system deployment.

```bash
./deploy_xavos_complete.sh
```

### implement_real_agents.sh

Deploy real agent implementations.

```bash
./implement_real_agents.sh [agent_count]
```

---

## Data Structures

### Work Claims Format
```json
{
  "work_item_id": "work_1750009123456789",
  "agent_id": "agent_ash_migration_1750009123456790",
  "worktree": "ash-phoenix-migration",
  "work_type": "schema_migration",
  "description": "Migrate user schema to Ash resource",
  "priority": "critical",
  "status": "in_progress",
  "progress": 45,
  "claimed_at": "2025-06-16T10:00:00.000Z",
  "estimated_completion": "2025-06-16T15:30:00Z",
  "story_points": 8,
  "dependencies": ["work_1750009123456788"],
  "telemetry": {
    "trace_id": "abc123def456",
    "span_id": "789ghi012"
  }
}
```

### Agent Status Format
```json
{
  "agent_id": "agent_1750009123456790",
  "team": "migration_team",
  "worktree": "ash-phoenix-migration",
  "specialization": "ash_migration",
  "status": "active",
  "capacity": 100,
  "current_workload": 75,
  "last_heartbeat": "2025-06-16T10:15:00Z",
  "performance_metrics": {
    "tasks_completed": 12,
    "average_completion_time": "2.5h",
    "success_rate": 0.95
  }
}
```

### Telemetry Span Format
```json
{
  "trace_id": "abc123def456789012345678901234567",
  "span_id": "1234567890abcdef",
  "parent_span_id": "fedcba0987654321",
  "operation_name": "coordination.work.claim",
  "service_name": "s2s-coordination",
  "start_time": "2025-06-16T10:00:00.000Z",
  "end_time": "2025-06-16T10:00:00.123Z",
  "duration_ms": 123,
  "status": "success",
  "attributes": {
    "agent_id": "agent_1750009123456790",
    "work_type": "schema_migration",
    "priority": "critical"
  }
}
```

---

## Environment Variables

### Core Configuration
- `AGENT_ID`: Unique agent identifier (nanosecond precision)
- `AGENT_ROLE`: Agent's role (e.g., Developer_Agent)
- `AGENT_TEAM`: Team assignment
- `AGENT_CAPACITY`: Work capacity (0-100)

### Coordination Settings
- `COORDINATION_MODE`: Coordination mode (safe/simple)
- `COORDINATION_DIR`: Coordination data directory
- `TELEMETRY_ENABLED`: Enable OpenTelemetry (true/false)
- `CLAUDE_INTEGRATION`: Enable Claude AI (true/false)

### OpenTelemetry
- `OTEL_SERVICE_NAME`: Service name for traces
- `OTEL_SERVICE_VERSION`: Service version
- `OTEL_EXPORTER_OTLP_ENDPOINT`: OTLP endpoint URL
- `FORCE_TRACE_ID`: Force specific trace ID

### Claude Integration
- `CLAUDE_OUTPUT_FORMAT`: Output format (json/text)
- `CLAUDE_STRUCTURED_RESPONSE`: Enable structured responses
- `CLAUDE_AGENT_CONTEXT`: Context for Claude agents

### Database Configuration
- `POSTGRES_USER`: PostgreSQL username
- `POSTGRES_PASSWORD`: PostgreSQL password
- `POSTGRES_HOST`: PostgreSQL host
- `POSTGRES_PORT`: PostgreSQL port
- `POSTGRES_DB`: Database name

---

## Exit Codes

### Standard Exit Codes
- `0`: Success
- `1`: General error
- `2`: Missing dependencies
- `3`: Invalid parameters
- `4`: File not found
- `5`: Permission denied

### Coordination-Specific Exit Codes
- `10`: Work claim conflict
- `11`: Agent not registered
- `12`: Capacity exceeded
- `13`: Work item not found
- `14`: Invalid work status

### Claude Integration Exit Codes
- `20`: Claude CLI not available
- `21`: Claude analysis failed
- `22`: Invalid JSON response
- `23`: Timeout waiting for Claude

### Worktree Exit Codes
- `30`: Worktree already exists
- `31`: Worktree creation failed
- `32`: Environment conflict
- `33`: Resource allocation failed

---

## API Usage Examples

### Complete Agent Registration and Work Flow
```bash
# 1. Register an agent
export AGENT_ID="agent_$(date +%s%N)"
export AGENT_ROLE="Developer_Agent"
./coordination_helper.sh register 100 "active" "backend_development"

# 2. Claim work
WORK_ID=$(./coordination_helper.sh claim "feature_implementation" \
  "Implement user authentication" "high")

# 3. Update progress
./coordination_helper.sh progress "$WORK_ID" 50 "in_progress"

# 4. Complete work
./coordination_helper.sh complete "$WORK_ID" "success" 8
```

### Deploy Multi-Agent Swarm
```bash
# 1. Quick start everything
./quick_start_agent_swarm.sh

# 2. Or step by step:
./agent_swarm_orchestrator.sh init
./agent_swarm_orchestrator.sh deploy
./agent_swarm_orchestrator.sh start

# 3. Monitor swarm
./agent_swarm_orchestrator.sh status
```

### Create and Manage Worktrees
```bash
# 1. Create specialized worktree
./create_ash_phoenix_worktree.sh

# 2. List all worktrees
./manage_worktrees.sh list

# 3. Monitor worktree resources
./worktree_environment_manager.sh list

# 4. Clean up when done
./manage_worktrees.sh cleanup ash-phoenix-migration
```

---

This API reference provides comprehensive documentation for all shell scripts and commands in the SwarmSH system. For additional examples and use cases, refer to the main README and operations guide.