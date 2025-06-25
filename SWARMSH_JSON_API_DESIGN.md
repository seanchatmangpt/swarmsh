# SwarmSH JSON API Design - Modern Output Standardization

## 🎯 Objective

Transform SwarmSH from mixed human/machine outputs to a **modern JSON API** with consistent schemas, templates, and structured responses while maintaining backwards compatibility.

## 📊 Current State Analysis

### Output Format Inconsistencies Identified
- **Mixed emoji + JSON + text** outputs
- **Success/error reporting** varies by command
- **Performance metrics** scattered across formats
- **Validation results** mix JSON + text feedback
- **Real-time vs batch** format inconsistencies

### Commands Requiring JSON Standardization
| Command Category | Current Format | JSON API Needed |
|------------------|----------------|-----------------|
| Work Management | Mixed emoji/text | ✅ Structured |
| Dashboard | Rich text/ASCII | ✅ Data + Display |
| Claude AI | JSON + text | ✅ Schema validation |
| Scrum Commands | Text reports | ✅ Structured data |
| Agent Operations | Mixed formats | ✅ Consistent API |

## 🏗️ JSON API Framework Design

### Core Response Schema
```json
{
  "swarmsh_api": {
    "version": "1.0.0",
    "timestamp": "2025-06-24T23:59:59Z",
    "trace_id": "abc123...",
    "request_id": "req_123456789"
  },
  "status": {
    "code": "success|error|warning",
    "message": "Human-readable status",
    "details": "Additional context if needed"
  },
  "data": {
    // Command-specific structured data
  },
  "metadata": {
    "execution_time_ms": 123,
    "agent_id": "agent_123...",
    "operation": "claim|progress|complete|etc",
    "performance": {
      "cpu_time_ms": 45,
      "memory_usage_kb": 1024,
      "telemetry_spans": 3
    }
  },
  "telemetry": {
    "spans_generated": 2,
    "traces_active": 5,
    "coordination_events": 1
  }
}
```

### Command-Specific Schemas

#### Work Management Schema
```json
{
  "data": {
    "work_item": {
      "id": "work_1750808123456789",
      "type": "template_parse|coordination|analysis",
      "description": "Parse user dashboard template",
      "priority": "critical|high|medium|low",
      "status": "active|in_progress|completed|failed",
      "agent_id": "agent_1750808123456788",
      "team": "parser_team",
      "created_at": "2025-06-24T23:59:59Z",
      "updated_at": "2025-06-24T23:59:59Z",
      "progress_percent": 75,
      "velocity_points": 5,
      "estimated_completion": "2025-06-24T24:05:00Z"
    },
    "coordination": {
      "conflicts_detected": 0,
      "work_queue_depth": 12,
      "available_agents": 8,
      "team_capacity": 50
    }
  }
}
```

#### Agent Status Schema
```json
{
  "data": {
    "agent": {
      "id": "agent_1750808123456789",
      "role": "Template_Render_Agent",
      "team": "render_team",
      "status": "active|inactive|busy|error",
      "capacity": {
        "current": 7,
        "maximum": 10,
        "utilization_percent": 70
      },
      "specialization": "template_rendering",
      "performance": {
        "tasks_completed": 156,
        "success_rate": 98.7,
        "avg_completion_time_ms": 450
      },
      "registered_at": "2025-06-24T20:00:00Z",
      "last_activity": "2025-06-24T23:59:45Z"
    }
  }
}
```

#### Dashboard Schema
```json
{
  "data": {
    "system": {
      "health_score": 85,
      "status": "healthy|degraded|critical",
      "uptime_seconds": 86400,
      "version": "3.0.0"
    },
    "agents": {
      "total": 12,
      "active": 10,
      "busy": 2,
      "idle": 8,
      "by_team": {
        "parser_team": 3,
        "render_team": 4,
        "cache_team": 2,
        "coordination_team": 3
      }
    },
    "work": {
      "total_items": 45,
      "active": 12,
      "completed": 30,
      "failed": 3,
      "queue_depth": 5,
      "avg_completion_time_ms": 350
    },
    "telemetry": {
      "total_spans": 15847,
      "active_traces": 42,
      "success_rate": 99.2,
      "spans_per_minute": 24
    },
    "performance": {
      "coordination_latency_ms": 45,
      "work_claim_conflicts": 0,
      "memory_usage_mb": 256,
      "cpu_utilization": 35
    }
  }
}
```

#### Claude AI Analysis Schema
```json
{
  "data": {
    "analysis": {
      "type": "priorities|health|optimization|team",
      "confidence_score": 0.95,
      "model_used": "qwen3:latest",
      "analysis_duration_ms": 1250,
      "recommendations": {
        "immediate": [
          {
            "action": "Scale up parser team",
            "priority": "high",
            "estimated_impact": "25% throughput increase",
            "effort_required": "low"
          }
        ],
        "short_term": [...],
        "long_term": [...]
      },
      "insights": {
        "bottlenecks": ["template_parsing"],
        "opportunities": ["agent_optimization"],
        "risks": ["capacity_limits"]
      },
      "data_quality": {
        "completeness": 0.98,
        "freshness_minutes": 2,
        "reliability_score": 0.94
      }
    },
    "llm_metadata": {
      "tokens_used": 1847,
      "response_time_ms": 1250,
      "cost_estimate": 0.0023,
      "cache_hit": false
    }
  }
}
```

