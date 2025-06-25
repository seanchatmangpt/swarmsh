# SwarmSH Template Engine - Pure Shell Jinja-like Implementation

## Overview
A distributed, agent-based template engine written in pure bash that leverages ALL SwarmSH features for parallel template processing, intelligent caching, and reality-based validation.

## Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────────┐
│                    SwarmSH Template Engine                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐        │
│  │   Template   │  │  Coordination │  │    Render     │        │
│  │    Parser    │──│    Helper     │──│    Agents     │        │
│  └──────────────┘  └──────────────┘  └───────────────┘        │
│         │                  │                   │                 │
│         ▼                  ▼                   ▼                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐        │
│  │  Work Claims │  │   Agent       │  │  Telemetry    │        │
│  │   (Blocks)   │  │   Status      │  │   Tracking    │        │
│  └──────────────┘  └──────────────┘  └───────────────┘        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐        │
│  │     8020     │  │   Reality     │  │     BPMN      │        │
│  │   Caching    │  │ Verification  │  │  Workflows    │        │
│  └──────────────┘  └──────────────┘  └───────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Template Syntax (Jinja-like)

### Variables
```bash
{{ variable }}                    # Simple variable
{{ user.name }}                   # Dot notation
{{ items[0] }}                    # Array access
{{ variable | upper }}            # Filters
{{ variable | default:"none" }}   # Default values
```

### Control Structures
```bash
{% if condition %}
    Content when true
{% elif other_condition %}
    Alternative content
{% else %}
    Default content
{% endif %}

{% for item in items %}
    {{ item.name }}: {{ item.value }}
{% endfor %}

{% while counter < 10 %}
    Counter: {{ counter }}
    {% set counter = counter + 1 %}
{% endwhile %}
```

### Template Inheritance
```bash
# base.html.sh
<!DOCTYPE html>
<html>
<head>
    <title>{% block title %}Default Title{% endblock %}</title>
</head>
<body>
    {% block content %}{% endblock %}
</body>
</html>

# page.html.sh
{% extends "base.html.sh" %}
{% block title %}My Page{% endblock %}
{% block content %}
    <h1>Welcome {{ user.name }}</h1>
{% endblock %}
```

### Includes
```bash
{% include "header.sh" %}
{% include "components/nav.sh" with {"active": "home"} %}
```

## SwarmSH Feature Integration

### 1. Coordination System Integration
```bash
# Template rendering as coordinated work
./coordination_helper.sh claim "template_render" "Render template: $template_file" "high" "template_team"

# Distributed block processing
./coordination_helper.sh claim "template_block" "Process block: $block_id" "medium" "parser_team"

# Progress tracking
./coordination_helper.sh progress "$WORK_ID" 50 "parsing"
./coordination_helper.sh progress "$WORK_ID" 100 "rendered"
```

### 2. Agent-Based Rendering
```bash
# Specialized agents for different template operations
PARSER_AGENT="agent_parser_$(date +%s%N)"
RENDER_AGENT="agent_render_$(date +%s%N)"
CACHE_AGENT="agent_cache_$(date +%s%N)"
VALIDATOR_AGENT="agent_validator_$(date +%s%N)"

# Agent registration
./coordination_helper.sh agent-register "$PARSER_AGENT" "Parser_Agent" 5
./coordination_helper.sh agent-register "$RENDER_AGENT" "Render_Agent" 10
```

### 3. Work Claims for Template Blocks
```json
{
  "work_id": "template_block_1750805123456",
  "work_type": "template_parse",
  "description": "Parse if-block at line 45",
  "priority": "medium",
  "status": "claimed",
  "claimed_by": "agent_parser_1750805123456",
  "template_context": {
    "file": "index.html.sh",
    "block_type": "if",
    "line_start": 45,
    "line_end": 52
  }
}
```

### 4. OpenTelemetry Instrumentation
```bash
# Full distributed tracing for template operations
log_template_span() {
    local operation="$1"
    local template="$2"
    local duration_ms="$3"
    local block_count="$4"
    
    cat >> telemetry_spans.jsonl <<EOF
{
  "trace_id": "$TRACE_ID",
  "span_id": "$(generate_span_id)",
  "operation_name": "template_engine.$operation",
  "template_file": "$template",
  "duration_ms": $duration_ms,
  "metrics": {
    "blocks_processed": $block_count,
    "cache_hits": $CACHE_HITS,
    "agents_used": $AGENT_COUNT
  }
}
EOF
}
```

