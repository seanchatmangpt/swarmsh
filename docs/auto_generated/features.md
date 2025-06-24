# Feature Documentation

Generated: 2025-06-24T22:24:12Z
Trace ID: cec18802f1e09c9f7cb6049d9e14f0ed

## Available Features

## SwarmSH Auto-Documentation Features

### Core Documentation Features

**Automated Generation:**
- AI-powered content analysis using ollama-pro backend
- Multiple documentation types in a single operation
- Intelligent content extraction from codebase
- Performance-optimized 80/20 approach

**Documentation Types:**
- **README Updates** - Analysis and improvement suggestions
- **API Documentation** - Extracted from script interfaces and functions
- **Changelog** - Recent changes from git history with user impact analysis
- **Feature Documentation** - Makefile targets and system capabilities

**Cron Integration:**
- Daily full documentation generation (2 AM)
- Bi-daily quick updates (8 AM, 6 PM)
- Automated installation and management
- Error handling and logging

**Performance Features:**
- Sub-600ms generation for full documentation
- Minimal resource usage
- Graceful fallbacks for AI service issues
- Comprehensive error handling

### Usage Examples

```bash
# Generate all documentation
./auto_doc_generator.sh

# Generate specific types only
./auto_doc_generator.sh --types readme,api

# Install cron automation
./cron_auto_docs.sh install

# Check automation status
./cron_auto_docs.sh status
```

### OpenTelemetry Integration

**Monitored Operations:**
- Documentation generation cycles
- AI model response times
- File creation and management
- Cron job execution
- Error rates and recovery

**Telemetry Features:**
- Distributed trace correlation
- Performance metrics collection
- Integration with existing OTEL infrastructure
- Real-time monitoring capability