## 🔧 Implementation Strategy

### Phase 1: Core JSON Framework
1. **Add `--json` flag** to all coordination_helper.sh commands
2. **Implement base response wrapper** with standard schema
3. **Create JSON output functions** for each command type
4. **Add backwards compatibility** layer

### Phase 2: Command Standardization
1. **Work management commands** (claim, progress, complete)
2. **Agent operations** (register, status, health)
3. **Dashboard and reporting** commands
4. **Claude AI integration** commands

### Phase 3: Advanced Features
1. **JSON schema validation** for all outputs
2. **Templating system** for custom output formats
3. **Streaming JSON** for real-time commands
4. **API versioning** and deprecation management

## 🎨 Output Mode Design

### Command Line Interface
```bash
# Current (mixed format)
./coordination_helper.sh claim "template_parse" "Parse dashboard" "high"

# New JSON mode
./coordination_helper.sh --json claim "template_parse" "Parse dashboard" "high"

# JSON with custom template
./coordination_helper.sh --json --template=compact claim "template_parse" "Parse dashboard" "high"

# JSON streaming mode
./coordination_helper.sh --json --stream dashboard

# JSON with schema validation
./coordination_helper.sh --json --validate claim "template_parse" "Parse dashboard" "high"
```

### Environment Variable Control
```bash
# Global JSON mode
export SWARMSH_OUTPUT_FORMAT="json"
export SWARMSH_JSON_SCHEMA_VALIDATION="true"
export SWARMSH_JSON_TEMPLATE="standard|compact|verbose"

# Backwards compatibility
export SWARMSH_LEGACY_OUTPUT="true"  # Force emoji/text output
```

## 📋 JSON Templates

### Standard Template (Default)
- Full schema compliance
- Complete metadata
- Human-readable status messages
- Performance metrics included

### Compact Template
- Minimal metadata
- Essential data only
- Reduced JSON size
- Optimized for parsing

### Verbose Template  
- Extended telemetry data
- Debug information included
- Full error stack traces
- Development-friendly

### Streaming Template
- Real-time updates
- Incremental data
- Event-based structure
- WebSocket compatible

## 🔍 Schema Validation Framework

### Schema Definition Files
```bash
/schemas/
├── base_response.json           # Core response wrapper
├── work_management.json         # Work operations
├── agent_operations.json        # Agent commands  
├── dashboard.json              # Dashboard data
├── claude_analysis.json        # AI analysis results
├── telemetry.json             # Telemetry structures
└── error_responses.json        # Error schemas
```

### Validation Integration
```bash
# Automatic validation
./coordination_helper.sh --json --validate claim "work" "desc" "high"

# Schema development mode
./coordination_helper.sh --json --schema-debug claim "work" "desc" "high"

# Custom schema path
./coordination_helper.sh --json --schema-path=/custom/schemas claim "work" "desc" "high"
```

## 🔄 Backwards Compatibility

### Dual Output Support
- **Default behavior**: Current emoji/text output unchanged
- **Explicit JSON**: Only with `--json` flag or environment variable
- **Legacy mode**: `--legacy` flag forces old output even with JSON env vars

### Migration Strategy
1. **Phase 1**: Add JSON alongside existing outputs
2. **Phase 2**: Make JSON default for new scripts
3. **Phase 3**: Deprecate emoji outputs (with warnings)
4. **Phase 4**: JSON-only mode (with legacy flag available)

## 🌟 Modern Usage Benefits

### API Integration
```json
{
  "status": {"code": "success"},
  "data": {"work_item": {"id": "work_123", "status": "completed"}},
  "metadata": {"execution_time_ms": 45}
}
```

### Microservices Communication
- **Kubernetes ready**: JSON logs and API responses
- **Service mesh compatible**: Structured telemetry data
- **CI/CD pipeline integration**: Machine-parseable results
- **Monitoring system integration**: Structured metrics

### Developer Experience
- **IDE integration**: IntelliSense with JSON schemas
- **Testing frameworks**: Assert against structured data
- **Documentation generation**: Auto-generated API docs
- **Type safety**: Language-specific JSON bindings

## 🎯 Success Metrics

### Technical Metrics
- **100% command coverage** with JSON output mode
- **Schema validation** for all structured outputs
- **Backwards compatibility** maintained
- **Performance impact** < 5% overhead

### Usage Metrics
- **API adoption rate** by modern tooling
- **Error reduction** in programmatic usage
- **Development velocity** improvements
- **Integration success rate** with external systems

## 🚀 Implementation Priority

### High Priority (Week 1-2)
1. Core JSON framework and base schema
2. Work management commands (claim, progress, complete)
3. Agent operations (register, status)
4. Basic template system

### Medium Priority (Week 3-4)
1. Dashboard JSON output
2. Claude AI command standardization
3. Schema validation framework
4. Streaming JSON support

### Low Priority (Week 5+)
1. Custom template engine
2. API versioning system
3. Advanced error handling
4. Documentation generation

**Result**: SwarmSH evolves from human-centric tool to modern JSON API while preserving all existing functionality and human-readable outputs.