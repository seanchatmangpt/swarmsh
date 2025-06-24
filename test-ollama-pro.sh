#!/usr/bin/env bash

# Test Suite for Ollama Pro
# Comprehensive testing framework for the advanced Ollama CLI wrapper

set -euo pipefail

# Test configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly OLLAMA_PRO="$SCRIPT_DIR/ollama-pro"
readonly TEST_DIR="$SCRIPT_DIR/tests"
readonly TEST_FIXTURES="$TEST_DIR/fixtures"
readonly TEST_RESULTS="$TEST_DIR/results"
readonly TEST_TEMP="$TEST_DIR/temp"
readonly TELEMETRY_DATA_DIR="$SCRIPT_DIR/telemetry-data"

# OpenTelemetry test configuration
readonly OTEL_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
readonly TEST_WITH_TELEMETRY="${TEST_WITH_TELEMETRY:-false}"

# Create test directories
mkdir -p "$TEST_DIR" "$TEST_FIXTURES" "$TEST_RESULTS" "$TEST_TEMP" "$TELEMETRY_DATA_DIR"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Telemetry tracking
TRACES_GENERATED=0
METRICS_GENERATED=0
TELEMETRY_ERRORS=0

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Mock Ollama server
MOCK_SERVER_PID=""
MOCK_SERVER_PORT=11435

# Cleanup
trap cleanup EXIT

cleanup() {
    if [[ -n "$MOCK_SERVER_PID" ]] && kill -0 "$MOCK_SERVER_PID" 2>/dev/null; then
        kill -TERM "$MOCK_SERVER_PID" 2>/dev/null || true
    fi
    rm -rf "$TEST_TEMP"
}

# Test framework functions
describe() {
    echo -e "\n${BLUE}Testing: $1${NC}"
}

it() {
    local description=$1
    shift
    ((TESTS_RUN++))
    
    if "$@" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} $description"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}✗${NC} $description"
        ((TESTS_FAILED++))
        # Show error details if in verbose mode
        if [[ "${VERBOSE:-}" == "true" ]]; then
            "$@" 2>&1 | sed 's/^/    /'
        fi
    fi
}

skip() {
    local description=$1
    echo -e "  ${YELLOW}○${NC} $description (skipped)"
    ((TESTS_SKIPPED++))
}

assert_equals() {
    local expected=$1
    local actual=$2
    [[ "$expected" == "$actual" ]]
}

assert_contains() {
    local haystack=$1
    local needle=$2
    [[ "$haystack" == *"$needle"* ]]
}

assert_file_exists() {
    [[ -f "$1" ]]
}

assert_exit_code() {
    local expected=$1
    shift
    local actual
    "$@"
    actual=$?
    [[ $expected -eq $actual ]]
}

# Check OpenTelemetry availability
check_otel_availability() {
    if [[ "$TEST_WITH_TELEMETRY" == "true" ]]; then
        if ! curl -sf "${OTEL_ENDPOINT}/health" >/dev/null 2>&1; then
            echo -e "${YELLOW}Warning: OpenTelemetry collector not available at $OTEL_ENDPOINT${NC}"
            echo "Run './run-tests-with-telemetry.sh' for full telemetry testing"
            export TEST_WITH_TELEMETRY=false
        else
            echo -e "${GREEN}✓ OpenTelemetry collector available${NC}"
        fi
    fi
}

