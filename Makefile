# Agent Swarm Orchestration System Makefile
# Comprehensive automation for S@S coordination, OpenTelemetry, and 80/20 optimization

.PHONY: all init deploy start stop status logs clean help
.PHONY: test test-unit test-integration test-performance test-quick verify
.PHONY: analyze optimize monitor feedback intelligence decide complete
.PHONY: cleanup cleanup-aggressive cleanup-auto cleanup-synthetic
.PHONY: env-setup env-list env-isolate env-monitor
.PHONY: telemetry-start telemetry-stop telemetry-verify otel-demo
.PHONY: deps test-deps check-deps format lint
.PHONY: ci cd demo quick-start 8020-loop

# === DEFAULT TARGET ===
all: init deploy start status
	@echo "✅ Complete agent swarm system operational"

# === CORE SYSTEM OPERATIONS ===

# System Initialization
init:
	@echo "🚀 Initializing Agent Swarm Orchestration System..."
	@./agent_swarm_orchestrator.sh init
	@./coordination_helper.sh init-session
	@echo "✅ System initialized"

# Deployment
deploy:
	@echo "📦 Deploying Agent Swarm System..."
	@./agent_swarm_orchestrator.sh deploy
	@./deploy_xavos_complete.sh
	@echo "✅ Deployment completed"

# Lifecycle Management  
start:
	@echo "▶️  Starting Agent Swarm Services..."
	@./agent_swarm_orchestrator.sh start
	@echo "✅ Services started"

stop:
	@echo "⏹️  Stopping Agent Swarm Services..."
	@./agent_swarm_orchestrator.sh stop
	@echo "✅ Services stopped"

status:
	@echo "📊 Agent Swarm System Status:"
	@./agent_swarm_orchestrator.sh status
	@./coordination_helper.sh dashboard
	@./reality_verification_engine.sh

logs:
	@echo "📋 Recent System Logs:"
	@./agent_swarm_orchestrator.sh logs

# === TESTING SUITE ===

# 80/20 OPTIMIZED TESTS (High-ROI)

# Essential Tests - 80% validation with 20% complexity
test-essential:
	@echo "🎯 Running Essential Tests (80/20 optimized)..."
	@chmod +x ./test-essential.sh
	@./test-essential.sh
	@echo "✅ Essential validation completed"

# OTEL Quick Validation - No Docker dependency
otel-validate:
	@echo "📡 Running OpenTelemetry Quick Validation..."
	@chmod +x ./otel-quick-validate.sh
	@./otel-quick-validate.sh
	@echo "✅ OTEL validation completed"

# Fast Feedback Loop - Essential + OTEL in under 1 minute
validate: test-essential otel-validate
	@echo "⚡ Fast validation cycle completed"

# Clean + Test Cycle - Fresh validation
clean-validate: clean test-essential otel-validate
	@echo "🧹 Clean validation cycle completed"

# CRON AUTOMATION (80/20 OPTIMIZED)

# Install automated cron jobs
cron-install:
	@echo "🔧 Installing 80/20 cron automation..."
	@chmod +x ./cron-setup.sh
	@./cron-setup.sh install
	@echo "✅ Automated scheduling installed"

# Remove cron jobs
cron-remove:
	@echo "🗑️ Removing cron automation..."
	@./cron-setup.sh remove
	@echo "✅ Cron jobs removed"

# Check cron job status
cron-status:
	@echo "📊 Cron automation status..."
	@./cron-setup.sh status

# Test cron jobs manually
cron-test:
	@echo "🧪 Testing cron automation..."
	@./cron-setup.sh test

# Generate Mermaid diagrams from live data
diagrams:
	@echo "🎨 Generating Mermaid diagrams from live telemetry..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh all
	@echo "📊 View diagrams in docs/auto_generated_diagrams/"

# Generate specific diagram type
diagram-dashboard:
	@echo "📈 Generating live dashboard..."
	@./auto-generate-mermaid.sh dashboard

diagram-timeline:
	@echo "⏱️ Generating timeline diagram..."
	@./auto-generate-mermaid.sh timeline

