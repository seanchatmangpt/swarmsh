# SwarmSH Coordination System - 80/20 Optimized Container
# Multi-stage build for production-ready coordination system

# Build stage
FROM ubuntu:22.04 AS builder

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    bash \
    jq \
    python3 \
    python3-pip \
    openssl \
    curl \
    bc \
    util-linux \
    cron \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /app

# Copy coordination system files
COPY *.sh ./
COPY *.json ./
COPY *.md ./
COPY *.yml ./

# Make scripts executable
RUN chmod +x *.sh

# Production stage  
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    bash \
    jq \
    python3 \
    openssl \
    curl \
    bc \
    util-linux \
    cron \
    supervisor \
    procps \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash swarmsh

# Set up application directory
WORKDIR /app
RUN chown swarmsh:swarmsh /app

# Copy built application from builder stage
COPY --from=builder --chown=swarmsh:swarmsh /app /app

# Create required directories
RUN mkdir -p \
    /app/logs \
    /app/telemetry_archive \
    /app/real_agents \
    /app/real_work_results \
    && chown -R swarmsh:swarmsh /app

# Configuration files
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/crontab.docker /etc/cron.d/swarmsh-cron

# Set up cron
RUN chmod 0644 /etc/cron.d/swarmsh-cron \
    && crontab -u swarmsh /etc/cron.d/swarmsh-cron

# Environment variables
ENV COORDINATION_DIR=/app
ENV OTEL_SERVICE_NAME=swarmsh-coordination
ENV OTEL_SERVICE_VERSION=1.0.0
ENV OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
ENV DEPLOYMENT_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /app/docker-healthcheck.sh

# Expose coordination API port (if needed)
EXPOSE 8080

# Switch to non-root user
USER swarmsh

# Default command
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]