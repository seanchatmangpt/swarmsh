# Homebrew Formula for SwarmSH v1.1.0
# Usage: brew tap seanchatmangpt/swarmsh https://github.com/seanchatmangpt/swarmsh.git
#        brew install swarmsh

class Swarmsh < Formula
  desc "Enterprise-grade bash-based agent coordination framework with OpenTelemetry"
  homepage "https://github.com/seanchatmangpt/swarmsh"
  url "https://github.com/seanchatmangpt/swarmsh/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "TODO_REPLACE_WITH_ACTUAL_SHA256"
  license "MIT"

  version "1.1.0"

  # Dependencies
  depends_on "bash" => :build
  depends_on "jq"
  depends_on "python@3.11"
  depends_on "openssl"

  # Optional dependencies
  option "with-flock", "Install flock for atomic file locking (macOS)"
  depends_on "util-linux" => :optional

  def install
    # Create installation directory structure
    libexec.mkpath
    bin.mkpath

    # Copy main coordination scripts
    bin.install "coordination_helper.sh" => "swarmsh"
    bin.install "real_agent_coordinator.sh" => "swarmsh-coordinator"
    bin.install "agent_swarm_orchestrator.sh" => "swarmsh-orchestrator"
    bin.install "quick_start_agent_swarm.sh" => "swarmsh-quickstart"

    # Copy core utilities
    libexec.install Dir["*.sh"]
    libexec.install Dir["docs"]
    libexec.install Dir["agent_coordination"]
    libexec.install "Makefile"
    libexec.install "CHANGELOG.md"
    libexec.install "README.md"
    libexec.install "CLAUDE.md"
    libexec.install "API_REFERENCE.md"

    # Create wrapper scripts for direct command access
    (bin/"swarmsh-init").write init_script
    (bin/"swarmsh-dashboard").write dashboard_script
    (bin/"swarmsh-monitor").write monitor_script
  end

  def post_install
    puts "SwarmSH v1.1.0 installed successfully!"
    puts ""
    puts "Quick Start:"
    puts "  swarmsh-init                    # Initialize new project"
    puts "  swarmsh-dashboard               # View coordination dashboard"
    puts "  swarmsh-monitor                 # Real-time monitoring (24h)"
    puts ""
    puts "Main Commands:"
    puts "  swarmsh claim feature \"Task description\" high"
    puts "  swarmsh dashboard"
    puts "  swarmsh help"
    puts ""
    puts "Documentation:"
    puts "  https://github.com/seanchatmangpt/swarmsh"
    puts "  swarmsh-docs                    # View installed documentation"
    puts ""
    puts "For more information, run: swarmsh help"
  end

  def init_script
    <<~EOS
      #!/bin/bash
      # SwarmSH initialization wrapper
      LIBEXEC="#{libexec}"
      "$LIBEXEC/quick_start_agent_swarm.sh" "$@"
    EOS
  end

  def dashboard_script
    <<~EOS
      #!/bin/bash
      # SwarmSH dashboard wrapper
      LIBEXEC="#{libexec}"
      "$LIBEXEC/coordination_helper.sh" dashboard
    EOS
  end

  def monitor_script
    <<~EOS
      #!/bin/bash
      # SwarmSH monitoring wrapper
      LIBEXEC="#{libexec}"
      cd "$(pwd)" || exit 1
      make monitor-24h 2>/dev/null || {
        echo "Error: make monitor-24h not available"
        echo "Run this command from a SwarmSH project directory"
        exit 1
      }
    EOS
  end

  test do
    # Test basic functionality
    system "#{bin}/swarmsh", "check-dependencies" if File.exist?("#{bin}/swarmsh")
    system "bash", "--version"
    system "jq", "--version"
  end
end