diagram-flow:
	@echo "🌊 Generating flow diagram..."
	@./auto-generate-mermaid.sh flow

# PROJECT SIMULATION & PLANNING

# Analyze project document and generate Claude Code guide
project-analyze:
	@if [ -z "$(DOC)" ]; then \
		echo "Usage: make project-analyze DOC=<document_path> PROJECT=<project_name>"; \
		exit 1; \
	fi
	@echo "📄 Analyzing project document and generating implementation guide..."
	@chmod +x ./project_simulation_engine.sh
	@./project_simulation_engine.sh end-to-end "$(DOC)" "$(PROJECT)"

# Run project simulation only
project-simulate:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Usage: make project-simulate PROJECT=<project_name> [COMPLEXITY=<low|medium|high|enterprise>]"; \
		exit 1; \
	fi
	@echo "🎲 Running Monte Carlo project simulation..."
	@./project_simulation_engine.sh simulate "$(PROJECT)" "$(COMPLEXITY)"

# Generate Claude Code implementation guide
project-guide:
	@if [ -z "$(PROJECT)" ]; then \
		echo "Usage: make project-guide PROJECT=<project_name>"; \
		exit 1; \
	fi
	@echo "📖 Generating Claude Code implementation guide..."
	@./project_simulation_engine.sh guide "$(PROJECT)"

# Show project simulation dashboard
project-dashboard:
	@echo "📊 Project Simulation Dashboard..."
	@./project_simulation_engine.sh dashboard

# COMPREHENSIVE TESTS

# Complete Test Suite
test: test-deps
	@echo "🧪 Running Complete Test Suite with OpenTelemetry..."
	@./run-tests-with-telemetry.sh

# Unit Tests
test-unit:
	@echo "🔬 Running Unit Tests..."
	@./test_coordination_helper.sh
	@./test_otel_integration.sh
	@./minimal-test.sh

# Integration Tests
test-integration:
	@echo "🔗 Running Integration Tests..."
	@./test_worktree_gaps.sh
	@./test_xavos_commands.sh
	@./test_8020_quick.sh

# Performance Tests
test-performance:
	@echo "⚡ Running Performance Tests..."
	@./test_8020_quick.sh
	@./realtime_performance_monitor.sh
	@echo "Performance results logged to coordination_log.json"

# Quick Tests (Legacy)
test-quick:
	@echo "🏃 Running Quick Validation Tests..."
	@./quick-test.sh
	@./test-simple-otel.sh

# Reality Verification
verify:
	@echo "🔍 Verifying System Reality (NO synthetic metrics)..."
	@./reality_verification_engine.sh
	@./telemetry-verification.sh
	@echo "✅ Reality verification completed"

# === ANALYSIS & OPTIMIZATION ===

# 80/20 Analysis
analyze:
	@echo "📈 Running 80/20 Performance Analysis..."
	@./8020_analysis.sh
	@./coordination_helper.sh claude-analyze-priorities
	@echo "Analysis results available in claude_analysis.json"

# Performance Optimization
optimize:
	@echo "⚡ Running 80/20 Performance Optimization..."
	@./8020_optimizer.sh
	@./coordination_helper.sh optimize
	@echo "✅ Optimization completed"

# Real-time Monitoring
monitor:
	@echo "📊 Starting Real-time Performance Monitor..."
	@./realtime_performance_monitor.sh

# Feedback Loop
feedback:
	@echo "🔄 Running Reality-based Feedback Loop..."
	@./reality_feedback_loop.sh
	@./8020_feedback_loop.sh

# Continuous 80/20 Loop
8020-loop:
	@echo "🔄 Starting Continuous 80/20 Optimization Loop..."
	@./continuous_8020_loop.sh

# === INTELLIGENCE & DECISION MAKING ===

# Claude Intelligence Analysis
intelligence:
	@echo "🧠 Running Claude Intelligence Analysis..."
	@./coordination_helper.sh claude-analyze-priorities
	@./coordination_helper.sh claude-health
	@./demo_claude_intelligence.sh