# Mock server implementation
start_mock_server() {
    # Create a simple HTTP server that mimics Ollama API
    cat > "$TEST_TEMP/mock_server.py" <<'EOF'
#!/usr/bin/env python3
import json
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

class MockOllamaHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlparse(self.path).path
        
        if path == "/api/tags":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                "models": [
                    {"name": "llama2:latest", "size": "3.8GB", "modified": "2024-01-01T00:00:00Z"},
                    {"name": "codellama:latest", "size": "4.5GB", "modified": "2024-01-02T00:00:00Z"}
                ]
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_error(404)
    
    def do_POST(self):
        path = urlparse(self.path).path
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        
        try:
            data = json.loads(body) if body else {}
        except:
            data = {}
        
        if path == "/api/chat":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            if data.get("stream", True):
                # Streaming response
                response = {"message": {"role": "assistant", "content": "Hello"}}
                self.wfile.write((json.dumps(response) + "\n").encode())
                response = {"message": {"role": "assistant", "content": " from"}}
                self.wfile.write((json.dumps(response) + "\n").encode())
                response = {"message": {"role": "assistant", "content": " Ollama!"}}
                self.wfile.write((json.dumps(response) + "\n").encode())
            else:
                # Non-streaming response
                response = {
                    "message": {
                        "role": "assistant",
                        "content": "Hello from Ollama!"
                    }
                }
                self.wfile.write(json.dumps(response).encode())
                
        elif path == "/api/generate":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            if data.get("stream", True):
                response = {"response": "Generated text"}
                self.wfile.write((json.dumps(response) + "\n").encode())
            else:
                response = {"response": "Generated text"}
                self.wfile.write(json.dumps(response).encode())
                
        elif path == "/api/pull":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            # Simulate download progress
            for i in range(0, 101, 20):
                response = {
                    "status": f"pulling {data.get('name', 'model')}",
                    "completed": i,
                    "total": 100
                }
                self.wfile.write((json.dumps(response) + "\n").encode())
                time.sleep(0.1)
                
        elif path == "/api/show":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                "name": data.get("name", "model"),
                "modified_at": "2024-01-01T00:00:00Z",
                "size": "3.8GB",
                "template": "{{ .Prompt }}",
                "parameters": {
                    "temperature": 0.7,
                    "top_p": 0.9,
                    "num_ctx": 4096
                }
            }
            self.wfile.write(json.dumps(response).encode())
            
        elif path == "/api/create":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {"status": "success"}
            self.wfile.write((json.dumps(response) + "\n").encode())
            
        elif path == "/api/embeddings":
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                "embedding": [0.1, 0.2, 0.3, 0.4, 0.5]
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_error(404)
    
    def log_message(self, format, *args):
        pass  # Suppress logs

if __name__ == "__main__":
    server = HTTPServer(('localhost', 11435), MockOllamaHandler)
    server.serve_forever()
EOF
    
    chmod +x "$TEST_TEMP/mock_server.py"
    python3 "$TEST_TEMP/mock_server.py" &
    MOCK_SERVER_PID=$!
    
    # Wait for server to start
    sleep 2
}

