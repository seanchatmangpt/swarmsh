# tdd-swarm

## Overview
Concurrent Sub-Agent System for Test-Driven Development that orchestrates multiple AI agents to implement TDD workflows with automated testing, code generation, and quality assurance.

## Purpose
- Automate Test-Driven Development workflows
- Coordinate multiple AI agents for different TDD phases
- Implement Red-Green-Refactor cycles automatically
- Provide continuous quality feedback
- Scale TDD practices across development teams

## Key Features
- **Multi-Agent TDD**: Specialized agents for different TDD phases
- **Concurrent Execution**: Parallel test and code development
- **Automated Workflows**: Red-Green-Refactor cycle automation
- **Quality Gates**: Automated quality assurance and validation
- **Integration Ready**: Works with existing development tools

## Usage
```bash
# Start TDD swarm for a feature
./tdd-swarm start --feature user-authentication

# Run specific TDD cycle
./tdd-swarm cycle --test login_test.py --implementation auth.py

# Monitor TDD progress
./tdd-swarm status

# Complete TDD session
./tdd-swarm complete
```

## TDD Agent Roles

### Test Agent
- **Purpose**: Write failing tests first (Red phase)
- **Responsibilities**: Test case generation, edge case identification
- **Output**: Comprehensive test suites

### Implementation Agent  
- **Purpose**: Write minimal code to pass tests (Green phase)
- **Responsibilities**: Code generation, requirement fulfillment
- **Output**: Working implementation code

### Refactor Agent
- **Purpose**: Improve code quality while maintaining tests (Refactor phase)
- **Responsibilities**: Code optimization, pattern implementation
- **Output**: Clean, maintainable code

### Quality Agent
- **Purpose**: Validate overall code quality
- **Responsibilities**: Code review, standards compliance
- **Output**: Quality reports and recommendations

## TDD Workflow

### Phase 1: Red (Failing Tests)
```bash
# Test Agent creates failing tests
./tdd-swarm red --requirement "User login functionality"

# Output: test_user_login.py with comprehensive test cases
```

### Phase 2: Green (Passing Implementation)
```bash
# Implementation Agent writes minimal code
./tdd-swarm green --tests test_user_login.py

# Output: user_login.py with basic implementation
```

### Phase 3: Refactor (Code Improvement)
```bash
# Refactor Agent improves code quality
./tdd-swarm refactor --code user_login.py --tests test_user_login.py

# Output: Optimized code maintaining test compliance
```

### Phase 4: Quality Validation
```bash
# Quality Agent validates overall quality
./tdd-swarm validate --implementation user_login.py --tests test_user_login.py

# Output: Quality report and recommendations
```

## Configuration

### Agent Configuration
```json
{
  "tdd_swarm": {
    "agents": {
      "test_agent": {
        "model": "codellama",
        "temperature": 0.2,
        "specialization": "test_generation"
      },
      "implementation_agent": {
        "model": "codellama", 
        "temperature": 0.3,
        "specialization": "code_implementation"
      },
      "refactor_agent": {
        "model": "codellama",
        "temperature": 0.1,
        "specialization": "code_optimization"
      },
      "quality_agent": {
        "model": "claude-3-opus",
        "temperature": 0.1,
        "specialization": "code_review"
      }
    },
    "workflow": {
      "max_iterations": 5,
      "quality_threshold": 0.8,
      "test_coverage_target": 90
    }
  }
}
```

### Environment Variables
```bash
# TDD configuration
export TDD_LANGUAGE="python"
export TDD_FRAMEWORK="pytest"
export TDD_COVERAGE_TARGET=90

# Agent coordination
export COORDINATION_MODE="concurrent"
export MAX_TDD_ITERATIONS=5
export QUALITY_THRESHOLD=0.8
```

## Commands Reference