# Autonomous Decision Engine
decide:
	@echo "🤖 Running Autonomous Decision Engine..."
	@./autonomous_decision_engine.sh

# Intelligent Completion
complete:
	@echo "✨ Running Intelligent Completion Engine..."
	@./intelligent_completion_engine.sh

# === MAINTENANCE & CLEANUP ===

# Standard Cleanup
cleanup:
	@echo "🧹 Running Comprehensive System Cleanup..."
	@./comprehensive_cleanup.sh
	@echo "✅ Cleanup completed"

# Aggressive Cleanup
cleanup-aggressive:
	@echo "🗑️  Running Aggressive System Cleanup..."
	@./aggressive_cleanup.sh
	@echo "✅ Aggressive cleanup completed"

# Automated Cleanup
cleanup-auto:
	@echo "🤖 Running Automated Cleanup..."
	@./auto_cleanup.sh --auto
	@echo "✅ Automated cleanup completed"

# Remove Synthetic Work
cleanup-synthetic:
	@echo "🎭 Removing Synthetic Work Items..."
	@./cleanup_synthetic_work.sh
	@echo "✅ Synthetic work cleaned up"

# Benchmark-aware Cleanup
cleanup-benchmark:
	@echo "📊 Running Benchmark-aware Cleanup..."
	@./benchmark_cleanup_script.sh
	@echo "✅ Benchmark cleanup completed"

# === ENVIRONMENT MANAGEMENT ===

# Environment Setup
env-setup:
	@echo "🏗️  Setting up Worktree Environments..."
	@./worktree_environment_manager.sh setup
	@./create_s2s_worktree.sh
	@echo "✅ Environment setup completed"

# List Environments
env-list:
	@echo "📋 Listing Worktree Environments:"
	@./manage_worktrees.sh list

# Environment Isolation
env-isolate:
	@echo "🔒 Configuring Environment Isolation..."
	@./worktree_environment_manager.sh isolate

# Monitor Environments
env-monitor:
	@echo "👀 Monitoring Worktree Environments..."
	@./manage_worktrees.sh monitor

# === TELEMETRY & OBSERVABILITY ===

# Start OpenTelemetry Stack
telemetry-start:
	@echo "📡 Starting OpenTelemetry Infrastructure..."
	@if [ -f docker-compose.otel.yml ]; then \
		docker-compose -f docker-compose.otel.yml up -d; \
	else \
		echo "⚠️  docker-compose.otel.yml not found - using local telemetry"; \
	fi
	@echo "✅ Telemetry infrastructure started"

# Stop OpenTelemetry Stack
telemetry-stop:
	@echo "📡 Stopping OpenTelemetry Infrastructure..."
	@if [ -f docker-compose.otel.yml ]; then \
		docker-compose -f docker-compose.otel.yml down; \
	fi
	@echo "✅ Telemetry infrastructure stopped"

# Verify OpenTelemetry
telemetry-verify:
	@echo "🔍 Verifying OpenTelemetry Integration..."
	@./telemetry-verification.sh
	@echo "✅ OpenTelemetry verification completed"

# OpenTelemetry Demo
otel-demo:
	@echo "🎭 Running OpenTelemetry Demonstration..."
	@./test_otel_integration.sh
	@echo "✅ OpenTelemetry demo completed"

# === QUICK START & DEMOS ===

# One-Command Quick Start
quick-start:
	@echo "🚀 Quick Start: Complete Agent Swarm Setup..."
	@./quick_start_agent_swarm.sh
	@echo "✅ Quick start completed"

# Demonstration
demo:
	@echo "🎭 Running System Demonstrations..."
	@./8020_demonstration.sh
	@./demo_claude_intelligence.sh
	@echo "✅ Demonstrations completed"

# === DEPENDENCIES & VALIDATION ===

# Install Dependencies
deps: check-deps
	@echo "✅ All required dependencies verified"

