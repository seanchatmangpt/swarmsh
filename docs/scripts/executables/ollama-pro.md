# ollama-pro

## Overview
Advanced CLI wrapper for Ollama with enhanced features including OpenTelemetry instrumentation, session management, performance monitoring, and multi-modal support.

## Purpose
- Enhanced Ollama experience with advanced features
- Performance monitoring and telemetry integration
- Session management for conversation continuity
- Multi-modal support for vision and embeddings
- Professional-grade CLI interface

## Installation & Setup
```bash
# Make executable
chmod +x ollama-pro

# Configure (optional)
./ollama-pro config

# Verify installation
./ollama-pro --version
```

## Key Features
- **OpenTelemetry Integration**: Complete observability with traces and metrics
- **Session Management**: Persistent conversation contexts
- **Performance Monitoring**: Real-time metrics and timing
- **Multi-modal Support**: Vision, embeddings, and text processing
- **Enhanced UX**: Professional CLI with rich features

## Basic Usage
```bash
# Interactive chat
./ollama-pro chat llama2

# Single prompt
./ollama-pro run llama2 "Explain quantum computing"

# Vision analysis
./ollama-pro vision llava-v1.6 image.jpg "What's in this image?"

# Generate embeddings
./ollama-pro embed nomic-embed-text "Hello world"
```

## Commands Reference

### Model Management
```bash
# List available models
./ollama-pro list

# Pull a model
./ollama-pro pull llama2

# Show model information
./ollama-pro show llama2

# Create custom model
./ollama-pro create my-model ./Modelfile

# Remove model
./ollama-pro rm old-model
```

### Chat & Generation
```bash
# Interactive chat mode
./ollama-pro chat [model]

# Single generation
./ollama-pro run [model] "prompt"

# Stream responses
./ollama-pro run --stream llama2 "Long prompt..."

# No context mode
./ollama-pro run --no-context llama2 "Independent prompt"
```

### Multi-modal Features
```bash
# Vision analysis
./ollama-pro vision [model] [image_path] ["prompt"]

# Generate embeddings
./ollama-pro embed [model] "text to embed"

# Custom model creation
./ollama-pro create [name] [modelfile]
```

### Session Management
```bash
# List sessions
./ollama-pro session list

# Load specific session
./ollama-pro session load [session_id]

# Sessions are auto-created and managed
```

### Performance & Monitoring
```bash
# Show performance metrics
./ollama-pro metrics

# Monitor with telemetry
OTEL_TRACE_ENABLED=true ./ollama-pro chat llama2
```

## Configuration

### Environment Variables
```bash
# Ollama host
export OLLAMA_HOST="http://localhost:11434"

# OpenTelemetry
export OTEL_TRACE_ENABLED=true
export OTEL_METRICS_ENABLED=true
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"

# Performance
export STREAM_MODE=true
export MULTIMODAL_MODE=true
```

### Configuration File
```bash
# Edit configuration
./ollama-pro config

# Location: ~/.config/ollama-pro/config.json
```

## OpenTelemetry Integration

### Trace Generation
- **Service Name**: `ollama-pro`
- **Span Hierarchy**: Main → Command → API Request
- **Context Propagation**: Full trace correlation
- **Error Tracking**: Comprehensive error spans

### Metrics Collection
```bash
# Request metrics
- ollama_pro.api.request.duration
- ollama_pro.api.request.count
- ollama_pro.model.pull.duration

# Performance metrics
- ollama_pro.chat.response.length
- ollama_pro.session.duration
- ollama_pro.error.count
```

### Telemetry Examples
```bash
# Enable full telemetry
export OTEL_TRACE_ENABLED=true
export OTEL_METRICS_ENABLED=true

# Run with telemetry
./ollama-pro chat llama2

# View traces
grep "ollama_pro" telemetry_data/traces.json
```

## Advanced Features

### Session Continuity
- Automatic session creation and management
- Context preservation across conversations
- Session-based memory for coherent discussions

### Performance Optimization
- Request timing and optimization
- Response caching capabilities  
- Concurrent request handling
- Resource usage monitoring

### Error Recovery
- Retry logic with exponential backoff
- Graceful failure handling
- Connection resilience
- Fallback mechanisms

## Examples

### Development Workflow
```bash
# Start development session
./ollama-pro chat codellama

# Analyze code file
./ollama-pro vision llava-v1.6 screenshot.png "Review this code"

# Generate embeddings for search
./ollama-pro embed nomic-embed-text "function documentation"
```

### Performance Monitoring
```bash
# Monitor request performance
time ./ollama-pro run llama2 "Complex analysis task"

# Check metrics
./ollama-pro metrics | grep duration

# Telemetry analysis
OTEL_TRACE_ENABLED=true ./ollama-pro chat llama2
```

### Multi-modal Analysis
```bash
# Image + text analysis
./ollama-pro vision llava-v1.6 diagram.png "Explain this architecture"

# Document processing
./ollama-pro vision llava-v1.6 document.jpg "Summarize key points"
```

## Troubleshooting

### Common Issues
```bash
# Check Ollama service
./ollama-pro list

# Verify model availability
./ollama-pro show llama2

# Test connectivity
curl http://localhost:11434/api/tags
```

### Debug Mode
```bash
# Enable debug logging
DEBUG=1 ./ollama-pro chat llama2

# Verbose telemetry
OTEL_LOG_LEVEL=debug ./ollama-pro run llama2 "test"
```

### Performance Issues
```bash
# Check system resources
./ollama-pro metrics | grep memory

# Monitor response times
time ./ollama-pro run llama2 "benchmark prompt"
```

## Integration Points
- Compatible with Ollama server
- Integrates with OpenTelemetry collectors
- Works with Prometheus/Grafana monitoring
- Supports CI/CD automation workflows

## Dependencies
- **Ollama**: Core language model server
- **jq**: JSON processing
- **curl**: HTTP requests
- **OpenTelemetry**: Observability (optional)
- **Python3**: Advanced features (optional)