### Workflow Commands
```bash
# Start new TDD session
./tdd-swarm start [options]
  --feature <name>      Feature to implement
  --language <lang>     Programming language  
  --framework <test>    Test framework

# Run TDD cycle
./tdd-swarm cycle [options]
  --requirement <req>   Requirements specification
  --iteration <num>     Cycle iteration number

# Complete session
./tdd-swarm complete
  --report             Generate completion report
  --archive            Archive session artifacts
```

### Agent Commands
```bash
# Red phase (failing tests)
./tdd-swarm red [options]
  --requirement <spec>  Feature specification
  --test-file <path>    Output test file

# Green phase (passing code)
./tdd-swarm green [options]
  --tests <path>        Test file to satisfy
  --implementation <path> Output implementation file

# Refactor phase (improve code)
./tdd-swarm refactor [options]
  --code <path>         Code to refactor
  --tests <path>        Tests to maintain
  --output <path>       Refactored output

# Quality validation
./tdd-swarm validate [options]
  --implementation <path> Code to validate
  --tests <path>         Test suite
  --report <path>        Quality report output
```

### Monitoring Commands
```bash
# Show current status
./tdd-swarm status
  --verbose            Detailed agent status
  --metrics            Performance metrics

# List active sessions
./tdd-swarm list
  --all               Include completed sessions
  --filter <criteria> Filter by criteria

# Show session logs
./tdd-swarm logs [session_id]
  --follow            Follow logs in real-time
  --agent <name>      Show specific agent logs
```

## Integration Examples

### CI/CD Integration
```bash
# Pre-commit TDD validation
./tdd-swarm validate --implementation src/ --tests tests/ --report quality.json

# Automated TDD in pipeline
./tdd-swarm cycle --requirement requirements.md --output ./generated/
```

### IDE Integration
```bash
# Generate tests for selected code
./tdd-swarm red --code-selection selection.py --output tests/

# Improve selected code
./tdd-swarm refactor --code selection.py --tests tests/test_selection.py
```

### Development Workflow
```bash
# Morning TDD session
./tdd-swarm start --feature "payment-processing"

# Iterative development
while ! ./tdd-swarm validate --threshold 0.9; do
    ./tdd-swarm cycle --auto-iterate
done

# Complete and review
./tdd-swarm complete --report
```

## Output Artifacts

### Test Files
- Comprehensive test suites with edge cases
- Behavior-driven test scenarios
- Performance and integration tests
- Test documentation and examples

### Implementation Code
- Minimal viable implementations
- Clean, readable code structure
- Proper error handling
- Documentation and comments

### Quality Reports
- Code coverage analysis
- Complexity metrics
- Style compliance reports
- Refactoring recommendations

## Advanced Features

### Concurrent Agent Execution
- Parallel test and implementation generation
- Real-time collaboration between agents
- Conflict resolution and synchronization
- Resource-optimized execution

### Quality Gates
- Automated code quality validation
- Test coverage enforcement
- Performance benchmark validation
- Security vulnerability scanning

### Learning and Adaptation
- Agent performance improvement over time
- Pattern recognition for common implementations
- Test case optimization based on failure patterns
- Code style learning from existing codebase

## Troubleshooting

### Common Issues
```bash
# Agent coordination failures
./tdd-swarm status --debug

# Test generation issues
./tdd-swarm red --verbose --requirement "detailed spec"

# Code quality problems
./tdd-swarm validate --detailed-report
```

### Performance Optimization
```bash
# Monitor agent resource usage
./tdd-swarm metrics --agents

# Optimize concurrent execution
export COORDINATION_MODE="sequential"  # For resource-constrained environments
```

## Dependencies
- **Programming Language Support**: Python, JavaScript, Java, etc.
- **Test Frameworks**: pytest, jest, junit, etc.
- **AI Models**: CodeLlama, Claude, etc.
- **Quality Tools**: coverage.py, eslint, sonarqube, etc.
- **Coordination System**: integration with coordination_helper.sh