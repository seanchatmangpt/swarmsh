# Diataxis Swarm - 10 Concurrent Documentation Agents

> A coordinated swarm of 10 Claude Code web VM agents specialized in the Diataxis documentation framework

**Version:** 1.0.0
**Created:** 2025-12-27
**Swarm ID:** `diataxis_swarm_web_vm_10`

---

## 🎯 Overview

The Diataxis Swarm is a revolutionary approach to documentation generation and maintenance using 10 concurrent Claude Code web VM agents, each specialized in one of the four Diataxis documentation quadrants:

- **Tutorials** (Learning-oriented)
- **How-To Guides** (Task-oriented)
- **Reference** (Information-oriented)
- **Explanations** (Understanding-oriented)

## 🏗️ Architecture

### Agent Distribution

```
┌─────────────────────────────────────────────────────┐
│              DIATAXIS SWARM (10 Agents)             │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📚 TUTORIALS (3 agents)                           │
│    ├─ Agent 1: Beginner tutorials                  │
│    ├─ Agent 2: Intermediate tutorials              │
│    └─ Agent 3: Advanced tutorials                  │
│                                                     │
│  🔧 HOW-TO GUIDES (2 agents)                       │
│    ├─ Agent 4: Operations & troubleshooting        │
│    └─ Agent 5: Integration & deployment            │
│                                                     │
│  📖 REFERENCE (3 agents)                           │
│    ├─ Agent 6: API reference                       │
│    ├─ Agent 7: Architecture docs                   │
│    └─ Agent 8: Changelog & migrations              │
│                                                     │
│  🧠 EXPLANATIONS (2 agents)                        │
│    ├─ Agent 9: Core concepts                       │
│    └─ Agent 10: Design & architecture              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Work Distribution

| Quadrant | Agents | Priority | Allocation % | Typical Tasks |
|----------|--------|----------|--------------|---------------|
| **Tutorials** | 3 | High | 30% | Getting started, installation, quickstart guides |
| **How-To Guides** | 2 | High | 25% | Troubleshooting, configuration, deployment |
| **Reference** | 3 | Medium | 30% | API docs, command reference, changelogs |
| **Explanations** | 2 | Medium | 15% | Concepts, design decisions, philosophy |

---

## 🚀 Quick Start

### 1. Complete Setup (Recommended)

Run all setup steps at once:

```bash
./diataxis_swarm_orchestrator.sh full-setup
```

This will:
- Initialize swarm coordination
- Register all 10 agents
- Deploy work queues for all quadrants
- Start the swarm

### 2. Manual Setup

If you prefer step-by-step control:

```bash
# Step 1: Initialize coordination
./diataxis_swarm_orchestrator.sh init

# Step 2: Register agents
./diataxis_swarm_orchestrator.sh register

# Step 3: Deploy work queues
./diataxis_swarm_orchestrator.sh deploy

# Step 4: Start swarm
./diataxis_swarm_orchestrator.sh start
```

### 3. Monitor Progress

```bash
# Check swarm status
./diataxis_swarm_orchestrator.sh status

# View coordination dashboard
./diataxis_swarm_orchestrator.sh dashboard

# Generate architecture diagram
./diataxis_swarm_orchestrator.sh diagram
```

---

## 📋 Command Reference

### Core Commands

| Command | Description | Example |
|---------|-------------|---------|
| `init` | Initialize swarm coordination | `./diataxis_swarm_orchestrator.sh init` |
| `register` | Register all 10 agents | `./diataxis_swarm_orchestrator.sh register` |
| `deploy` | Deploy work queues | `./diataxis_swarm_orchestrator.sh deploy` |
| `start` | Start the swarm | `./diataxis_swarm_orchestrator.sh start` |
| `status` | Show swarm status | `./diataxis_swarm_orchestrator.sh status` |
| `stop` | Stop the swarm | `./diataxis_swarm_orchestrator.sh stop` |
| `dashboard` | Show coordination dashboard | `./diataxis_swarm_orchestrator.sh dashboard` |
| `diagram` | Generate Mermaid diagram | `./diataxis_swarm_orchestrator.sh diagram output.mmd` |
| `full-setup` | Complete setup in one command | `./diataxis_swarm_orchestrator.sh full-setup` |

### Work Management Commands

Use `coordination_helper.sh` for detailed work management:

```bash
# View all work items
./coordination_helper.sh list-work