# Test Dependencies
test-deps:
	@echo "🔍 Checking Test Dependencies..."
	@command -v jq >/dev/null || { echo "❌ Please install jq"; exit 1; }
	@command -v openssl >/dev/null || { echo "❌ Please install openssl"; exit 1; }
	@command -v python3 >/dev/null || { echo "❌ Please install python3"; exit 1; }
	@echo "✅ Test dependencies verified"

# Check All Dependencies
check-deps:
	@echo "🔍 Checking System Dependencies..."
	@./coordination_helper.sh check-dependencies || true
	@command -v jq >/dev/null || echo "⚠️  Missing: jq"
	@command -v openssl >/dev/null || echo "⚠️  Missing: openssl"
	@command -v python3 >/dev/null || echo "⚠️  Missing: python3"
	@command -v curl >/dev/null || echo "⚠️  Missing: curl"
	@command -v bc >/dev/null || echo "⚠️  Missing: bc"
	@command -v docker >/dev/null || echo "ℹ️  Optional: docker"
	@command -v claude >/dev/null || echo "ℹ️  Optional: claude CLI"

# === CODE QUALITY ===

# Linting
lint:
	@echo "🔍 Running Shellcheck Linting..."
	@find . -name "*.sh" -exec shellcheck {} + || true
	@echo "✅ Linting completed"

# Formatting
format:
	@echo "✨ Formatting Shell Scripts..."
	@find . -name "*.sh" -exec shfmt -w -i 4 -ci {} + || true
	@echo "✅ Formatting completed"

# Format Check
format-check:
	@echo "🔍 Checking Script Formatting..."
	@find . -name "*.sh" -exec shfmt -d -i 4 -ci {} + || true

# === CI/CD OPERATIONS ===

# Continuous Integration
ci: deps test verify analyze
	@echo "🔄 Continuous Integration Pipeline Completed"
	@echo "  ✅ Dependencies verified"
	@echo "  ✅ Tests passed"
	@echo "  ✅ Reality verification completed"
	@echo "  ✅ Performance analysis completed"

# Continuous Deployment
cd: ci deploy start status
	@echo "🚀 Continuous Deployment Pipeline Completed"
	@echo "  ✅ CI pipeline passed"
	@echo "  ✅ System deployed"
	@echo "  ✅ Services started"
	@echo "  ✅ Status verified"

# === WORK COORDINATION ===

# Claim Work (using 80/20 optimized fast-path)
claim:
	@if [ -z "$(WORK_TYPE)" ]; then \
		echo "Usage: make claim WORK_TYPE=<type> DESC=<description> [PRIORITY=<priority>] [TEAM=<team>]"; \
		exit 1; \
	fi
	@./coordination_helper.sh claim "$(WORK_TYPE)" "$(DESC)" "$(PRIORITY)" "$(TEAM)"

# Show Dashboard
dashboard:
	@echo "📊 Agent Swarm Coordination Dashboard:"
	@./coordination_helper.sh dashboard

# List Work Items
list-work:
	@echo "📋 Active Work Items:"
	@./coordination_helper.sh list-work

# === CLEANUP TARGET ===

