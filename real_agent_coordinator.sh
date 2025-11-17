#!/bin/bash

################################################################################
# Real Agent Coordinator
#
# NOTICE: This script is maintained for documentation compatibility.
# All coordination functionality is implemented in coordination_helper.sh
#
# This was originally designed as a separate real process coordination layer,
# but the functionality has been consolidated into coordination_helper.sh
# to reduce complexity and improve maintainability.
#
# USE coordination_helper.sh INSTEAD FOR ALL COORDINATION OPERATIONS
#
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Show deprecation notice
cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                    DEPRECATION NOTICE                                      ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  real_agent_coordinator.sh is deprecated.                                 ║
║                                                                            ║
║  All coordination functionality has been consolidated into:                ║
║  → coordination_helper.sh                                                  ║
║                                                                            ║
║  Please use coordination_helper.sh for all operations:                     ║
║                                                                            ║
║    ./coordination_helper.sh register    # Register agents                  ║
║    ./coordination_helper.sh claim       # Claim work                       ║
║    ./coordination_helper.sh progress    # Update progress                  ║
║    ./coordination_helper.sh complete    # Complete work                    ║
║    ./coordination_helper.sh dashboard   # Show status                      ║
║                                                                            ║
║  See coordination_helper.sh --help for complete command reference.         ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF

# Delegate to coordination_helper.sh
if [ $# -eq 0 ]; then
    echo
    echo "Usage: $0 <command> [arguments]"
    echo
    echo "Delegating to coordination_helper.sh..."
    echo
    exec "$SCRIPT_DIR/coordination_helper.sh" --help
else
    # Proxy all commands to coordination_helper.sh
    exec "$SCRIPT_DIR/coordination_helper.sh" "$@"
fi