# Claim work for a specific quadrant
./coordination_helper.sh claim "tutorial" "Write getting started guide" "high" "tutorial_team"

# Update progress
./coordination_helper.sh progress WORK_ID 50 "in_progress"

# Complete work
./coordination_helper.sh complete WORK_ID "success" 10

# View dashboard
./coordination_helper.sh dashboard
```

---

## 📚 Agent Specializations

### Tutorial Agents (3)

**Agent 1: Beginner Tutorial Agent**
- **Focus:** Getting started, installation, first steps
- **Output Style:** Very detailed, step-by-step
- **Target Audience:** Complete beginners
- **Example Tasks:**
  - "Create a 5-minute getting started tutorial"
  - "Write installation guide for macOS/Linux/Windows"
  - "Develop first agent coordination tutorial"

**Agent 2: Intermediate Tutorial Agent**
- **Focus:** Agent coordination, worktrees, telemetry
- **Output Style:** Hands-on with practical examples
- **Target Audience:** Users with basic understanding
- **Example Tasks:**
  - "Tutorial: Setting up telemetry monitoring"
  - "Tutorial: Creating your first worktree"
  - "Tutorial: Multi-agent coordination"

**Agent 3: Advanced Tutorial Agent**
- **Focus:** Swarm orchestration, integrations, automation
- **Output Style:** Comprehensive walkthroughs
- **Target Audience:** Advanced users
- **Example Tasks:**
  - "Tutorial: Building custom agent swarms"
  - "Tutorial: Integrating with external systems"
  - "Tutorial: Advanced 8020 automation"

### How-To Agents (2)

**Agent 4: Operations How-To Agent**
- **Focus:** Troubleshooting, configuration, optimization
- **Output Style:** Solution-focused, practical
- **Target Audience:** Operations teams
- **Example Tasks:**
  - "How-To: Troubleshoot coordination conflicts"
  - "How-To: Optimize agent performance"
  - "How-To: Configure telemetry exporters"

**Agent 5: Integration How-To Agent**
- **Focus:** Deployment, integrations, monitoring
- **Output Style:** Task-oriented, multi-approach
- **Target Audience:** DevOps engineers
- **Example Tasks:**
  - "How-To: Deploy to Kubernetes"
  - "How-To: Integrate with CI/CD pipelines"
  - "How-To: Set up advanced monitoring"

### Reference Agents (3)

**Agent 6: API Reference Agent**
- **Focus:** Command reference, API documentation
- **Output Style:** Detailed, precise, comprehensive
- **Target Audience:** All users (reference lookup)
- **Example Tasks:**
  - "Document coordination_helper.sh complete API"
  - "Update command parameter reference"
  - "Create quick reference card"

**Agent 7: Architecture Reference Agent**
- **Focus:** System architecture, component docs
- **Output Style:** Technical, detailed
- **Target Audience:** Developers, architects
- **Example Tasks:**
  - "Document coordination system architecture"
  - "Update system composition overview"
  - "Create component interaction diagrams"

**Agent 8: Changelog Reference Agent**
- **Focus:** Version history, migrations, changes
- **Output Style:** Chronological, detailed
- **Target Audience:** All users (upgrade planning)
- **Example Tasks:**
  - "Maintain CHANGELOG.md"
  - "Create migration guide for v1.1 to v1.2"
  - "Document breaking changes"

### Explanation Agents (2)

**Agent 9: Concepts Explanation Agent**
- **Focus:** Core concepts, coordination theory, 8020 principle
- **Output Style:** Explanatory, conceptual
- **Target Audience:** Users wanting deep understanding
- **Example Tasks:**
  - "Explain nanosecond ID conflict prevention"
  - "Explain 8020 principle application"
  - "Explain Scrum at Scale coordination"

**Agent 10: Architecture Explanation Agent**
- **Focus:** Design decisions, architectural patterns
- **Output Style:** Why-focused, trade-off analysis
- **Target Audience:** Architects, senior developers
- **Example Tasks:**
  - "Explain coordination architecture design"
  - "Explain atomic file locking strategy"
  - "Explain OpenTelemetry integration design"

---

## 🔧 Configuration

### Swarm Configuration File

Location: `diataxis_swarm_config.json`

Key configuration sections:

```json
{
  "swarm_id": "diataxis_swarm_web_vm_10",
  "total_agents": 10,
  "coordination_rules": {
    "max_concurrent_work_per_agent": 2,
    "cross_quadrant_collaboration": true,
    "automatic_load_balancing": true,
    "conflict_resolution": "priority_based"
  }
}
```

### Work Templates

Location: `diataxis_work_templates.json`

Contains templates for each quadrant with:
- Structure guidelines
- Quality standards
- Example tasks
- Collaboration patterns

---

## 📊 Monitoring & Telemetry

### Real-Time Monitoring

```bash
# View swarm status
./diataxis_swarm_orchestrator.sh status

