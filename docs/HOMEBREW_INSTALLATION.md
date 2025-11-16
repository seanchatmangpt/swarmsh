# SwarmSH v1.1.0 Homebrew Installation Guide

> **Platform:** macOS (Intel & Apple Silicon)
> **Version:** 1.1.0
> **Last Updated:** November 16, 2025

---

## Table of Contents

1. [Quick Install](#quick-install)
2. [Full Installation Steps](#full-installation-steps)
3. [Verification](#verification)
4. [What Gets Installed](#what-gets-installed)
5. [Post-Installation Setup](#post-installation-setup)
6. [Troubleshooting](#troubleshooting)
7. [Updating & Uninstalling](#updating--uninstalling)

---

## Quick Install

If you're in a hurry:

```bash
# One-liner installation
brew tap seanchatmangpt/swarmsh && brew install swarmsh
```

That's it! SwarmSH v1.1.0 will be installed with all dependencies.

---

## Full Installation Steps

### Step 1: Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

If you already have Homebrew installed, skip this step.

### Step 2: Add the SwarmSH Tap

```bash
brew tap seanchatmangpt/swarmsh
```

This adds the SwarmSH formula repository to your Homebrew installation.

### Step 3: Install SwarmSH

```bash
brew install swarmsh
```

### Step 4: Verify Installation

```bash
swarmsh --version
swarmsh help
```

### Step 5: (Optional) Install Production Dependencies

For production use with atomic file locking:

```bash
brew install util-linux  # Provides flock for macOS
```

Or install SwarmSH with the option:

```bash
brew install swarmsh --with-flock
```

---

## Verification

### Quick Health Check

```bash
# Check core dependencies
swarmsh check-dependencies

# Verify Homebrew installation
brew list swarmsh
```

### Expected Output

```
✓ bash found
✓ jq found
✓ python3 found
✓ openssl found
✓ flock found (optional)
```

---

## What Gets Installed

### Executable Commands

After installation, the following commands are available system-wide:

| Command | Purpose |
|---------|---------|
| `swarmsh` | Main coordination helper |
| `swarmsh-coordinator` | Real agent process coordination |
| `swarmsh-orchestrator` | Multi-agent orchestration |
| `swarmsh-quickstart` | Quick initialization script |
| `swarmsh-init` | Initialize new project |
| `swarmsh-dashboard` | View coordination dashboard |
| `swarmsh-monitor` | Real-time monitoring |

### Installation Directories

On macOS, Homebrew installs to:

```
/usr/local/Cellar/swarmsh/1.1.0/  (Intel Mac)
/opt/homebrew/Cellar/swarmsh/1.1.0/  (Apple Silicon Mac)
```

Symlinks are created in:
```
/usr/local/bin/  (Intel Mac)
/opt/homebrew/bin/  (Apple Silicon Mac)
```

### Included Documentation

- `README.md` - Project overview
- `CHANGELOG.md` - Release notes
- `CLAUDE.md` - Development guidelines
- `API_REFERENCE.md` - API documentation
- `docs/` - Comprehensive guides and references

---

## Post-Installation Setup

### 1. Initialize Your First Project

```bash
# Create a project directory
mkdir my-swarmsh-project
cd my-swarmsh-project

# Initialize SwarmSH
swarmsh-init
```

This creates the necessary directories and configuration files.

### 2. Verify Project Setup

```bash
# Check health
swarmsh-dashboard

# View quick reference
make quick-ref
```

### 3. (Optional) Set Up Automation

For automatic cron jobs and monitoring:

```bash
make cron-install
make cron-status
```

### 4. (Optional) Configure Telemetry

SwarmSH can integrate with external telemetry systems:

```bash
# Set OpenTelemetry endpoint (if using)
export OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4317"

# View real-time dashboard
make diagrams-dashboard
make monitor-24h
```

---

## Troubleshooting

### Issue: "Command not found: swarmsh"

**Solution:** Add Homebrew to your PATH:

```bash
# For Apple Silicon Macs:
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile

# For Intel Macs:
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zprofile
source ~/.zprofile
```

### Issue: "jq not found"

**Solution:** Install jq:

```bash
brew install jq
```

### Issue: "python3 not found"

**Solution:** Install Python:

```bash
brew install python@3.11
```

### Issue: "flock not available"

This is optional but recommended for production:

```bash
brew install util-linux
```

### Issue: Installation fails with "Formula not found"

**Solution:** Ensure the tap is added correctly:

```bash
brew tap seanchatmangpt/swarmsh
brew tap-list  # Verify seanchatmangpt/swarmsh appears
brew install swarmsh
```

### Issue: "Permission denied" errors

**Solution:** Fix Homebrew permissions:

```bash
brew doctor
brew cleanup
```

---

## Updating & Uninstalling

### Update to Latest Version

```bash
# Update all packages
brew upgrade swarmsh

# Or check for available versions
brew info swarmsh
```

### Uninstall SwarmSH

```bash
# Remove SwarmSH
brew uninstall swarmsh

# Remove the tap (optional)
brew untap seanchatmangpt/swarmsh
```

### Clean Up

```bash
# Remove cached downloads
brew cleanup

# Fix any issues
brew doctor
```

---

## Platform-Specific Notes

### Apple Silicon (M1/M2/M3)

SwarmSH v1.1.0 is fully compatible with Apple Silicon:

```bash
# Homebrew automatically handles ARM64 builds
brew install swarmsh

# Verify Apple Silicon
file $(which swarmsh)
# Should show: Mach-O 64-bit executable arm64
```

### Intel Macs

SwarmSH v1.1.0 is fully compatible with Intel Macs:

```bash
brew install swarmsh

# Verify Intel architecture
file $(which swarmsh)
# Should show: Mach-O 64-bit executable x86_64
```

---

## System Requirements

### Minimum Requirements

- **macOS:** 10.15 (Catalina) or later
- **Homebrew:** Latest version
- **Bash:** 4.0+
- **jq:** Latest version
- **Python:** 3.8+
- **OpenSSL:** Latest version

### Recommended Requirements

- **macOS:** 11.0 (Big Sur) or later
- **Bash:** 5.0+ (via Homebrew)
- **flock:** util-linux (for atomic operations)
- **Memory:** 2GB minimum
- **Disk Space:** 500MB for installation + work data

---

## Advanced Configuration

### Using Different Installation Prefix

To install to a custom location:

```bash
# Not recommended, but possible
brew install --prefix=/custom/path swarmsh
```

### Building From Source

```bash
brew install --build-from-source swarmsh
```

### Version-Specific Installation

```bash
# Install specific version
brew install swarmsh@1.1.0

# Or from version list
brew search swarmsh
```

---

## Getting Help

### Check Installation

```bash
# Verify everything is working
swarmsh help
make --version  # If in a project
jq --version
python3 --version
```

### View Installed Files

```bash
# See what was installed
brew list swarmsh

# Get installation path
brew --prefix swarmsh
```

### Report Issues

- **GitHub Issues:** https://github.com/seanchatmangpt/swarmsh/issues
- **Quick Reference:** `make quick-ref` (in project)
- **Documentation:** `make help` (in project)

---

## Common Tasks After Installation

### Create a New Agent Project

```bash
mkdir my-agents
cd my-agents
swarmsh-init
```

### Claim Work

```bash
swarmsh claim feature "Implement feature X" high
```

### View Dashboard

```bash
swarmsh-dashboard
```

### Monitor System

```bash
swarmsh-monitor
```

### Update to Latest Version

```bash
brew upgrade swarmsh
```

---

## Uninstallation

If you need to remove SwarmSH:

```bash
# Remove the package
brew uninstall swarmsh

# Remove the tap
brew untap seanchatmangpt/swarmsh

# Clean up
brew cleanup
```

---

## Next Steps

1. **[Quick Start](../docs/QUICK_REFERENCE.md)** - Essential commands
2. **[Development Guide](../CLAUDE.md)** - Development patterns
3. **[API Reference](../API_REFERENCE.md)** - Complete API docs
4. **[Telemetry Guide](../docs/TELEMETRY_GUIDE.md)** - Monitoring setup
5. **[Migration Guide](../docs/MIGRATION_1.0_TO_1.1.md)** - Upgrading from v1.0.0

---

## Version Information

| Item | Value |
|------|-------|
| SwarmSH Version | 1.1.0 |
| Release Date | November 16, 2025 |
| macOS Support | 10.15+ |
| Homebrew Support | Latest |
| Status | Stable - Production Ready |

---

## Support

For issues, questions, or contributions:

- **GitHub:** https://github.com/seanchatmangpt/swarmsh
- **Issues:** https://github.com/seanchatmangpt/swarmsh/issues
- **Discussions:** https://github.com/seanchatmangpt/swarmsh/discussions

---

**Installed successfully? Start with:** `swarmsh-init` 🚀
