# SwarmSH Configuration Reference

This document provides comprehensive documentation for all configuration files, formats, and settings in the SwarmSH system.

## Table of Contents

1. [Configuration Files Overview](#configuration-files-overview)
2. [JSON Data Formats](#json-data-formats)
3. [Environment Variables](#environment-variables)
4. [Shell Script Configuration](#shell-script-configuration)
5. [Worktree Configuration](#worktree-configuration)
6. [Agent Configuration](#agent-configuration)
7. [Telemetry Configuration](#telemetry-configuration)
8. [Database Configuration](#database-configuration)
9. [Claude AI Configuration](#claude-ai-configuration)
10. [Advanced Configuration](#advanced-configuration)

---

## Configuration Files Overview

### Core Configuration Files

| File | Purpose | Format | Location |
|------|---------|--------|----------|
| `swarm_config.json` | Main swarm configuration | JSON | `shared_coordination/` |
| `agent_status.json` | Agent registry and status | JSON | Root directory |
| `work_claims.json` | Active work items | JSON | Root directory |
| `coordination_log.json` | Completed work history | JSON | Root directory |
| `.env` | Environment variables | Shell | Root directory |
| `continuous_feedback_config.json` | Feedback loop settings | JSON | Root directory |

### Generated Configuration Files

| File | Purpose | Generated By |
|------|---------|--------------|
| `agent_{n}_config.json` | Individual agent config | `agent_swarm_orchestrator.sh` |
| `environment_config.json` | Worktree environment settings | `worktree_environment_manager.sh` |
| `telemetry_config.json` | OpenTelemetry settings | `enhance_trace_correlation.sh` |

---

## JSON Data Formats

### Swarm Configuration Format
**File**: `shared_coordination/swarm_config.json`

```json
{
  "swarm_id": "swarm_1750009123456789",
  "coordination_strategy": "distributed_consensus",
  "created_at": "2025-06-16T10:00:00.000Z",
  "claude_integration": {
    "output_format": "json",
    "intelligence_mode": "structured",
    "coordination_context": "s2s_swarm",
    "timeout_seconds": 30,
    "retry_attempts": 3
  },
  "worktrees": [
    {
      "name": "ash-phoenix-migration",
      "agent_count": 2,
      "specialization": "ash_migration",
      "focus_areas": ["schema_migration", "action_conversion", "testing"],
      "resource_allocation": {
        "port_range": [4001, 4005],
        "database_suffix": "_ash_phoenix",
        "max_memory": "4G",
        "max_cpu": 2.0
      },
      "claude_config": {
        "focus": "ash_framework",
        "output_format": "json",
        "agent_mode": true,
        "context_window": 100000
      }
    }
  ],
  "coordination_rules": {
    "max_concurrent_work_per_agent": 3,
    "work_claim_timeout_minutes": 30,
    "cross_team_collaboration": true,
    "automatic_load_balancing": true,
    "load_balance_threshold": 0.8,
    "conflict_resolution": "claude_mediated",
    "heartbeat_interval": 60,
    "stale_agent_timeout": 300,
    "scaling_strategy": "demand_based",
    "min_agents_per_worktree": 1,
    "max_agents_per_worktree": 10
  },
  "telemetry": {
    "enabled": true,
    "sampling_rate": 1.0,
    "export_interval_seconds": 30,
    "retention_days": 7
  }
}
```

### Agent Status Format
**File**: `agent_status.json`

```json
[
  {
    "agent_id": "agent_1750009123456790",
    "team": "migration_team",
    "worktree": "ash-phoenix-migration",
    "specialization": "ash_migration",
    "status": "active",
    "capacity": 100,
    "current_workload": 75,
    "registered_at": "2025-06-16T09:00:00.000Z",
    "last_heartbeat": "2025-06-16T10:15:00.000Z",
    "configuration": {
      "max_concurrent_work": 3,
      "skill_set": ["ecto_to_ash", "schema_design", "testing"],
      "preferred_work_types": ["migration", "refactoring"]
    },
    "performance_metrics": {
      "tasks_completed": 12,
      "tasks_failed": 1,
      "average_completion_time": "2.5h",
      "success_rate": 0.92,
      "velocity_trend": "increasing",
      "skill_effectiveness": {
        "ecto_to_ash": 0.92,
        "schema_design": 0.88,
        "testing": 0.91
      }
    },
    "resource_usage": {
      "cpu_average": 0.45,
      "memory_average": 0.62,
      "peak_cpu": 0.89,
      "peak_memory": 0.78
    }
  }
]
```

### Work Claims Format
**File**: `work_claims.json`

```json
[
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
    "started_at": "2025-06-16T10:05:00.000Z",
    "updated_at": "2025-06-16T10:30:00.000Z",
    "estimated_completion": "2025-06-16T15:30:00.000Z",
    "actual_effort_minutes": 25,
    "estimated_effort_minutes": 180,
    "story_points": 8,
    "acceptance_criteria": [
      "Schema successfully migrated",
      "All tests passing",
      "Documentation updated"
    ],
    "dependencies": ["work_1750009123456788"],
    "blockers": [],
    "metadata": {
      "schema_name": "users",
      "migration_complexity": "high",
      "breaking_changes": false
    },
    "telemetry": {
      "trace_id": "abc123def456789012345678901234567",
      "span_id": "1234567890abcdef",
      "parent_span_id": "fedcba0987654321"
    }
  }
]
```

### Coordination Log Format
**File**: `coordination_log.json`

```json
[
  {
    "work_item_id": "work_1750009123456789",
    "agent_id": "agent_1750009123456790",
    "completion_time": "2025-06-16T15:28:00.000Z",
    "duration_minutes": 328,
    "status": "success",
    "story_points_earned": 8,
    "velocity_impact": 1.2,
    "quality_metrics": {
      "code_coverage": 0.89,
      "tests_passed": 42,
      "tests_failed": 0,
      "bugs_introduced": 0
    },
    "lessons_learned": [
      "Ash resource validations require careful migration",
      "Performance improved with batch operations"
    ]
  }
]
```

### Continuous Feedback Configuration
**File**: `continuous_feedback_config.json`

```json
{
  "timestamp": "2025-06-15T23:59:47-07:00",
  "continuous_feedback_config": {
    "verification_schedule": {
      "frequency": "every_100_work_items",
      "minimum_interval_hours": 24,
      "automatic_trigger": true,
      "verification_types": ["accuracy", "performance", "health"]
    },
    "accuracy_thresholds": {
      "acceptable_variance": 20,
      "warning_variance": 35,
      "critical_variance": 50,
      "confidence_threshold": 0.85
    },
    "improvement_triggers": {
      "claim_accuracy_below": 80,
      "performance_deviation_above": 25,
      "health_score_below": 70,
      "agent_failure_rate_above": 0.15
    },
    "feedback_actions": [
      "update_baseline_metrics",
      "generate_improved_claims",
      "schedule_next_verification",
      "alert_on_critical_deviations",
      "trigger_agent_retraining",
      "adjust_work_distribution"
    ],
    "learning_parameters": {
      "history_window_days": 7,
      "sample_size_minimum": 50,
      "confidence_interval": 0.95
    }
  },
  "integration_points": {
    "coordination_helper": "auto_verification_on_milestone",
    "intelligent_completion": "accuracy_feedback_integration",
    "autonomous_decision": "evidence_based_decision_making",
    "claude_ai": "continuous_learning_integration"
  }
}
```

---

## Environment Variables

### Core Configuration Variables

```bash
# Agent Identity
AGENT_ID="agent_$(date +%s%N)"          # Unique nanosecond-precision ID
AGENT_ROLE="Developer_Agent"            # Agent role in the system
AGENT_TEAM="migration_team"             # Team assignment
AGENT_CAPACITY=100                      # Work capacity (0-100)
AGENT_SPECIALIZATION="ash_migration"    # Primary specialization

# Coordination Settings
COORDINATION_MODE="safe"                # Options: safe, simple, distributed
COORDINATION_DIR="/path/to/coordination" # Data directory path
TELEMETRY_ENABLED=true                  # Enable OpenTelemetry
CLAUDE_INTEGRATION=true                 # Enable Claude AI features
CONFLICT_RESOLUTION="claude_mediated"   # Options: priority, timestamp, claude_mediated

# System Behavior
MAX_CONCURRENT_WORK=3                   # Max work items per agent
HEARTBEAT_INTERVAL=60                   # Seconds between heartbeats
WORK_CLAIM_TIMEOUT=1800                 # Work claim timeout (seconds)
AUTO_SCALING_ENABLED=true               # Enable automatic scaling
```

### OpenTelemetry Configuration

```bash
# Service Identity
OTEL_SERVICE_NAME="s2s-agent-swarm"
OTEL_SERVICE_VERSION="1.0.0"
OTEL_SERVICE_NAMESPACE="production"

# Exporter Configuration
OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
OTEL_EXPORTER_OTLP_HEADERS="api-key=your-api-key"

# Trace Configuration
OTEL_TRACES_EXPORTER="otlp"
OTEL_TRACES_SAMPLER="always_on"
OTEL_TRACES_SAMPLER_ARG="1.0"

# Resource Attributes
OTEL_RESOURCE_ATTRIBUTES="deployment.environment=production,cloud.provider=aws"

# Propagation
OTEL_PROPAGATORS="tracecontext,baggage"

# Special Trace Control
FORCE_TRACE_ID="abc123..."             # Force specific trace ID
COORDINATION_TRACE_ID="def456..."       # Coordination-specific trace
```

### Claude AI Configuration

```bash
# Claude CLI Settings
CLAUDE_OUTPUT_FORMAT="json"             # Options: json, text, markdown
CLAUDE_STRUCTURED_RESPONSE="true"       # Enforce structured output
CLAUDE_AGENT_CONTEXT="s2s_coordination" # Context identifier
CLAUDE_MODEL="claude-3-opus-20240229"   # Model selection
CLAUDE_MAX_TOKENS=4096                  # Maximum response tokens
CLAUDE_TEMPERATURE=0.7                  # Response randomness (0-1)

# Claude Integration Settings
CLAUDE_TIMEOUT_SECONDS=30               # API timeout
CLAUDE_RETRY_ATTEMPTS=3                 # Retry on failure
CLAUDE_RETRY_DELAY=1000                 # Milliseconds between retries
CLAUDE_CACHE_RESPONSES=true             # Cache for efficiency
CLAUDE_CACHE_TTL=3600                   # Cache TTL in seconds
```

### Database Configuration

```bash
# PostgreSQL Connection
POSTGRES_USER="swarmsh"
POSTGRES_PASSWORD="secure_password"
POSTGRES_HOST="localhost"
POSTGRES_PORT="5432"
POSTGRES_DB="swarmsh_development"

# Connection Pool Settings
POSTGRES_MAX_CONNECTIONS=100
POSTGRES_POOL_SIZE=20
POSTGRES_POOL_TIMEOUT=30
POSTGRES_IDLE_TIMEOUT=600

# Database Isolation (per worktree)
WORKTREE_DB_PREFIX="swarmsh_"
WORKTREE_DB_SUFFIX="_dev"
WORKTREE_SCHEMA_ISOLATION=true
```

---

## Shell Script Configuration

### Script-Specific Variables

```bash
# coordination_helper.sh
COORDINATION_HELPER_LOG_LEVEL="info"    # debug, info, warn, error
COORDINATION_HELPER_TIMEOUT=300         # Operation timeout
ATOMIC_OPERATIONS=true                  # Use file locking

# agent_swarm_orchestrator.sh
SWARM_DEPLOY_STRATEGY="rolling"         # rolling, parallel, canary
SWARM_HEALTH_CHECK_INTERVAL=30          # Health check frequency
SWARM_AUTO_RECOVERY=true                # Auto-recover failed agents

# worktree_environment_manager.sh
PORT_ALLOCATION_START=4000              # Starting port number
PORT_ALLOCATION_RANGE=100               # Port range size
DATABASE_ALLOCATION_STRATEGY="isolated"  # isolated, shared, hybrid
```

### Logging Configuration

```bash
# Log Levels and Destinations
LOG_LEVEL="info"                        # debug, info, warn, error, fatal
LOG_FORMAT="json"                       # json, text, structured
LOG_DESTINATION="file"                  # file, stdout, syslog
LOG_FILE_PATH="logs/swarmsh.log"
LOG_ROTATION="daily"                    # daily, size, age
LOG_MAX_SIZE="100M"
LOG_MAX_AGE="30d"
LOG_COMPRESS=true

# Component-Specific Logging
COORDINATION_LOG_LEVEL="debug"
AGENT_LOG_LEVEL="info"
TELEMETRY_LOG_LEVEL="warn"
```

---

## Worktree Configuration

### Worktree Environment Configuration
**File**: `worktrees/{name}/environment_config.json`

```json
{
  "worktree_name": "ash-phoenix-migration",
  "created_at": "2025-06-16T10:00:00.000Z",
  "environment": {
    "PORT": 4001,
    "DATABASE_URL": "postgres://swarmsh:password@localhost:5432/swarmsh_ash_phoenix",
    "PHX_SERVER": "true",
    "MIX_ENV": "dev",
    "SECRET_KEY_BASE": "generated_secret_key",
    "LIVE_VIEW_SIGNING_SALT": "generated_salt"
  },
  "resource_allocation": {
    "port_range": [4001, 4005],
    "database_name": "swarmsh_ash_phoenix",
    "max_agents": 5,
    "cpu_limit": 2.0,
    "memory_limit": "4G"
  },
  "agent_configuration": {
    "specialization": "ash_migration",
    "default_capacity": 100,
    "skill_requirements": ["elixir", "ash", "ecto"],
    "work_types": ["migration", "testing", "documentation"]
  },
  "integration": {
    "main_app_url": "http://localhost:4000",
    "telemetry_endpoint": "http://localhost:4318",
    "coordination_api": "http://localhost:4000/api/coordination"
  }
}
```

### Agent Management Configuration
**File**: `worktrees/{name}/agent_{n}_config.json`

```json
{
  "agent_id": "agent_ash_migration_1_1750009123456789",
  "agent_number": 1,
  "worktree": "ash-phoenix-migration",
  "specialization": "ash_migration",
  "created_at": "2025-06-16T10:00:00.000Z",
  "startup_command": "./start_agent_1.sh",
  "shutdown_command": "./stop_agent_1.sh",
  "health_check_endpoint": "http://localhost:4001/health/agent_1",
  "claude_context": {
    "focus_areas": ["ash_migration", "elixir", "phoenix"],
    "output_format": "json",
    "coordination_mode": "s2s_swarm",
    "memory_retention": true,
    "context_window": 100000
  },
  "coordination": {
    "work_claiming_strategy": "skill_matched",
    "collaboration_mode": "active",
    "reporting_interval": "60s",
    "max_concurrent_work": 3
  },
  "resource_limits": {
    "cpu_shares": 1024,
    "memory_limit": "2G",
    "io_weight": 100
  }
}
```

---

## Agent Configuration

### Agent Startup Configuration

```bash
# Agent-specific environment variables
export AGENT_CONFIG_FILE="agent_1_config.json"
export AGENT_LOG_FILE="logs/agent_1.log"
export AGENT_PID_FILE="agent_1.pid"
export AGENT_WORK_DIR="work/agent_1"

# Performance tuning
export AGENT_WORKER_THREADS=4
export AGENT_ASYNC_OPERATIONS=true
export AGENT_BATCH_SIZE=10
export AGENT_QUEUE_SIZE=100

# Communication settings
export AGENT_COMMUNICATION_PROTOCOL="json-rpc"
export AGENT_MESSAGE_TIMEOUT=5000
export AGENT_RETRY_STRATEGY="exponential"
```

### Agent Capability Matrix

```json
{
  "capability_matrix": {
    "ash_migration": {
      "agents": ["agent_1", "agent_2"],
      "skills": {
        "ecto_to_ash": 0.9,
        "schema_design": 0.85,
        "testing": 0.88,
        "documentation": 0.75
      },
      "work_types": ["migration", "refactoring", "testing"],
      "preferred_complexity": "medium-high"
    },
    "n8n_integration": {
      "agents": ["agent_3"],
      "skills": {
        "workflow_design": 0.92,
        "api_integration": 0.88,
        "automation": 0.90
      },
      "work_types": ["integration", "automation", "optimization"],
      "preferred_complexity": "medium"
    }
  }
}
```

---

## Telemetry Configuration

### Telemetry Export Configuration

```json
{
  "telemetry_config": {
    "enabled": true,
    "service_name": "s2s-agent-swarm",
    "export_interval_ms": 30000,
    "batch_size": 100,
    "queue_size": 2048,
    "exporters": [
      {
        "type": "otlp",
        "endpoint": "http://localhost:4318",
        "protocol": "grpc",
        "compression": "gzip",
        "timeout_ms": 10000,
        "headers": {
          "api-key": "${OTEL_API_KEY}"
        }
      },
      {
        "type": "file",
        "path": "telemetry_spans.jsonl",
        "rotation": "daily",
        "compression": true
      }
    ],
    "sampling": {
      "strategy": "adaptive",
      "initial_rate": 1.0,
      "target_rate": 0.1,
      "decisions_per_second": 100
    },
    "resource_attributes": {
      "service.namespace": "swarmsh",
      "deployment.environment": "${DEPLOYMENT_ENV}",
      "service.version": "${SERVICE_VERSION}"
    }
  }
}
```

### Metrics Configuration

```json
{
  "metrics_config": {
    "enabled": true,
    "collection_interval_ms": 60000,
    "metrics": [
      {
        "name": "agent_work_completed",
        "type": "counter",
        "unit": "items",
        "tags": ["agent_id", "work_type", "status"]
      },
      {
        "name": "agent_capacity_utilization",
        "type": "gauge",
        "unit": "percent",
        "tags": ["agent_id", "team"]
      },
      {
        "name": "work_completion_time",
        "type": "histogram",
        "unit": "seconds",
        "buckets": [60, 300, 900, 1800, 3600],
        "tags": ["work_type", "priority"]
      }
    ],
    "aggregations": {
      "window_size_ms": 60000,
      "percentiles": [0.5, 0.9, 0.95, 0.99]
    }
  }
}
```

---

## Database Configuration

### Database Schema Configuration

```sql
-- Coordination schema
CREATE SCHEMA IF NOT EXISTS coordination;

-- Agent status table
CREATE TABLE coordination.agent_status (
    agent_id VARCHAR(255) PRIMARY KEY,
    team VARCHAR(100),
    worktree VARCHAR(100),
    specialization VARCHAR(100),
    status VARCHAR(50),
    capacity INTEGER,
    current_workload INTEGER,
    last_heartbeat TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Work claims table
CREATE TABLE coordination.work_claims (
    work_item_id VARCHAR(255) PRIMARY KEY,
    agent_id VARCHAR(255) REFERENCES coordination.agent_status(agent_id),
    work_type VARCHAR(100),
    description TEXT,
    priority VARCHAR(50),
    status VARCHAR(50),
    progress INTEGER,
    claimed_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB
);

-- Indexes for performance
CREATE INDEX idx_work_claims_status ON coordination.work_claims(status);
CREATE INDEX idx_work_claims_agent ON coordination.work_claims(agent_id);
CREATE INDEX idx_agent_status_team ON coordination.agent_status(team);
```

### Connection Pool Configuration

```json
{
  "database_pool": {
    "min_connections": 5,
    "max_connections": 20,
    "acquisition_timeout_ms": 30000,
    "idle_timeout_ms": 600000,
    "max_lifetime_ms": 1800000,
    "validation_query": "SELECT 1",
    "validation_timeout_ms": 5000,
    "leak_detection_threshold_ms": 60000
  }
}
```

---

## Claude AI Configuration

### Claude Integration Settings

```json
{
  "claude_integration": {
    "enabled": true,
    "api_endpoint": "https://api.anthropic.com/v1",
    "api_version": "2024-01-01",
    "default_model": "claude-3-opus-20240229",
    "authentication": {
      "method": "api_key",
      "key_source": "environment",
      "key_variable": "CLAUDE_API_KEY"
    },
    "request_defaults": {
      "max_tokens": 4096,
      "temperature": 0.7,
      "top_p": 0.9,
      "stop_sequences": ["</output>", "Human:"],
      "timeout_seconds": 30
    },
    "coordination_context": {
      "system_prompt": "You are an AI agent coordinator...",
      "output_format": "json",
      "include_confidence": true,
      "include_reasoning": true
    },
    "caching": {
      "enabled": true,
      "ttl_seconds": 3600,
      "max_cache_size": 1000,
      "cache_key_prefix": "swarmsh_claude_"
    },
    "rate_limiting": {
      "requests_per_minute": 60,
      "tokens_per_minute": 100000,
      "concurrent_requests": 5
    }
  }
}
```

---

## Advanced Configuration

### Performance Tuning

```json
{
  "performance_tuning": {
    "work_claiming": {
      "lock_timeout_ms": 5000,
      "retry_attempts": 3,
      "retry_delay_ms": 100,
      "batch_claim_size": 5
    },
    "agent_communication": {
      "message_compression": true,
      "batch_messages": true,
      "batch_interval_ms": 100,
      "max_batch_size": 50
    },
    "file_operations": {
      "use_memory_buffers": true,
      "buffer_size_kb": 64,
      "async_writes": true,
      "fsync_interval_ms": 1000
    },
    "json_processing": {
      "streaming_parser": true,
      "max_depth": 10,
      "max_array_size": 10000,
      "number_precision": "double"
    }
  }
}
```

### Security Configuration

```json
{
  "security_config": {
    "authentication": {
      "enabled": true,
      "method": "token",
      "token_expiry_seconds": 3600,
      "refresh_enabled": true
    },
    "authorization": {
      "rbac_enabled": true,
      "default_role": "agent",
      "admin_roles": ["coordinator", "admin"]
    },
    "encryption": {
      "data_at_rest": true,
      "data_in_transit": true,
      "algorithm": "AES-256-GCM",
      "key_rotation_days": 90
    },
    "audit": {
      "enabled": true,
      "log_level": "info",
      "include_payloads": false,
      "retention_days": 90
    }
  }
}
```

### Disaster Recovery Configuration

```json
{
  "disaster_recovery": {
    "backup": {
      "enabled": true,
      "schedule": "0 2 * * *",
      "retention_days": 30,
      "destination": "s3://swarmsh-backups",
      "encryption": true
    },
    "replication": {
      "enabled": true,
      "mode": "async",
      "target": "secondary-region",
      "lag_threshold_seconds": 60
    },
    "health_checks": {
      "interval_seconds": 30,
      "timeout_seconds": 10,
      "failure_threshold": 3,
      "recovery_command": "./recovery_handler.sh"
    }
  }
}
```

---

## Configuration Best Practices

1. **Environment-Specific Configs**: Use separate config files for dev/staging/prod
2. **Secret Management**: Never commit secrets; use environment variables or secret managers
3. **Version Control**: Track configuration changes in version control
4. **Validation**: Validate JSON configs before deployment
5. **Documentation**: Document all custom configuration options
6. **Defaults**: Provide sensible defaults for all optional settings
7. **Migration**: Include configuration migration scripts for updates

---

This configuration reference provides comprehensive documentation for all configuration options in the SwarmSH system. Always validate configurations before deployment and follow security best practices for sensitive settings.