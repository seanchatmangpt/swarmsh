#!/bin/bash
# Auto-documentation cron job wrapper
# Runs documentation generation with proper error handling and logging

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/auto_doc_cron.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Run documentation generation with logging
{
    echo "$(date): Starting automated documentation generation"
    
    # Change to project root (assuming docs/auto_generated structure)
    cd "$SCRIPT_DIR/../.."
    
    # Run the documentation generator
    if ./auto_doc_generator.sh; then
        echo "$(date): Documentation generation completed successfully"
    else
        echo "$(date): Documentation generation failed with exit code $?"
    fi
    
    echo "----------------------------------------"
} >> "$LOG_FILE" 2>&1
