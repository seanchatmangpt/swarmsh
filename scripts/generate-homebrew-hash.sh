#!/bin/bash
################################################################################
# Generate SHA256 hash for Homebrew formula
# Run this after tagging a release
################################################################################

set -euo pipefail

echo "SwarmSH Homebrew SHA256 Hash Generator"
echo "========================================"
echo ""

# Get the version from CHANGELOG or argument
VERSION="${1:-1.1.0}"
RELEASE_URL="https://github.com/seanchatmangpt/swarmsh/archive/refs/tags/v${VERSION}.tar.gz"

echo "Version: $VERSION"
echo "Download URL: $RELEASE_URL"
echo ""

# Download and calculate hash
echo "Downloading archive..."
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

if curl -fsSL "$RELEASE_URL" -o "$TEMP_FILE"; then
    echo "✓ Download successful"
    echo ""

    # Calculate SHA256
    SHA256=$(shasum -a 256 "$TEMP_FILE" | awk '{print $1}')

    echo "SHA256 Hash:"
    echo "$SHA256"
    echo ""

    # Show how to update the formula
    echo "To update Formula/swarmsh.rb:"
    echo "Replace:"
    echo "  sha256 \"TODO_REPLACE_WITH_ACTUAL_SHA256\""
    echo "With:"
    echo "  sha256 \"$SHA256\""
    echo ""

    # Generate Ruby snippet
    echo "Or copy the snippet below:"
    echo ""
    cat <<EOF
# Version $VERSION
class Swarmsh < Formula
  version "$VERSION"
  sha256 "$SHA256"
  url "https://github.com/seanchatmangpt/swarmsh/archive/refs/tags/v${VERSION}.tar.gz"
  # ... rest of formula
end
EOF

else
    echo "✗ Download failed"
    echo "Check that the version tag exists: v$VERSION"
    exit 1
fi