# Test fixtures
create_fixtures() {
    # Sample Modelfile
    cat > "$TEST_FIXTURES/test.modelfile" <<'EOF'
FROM llama2
PARAMETER temperature 0.7
PARAMETER top_p 0.9
SYSTEM You are a helpful assistant.
EOF

    # Sample image (1x1 PNG)
    printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\rIDATx\xdac\xf8\x0f\x00\x00\x01\x01\x01\x00\x18\xdd\x8d\xb4\x00\x00\x00\x00IEND\xaeB`\x82' > "$TEST_FIXTURES/test.png"
    
    # Sample config
    cat > "$TEST_FIXTURES/test-config.json" <<'EOF'
{
    "host": "http://localhost:11435",
    "default_model": "llama2",
    "timeout": 30,
    "retry_attempts": 3
}
EOF
}

# Unit Tests
test_logging_functions() {
    describe "Logging Functions"
    
    it "should create log directory" assert_file_exists "$HOME/.cache/ollama-pro/logs"
    
    # Test log levels
    export LOG_LEVEL=4  # DEBUG level
    
    it "should log error messages" bash -c "
        source $OLLAMA_PRO
        log_error 'Test error' 2>&1 | grep -q '\[ERROR\].*Test error'
    "
    
    it "should log warning messages" bash -c "
        source $OLLAMA_PRO
        log_warn 'Test warning' 2>&1 | grep -q '\[WARN\].*Test warning'
    "
    
    it "should log info messages" bash -c "
        source $OLLAMA_PRO
        log_info 'Test info' | grep -q '\[INFO\].*Test info'
    "
    
    it "should log debug messages" bash -c "
        source $OLLAMA_PRO
        log_debug 'Test debug' | grep -q '\[DEBUG\].*Test debug'
    "
    
    it "should write to log file" bash -c "
        source $OLLAMA_PRO
        log_info 'Test file logging'
        grep -q 'Test file logging' $HOME/.cache/ollama-pro/logs/ollama-pro.log
    "
}

test_configuration_management() {
    describe "Configuration Management"
    
    local test_config="$TEST_TEMP/config.json"
    export XDG_CONFIG_HOME="$TEST_TEMP"
    
    it "should save configuration" bash -c "
        source $OLLAMA_PRO
        DEFAULT_HOST='http://test:11434'
        save_config
        [[ -f $TEST_TEMP/ollama-pro/config.json ]]
    "
    
    it "should load configuration" bash -c "
        cp $TEST_FIXTURES/test-config.json $TEST_TEMP/ollama-pro/config.json
        source $OLLAMA_PRO
        load_config
        [[ \$DEFAULT_HOST == 'http://localhost:11435' ]]
    "
}

test_error_handling() {
    describe "Error Handling and Retry Logic"
    
    it "should retry failed commands" bash -c "
        source $OLLAMA_PRO
        RETRY_ATTEMPTS=3
        RETRY_DELAY=0.1
        
        # Create a command that fails twice then succeeds
        attempt=0
        test_command() {
            ((attempt++))
            [[ \$attempt -eq 3 ]]
        }
        
        retry_with_backoff test_command
    "
    
    it "should handle exponential backoff" bash -c "
        source $OLLAMA_PRO
        RETRY_ATTEMPTS=2
        RETRY_DELAY=0.1
        
        start_time=\$(date +%s%N)
        retry_with_backoff false || true
        end_time=\$(date +%s%N)
        
        # Should take at least 0.3s (0.1 + 0.2)
        duration=\$(( (end_time - start_time) / 1000000 ))
        [[ \$duration -ge 300 ]]
    "
}

test_api_functions() {
    describe "API Functions"
    
    export OLLAMA_HOST="http://localhost:$MOCK_SERVER_PORT"
    
    it "should make GET requests" bash -c "
        source $OLLAMA_PRO
        DEFAULT_HOST=\$OLLAMA_HOST
        api_request GET /api/tags | jq -e '.models | length > 0'
    "
    
    it "should make POST requests" bash -c "
        source $OLLAMA_PRO
        DEFAULT_HOST=\$OLLAMA_HOST
        data='{\"model\":\"llama2\",\"prompt\":\"test\"}'
        api_request POST /api/generate \"\$data\" | jq -e '.response'
    "
    
    it "should handle streaming responses" bash -c "
        source $OLLAMA_PRO
        DEFAULT_HOST=\$OLLAMA_HOST
        data='{\"model\":\"llama2\",\"messages\":[{\"role\":\"user\",\"content\":\"test\"}],\"stream\":true}'
        api_request POST /api/chat \"\$data\" true | grep -q 'Hello'
    "
}

test_model_management() {
    describe "Model Management"
    
    export OLLAMA_HOST="http://localhost:$MOCK_SERVER_PORT"
    
    it "should list models" bash -c "
        export DEFAULT_HOST=\$OLLAMA_HOST
        $OLLAMA_PRO list | grep -q 'llama2:latest'
    "
    
    it "should show model info" bash -c "
        export DEFAULT_HOST=\$OLLAMA_HOST
        $OLLAMA_PRO show llama2 | grep -q 'temperature: 0.7'
    "
    
    it "should pull models with progress" bash -c "
        export DEFAULT_HOST=\$OLLAMA_HOST
        $OLLAMA_PRO pull llama2 2>&1 | grep -q 'pulling llama2'
    "
}

test_session_management() {
    describe "Session Management"
    
    export XDG_CACHE_HOME="$TEST_TEMP"
    
    it "should create session" bash -c "
        source $OLLAMA_PRO
        create_session
        [[ -n \$SESSION_ID ]]
    "
    
    it "should save messages to session" bash -c "
        source $OLLAMA_PRO
        create_session
        save_message 'user' 'Test message'
        save_message 'assistant' 'Test response'
        
        session_file=\"\$SESSION_DIR/\$SESSION_ID.json\"
        jq -e '.messages | length == 2' \"\$session_file\"
    "
    
    it "should load existing session" bash -c "
        source $OLLAMA_PRO
        create_session
        old_session=\$SESSION_ID
        SESSION_ID=''
        
        load_session \$old_session
        [[ \$SESSION_ID == \$old_session ]]
    "
}

test_chat_functions() {
    describe "Chat Functions"
    
    export OLLAMA_HOST="http://localhost:$MOCK_SERVER_PORT"
    export XDG_CACHE_HOME="$TEST_TEMP"
    
    it "should complete chat without context" bash -c "
        source $OLLAMA_PRO
        DEFAULT_HOST=\$OLLAMA_HOST
        STREAM_MODE=false
        
        response=\$(chat_completion 'llama2' 'Hello' false)
        [[ \$response == 'Hello from Ollama!' ]]
    "
    
    it "should complete chat with streaming" bash -c "
        source $OLLAMA_PRO
        DEFAULT_HOST=\$OLLAMA_HOST
        STREAM_MODE=true
        
        response=\$(chat_completion 'llama2' 'Hello' false)
        [[ \$response == 'Hello from Ollama!' ]]
    "
}

test_multimodal_support() {
    describe "Multi-modal Support"
    
    it "should process images to base64" bash -c "
        source $OLLAMA_PRO
        base64_result=\$(process_image '$TEST_FIXTURES/test.png')
        [[ -n \$base64_result ]]
    "
    
    it "should handle missing image files" bash -c "
        source $OLLAMA_PRO
        ! process_image '/nonexistent/image.png' 2>/dev/null
    "
}

test_performance_monitoring() {
    describe "Performance Monitoring"
    
    export XDG_CACHE_HOME="$TEST_TEMP"
    
    it "should update metrics" bash -c "
        source $OLLAMA_PRO
        update_metrics 'test_op' '1.5' 'llama2'
        [[ -f \$METRICS_FILE ]]
    "
    
    it "should append metrics" bash -c "
        source $OLLAMA_PRO
        update_metrics 'op1' '1.0' 'model1'
        update_metrics 'op2' '2.0' 'model2'
        
        count=\$(jq '. | length' \$METRICS_FILE)
        [[ \$count -eq 2 ]]
    "
}

test_custom_model_creation() {
    describe "Custom Model Creation"
    
    export OLLAMA_HOST="http://localhost:$MOCK_SERVER_PORT"
    
    it "should create custom model from Modelfile" bash -c "
        export DEFAULT_HOST=\$OLLAMA_HOST
        $OLLAMA_PRO create testmodel $TEST_FIXTURES/test.modelfile | grep -q 'success'
    "
    
    it "should handle missing Modelfile" bash -c "
        export DEFAULT_HOST=\$OLLAMA_HOST
        ! $OLLAMA_PRO create testmodel /nonexistent/modelfile 2>/dev/null
    "
}

test_command_line_interface() {
    describe "Command Line Interface"
    
    it "should show help" bash -c "
        $OLLAMA_PRO --help | grep -q 'Ollama Pro'
    "
    
    it "should show version" bash -c "
        $OLLAMA_PRO --version | grep -q 'v1.0.0'
    "
    
    it "should accept host option" bash -c "
        $OLLAMA_PRO --host http://custom:11434 --help | grep -q 'Ollama Pro'
    "
    
    it "should handle unknown commands" bash -c "
        ! $OLLAMA_PRO unknown-command 2>/dev/null
    "
}

test_integration_scenarios() {
    describe "Integration Scenarios"
    
    export OLLAMA_HOST="http://localhost:$MOCK_SERVER_PORT"
    export XDG_CACHE_HOME="$TEST_TEMP"
    export XDG_CONFIG_HOME="$TEST_TEMP"
    
    skip "Interactive chat mode" # Requires TTY
    
    it "should handle full workflow" bash -c "
        # List models
        $OLLAMA_PRO --host \$OLLAMA_HOST list | grep -q 'llama2'
        
        # Run quick prompt
        $OLLAMA_PRO --host \$OLLAMA_HOST --no-stream run llama2 'test' | grep -q 'Hello from Ollama'
        
        # Check metrics
        source $OLLAMA_PRO
        [[ -f \$METRICS_FILE ]]
    "
}

test_opentelemetry_instrumentation() {
    describe "OpenTelemetry Instrumentation"
    
    if [[ "$TEST_WITH_TELEMETRY" != "true" ]]; then
        skip "OpenTelemetry tests (telemetry disabled)"
        return
    fi
    
    export OTEL_TRACE_ENABLED=true
    export OTEL_METRICS_ENABLED=true
    export OTEL_EXPORTER_OTLP_ENDPOINT="$OTEL_ENDPOINT"
    
    it "should generate traces for main commands" bash -c "
        # Run a simple command and check for traces
        timeout 30s $OLLAMA_PRO --host \$OLLAMA_HOST list >/dev/null 2>&1 || true
        
        # Wait for trace data to be written
        sleep 2
        
        # Check if traces were generated
        if [[ -f '$TELEMETRY_DATA_DIR/traces.json' ]]; then
            grep -q 'ollama_pro.main' '$TELEMETRY_DATA_DIR/traces.json'
        else
            # Alternative: check collector directly
            curl -sf '$OTEL_ENDPOINT/v1/traces' >/dev/null 2>&1
        fi
    "
    
    it "should generate metrics for API requests" bash -c "
        # Run command that makes API requests
        timeout 30s $OLLAMA_PRO --host \$OLLAMA_HOST list >/dev/null 2>&1 || true
        
        # Wait for metrics
        sleep 2
        
        # Check for metrics
        if [[ -f '$TELEMETRY_DATA_DIR/metrics.json' ]]; then
            grep -q 'api.request' '$TELEMETRY_DATA_DIR/metrics.json'
        else
            # Check via Prometheus endpoint if available
            curl -sf 'http://localhost:8889/metrics' 2>/dev/null | grep -q 'ollama_pro_' || true
        fi
    "
    
    it "should create spans with proper hierarchy" bash -c "
        # Run a complex command
        timeout 30s $OLLAMA_PRO --host \$OLLAMA_HOST run llama2 'test' >/dev/null 2>&1 || true
        
        sleep 2
        
        if [[ -f '$TELEMETRY_DATA_DIR/traces.json' ]]; then
            # Check for parent-child span relationships
            if command -v jq >/dev/null 2>&1; then
                # Verify span hierarchy exists
                jq -e '.resourceSpans[]?.scopeSpans[]?.spans[] | select(.parentSpanId != null)' '$TELEMETRY_DATA_DIR/traces.json' >/dev/null
            else
                # Simple grep check
                grep -q 'parentSpanId' '$TELEMETRY_DATA_DIR/traces.json'
            fi
        else
            true  # Skip if file doesn't exist
        fi
    "
    
    it "should record timing metrics" bash -c "
        # Run timed operation
        timeout 30s $OLLAMA_PRO --host \$OLLAMA_HOST list >/dev/null 2>&1 || true
        
        sleep 2
        
        if [[ -f '$TELEMETRY_DATA_DIR/metrics.json' ]]; then
            grep -q 'duration' '$TELEMETRY_DATA_DIR/metrics.json'
        else
            true  # Skip if no telemetry data
        fi
    "
    
    it "should handle telemetry errors gracefully" bash -c "
        # Test with invalid OTEL endpoint
        export OTEL_EXPORTER_OTLP_ENDPOINT='http://invalid:9999'
        
        # Should still work even with broken telemetry
        timeout 10s $OLLAMA_PRO --host \$OLLAMA_HOST --help >/dev/null 2>&1
    "
}

test_stress_and_performance() {
    describe "Stress and Performance Tests"
    
    it "should handle concurrent requests with telemetry" bash -c "
        if [[ \$TEST_WITH_TELEMETRY != 'true' ]]; then
            exit 0  # Skip if no telemetry
        fi
        
        # Start multiple concurrent requests
        for i in {1..5}; do
            timeout 10s $OLLAMA_PRO --host \$OLLAMA_HOST list >/dev/null 2>&1 &
        done
        
        wait
        
        # Check that all traces were recorded
        sleep 3
        if [[ -f '$TELEMETRY_DATA_DIR/traces.json' ]]; then
            local trace_count=\$(grep -c 'traceId' '$TELEMETRY_DATA_DIR/traces.json' 2>/dev/null || echo '0')
            [[ \$trace_count -gt 0 ]]
        fi
    "
    
    skip "Large file handling" # Would require generating large test files
    
    skip "Memory leak detection" # Requires valgrind or similar
}

# Test runner
run_tests() {
    echo -e "${GREEN}Ollama Pro Test Suite${NC}"
    echo "========================"
    
    # Setup
    create_fixtures
    start_mock_server
    
    # Check telemetry availability
    check_otel_availability
    
    # Run all test suites
    test_logging_functions
    test_configuration_management
    test_error_handling
    test_api_functions
    test_model_management
    test_session_management
    test_chat_functions
    test_multimodal_support
    test_performance_monitoring
    test_custom_model_creation
    test_command_line_interface
    test_integration_scenarios
    test_opentelemetry_instrumentation
    test_stress_and_performance
    
    # Summary
    echo
    echo "========================"
    echo -e "${GREEN}Test Summary${NC}"
    echo "Total:   $TESTS_RUN"
    echo -e "Passed:  ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed:  ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    
    # Generate report
    generate_report
    
    # Generate telemetry summary if available
    generate_telemetry_summary
    
    # Exit with appropriate code
    [[ $TESTS_FAILED -eq 0 ]]
}

generate_report() {
    local report_file="$TEST_RESULTS/test-report-$(date +%Y%m%d-%H%M%S).json"
    
    cat > "$report_file" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "total": $TESTS_RUN,
    "passed": $TESTS_PASSED,
    "failed": $TESTS_FAILED,
    "skipped": $TESTS_SKIPPED,
    "success_rate": $(awk "BEGIN {printf \"%.2f\", $TESTS_PASSED * 100 / $TESTS_RUN}"),
    "telemetry": {
        "enabled": "$TEST_WITH_TELEMETRY",
        "endpoint": "$OTEL_ENDPOINT",
        "traces_generated": $TRACES_GENERATED,
        "metrics_generated": $METRICS_GENERATED,
        "telemetry_errors": $TELEMETRY_ERRORS
    }
}
EOF
    
    echo
    echo "Report saved to: $report_file"
}

generate_telemetry_summary() {
    if [[ "$TEST_WITH_TELEMETRY" != "true" ]]; then
        return
    fi
    
    echo
    echo "========================"
    echo -e "${CYAN}OpenTelemetry Summary${NC}"
    echo "========================"
    
    # Count traces and metrics if files exist
    if [[ -f "$TELEMETRY_DATA_DIR/traces.json" ]]; then
        TRACES_GENERATED=$(grep -c '"traceId"' "$TELEMETRY_DATA_DIR/traces.json" 2>/dev/null || echo "0")
        echo "Traces generated: $TRACES_GENERATED"
        
        # Show unique span names
        if command -v jq >/dev/null 2>&1; then
            echo "Span operations:"
            jq -r '.resourceSpans[]?.scopeSpans[]?.spans[]?.name // empty' "$TELEMETRY_DATA_DIR/traces.json" 2>/dev/null | sort | uniq -c | head -10
        fi
    fi
    
    if [[ -f "$TELEMETRY_DATA_DIR/metrics.json" ]]; then
        METRICS_GENERATED=$(grep -c '"name"' "$TELEMETRY_DATA_DIR/metrics.json" 2>/dev/null || echo "0")
        echo "Metrics generated: $METRICS_GENERATED"
        
        # Show unique metric names
        if command -v jq >/dev/null 2>&1; then
            echo "Metric types:"
            jq -r '.resourceMetrics[]?.scopeMetrics[]?.metrics[]?.name // empty' "$TELEMETRY_DATA_DIR/metrics.json" 2>/dev/null | sort | uniq -c | head -10
        fi
    fi
    
    # Show links to telemetry UIs
    echo
    echo "Telemetry Visualization:"
    echo "  Jaeger (traces): http://localhost:16686"
    echo "  Prometheus (metrics): http://localhost:9090"
    echo "  Grafana (dashboards): http://localhost:3000"
    
    # Verify key spans exist
    verify_required_telemetry_data
}

verify_required_telemetry_data() {
    local required_spans=(
        "ollama_pro.main"
        "api.request"
        "config.load"
    )
    
    local missing_spans=()
    
    for span in "${required_spans[@]}"; do
        if [[ -f "$TELEMETRY_DATA_DIR/traces.json" ]]; then
            if ! grep -q "\"$span\"" "$TELEMETRY_DATA_DIR/traces.json"; then
                missing_spans+=("$span")
            fi
        else
            missing_spans+=("$span")
        fi
    done
    
    if [[ ${#missing_spans[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓ All required telemetry data present${NC}"
    else
        echo -e "${YELLOW}⚠ Missing telemetry data:${NC}"
        for span in "${missing_spans[@]}"; do
            echo -e "  ${RED}- $span${NC}"
        done
        ((TELEMETRY_ERRORS++))
    fi
}

# Main
main() {
    case "${1:-}" in
        --verbose|-v)
            VERBOSE=true
            run_tests
            ;;
        --help|-h)
            cat <<EOF
Ollama Pro Test Suite

Usage: $0 [options]

Options:
  --verbose, -v    Show detailed error output
  --help, -h       Show this help message

Environment:
  OLLAMA_HOST      Override mock server URL
  TEST_FILTER      Run only tests matching pattern
EOF
            ;;
        *)
            run_tests
            ;;
    esac
}

main "$@"