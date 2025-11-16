#!/bin/bash
################################################################################
# SwarmSH v1.1.0 Homebrew Installation Helper
# This script sets up SwarmSH via Homebrew on macOS
################################################################################

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
SWARMSH_VERSION="1.1.0"

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     SwarmSH v${SWARMSH_VERSION} Homebrew Installation        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running on macOS
if [[ ! "$OSTYPE" == "darwin"* ]]; then
    echo -e "${RED}✗ Error: This script is designed for macOS${NC}"
    echo "For Linux, use standard package managers (apt, yum, etc.)"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}⚠ Homebrew not found${NC}"
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo -e "${GREEN}✓ Homebrew found${NC}"
echo ""

# Step 1: Tap the SwarmSH repository
echo -e "${BLUE}Step 1: Adding SwarmSH tap${NC}"
echo "Run: brew tap seanchatmangpt/swarmsh"
echo ""

if brew tap seanchatmangpt/swarmsh 2>/dev/null || \
   brew tap-list | grep -q "seanchatmangpt/swarmsh"; then
    echo -e "${GREEN}✓ SwarmSH tap added${NC}"
else
    echo -e "${YELLOW}Note: Tap may already be installed${NC}"
fi
echo ""

# Step 2: Install SwarmSH
echo -e "${BLUE}Step 2: Installing SwarmSH${NC}"
if brew install swarmsh; then
    echo -e "${GREEN}✓ SwarmSH installed${NC}"
else
    echo -e "${RED}✗ Installation failed${NC}"
    exit 1
fi
echo ""

# Step 3: Verify installation
echo -e "${BLUE}Step 3: Verifying installation${NC}"
if command -v swarmsh &> /dev/null; then
    echo -e "${GREEN}✓ SwarmSH is available in PATH${NC}"
    swarmsh --version 2>/dev/null || echo "Version check completed"
else
    echo -e "${RED}✗ SwarmSH not found in PATH${NC}"
    exit 1
fi
echo ""

# Step 4: Check dependencies
echo -e "${BLUE}Step 4: Verifying dependencies${NC}"
MISSING_DEPS=0

for dep in bash jq python3 openssl; do
    if command -v "$dep" &> /dev/null; then
        VERSION=$(eval "$dep --version 2>&1 | head -1")
        echo -e "${GREEN}✓${NC} $dep: $VERSION"
    else
        echo -e "${RED}✗${NC} $dep: NOT FOUND"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
done
echo ""

if [ $MISSING_DEPS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Warning: $MISSING_DEPS dependencies missing${NC}"
    echo "Run: brew install jq python@3.11 openssl"
    echo ""
fi

# Step 5: Optional flock installation
echo -e "${BLUE}Step 5: Optional dependencies${NC}"
if command -v flock &> /dev/null; then
    echo -e "${GREEN}✓${NC} flock is installed (atomic file locking)"
else
    echo -e "${YELLOW}⚠${NC} flock is NOT installed (recommended for production)"
    echo "Install with: brew install util-linux"
    echo "Or: brew install swarmsh --with-flock"
fi
echo ""

# Step 6: Setup instructions
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}Quick Start:${NC}"
echo ""
echo "1. Initialize a new SwarmSH project:"
echo -e "   ${GREEN}swarmsh-init${NC}"
echo ""
echo "2. View coordination dashboard:"
echo -e "   ${GREEN}swarmsh-dashboard${NC}"
echo ""
echo "3. Start monitoring (24h window):"
echo -e "   ${GREEN}swarmsh-monitor${NC}"
echo ""
echo "4. Claim work:"
echo -e "   ${GREEN}swarmsh claim feature \"Task description\" high${NC}"
echo ""

echo -e "${BLUE}Documentation:${NC}"
echo "  • GitHub: https://github.com/seanchatmangpt/swarmsh"
echo "  • README: $(brew --prefix swarmsh)/README.md"
echo "  • CHANGELOG: $(brew --prefix swarmsh)/CHANGELOG.md"
echo "  • Quick Reference: make quick-ref (in project)"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Create/navigate to your project directory"
echo "2. Run: swarmsh-init"
echo "3. Follow the Quick Start prompts"
echo "4. Use 'make help' to see all available commands"
echo ""

echo -e "${GREEN}Happy coding with SwarmSH! 🚀${NC}"