clean: cleanup
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf tests/temp tests/results/*.json || true
	@find . -name "*.pyc" -delete || true
	@find . -name "__pycache__" -delete || true
	@find . -name "*.log" -delete || true
	@find . -name "temp_*" -delete || true
	@echo "✅ Clean completed"

# === HELP ===

help:
	@echo "🤖 Agent Swarm Orchestration System"
	@echo "===================================="
	@echo ""
	@echo "🚀 QUICK START:"
	@echo "  make quick-start    - One-command complete setup"
	@echo "  make all           - Initialize, deploy, start, and show status"
	@echo ""
	@echo "⚙️  CORE OPERATIONS:"
	@echo "  make init          - Initialize system"
	@echo "  make deploy        - Deploy services"
	@echo "  make start         - Start services"
	@echo "  make stop          - Stop services"
	@echo "  make status        - Show system status"
	@echo "  make logs          - Show recent logs"
	@echo ""
	@echo "🧪 TESTING (80/20 OPTIMIZED):"
	@echo "  make validate      - ⚡ Fast feedback loop (essential + OTEL)"
	@echo "  make test-essential - 🎯 Essential tests (80% validation, 20% complexity)"
	@echo "  make otel-validate - 📡 OpenTelemetry quick validation (no Docker)"
	@echo ""
	@echo "🧪 COMPREHENSIVE TESTING:"
	@echo "  make test          - Run complete test suite"
	@echo "  make test-unit     - Run unit tests"
	@echo "  make test-integration - Run integration tests"
	@echo "  make test-performance - Run performance tests"
	@echo "  make test-quick    - Run quick validation (legacy)"
	@echo "  make verify        - Reality verification (NO synthetic metrics)"
	@echo ""
	@echo "📈 ANALYSIS & OPTIMIZATION:"
	@echo "  make analyze       - 80/20 performance analysis"
	@echo "  make optimize      - Performance optimization"
	@echo "  make monitor       - Real-time monitoring"
	@echo "  make feedback      - Reality-based feedback loop"
	@echo "  make 8020-loop     - Continuous 80/20 optimization"
	@echo ""
	@echo "🧠 INTELLIGENCE:"
	@echo "  make intelligence  - Claude AI analysis"
	@echo "  make decide        - Autonomous decision engine"
	@echo "  make complete      - Intelligent completion"
	@echo ""
	@echo "🧹 MAINTENANCE:"
	@echo "  make cleanup       - Standard cleanup"
	@echo "  make cleanup-aggressive - Aggressive cleanup"
	@echo "  make cleanup-auto  - Automated cleanup"
	@echo "  make cleanup-synthetic - Remove synthetic work"
	@echo "  make clean         - Clean build artifacts"
	@echo ""
	@echo "🏗️  ENVIRONMENT:"
	@echo "  make env-setup     - Setup worktree environments"
	@echo "  make env-list      - List environments"
	@echo "  make env-isolate   - Configure isolation"
	@echo "  make env-monitor   - Monitor environments"
	@echo ""
	@echo "📡 TELEMETRY:"
	@echo "  make telemetry-start - Start OpenTelemetry stack"
	@echo "  make telemetry-stop  - Stop OpenTelemetry stack"
	@echo "  make telemetry-verify - Verify telemetry"
	@echo "  make otel-demo     - OpenTelemetry demonstration"
	@echo ""
	@echo "🤖 AUTOMATION (80/20 OPTIMIZED):"
	@echo "  make cron-install  - Install automated cron jobs"
	@echo "  make cron-status   - Check cron automation status"
	@echo "  make cron-test     - Test cron jobs manually"
	@echo "  make cron-remove   - Remove cron automation"
	@echo ""
	@echo "📊 VISUAL DIAGRAMS (AUTO-GENERATED FROM LIVE DATA):"
	@echo "  make diagrams      - Generate all diagrams (24h default)"
	@echo "  make diagrams-24h  - Generate diagrams for last 24 hours"
	@echo "  make diagrams-7d   - Generate diagrams for last 7 days"
	@echo "  make diagrams-30d  - Generate diagrams for last 30 days"
	@echo "  make diagrams-all  - Generate diagrams for all data"
	@echo "  make diagrams-dashboard - Live system dashboard"
	@echo "  make diagrams-timeline  - Timeline from telemetry"
	@echo "  make diagrams-flow      - System flow diagram"
	@echo "  make diagrams-gantt     - Real-time Gantt chart"
	@echo "  make diagrams-architecture - System architecture"
	@echo ""
	@echo "🔍 REAL-TIME MONITORING:"
	@echo "  make monitor-24h   - Monitor telemetry (24h window)"
	@echo "  make monitor-7d    - Monitor telemetry (7d window)"
	@echo "  make monitor-all   - Monitor telemetry (all data)"
	@echo "  make telemetry-stats - Show telemetry statistics"
	@echo ""
	@echo "🎯 PROJECT SIMULATION & PLANNING:"
	@echo "  make project-analyze DOC=<file> PROJECT=<name> - Full document analysis pipeline"
	@echo "  make project-simulate PROJECT=<name> [COMPLEXITY=<level>] - Monte Carlo simulation"
	@echo "  make project-guide PROJECT=<name> - Generate Claude Code guide"
	@echo "  make project-dashboard - Show simulation results dashboard"
	@echo ""
	@echo "🔧 DEVELOPMENT:"
	@echo "  make deps          - Verify dependencies"
	@echo "  make lint          - Run shellcheck"
	@echo "  make format        - Format scripts"
	@echo "  make ci            - Continuous integration"
	@echo "  make cd            - Continuous deployment"
	@echo ""
	@echo "📋 COORDINATION:"
	@echo "  make claim WORK_TYPE=<type> DESC=<desc> - Claim work"
	@echo "  make dashboard     - Show coordination dashboard"
	@echo "  make list-work     - List active work items"
	@echo ""
	@echo "🎭 DEMONSTRATIONS:"
	@echo "  make demo          - Run system demonstrations"
	@echo ""
	@echo "📚 Environment Variables:"
	@echo "  WORK_TYPE         - Work item type for claiming"
	@echo "  DESC              - Work description"
	@echo "  PRIORITY          - Work priority (high/medium/low)"
	@echo "  TEAM              - Team assignment"
	@echo "  TRACE_ID          - OpenTelemetry trace ID"
	@echo "  COORDINATION_DIR  - Coordination data directory"
	@echo ""
	@echo "💡 Examples:"
	@echo "  make claim WORK_TYPE=optimization DESC='Fix performance' PRIORITY=high"
	@echo "  make test && make verify && make optimize"
	@echo "  make telemetry-start && make monitor"

# === VISUAL DIAGRAMS ===

# Mermaid diagram generation
.PHONY: diagrams diagrams-timeline diagrams-flow diagrams-gantt diagrams-architecture diagrams-dashboard diagrams-24h diagrams-7d diagrams-30d diagrams-all
diagrams: diagrams-24h

diagrams-24h:
	@echo "🎨 Generating Mermaid diagrams (last 24 hours)..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh all 24h

diagrams-7d:
	@echo "🎨 Generating Mermaid diagrams (last 7 days)..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh all 7d

diagrams-30d:
	@echo "🎨 Generating Mermaid diagrams (last 30 days)..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh all 30d

diagrams-all:
	@echo "🎨 Generating Mermaid diagrams (all data)..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh all all

diagrams-timeline:
	@echo "⏱️ Generating timeline diagram..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh timeline

diagrams-flow:
	@echo "🌊 Generating system flow diagram..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh flow

diagrams-gantt:
	@echo "📅 Generating Gantt chart..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh gantt

diagrams-architecture:
	@echo "🏗️ Generating architecture graph..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh architecture

diagrams-dashboard:
	@echo "📊 Generating live dashboard..."
	@chmod +x ./auto-generate-mermaid.sh
	@./auto-generate-mermaid.sh dashboard

# === REAL-TIME MONITORING ===

.PHONY: monitor-telemetry monitor-24h monitor-7d monitor-all telemetry-stats
monitor-telemetry: monitor-24h

monitor-24h:
	@echo "🔍 Starting real-time telemetry monitor (24h window)..."
	@chmod +x ./realtime-telemetry-monitor.sh
	@./realtime-telemetry-monitor.sh 24h 300

monitor-7d:
	@echo "🔍 Starting real-time telemetry monitor (7d window)..."
	@chmod +x ./realtime-telemetry-monitor.sh
	@./realtime-telemetry-monitor.sh 7d 300

monitor-all:
	@echo "🔍 Starting real-time telemetry monitor (all data)..."
	@chmod +x ./realtime-telemetry-monitor.sh
	@./realtime-telemetry-monitor.sh all 300

telemetry-stats:
	@echo "📊 Generating telemetry timeframe statistics..."
	@chmod +x ./telemetry-timeframe-stats.sh
	@./telemetry-timeframe-stats.sh

# Default target for make without arguments
.DEFAULT_GOAL := help