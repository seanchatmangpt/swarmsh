# Contributing to SwarmSH

Welcome to the SwarmSH project! This guide provides comprehensive information for developers who want to contribute to the agent coordination system.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Environment](#development-environment)
3. [Code Standards](#code-standards)
4. [Development Workflow](#development-workflow)
5. [Testing Guidelines](#testing-guidelines)
6. [Documentation Standards](#documentation-standards)
7. [Pull Request Process](#pull-request-process)
8. [Issue Guidelines](#issue-guidelines)
9. [Architecture Guidelines](#architecture-guidelines)
10. [Release Process](#release-process)

---

## Getting Started

### Prerequisites for Contributors

1. **System Requirements**:
   - macOS 10.15+ or Ubuntu 20.04+
   - Bash 4.0+, Git 2.30+, jq 1.6+, Python 3.8+
   - Docker (optional but recommended)

2. **Development Tools**:
   - Code editor with shell script support (VS Code recommended)
   - Git with proper configuration
   - Claude CLI (for AI integration features)

3. **Knowledge Requirements**:
   - Shell scripting (Bash)
   - JSON data structures
   - Git workflows and worktrees
   - Basic understanding of agent systems

### Initial Setup

```bash
# 1. Fork and clone the repository
git clone https://github.com/your-username/swarmsh.git
cd swarmsh

# 2. Install dependencies
./scripts/install_deps.sh

# 3. Set up development environment
./scripts/setup_dev_env.sh

# 4. Verify installation
./quick_start_agent_swarm.sh

# 5. Run tests
./test_coordination_helper.sh all
```

---

## Development Environment

### Recommended Setup

```bash
# Development environment configuration
cat > .env.dev <<EOF
# Development settings
COORDINATION_MODE="safe"
DEBUG=true
LOG_LEVEL="debug"
TELEMETRY_ENABLED=true

# Claude integration (optional)
CLAUDE_INTEGRATION=true
CLAUDE_OUTPUT_FORMAT="json"

# Database (optional)
POSTGRES_USER="swarmsh_dev"
POSTGRES_DB="swarmsh_development"
EOF
```

### IDE Configuration

**VS Code Settings** (`.vscode/settings.json`):
```json
{
  "files.associations": {
    "*.sh": "shellscript"
  },
  "shellformat.flag": "-i 2 -ci",
  "shellcheck.enable": true,
  "bash-ide-vscode.shellcheckPath": "/usr/local/bin/shellcheck"
}
```

### Debugging Setup

```bash
# Enable debug mode for development
export DEBUG=true
export BASH_DEBUG=true
export VERBOSE=true

# Use debug trace IDs
export FORCE_TRACE_ID="dev_debug_$(date +%s)"

# Enable comprehensive logging
export LOG_LEVEL="debug"
export COORDINATION_DEBUG=true
```

---

## Code Standards

### Shell Script Standards

#### 1. Script Header Template
```bash
#!/bin/bash

##############################################################################
# Script Name: example_script.sh
##############################################################################
#
# DESCRIPTION:
#   Brief description of what this script does
#
# USAGE:
#   ./example_script.sh [options] [arguments]
#
# OPTIONS:
#   -h, --help    Show this help message
#   -v, --verbose Enable verbose output
#
# DEPENDENCIES:
#   - jq (JSON processing)
#   - python3 (timestamp calculations)
#
# AUTHOR:
#   Your Name <your.email@example.com>
#
##############################################################################

set -euo pipefail

# Script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
```

#### 2. Function Standards
```bash
# Function documentation template
#
# Processes a work claim with validation and error handling
#
# Arguments:
#   $1 - work_item_id (string): Unique work item identifier
#   $2 - agent_id (string): Agent claiming the work
#   $3 - validation_mode (string): "strict" or "lenient"
#
# Returns:
#   0 - Success
#   1 - Invalid parameters
#   2 - Work item not found
#   3 - Agent not authorized
#
# Outputs:
#   JSON object with claim result
#
process_work_claim() {
    local work_item_id="$1"
    local agent_id="$2"
    local validation_mode="${3:-strict}"
    
    # Input validation
    if [[ -z "$work_item_id" ]]; then
        echo "ERROR: work_item_id is required" >&2
        return 1
    fi
    
    # Function implementation
    # ...
    
    echo "{\"status\":\"success\",\"work_item_id\":\"$work_item_id\"}"
    return 0
}
```

#### 3. Error Handling Standards
```bash
# Comprehensive error handling
handle_error() {
    local exit_code="$1"
    local line_number="$2"
    local command="$3"
    
    echo "ERROR: Command '$command' failed with exit code $exit_code at line $line_number" >&2
    
    # Cleanup on error
    cleanup_on_error
    
    exit "$exit_code"
}

# Set error trap
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR

# Cleanup function
cleanup_on_error() {
    # Remove lock files
    rm -f *.lock
    
    # Log error context
    echo "Error context: $(date), PWD: $(pwd), USER: $USER" >> logs/error.log
}
```

### JSON Data Standards

#### 1. Schema Validation
```bash
# JSON schema validation
validate_work_claim_schema() {
    local json_file="$1"
    
    # Required fields validation
    local required_fields=("work_item_id" "agent_id" "work_type" "status")
    
    for field in "${required_fields[@]}"; do
        if ! jq -e "has(\"$field\")" "$json_file" >/dev/null 2>&1; then
            echo "ERROR: Missing required field: $field" >&2
            return 1
        fi
    done
    
    # Data type validation
    if ! jq -e '.progress | type == "number"' "$json_file" >/dev/null 2>&1; then
        echo "ERROR: progress must be a number" >&2
        return 1
    fi
    
    return 0
}
```

#### 2. JSON Processing Best Practices
```bash
# Safe JSON processing
safe_jq_update() {
    local file="$1"
    local query="$2"
    local temp_file="${file}.tmp"
    
    # Validate input file
    if ! jq empty "$file" 2>/dev/null; then
        echo "ERROR: Invalid JSON in $file" >&2
        return 1
    fi
    
    # Apply update with error checking
    if ! jq "$query" "$file" > "$temp_file"; then
        echo "ERROR: jq query failed: $query" >&2
        rm -f "$temp_file"
        return 1
    fi
    
    # Validate output
    if ! jq empty "$temp_file" 2>/dev/null; then
        echo "ERROR: jq produced invalid JSON" >&2
        rm -f "$temp_file"
        return 1
    fi
    
    # Atomic replace
    mv "$temp_file" "$file"
}
```

### Naming Conventions

#### Files and Directories
- Scripts: `snake_case.sh`
- Configuration: `snake_case.json`
- Logs: `snake_case.log`
- Directories: `snake_case/`

#### Variables and Functions
```bash
# Variables: UPPER_CASE for constants, lower_case for variables
readonly COORDINATION_DIR="/path/to/coordination"
local agent_id="agent_$(date +%s%N)"

# Functions: snake_case
function register_agent() { ... }
function claim_work_item() { ... }
function update_agent_status() { ... }
```

#### JSON Fields
```json
{
  "work_item_id": "snake_case",
  "agent_id": "snake_case", 
  "created_at": "ISO 8601 timestamp",
  "snake_case_field": "value"
}
```

---

## Development Workflow

### 1. Feature Development Process

```bash
# 1. Create feature branch
git checkout -b feature/agent-load-balancing

# 2. Set up development worktree
./create_s2s_worktree.sh feature-development

# 3. Implement feature with tests
./scripts/implement_feature.sh agent-load-balancing

# 4. Run comprehensive tests
./test_coordination_helper.sh all
./test_feature.sh agent-load-balancing

# 5. Update documentation
./scripts/update_docs.sh

# 6. Commit and push
git add .
git commit -m "feat: implement agent load balancing algorithm"
git push origin feature/agent-load-balancing
```

### 2. Testing During Development

```bash
# Continuous testing workflow
watch_and_test() {
    while inotifywait -e modify *.sh; do
        echo "Running tests..."
        ./test_coordination_helper.sh basic
        echo "Tests complete at $(date)"
    done
}

# Run in background during development
watch_and_test &
```

### 3. Integration Testing

```bash
# Full integration test suite
run_integration_tests() {
    echo "Starting integration tests..."
    
    # 1. Clean environment
    ./comprehensive_cleanup.sh
    
    # 2. Deploy fresh system
    ./quick_start_agent_swarm.sh
    
    # 3. Run test scenarios
    ./test_coordination_helper.sh integration
    ./test_otel_integration.sh
    ./test_worktree_gaps.sh
    
    # 4. Performance tests
    ./test_coordination_helper.sh performance
    
    echo "Integration tests complete"
}
```

---

## Testing Guidelines

### 1. Test Structure

```bash
# Test file template: test_feature_name.sh
#!/bin/bash

##############################################################################
# Test Suite: Feature Name
##############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_common.sh"

# Test counter
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Test runner
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    ((TEST_COUNT++))
    echo "Running test: $test_name"
    
    if $test_function; then
        echo "✅ PASS: $test_name"
        ((PASS_COUNT++))
    else
        echo "❌ FAIL: $test_name"
        ((FAIL_COUNT++))
    fi
}

# Individual test functions
test_agent_registration() {
    local agent_id="test_agent_$(date +%s%N)"
    
    # Test agent registration
    ./coordination_helper.sh register 100 "active" "test_specialization"
    
    # Verify registration
    if jq -e ".[] | select(.agent_id == \"$agent_id\")" agent_status.json >/dev/null; then
        return 0
    else
        return 1
    fi
}

test_work_claim_process() {
    # Setup
    local work_id
    work_id=$(./coordination_helper.sh claim "test_work" "test description" "low")
    
    # Verify claim
    if jq -e ".[] | select(.work_item_id == \"$work_id\")" work_claims.json >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Main test execution
main() {
    echo "Starting Feature Name Test Suite"
    echo "================================"
    
    # Setup test environment
    setup_test_environment
    
    # Run tests
    run_test "Agent Registration" test_agent_registration
    run_test "Work Claim Process" test_work_claim_process
    
    # Cleanup
    cleanup_test_environment
    
    # Summary
    echo ""
    echo "Test Summary:"
    echo "  Total: $TEST_COUNT"
    echo "  Passed: $PASS_COUNT"
    echo "  Failed: $FAIL_COUNT"
    
    if [ $FAIL_COUNT -eq 0 ]; then
        echo "✅ All tests passed!"
        exit 0
    else
        echo "❌ $FAIL_COUNT test(s) failed!"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### 2. Test Categories

#### Unit Tests
```bash
# Test individual functions
test_nanosecond_id_generation() {
    local id1=$(generate_nanosecond_id)
    local id2=$(generate_nanosecond_id)
    
    # IDs should be different
    [[ "$id1" != "$id2" ]]
    
    # IDs should be numeric
    [[ "$id1" =~ ^[0-9]+$ ]]
}
```

#### Integration Tests
```bash
# Test component interactions
test_agent_coordination_flow() {
    # Register agent
    local agent_id="test_agent_$(date +%s%N)"
    ./coordination_helper.sh register 100 "active" "test"
    
    # Claim work
    local work_id
    work_id=$(./coordination_helper.sh claim "test" "description" "low")
    
    # Update progress
    ./coordination_helper.sh progress "$work_id" 50 "in_progress"
    
    # Complete work
    ./coordination_helper.sh complete "$work_id" "success" 5
    
    # Verify completion in log
    jq -e ".[] | select(.work_item_id == \"$work_id\" and .status == \"success\")" coordination_log.json >/dev/null
}
```

#### Performance Tests
```bash
# Test performance characteristics
test_coordination_performance() {
    local start_time=$(date +%s%N)
    
    # Perform 100 coordination operations
    for i in {1..100}; do
        local work_id
        work_id=$(./coordination_helper.sh claim "perf_test_$i" "test" "low")
        ./coordination_helper.sh complete "$work_id" "success" 1
    done
    
    local end_time=$(date +%s%N)
    local duration_ms=$(((end_time - start_time) / 1000000))
    
    # Should complete in reasonable time
    [[ $duration_ms -lt 10000 ]]  # Less than 10 seconds
}
```

### 3. Test Environment Management

```bash
# Test environment setup
setup_test_environment() {
    # Create isolated test directory
    export TEST_DIR="/tmp/swarmsh_test_$$"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Copy necessary scripts
    cp -r "$PROJECT_ROOT"/*.sh "$TEST_DIR/"
    
    # Initialize empty data files
    echo "[]" > agent_status.json
    echo "[]" > work_claims.json
    echo "[]" > coordination_log.json
    
    # Set test environment variables
    export COORDINATION_MODE="test"
    export TELEMETRY_ENABLED=false
    export DEBUG=true
}

cleanup_test_environment() {
    cd "$PROJECT_ROOT"
    rm -rf "$TEST_DIR"
}
```

---

## Documentation Standards

### 1. Code Documentation

#### Inline Comments
```bash
# Process work claims with conflict resolution
process_work_claims() {
    local claims_file="$1"
    
    # Read claims atomically to prevent race conditions
    local temp_file="${claims_file}.processing"
    cp "$claims_file" "$temp_file"
    
    # Process each claim with validation
    while IFS= read -r claim_line; do
        # Parse JSON claim data
        local work_id agent_id
        work_id=$(echo "$claim_line" | jq -r '.work_item_id')
        agent_id=$(echo "$claim_line" | jq -r '.agent_id')
        
        # Validate agent authorization
        if validate_agent_authorization "$agent_id" "$work_id"; then
            process_authorized_claim "$work_id" "$agent_id"
        else
            reject_unauthorized_claim "$work_id" "$agent_id"
        fi
    done < <(jq -c '.[]' "$temp_file")
    
    # Clean up temporary file
    rm -f "$temp_file"
}
```

#### Function Documentation
```bash
#
# Validates agent authorization for work claim
#
# This function checks if an agent has the required capabilities
# and capacity to claim a specific work item. It considers:
# - Agent specialization matching work requirements
# - Agent current workload vs capacity
# - Work item priority and urgency
#
# Arguments:
#   $1 - agent_id (string): Unique agent identifier
#   $2 - work_item_id (string): Work item to validate
#
# Returns:
#   0 - Agent authorized
#   1 - Agent not found
#   2 - Insufficient capacity
#   3 - Specialization mismatch
#   4 - Work item not found
#
# Side Effects:
#   Logs authorization decision to audit log
#
# Example:
#   if validate_agent_authorization "agent_123" "work_456"; then
#       echo "Agent authorized for work"
#   fi
#
validate_agent_authorization() {
    # Implementation...
}
```

### 2. API Documentation

Every script should include usage documentation:
```bash
show_help() {
    cat << EOF
USAGE:
    $0 [COMMAND] [OPTIONS] [ARGUMENTS]

DESCRIPTION:
    Agent coordination helper script for SwarmSH system.
    Provides comprehensive coordination capabilities for AI agent swarms.

COMMANDS:
    register [capacity] [status] [specialization]
        Register a new agent with the coordination system
        
    claim [work_type] [description] [priority] [team]
        Claim a new work item for processing
        
    progress [work_id] [percentage] [status]
        Update progress on an active work item
        
    complete [work_id] [status] [story_points]
        Mark a work item as completed
        
    dashboard
        Display real-time coordination dashboard

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Enable verbose output
    -d, --debug         Enable debug mode
    --dry-run           Show what would be done without executing

EXAMPLES:
    # Register an agent
    $0 register 100 "active" "backend_development"
    
    # Claim work
    $0 claim "feature_implementation" "Add user auth" "high"
    
    # Update progress
    $0 progress "work_123" 75 "in_progress"

ENVIRONMENT VARIABLES:
    AGENT_ID           Unique agent identifier
    COORDINATION_MODE  Coordination mode (safe, simple)
    DEBUG             Enable debug output (true/false)

FILES:
    agent_status.json     Agent registry
    work_claims.json      Active work claims
    coordination_log.json Completed work history

AUTHOR:
    SwarmSH Team <team@swarmsh.dev>

SEE ALSO:
    agent_swarm_orchestrator.sh(1), manage_worktrees.sh(1)
EOF
}
```

### 3. README Updates

When adding new features, update relevant README sections:

```markdown
## New Feature: Agent Load Balancing

### Overview
Intelligent load balancing across agents based on capacity and specialization.

### Usage
```bash
# Enable load balancing
export AUTO_LOAD_BALANCING=true

# Trigger manual rebalancing
./coordination_helper.sh rebalance-workload

# View load distribution
./coordination_helper.sh load-distribution
```

### Configuration
```json
{
  "load_balancing": {
    "enabled": true,
    "rebalance_threshold": 0.8,
    "rebalance_interval": 300
  }
}
```
```

---

## Pull Request Process

### 1. Before Submitting

**Pre-submission Checklist**:
- [ ] All tests pass locally
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] No sensitive information in commits
- [ ] Commit messages follow convention
- [ ] Feature branch is up to date with main

```bash
# Pre-submission script
./scripts/pre_submit_check.sh
```

### 2. Pull Request Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance impact assessed

## Documentation
- [ ] Code comments updated
- [ ] API documentation updated
- [ ] README updated if needed
- [ ] Architecture docs updated if needed

## Screenshots/Logs
If applicable, add screenshots or log output to help explain the changes.

## Additional Notes
Any additional information reviewers should know.
```

### 3. Review Process

#### Code Review Checklist
- **Functionality**: Does the code work as intended?
- **Tests**: Are there adequate tests covering the changes?
- **Performance**: Any performance implications?
- **Security**: Any security concerns?
- **Documentation**: Is documentation adequate?
- **Style**: Does code follow project conventions?

#### Reviewer Guidelines
```bash
# Checkout PR for testing
git fetch origin pull/ID/head:pr-ID
git checkout pr-ID

# Run full test suite
./test_coordination_helper.sh all
./test_new_feature.sh

# Test in different scenarios
export COORDINATION_MODE="simple"
./test_coordination_helper.sh basic

# Check performance impact
./scripts/benchmark_changes.sh
```

---

## Issue Guidelines

### 1. Bug Reports

**Bug Report Template**:
```markdown
## Bug Description
Clear and concise description of the bug.

## Environment
- OS: [e.g. macOS 12.6, Ubuntu 20.04]
- Shell: [e.g. bash 5.1.8]
- SwarmSH Version: [e.g. commit hash]

## Reproduction Steps
1. Step one
2. Step two
3. Step three

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Logs
```
Relevant log output
```

## Additional Context
Any other context about the problem.
```

### 2. Feature Requests

**Feature Request Template**:
```markdown
## Feature Description
Clear description of the proposed feature.

## Motivation
Why is this feature needed? What problem does it solve?

## Proposed Solution
Detailed description of how you envision this working.

## Alternatives Considered
Other approaches you've considered.

## Implementation Ideas
Technical suggestions for implementation.

## Additional Context
Any other context or screenshots.
```

### 3. Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements or additions to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `priority/high`: High priority issue
- `priority/low`: Low priority issue
- `component/coordination`: Related to coordination system
- `component/agents`: Related to agent management
- `component/worktrees`: Related to worktree management

---

## Architecture Guidelines

### 1. Design Principles

When contributing to SwarmSH, follow these architectural principles:

1. **Simplicity**: Prefer simple solutions over complex ones
2. **Modularity**: Keep components loosely coupled
3. **Testability**: Design for easy testing
4. **Observability**: Include telemetry and logging
5. **Reliability**: Handle errors gracefully

### 2. Adding New Components

```bash
# Component template
#!/bin/bash

##############################################################################
# Component Name: new_component.sh
##############################################################################
#
# DESCRIPTION:
#   Purpose and responsibilities of this component
#
# ARCHITECTURE:
#   - Input sources and data flows
#   - Output destinations
#   - Dependencies and interfaces
#
# INTEGRATION:
#   - How this component integrates with existing system
#   - Configuration requirements
#   - API contracts
#
##############################################################################

# Follow established patterns
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

# Implement standard interfaces
show_help() { ... }
validate_dependencies() { ... }
main() { ... }

# Include telemetry
generate_telemetry_span() { ... }

# Error handling
set -euo pipefail
trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR
```

### 3. API Consistency

New components should follow established API patterns:

```bash
# Standard command structure
component_name.sh [COMMAND] [OPTIONS] [ARGUMENTS]

# Standard commands
component_name.sh init          # Initialize component
component_name.sh status        # Show component status
component_name.sh start         # Start component
component_name.sh stop          # Stop component
component_name.sh help          # Show help
```

---

## Release Process

### 1. Version Management

SwarmSH uses semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### 2. Release Preparation

```bash
# Release preparation script
prepare_release() {
    local version="$1"
    
    # Update version in scripts
    sed -i "s/VERSION=.*/VERSION=\"$version\"/" *.sh
    
    # Update documentation
    ./scripts/update_version_docs.sh "$version"
    
    # Run full test suite
    ./test_coordination_helper.sh all
    
    # Generate changelog
    ./scripts/generate_changelog.sh "$version"
    
    # Create release commit
    git add .
    git commit -m "chore: release version $version"
    git tag -a "v$version" -m "Release version $version"
}
```

### 3. Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version numbers updated
- [ ] Changelog generated
- [ ] Breaking changes documented
- [ ] Migration guide created (if needed)
- [ ] Release notes prepared

---

## Community Guidelines

### 1. Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn and contribute
- Maintain professional communication

### 2. Getting Help

- Check existing documentation first
- Search existing issues
- Ask questions in discussions
- Provide context and details when asking for help

### 3. Recognition

Contributors are recognized through:
- Contributor acknowledgments in releases
- Contribution statistics tracking
- Special recognition for significant contributions

---

Thank you for contributing to SwarmSH! Your contributions help make the agent coordination system better for everyone.