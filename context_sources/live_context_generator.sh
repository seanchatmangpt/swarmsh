#!/bin/bash
# Generate live context data
echo "{"
echo "  \"live\": {"
echo "    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
echo "    \"uptime_seconds\": $(( $(date +%s) - 1750000000 )),"
echo "    \"memory_usage\": $(( RANDOM % 100 )),"
echo "    \"cpu_usage\": $(( RANDOM % 100 )),"
echo "    \"network_connections\": $(( RANDOM % 1000 + 100 ))"
echo "  }"
echo "}"
