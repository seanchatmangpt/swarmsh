#!/bin/bash
# Shell utility functions to replace Python dependencies
# Provides portable timestamp and random generation functions

# Get current time in milliseconds (portable)
get_time_ms() {
    if command -v gdate >/dev/null 2>&1; then
        # macOS with coreutils
        gdate +%s%3N
    elif date +%s%3N >/dev/null 2>&1; then
        # GNU date (Linux)
        date +%s%3N
    elif command -v perl >/dev/null 2>&1; then
        # Fallback to perl (more common than python)
        perl -MTime::HiRes=time -e 'printf "%.0f\n", time * 1000'
    else
        # Ultimate fallback using nanoseconds
        # Note: This might not work on all systems
        local ns=$(date +%s%N 2>/dev/null || echo "$(date +%s)000000000")
        echo $((ns / 1000000))
    fi
}

# Get ISO 8601 timestamp with milliseconds (UTC)
get_iso_timestamp() {
    if command -v gdate >/dev/null 2>&1; then
        # macOS with coreutils
        gdate -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
    elif date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" >/dev/null 2>&1; then
        # GNU date (Linux)
        date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
    else
        # Fallback - construct manually
        local base_time=$(date -u +"%Y-%m-%dT%H:%M:%S")
        local ms=$(($(get_time_ms) % 1000))
        printf '%s.%03dZ\n' "$base_time" "$ms"
    fi
}

# Generate random hex string
# Usage: generate_hex_token [length_in_bytes]
# Default: 16 bytes = 32 hex characters
generate_hex_token() {
    local length="${1:-16}"  # Default 16 bytes = 32 hex chars
    
    if command -v openssl >/dev/null 2>&1; then
        # Preferred method - openssl
        openssl rand -hex "$length"
    elif command -v xxd >/dev/null 2>&1; then
        # Alternative - xxd
        xxd -l "$length" -p /dev/urandom | tr -d '\n'
    elif command -v hexdump >/dev/null 2>&1; then
        # Alternative - hexdump
        hexdump -n "$length" -e '"%02x"' /dev/urandom
    else
        # Fallback - od (POSIX compliant)
        od -An -tx1 -N"$length" /dev/urandom | tr -d ' \n'
    fi
}

# Get nanosecond timestamp (for unique IDs)
get_nano_timestamp() {
    if date +%s%N >/dev/null 2>&1; then
        date +%s%N
    else
        # Fallback for systems without nanosecond support
        # Append a random component for uniqueness
        echo "$(date +%s)$(generate_hex_token 4)"
    fi
}

# Calculate duration in milliseconds
# Usage: calculate_duration_ms start_ms end_ms
calculate_duration_ms() {
    local start_ms="$1"
    local end_ms="$2"
    echo $((end_ms - start_ms))
}

# Self-test function to verify utilities work correctly
shell_utils_test() {
    echo "🧪 Testing shell utilities..."
    
    # Test millisecond timestamps
    local ms=$(get_time_ms)
    if [[ "$ms" =~ ^[0-9]{13}$ ]]; then
        echo "✅ get_time_ms: $ms"
    else
        echo "❌ get_time_ms failed: $ms"
        return 1
    fi
    
    # Test ISO timestamps
    local ts=$(get_iso_timestamp)
    if [[ "$ts" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z$ ]]; then
        echo "✅ get_iso_timestamp: $ts"
    else
        echo "❌ get_iso_timestamp failed: $ts"
        return 1
    fi
    
    # Test hex token generation
    local token=$(generate_hex_token 16)
    if [[ "${#token}" -eq 32 ]] && [[ "$token" =~ ^[0-9a-f]+$ ]]; then
        echo "✅ generate_hex_token: ${token:0:16}..."
    else
        echo "❌ generate_hex_token failed: $token"
        return 1
    fi
    
    # Test nanosecond timestamp
    local nano=$(get_nano_timestamp)
    if [[ "${#nano}" -ge 19 ]]; then
        echo "✅ get_nano_timestamp: $nano"
    else
        echo "❌ get_nano_timestamp failed: $nano"
        return 1
    fi
    
    # Test duration calculation
    local start=$(get_time_ms)
    sleep 0.1
    local end=$(get_time_ms)
    local duration=$(calculate_duration_ms "$start" "$end")
    if [[ "$duration" -ge 90 ]] && [[ "$duration" -le 200 ]]; then
        echo "✅ calculate_duration_ms: ${duration}ms"
    else
        echo "❌ calculate_duration_ms failed: ${duration}ms (expected ~100ms)"
        return 1
    fi
    
    echo "✅ All shell utility tests passed!"
    return 0
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    shell_utils_test
fi