# View telemetry spans
tail -f diataxis_coordination/telemetry_spans.jsonl | jq '.'

# View work distribution
./coordination_helper.sh list-work | jq '.[] | select(.status == "in_progress")'
```

### Key Metrics

- **Active Agents:** Number of registered and active agents
- **Work Distribution:** Tasks per quadrant
- **Completion Rate:** Percentage of completed work
- **Telemetry Spans:** Total operations tracked

### Dashboard

Access comprehensive dashboard:

```bash
./diataxis_swarm_orchestrator.sh dashboard
```

Shows:
- Agent status by quadrant
- Work item distribution
- Recent completions
- Telemetry statistics

---

## 🎨 Work Item Templates

### Tutorial Template

```markdown
# Tutorial: [Topic Name]

## What You'll Learn
- Learning objective 1
- Learning objective 2

## Prerequisites
- Prerequisite 1
- Prerequisite 2

## Step 1: [Action]
Detailed instructions...

## Step 2: [Action]
Detailed instructions...

## Verification
How to check your work...

## Next Steps
Where to go from here...
```

### How-To Template

```markdown
# How-To: [Task Name]

## Problem Statement
What problem does this solve?

## Prerequisites
- Prerequisite 1
- Prerequisite 2

## Solution - Method 1
Step-by-step instructions...

## Solution - Method 2 (Optional)
Alternative approach...

## Common Issues
- Issue 1: Solution
- Issue 2: Solution

## Verification
How to verify success...

## Related How-Tos
- Link 1
- Link 2
```

### Reference Template

```markdown
# Reference: [Component Name]

## Overview
Brief description...

## Command Synopsis
```bash
command [options] arguments
```

## Parameters
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| param1 | string | Yes | - | Description |

## Return Values
What the command returns...

## Examples
```bash
# Example 1
command example

# Example 2
command example
```

## Related Commands
- Command 1
- Command 2
```

### Explanation Template

```markdown
# Explanation: [Concept Name]

## Introduction
Why this concept matters...

## Core Concept
The fundamental idea...

## Design Rationale
Why it was designed this way...

## Trade-offs and Alternatives
What was considered and why...

## Real-World Applications
How this applies in practice...

## Further Reading
- Resource 1
- Resource 2
```

---

## 🔄 Workflow

### Typical Agent Workflow

1. **Agent Registration**
   - Agent starts and registers with coordination system
   - Receives unique nanosecond-precision ID
   - Joins team based on specialization

2. **Work Claiming**
   - Agent queries available work for its quadrant
   - Claims work atomically using file locking
   - Updates status to "in_progress"

3. **Work Execution**
   - Agent reads work description and templates
   - Creates/updates documentation
   - Follows Diataxis guidelines for quadrant

4. **Progress Updates**
   - Agent reports progress percentage
   - Updates telemetry with operation spans
   - Maintains heartbeat signal

5. **Work Completion**
   - Agent marks work complete
   - Provides quality score (1-10)
   - Releases work for review

### Cross-Quadrant Collaboration

Agents can collaborate across quadrants:

- **Tutorial → Reference:** Tutorial links to API reference
- **How-To → Tutorial:** How-to assumes tutorial completion
- **Explanation → All:** Provides conceptual context
- **Reference → Explanation:** Links to concept explanations

---

## 📈 Performance Characteristics

### Expected Performance

- **Agent Registration:** < 100ms
- **Work Claiming:** < 50ms (with atomic locking)
- **Status Updates:** < 30ms
- **Telemetry Logging:** < 20ms

### Scalability

- **Current:** 10 concurrent agents
- **Maximum Tested:** 50 agents
- **Recommended:** 10-20 agents for documentation tasks

### Conflict Prevention

- **Zero conflicts** guaranteed through nanosecond-precision IDs
- **Atomic file operations** prevent race conditions
- **Distributed tracing** tracks all operations

---

## 🛠️ Troubleshooting

### Common Issues

**Issue: Agents not claiming work**
```bash
# Check agent registration
./coordination_helper.sh list-agents

