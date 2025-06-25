#!/bin/bash

# Simple non-distributed template renderer for testing
# This renders templates without the full distributed infrastructure

set -euo pipefail

template_file="$1"
context_file="${2:-context.json}"

# Default empty context
[[ -f "$context_file" ]] || echo '{}' > "$context_file"
context=$(cat "$context_file")

# Process the template line by line
while IFS= read -r line; do
    # Replace variables {{ var }}
    while [[ "$line" =~ \{\{[[:space:]]*([^}|]+)([^}]*)[[:space:]]*\}\} ]]; do
        full_match="${BASH_REMATCH[0]}"
        var_name=$(echo "${BASH_REMATCH[1]}" | xargs)
        filters="${BASH_REMATCH[2]}"
        
        # Get value from context
        value=$(echo "$context" | jq -r --arg var "$var_name" '.[$var] // ""')
        
        # Apply filters
        if [[ "$filters" =~ \|[[:space:]]*upper ]]; then
            value=$(echo "$value" | tr '[:lower:]' '[:upper:]')
        elif [[ "$filters" =~ \|[[:space:]]*lower ]]; then
            value=$(echo "$value" | tr '[:upper:]' '[:lower:]')
        elif [[ "$filters" =~ \|[[:space:]]*length ]]; then
            value="${#value}"
        elif [[ "$filters" =~ \|[[:space:]]*default:[[:space:]]*\"([^\"]+)\" ]]; then
            default_val="${BASH_REMATCH[1]}"
            [[ -z "$value" ]] && value="$default_val"
        fi
        
        # Replace in line
        line="${line//$full_match/$value}"
    done
    
    echo "$line"
done < "$template_file"