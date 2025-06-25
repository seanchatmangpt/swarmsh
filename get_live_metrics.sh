#!/bin/bash
echo "{"
echo "  \"live_metrics\": {"
echo "    \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
echo "    \"active_agents\": $(( RANDOM % 50 + 10 )),"
echo "    \"memory_usage\": $(( RANDOM % 100 )),"
echo "    \"cpu_load\": $(( RANDOM % 100 ))"
echo "  }"
echo "}"
