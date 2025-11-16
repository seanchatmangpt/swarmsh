# SwarmSH Homebrew Tap Setup Guide

> Instructions for setting up a custom Homebrew tap for SwarmSH distribution

---

## Overview

A Homebrew "tap" is a custom formula repository. This guide explains how to set up the SwarmSH tap.

---

## For Users

### Install from SwarmSH Tap

```bash
# Add the tap
brew tap seanchatmangpt/swarmsh

# Install SwarmSH
brew install swarmsh

# Verify
swarmsh --version
```

### Remove Tap

```bash
# Remove the tap
brew untap seanchatmangpt/swarmsh
```

---

## For Maintainers

### Create a New Tap Repository

1. **Create a new GitHub repository:**
   - Name: `homebrew-swarmsh` (Homebrew convention)
   - Description: "Homebrew formula for SwarmSH"
   - Public repository

2. **Clone and structure:**

```bash
git clone https://github.com/seanchatmangpt/homebrew-swarmsh.git
cd homebrew-swarmsh

# Create Formula directory
mkdir -p Formula

# Copy the formula
cp ../swarmsh/Formula/swarmsh.rb Formula/

# Initialize repository
git add .
git commit -m "Initial commit: Add swarmsh formula v1.1.0"
git push
```

3. **Directory structure:**

```
homebrew-swarmsh/
├── Formula/
│   └── swarmsh.rb          # Main formula file
├── README.md               # Tap documentation
├── LICENSE                 # MIT License
└── .github/
    └── workflows/          # Optional: CI/CD for formula
```

### Update Formula Version

When releasing a new version:

1. **Generate SHA256 hash:**

```bash
cd swarmsh/
./scripts/generate-homebrew-hash.sh 1.2.0
```

2. **Update the formula:**

Edit `Formula/swarmsh.rb`:

```ruby
class Swarmsh < Formula
  version "1.2.0"
  sha256 "NEW_SHA256_HERE"
  url "https://github.com/seanchatmangpt/swarmsh/archive/refs/tags/v1.2.0.tar.gz"
end
```

3. **Test the formula:**

```bash
# Test installation
brew install ./Formula/swarmsh.rb --verbose

# Run tests
brew test swarmsh

# Uninstall
brew uninstall swarmsh
```

4. **Push changes:**

```bash
git add Formula/swarmsh.rb
git commit -m "Update swarmsh to v1.2.0"
git push
```

### Tap Repository README Example

Create `README.md` in the tap repository:

```markdown
# Homebrew SwarmSH Tap

Custom Homebrew formula repository for SwarmSH.

## Installation

```bash
brew tap seanchatmangpt/swarmsh
brew install swarmsh
```

## Formulas

- **swarmsh** - Enterprise-grade agent coordination framework

## Requirements

- macOS 10.15+
- Homebrew

## Documentation

- [SwarmSH GitHub](https://github.com/seanchatmangpt/swarmsh)
- [Installation Guide](https://github.com/seanchatmangpt/swarmsh/blob/main/docs/HOMEBREW_INSTALLATION.md)

## License

MIT License - See LICENSE file
```

---

## CI/CD for Formula Testing

Optional: Set up GitHub Actions to test formula on each push.

Create `.github/workflows/homebrew-test.yml`:

```yaml
name: Homebrew Formula Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Test Formula
        run: |
          brew install --verbose ./Formula/swarmsh.rb
          swarmsh --version
          brew test swarmsh
```

---

## Troubleshooting Formula Issues

### "Formula not found"

Ensure the tap is registered:

```bash
brew tap-list | grep swarmsh
# Should show: seanchatmangpt/swarmsh
```

### "Invalid SHA256"

Regenerate the correct hash:

```bash
./scripts/generate-homebrew-hash.sh 1.1.0
```

### "Installation fails"

Test the formula locally:

```bash
# Verbose output shows what's failing
brew install --verbose ./Formula/swarmsh.rb

# Check dependencies
brew deps ./Formula/swarmsh.rb
```

### "Tests fail"

Ensure all dependencies are installed:

```bash
# Install test dependencies
brew install bash jq python@3.11 openssl

# Retry
brew test swarmsh
```

---

## Formula Structure Explained

### Version Block

```ruby
class Swarmsh < Formula
  desc "..."        # Short description
  homepage "..."    # Project homepage
  url "..."         # Download URL
  sha256 "..."      # Download file hash
  license "MIT"     # License
  version "1.1.0"   # Version
```

### Dependencies

```ruby
# Required dependencies
depends_on "bash" => :build
depends_on "jq"
depends_on "python@3.11"
depends_on "openssl"

# Optional dependencies
option "with-flock", "Install flock..."
depends_on "util-linux" => :optional
```

### Installation

```ruby
def install
  # Create directories
  libexec.mkpath
  bin.mkpath

  # Install files
  bin.install "script.sh"
  libexec.install Dir["files/*"]
end
```

### Post-Install

```ruby
def post_install
  puts "Installation complete!"
  puts "Usage: swarmsh help"
end
```

### Tests

```ruby
test do
  system "#{bin}/swarmsh", "--version"
  system "bash", "--version"
end
```

---

## Homebrew Resources

- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Tap Documentation](https://docs.brew.sh/Taps)
- [Formula Class Reference](https://docs.brew.sh/Formula-class-API)

---

## Publishing Your Tap

### Option 1: GitHub

Host on GitHub (most common):

```bash
# Users install with:
brew tap seanchatmangpt/homebrew-swarmsh
brew install swarmsh
```

### Option 2: Homebrew Core

Submit to official Homebrew:

```bash
# Clone Homebrew-core
git clone https://github.com/Homebrew/homebrew-core.git

# Add formula to Formula/ directory
# Submit PR with formula

# Users install with:
brew install swarmsh  # No tap needed
```

### Option 3: GitHub Releases

Distribute via GitHub:

```bash
# Package as formula
# Upload to GitHub release
# Users install from URL
```

---

## Version Management

### Current Release

- **Version:** 1.1.0
- **Release Date:** November 16, 2025
- **Status:** Stable
- **Formula:** [Formula/swarmsh.rb](../Formula/swarmsh.rb)

### Updating Process

1. Update source code version
2. Tag release in git: `git tag v1.1.0`
3. Generate SHA256 from release tarball
4. Update formula with new version and hash
5. Test locally
6. Push to tap repository
7. Users can update with: `brew upgrade swarmsh`

---

## Support

For issues with the Homebrew formula:

- [GitHub Issues](https://github.com/seanchatmangpt/swarmsh/issues)
- [Homebrew Documentation](https://docs.brew.sh)
- [SwarmSH GitHub](https://github.com/seanchatmangpt/swarmsh)

---

**Ready to distribute?** Start with creating the GitHub repository and following the steps above.
