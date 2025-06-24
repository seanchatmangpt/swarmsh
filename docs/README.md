# SwarmSH Documentation

This directory contains comprehensive documentation for all scripts in the SwarmSH project.

## Directory Structure

- **`scripts/`** - Documentation for all scripts organized by category
  - **`core-coordination/`** - Core coordination system scripts
  - **`agent-management/`** - Agent creation and management scripts
  - **`worktree-management/`** - Git worktree handling scripts
  - **`verification-validation/`** - Evidence-based validation scripts
  - **`feedback-optimization/`** - Feedback loops and optimization scripts
  - **`monitoring/`** - Performance monitoring scripts
  - **`cleanup/`** - Cleanup and maintenance scripts
  - **`integration/`** - External integration scripts
  - **`deployment/`** - Deployment and setup scripts
  - **`trace-correlation/`** - OpenTelemetry trace correlation scripts
  - **`test/`** - Test scripts
  - **`library/`** - Shared library scripts
  - **`claude-integration/`** - Claude AI integration scripts
  - **`executables/`** - Other executable scripts

## Script Categories

### Core Coordination (3 scripts)
- `coordination_helper.sh` - Core coordination system with nanosecond-precision IDs
- `agent_swarm_orchestrator.sh` - Multi-agent coordination with Claude Code CLI
- `quick_start_agent_swarm.sh` - One-command setup for complete S@S agent swarm

### Agent Management (2 scripts)
- `real_agent_worker.sh` - Real Agent Worker Process
- `implement_real_agents.sh` - Convert JSON agents to running processes

### Worktree Management (4 scripts)
- `manage_worktrees.sh` - List, monitor, cleanup worktrees
- `worktree_environment_manager.sh` - Database isolation and port allocation
- `create_s2s_worktree.sh` - Create isolated worktrees with S@S support
- `create_ash_phoenix_worktree.sh` - Dedicated worktree for Ash Phoenix

### Verification and Validation (3 scripts)
- `claim_verification_engine.sh` - Evidence-based validation with OpenTelemetry
- `reality_verification_engine.sh` - Real evidence collection
- `observability_infrastructure_validation.sh` - Autonomous implementation validation

### Feedback and Optimization (4 scripts)
- `claim_accuracy_feedback_loop.sh` - Improve claim accuracy
- `reality_feedback_loop.sh` - Fix JSON database vs system gaps
- `intelligent_completion_engine.sh` - Automate work completion
- `autonomous_decision_engine.sh` - Rule-based system analysis

### Monitoring (1 script)
- `realtime_performance_monitor.sh` - Real-time performance dashboards

### Cleanup (6 scripts)
- `auto_cleanup.sh` - Automatic cleanup for cron
- `aggressive_cleanup.sh` - Target analysis artifacts
- `comprehensive_cleanup.sh` - Clean all accumulated files
- `cleanup_synthetic_work.sh` - Remove synthetic benchmarks
- `benchmark_cleanup_script.sh` - Clean stale benchmark entries
- `ttl_validation.sh` - Time-based cleanup mechanism

### Integration (2 scripts)
- `claude_code_headless.sh` - Claude Code headless integration
- `demo_claude_intelligence.sh` - Demonstrate Claude AI decision making

### Deployment (4 scripts)
- `deploy_xavos_complete.sh` - Full XAVOS-ASH-PHOENIX deployment
- `deploy_xavos_realistic.sh` - Incremental tested deployment
- `xavos_integration.sh` - XAVOS S@S Integration Bridge
- `xavos_exact_commands.sh` - Precise shell commands execution

### Trace Correlation (2 scripts)
- `enhance_trace_correlation.sh` - Enhance trace correlation
- `enhanced_trace_correlation.sh` - Enhanced OpenTelemetry correlation

### Test Scripts (4 scripts)
- `test_coordination_helper.sh` - Unit tests for coordination
- `test_otel_integration.sh` - OpenTelemetry integration tests
- `test_worktree_gaps.sh` - Test gap resolution
- `test_xavos_commands.sh` - Test command sequences

### Library Scripts (1 script)
- `lib/s2s-env.sh` - Environment-agnostic path resolution

### Claude Integration (4 scripts)
- `claude-analyze-priorities` - Priority analysis
- `claude-health-analysis` - Health analysis
- `claude-optimize-assignments` - Assignment optimization
- `claude-stream` - Stream implementation

### Other Executables (2 scripts)
- `ollama-pro` - Enhanced Ollama CLI wrapper
- `tdd-swarm` - TDD sub-agent system

## Usage

Each script has its own documentation file in the appropriate category directory. Documentation includes:
- Purpose and overview
- Prerequisites
- Usage instructions
- Configuration options
- Examples
- Error handling
- Integration points