### 5. 8020 Optimization
```bash
# Template caching based on usage patterns
TEMPLATE_CACHE_DIR="$SCRIPT_DIR/template_cache"

# Track template usage
track_template_usage() {
    local template="$1"
    local usage_count=$(jq -r --arg t "$template" '.[$t] // 0' template_usage.json)
    usage_count=$((usage_count + 1))
    jq --arg t "$template" --arg c "$usage_count" '.[$t] = ($c | tonumber)' template_usage.json > tmp.json
    mv tmp.json template_usage.json
}

# Cache top 20% most-used templates
cache_hot_templates() {
    # Get top 20% by usage
    local total=$(jq 'length' template_usage.json)
    local top_20=$((total / 5))
    
    jq -r 'to_entries | sort_by(.value) | reverse | .[0:$top_20] | .[].key' \
        --arg top_20 "$top_20" template_usage.json | \
    while read -r template; do
        ./coordination_helper.sh claim "cache_template" "Pre-render: $template" "low" "cache_team"
        render_and_cache "$template"
    done
}
```

### 6. Reality Verification
```bash
# Verify rendered output matches expectations
verify_template_output() {
    local template="$1"
    local output="$2"
    local expected="$3"
    
    # Use reality verification engine
    ./reality_verification_engine.sh verify_output "$output" "$expected"
    
    # Track verification results
    if [[ $? -eq 0 ]]; then
        echo "✅ Template output verified: $template"
    else
        ./claim_verification_engine.sh report "template_mismatch" "$template" "$output"
    fi
}
```

### 7. Autonomous Decision Engine
```bash
# Intelligent template optimization decisions
optimize_template_strategy() {
    # Analyze rendering patterns
    local avg_render_time=$(jq -r '[.[] | select(.operation_name == "template_render")] | 
        map(.duration_ms) | add/length' telemetry_spans.jsonl)
    
    # Let autonomous engine decide optimization strategy
    ./autonomous_decision_engine.sh analyze <<EOF
{
  "context": "template_optimization",
  "metrics": {
    "avg_render_time_ms": $avg_render_time,
    "cache_hit_rate": $CACHE_HIT_RATE,
    "agent_utilization": $AGENT_UTILIZATION
  }
}
EOF
}
```

### 8. BPMN Workflow Documentation
```bash
# Generate BPMN for template processing workflow
./bpmn-ollama-generator.sh generate template_engine <<EOF
Template processing workflow including:
- Template parsing and AST generation
- Work distribution to render agents  
- Parallel block processing
- Cache checking and storage
- Output assembly and verification
- Reality-based validation
EOF
```

## Implementation Plan

### Phase 1: Core Parser (Week 1)
- [ ] AST representation in JSON
- [ ] Basic variable substitution
- [ ] Control structure parsing
- [ ] Work claim integration

### Phase 2: Render Agents (Week 2)
- [ ] Agent pool management
- [ ] Parallel block rendering
- [ ] Context passing between agents
- [ ] Progress tracking

### Phase 3: Advanced Features (Week 3)
- [ ] Template inheritance
- [ ] Include system
- [ ] Filter implementation
- [ ] Macro support

### Phase 4: Optimization (Week 4)
- [ ] 8020 caching system
- [ ] Hot template pre-rendering
- [ ] Autonomous optimization
- [ ] Performance telemetry

### Phase 5: Validation & Docs (Week 5)
- [ ] Reality verification integration
- [ ] BPMN workflow generation
- [ ] Comprehensive testing
- [ ] Documentation

## Usage Examples

### Basic Rendering
```bash
# Simple variable substitution
echo '{{ greeting }} {{ name }}!' | ./swarmsh-template render \
    --context '{"greeting": "Hello", "name": "World"}'

# With coordination
./swarmsh-template render index.html.sh \
    --context-file data.json \
    --coordinate \
    --agents 5
```

### Distributed Rendering
```bash
# Large template with parallel processing
./swarmsh-template render large-report.sh \
    --distribute \
    --max-agents 10 \
    --cache-hot \
    --verify-output
```

### Template Development
```bash
# Develop in worktree with hot reload
./swarmsh-template dev my-template.sh \
    --worktree template-feature \
    --watch \
    --telemetry \
    --bpmn-document
```

## Performance Targets

Using all SwarmSH features:
- **Parse time**: < 10ms for typical templates (with AST caching)
- **Render time**: < 50ms for complex templates (with agent distribution)
- **Cache hit rate**: > 80% for production workloads (8020 optimization)
- **Parallel efficiency**: 0.9x speedup per additional agent
- **Reality verification**: 100% output validation
- **Telemetry coverage**: Every operation traced

## Conclusion

This template engine demonstrates the full power of SwarmSH by:
1. Using coordination for distributed parsing
2. Agent swarms for parallel rendering
3. Work claims for atomic operations
4. Full telemetry instrumentation
5. 8020 optimization for common patterns
6. Reality verification for correctness
7. Autonomous decisions for optimization
8. BPMN documentation for workflows

True dogfooding of our own distributed coordination system!