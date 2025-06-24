# Makefile for Ollama Pro Testing

.PHONY: all test test-verbose test-unit test-integration test-performance clean help

# Default target
all: test

# Run all tests
test:
	@echo "Running Ollama Pro test suite..."
	@./test-ollama-pro.sh

# Run tests with verbose output
test-verbose:
	@echo "Running Ollama Pro test suite (verbose)..."
	@./test-ollama-pro.sh --verbose

# Run only unit tests
test-unit:
	@echo "Running unit tests..."
	@TEST_FILTER="unit" ./test-ollama-pro.sh

# Run only integration tests
test-integration:
	@echo "Running integration tests..."
	@TEST_FILTER="integration" ./test-ollama-pro.sh

# Run performance tests
test-performance:
	@echo "Running performance tests..."
	@TEST_FILTER="performance" ./test-ollama-pro.sh

# Clean test artifacts
clean:
	@echo "Cleaning test artifacts..."
	@rm -rf tests/temp tests/results/*.json
	@find tests -name "*.pyc" -delete
	@find tests -name "__pycache__" -delete

# Run shellcheck
lint:
	@echo "Running shellcheck..."
	@shellcheck ollama-pro test-ollama-pro.sh || true

# Check script formatting
format-check:
	@echo "Checking script formatting..."
	@shfmt -d -i 4 -ci ollama-pro test-ollama-pro.sh || true

# Format scripts
format:
	@echo "Formatting scripts..."
	@shfmt -w -i 4 -ci ollama-pro test-ollama-pro.sh || true

# Install test dependencies
install-deps:
	@echo "Installing test dependencies..."
	@command -v jq >/dev/null 2>&1 || { echo "Please install jq"; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "Please install python3"; exit 1; }
	@echo "All dependencies are installed"

# Run continuous integration tests
ci: install-deps lint test
	@echo "CI tests completed"

# Generate test coverage report
coverage:
	@echo "Generating coverage report..."
	@if ls tests/results/test-report-*.json 1> /dev/null 2>&1; then \
		echo "Latest test results:"; \
		cat $$(ls -t tests/results/test-report-*.json | head -1) | jq .; \
	else \
		echo "No test results found. Run 'make test' first."; \
	fi

# Watch for changes and run tests
watch:
	@echo "Watching for changes..."
	@while true; do \
		inotifywait -e modify ollama-pro test-ollama-pro.sh 2>/dev/null || sleep 5; \
		clear; \
		make test; \
	done

# Run specific test by name
test-specific:
	@if [ -z "$(TEST_NAME)" ]; then \
		echo "Usage: make test-specific TEST_NAME=<test_function>"; \
		exit 1; \
	fi
	@echo "Running test: $(TEST_NAME)"
	@TEST_FILTER="$(TEST_NAME)" ./test-ollama-pro.sh

# Help target
help:
	@echo "Ollama Pro Test Suite"
	@echo "===================="
	@echo ""
	@echo "Available targets:"
	@echo "  make test           - Run all tests"
	@echo "  make test-verbose   - Run tests with verbose output"
	@echo "  make test-unit      - Run only unit tests"
	@echo "  make test-integration - Run only integration tests"
	@echo "  make test-performance - Run performance tests"
	@echo "  make test-specific TEST_NAME=<name> - Run specific test"
	@echo "  make clean          - Clean test artifacts"
	@echo "  make lint           - Run shellcheck"
	@echo "  make format         - Format scripts with shfmt"
	@echo "  make format-check   - Check script formatting"
	@echo "  make install-deps   - Install test dependencies"
	@echo "  make ci             - Run CI tests"
	@echo "  make coverage       - Show test coverage report"
	@echo "  make watch          - Watch for changes and run tests"
	@echo "  make help           - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  TEST_FILTER    - Run only tests matching pattern"
	@echo "  VERBOSE        - Enable verbose output"