# Verify work queue
./coordination_helper.sh list-work

# Check coordination directory permissions
ls -la diataxis_coordination/
```

**Issue: Swarm status shows "stopped"**
```bash
# Restart swarm
./diataxis_swarm_orchestrator.sh start

# Check swarm state
cat diataxis_coordination/swarm_state.json | jq '.'
```

**Issue: Telemetry not logging**
```bash
# Check telemetry file exists
ls -la diataxis_coordination/telemetry_spans.jsonl

# Verify OTEL configuration
echo $OTEL_SERVICE_NAME
```

---

## 📝 Best Practices

### For Tutorial Agents

1. ✅ Always start with clear learning objectives
2. ✅ Include estimated completion time
3. ✅ Test all steps before finalizing
4. ✅ Provide working code examples
5. ✅ Link to next logical tutorial

### For How-To Agents

1. ✅ Start with problem statement
2. ✅ Offer multiple solutions when applicable
3. ✅ Include troubleshooting section
4. ✅ Assume prerequisite knowledge
5. ✅ Provide verification steps

### For Reference Agents

1. ✅ Ensure 100% accuracy
2. ✅ Document every parameter
3. ✅ Provide complete examples
4. ✅ Use consistent formatting
5. ✅ Include version information

### For Explanation Agents

1. ✅ Focus on "why" not "how"
2. ✅ Discuss trade-offs
3. ✅ Use diagrams when helpful
4. ✅ Link to academic sources
5. ✅ Connect related concepts

---

## 🔗 Related Documentation

- **[DOCUMENTATION_MAP.md](DOCUMENTATION_MAP.md)** - Complete documentation index
- **[CLAUDE.md](CLAUDE.md)** - Development guidance
- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete API reference
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture

---

## 📊 Statistics

### Documentation Coverage

| Quadrant | Existing Docs | Target Docs | Coverage |
|----------|---------------|-------------|----------|
| Tutorials | 4 | 10 | 40% |
| How-To Guides | 6 | 15 | 40% |
| Reference | 6 | 10 | 60% |
| Explanations | 8 | 12 | 67% |

### Agent Productivity (Expected)

- **Tutorial Agent:** 1-2 tutorials per day
- **How-To Agent:** 2-3 guides per day
- **Reference Agent:** 3-5 reference docs per day
- **Explanation Agent:** 1 explanation per day

---

## 🎯 Roadmap

### Phase 1: Foundation (Current)
- ✅ 10-agent swarm architecture
- ✅ Diataxis-based work distribution
- ✅ Atomic coordination system
- ✅ OpenTelemetry integration

### Phase 2: Enhancement (Next)
- ⬜ AI-powered quality review
- ⬜ Automated cross-referencing
- ⬜ Multi-language support
- ⬜ Version-aware documentation

### Phase 3: Scale (Future)
- ⬜ 50+ concurrent agents
- ⬜ Multi-project support
- ⬜ Real-time collaboration
- ⬜ Advanced analytics dashboard

---

## 🤝 Contributing

To add new work items to the swarm:

```bash
# Add tutorial work
./coordination_helper.sh claim "tutorial" "Your tutorial description" "high" "tutorial_team"

# Add how-to work
./coordination_helper.sh claim "how_to" "Your how-to description" "medium" "howto_team"

# Add reference work
./coordination_helper.sh claim "reference" "Your reference description" "high" "reference_team"

# Add explanation work
./coordination_helper.sh claim "explanation" "Your explanation description" "medium" "explanation_team"
```

---

## 📜 License

Same as SwarmSH project license.

---

## 📞 Support

For issues or questions:
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- View swarm status: `./diataxis_swarm_orchestrator.sh status`
- Check telemetry: `tail -f diataxis_coordination/telemetry_spans.jsonl`

---

<div align="center">

**[Quick Start](#-quick-start)** • **[Commands](#-command-reference)** • **[Agents](#-agent-specializations)** • **[Troubleshooting](#-troubleshooting)**

*Powered by SwarmSH v1.1.0 and the Diataxis Framework*

</div>
