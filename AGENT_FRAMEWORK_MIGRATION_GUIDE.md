# SwarmSH Migration Guide: From Traditional Agent Frameworks

> **Comprehensive guide for migrating from LangChain, AutoGPT, CrewAI, and other agent frameworks to SwarmSH's telemetry-driven coordination system**

---

## Table of Contents

1. [Why Migrate to SwarmSH?](#why-migrate-to-swarmsh)
2. [Framework Comparisons](#framework-comparisons)
3. [Migration Paths](#migration-paths)
   - [From LangChain](#from-langchain)
   - [From AutoGPT](#from-autogpt)
   - [From CrewAI](#from-crewai)
   - [From BabyAGI](#from-babyagi)
4. [Common Migration Patterns](#common-migration-patterns)
5. [Quick Start Examples](#quick-start-examples)
6. [FAQ](#faq)

---

## Why Migrate to SwarmSH?

### 🎯 Key Advantages

| Feature | Traditional Frameworks | SwarmSH |
|---------|----------------------|---------|
| **Dependencies** | 100+ Python packages | Bash + jq + git |
| **Memory Management** | Complex vector DBs | File-based JSON |
| **Deployment** | Docker + K8s complexity | Single directory |
| **Conflict Resolution** | Race conditions common | Nanosecond precision IDs |
| **Observability** | Limited or custom | Built-in OpenTelemetry |
| **Resource Usage** | 1-4GB RAM minimum | <100MB RAM |
| **Language** | Python-heavy | Shell scripts |
| **State Management** | Complex abstractions | Simple file locks |

### 🚀 Performance Comparison

```bash
# LangChain startup time
$ time python langchain_agent.py
real    0m4.523s  # Import overhead + initialization

# SwarmSH startup time  
$ time ./coordination_helper.sh claim work "test"
real    0m0.042s  # 100x faster
```

---

## Framework Comparisons

### LangChain vs SwarmSH

| Aspect | LangChain | SwarmSH |
|--------|-----------|---------|
| **Architecture** | Chain-based LLM calls | Coordination-based agents |
| **State** | In-memory or vector DB | File-based with atomic locks |
| **Scaling** | Vertical (more RAM) | Horizontal (more agents) |
| **Dependencies** | langchain, openai, tiktoken, chromadb, etc. | bash, jq, git |
| **Code Example** | 50+ lines for basic agent | 3 lines for agent |

### AutoGPT vs SwarmSH

| Aspect | AutoGPT | SwarmSH |
|--------|---------|---------|
| **Memory** | Complex memory systems | Simple JSON files |
| **Goals** | Recursive goal decomposition | Work queue with priorities |
| **Execution** | Single agent, sequential | Multi-agent, parallel |
| **Resource Usage** | 2-4GB RAM typical | 50-100MB RAM |

### CrewAI vs SwarmSH

| Aspect | CrewAI | SwarmSH |
|--------|--------|---------|
| **Agent Definition** | Python classes | Shell functions |
| **Collaboration** | Message passing | File-based coordination |
| **Roles** | Hardcoded in Python | Dynamic JSON config |
| **Tools** | Python decorators | Shell commands |

---

## Migration Paths

## From LangChain

### LangChain Pattern:
```python
from langchain import OpenAI, LLMChain, PromptTemplate
from langchain.agents import initialize_agent, Tool
from langchain.memory import ConversationBufferMemory

# Complex setup
llm = OpenAI(temperature=0.7)
memory = ConversationBufferMemory()
tools = [
    Tool(name="Search", func=search_func, description="Search the web"),
    Tool(name="Calculate", func=calc_func, description="Do math")
]
agent = initialize_agent(tools, llm, agent="zero-shot-react-description", memory=memory)
result = agent.run("Search for AI news and summarize")
```

### SwarmSH Equivalent:
```bash
# Simple, direct approach
./coordination_helper.sh claim search "Search for AI news" high
./coordination_helper.sh claim analysis "Summarize AI news" medium

# Agents automatically pick up work
./real_agent_worker.sh &  # Starts working on queue
```

### Migration Steps:

1. **Replace Chain Logic with Work Queue**
   ```bash
   # Instead of LangChain's sequential chains
   # Create work items that agents process
   ./coordination_helper.sh claim task_type "description" priority
   ```

2. **Convert Tools to Scripts**
   ```bash
   # LangChain tool
   # def search_tool(query): ...
   
   # SwarmSH tool
   cat > tools/search.sh << 'EOF'
   #!/bin/bash
   query="$1"
   # Your search implementation
   EOF
   chmod +x tools/search.sh
   ```

3. **Replace Memory with JSON State**
   ```bash
   # Instead of ConversationBufferMemory
   # Use simple JSON files
   echo '{"context": "previous info"}' > state/conversation.json
   ```

---

## From AutoGPT

### AutoGPT Pattern:
```python
# Complex goal management
goals = [
    "Research AI trends",
    "Write a report",
    "Post to social media"
]
agent = AutoGPT(
    ai_name="ResearchBot",
    memory=LocalMemory(),
    goals=goals
)
agent.start()  # Runs recursively
```

### SwarmSH Equivalent:
```bash
# Direct work creation
./coordination_helper.sh create-epic "AI Research Project"
./coordination_helper.sh claim research "Research AI trends" high
./coordination_helper.sh claim writing "Write AI report" medium  
./coordination_helper.sh claim social "Post to social media" low

# Start multiple agents
for i in {1..3}; do
    ./real_agent_worker.sh &
done
```

### Migration Steps:

1. **Convert Goals to Work Items**
   ```bash
   # AutoGPT's recursive goals become explicit work items
   # with clear dependencies and priorities
   ```

2. **Replace Memory Systems**
   ```bash
   # AutoGPT: Complex vector memory
   # SwarmSH: Simple file-based memory
   mkdir -p memory
   echo "$result" > memory/research_findings.txt
   ```

3. **Parallel Execution**
   ```bash
   # AutoGPT: Single agent recursion
   # SwarmSH: Multiple parallel agents
   ./quick_start_agent_swarm.sh 5  # Start 5 agents
   ```

---

## From CrewAI

### CrewAI Pattern:
```python
from crewai import Agent, Task, Crew

researcher = Agent(
    role='Researcher',
    goal='Find information',
    backstory='Expert researcher'
)
writer = Agent(
    role='Writer', 
    goal='Write content',
    backstory='Professional writer'
)

task1 = Task(description='Research AI', agent=researcher)
task2 = Task(description='Write article', agent=writer)

crew = Crew(agents=[researcher, writer], tasks=[task1, task2])
result = crew.kickoff()
```

### SwarmSH Equivalent:
```bash
# Register specialized agents
./coordination_helper.sh register agent_researcher research_team 10 '{"skills":["research"]}'
./coordination_helper.sh register agent_writer writing_team 10 '{"skills":["writing"]}'

# Create tagged work
./coordination_helper.sh claim research "Research AI" high research_team
./coordination_helper.sh claim writing "Write article" medium writing_team

# Agents with matching skills/teams claim appropriate work
```

### Migration Steps:

1. **Agent Roles → Team Registration**
   ```bash
   # CrewAI roles become team assignments
   ./coordination_helper.sh register $AGENT_ID $TEAM_NAME
   ```

2. **Tasks → Work Items**
   ```bash
   # CrewAI tasks become work claims
   ./coordination_helper.sh claim $TYPE "$DESCRIPTION" $PRIORITY $TEAM
   ```

3. **Crew → Agent Swarm**
   ```bash
   # Instead of Crew class, use orchestrator
   ./agent_swarm_orchestrator.sh start 5
   ```

---

## Common Migration Patterns

### 1. **State Management**

**Before (Python):**
```python
# Complex state with ORMs, Redis, or Vector DBs
state_manager = StateManager(redis_client)
state_manager.save("conversation", conv_history)
```

**After (SwarmSH):**
```bash
# Simple file-based state
echo "$conv_history" > state/conversation.json
# Atomic updates with flock
flock state/conversation.lock -c 'jq ".history += [\"$new_message\"]" state/conversation.json'
```

### 2. **Agent Communication**

**Before (Python):**
```python
# Complex message passing, queues, or APIs
agent1.send_message(agent2, "process this data")
response = agent2.receive_message()
```

**After (SwarmSH):**
```bash
# File-based coordination
echo '{"from": "agent1", "data": "process this"}' > messages/agent2_inbox.json
# Agent 2 monitors its inbox
inotifywait -m messages/agent2_inbox.json
```

### 3. **Tool Integration**

**Before (Python):**
```python
@tool
def web_search(query: str) -> str:
    """Search the web"""
    return requests.get(f"https://api.search.com?q={query}").json()
```

**After (SwarmSH):**
```bash
# Direct command execution
web_search() {
    local query="$1"
    curl -s "https://api.search.com?q=$query" | jq '.'
}
```

### 4. **Parallel Processing**

**Before (Python):**
```python
# Complex async/threading code
async def process_tasks(tasks):
    results = await asyncio.gather(*[process(t) for t in tasks])
    return results
```

**After (SwarmSH):**
```bash
# Natural parallelism with multiple agents
for task in "${tasks[@]}"; do
    ./coordination_helper.sh claim processing "$task" &
done
# Agents automatically process in parallel
```

---

## Quick Start Examples

### Example 1: Simple Task Processing

**Goal:** Process a list of URLs and extract information

**LangChain Approach:**
```python
# 50+ lines of imports, setup, chain configuration
from langchain import OpenAI, PromptTemplate, LLMChain
# ... complex setup code ...
for url in urls:
    result = chain.run(url=url)
    save_result(result)
```

**SwarmSH Approach:**
```bash
# Create work for each URL
for url in "${urls[@]}"; do
    ./coordination_helper.sh claim url_processing "$url" medium
done

# Start agents to process
./quick_start_agent_swarm.sh 3  # 3 parallel agents
```

### Example 2: Research and Report Generation

**Goal:** Research a topic and generate a report

**AutoGPT Approach:**
```python
# Complex recursive goal processing
agent = AutoGPT(goals=["Research quantum computing", "Write technical report"])
agent.start()  # Hope it doesn't spiral out of control
```

**SwarmSH Approach:**
```bash
# Clear, controllable workflow
./coordination_helper.sh claim research "Research quantum computing papers" high
./coordination_helper.sh claim research "Research quantum computing applications" high  
./coordination_helper.sh claim synthesis "Synthesize research findings" medium
./coordination_helper.sh claim writing "Write technical report" low

# Monitor progress
./coordination_helper.sh dashboard
```

### Example 3: Multi-Agent Collaboration

**Goal:** Build a web scraper with multiple specialized agents

**CrewAI Approach:**
```python
# Define multiple agent classes, roles, tasks
scraper = Agent(role="Scraper", ...)
parser = Agent(role="Parser", ...)
analyzer = Agent(role="Analyzer", ...)
# Complex crew setup
```

**SwarmSH Approach:**
```bash
# Register specialized agents
./coordination_helper.sh register scraper_agent scraping_team 10
./coordination_helper.sh register parser_agent parsing_team 10
./coordination_helper.sh register analyzer_agent analysis_team 10

# Create workflow
./coordination_helper.sh claim scraping "Scrape tech news sites" high scraping_team
./coordination_helper.sh claim parsing "Parse HTML content" medium parsing_team
./coordination_helper.sh claim analysis "Analyze trends" low analysis_team

# Agents automatically coordinate through the work queue
```

---

## Migration Checklist

- [ ] **Dependencies Audit**
  - List all Python packages
  - Identify equivalent shell commands
  - Remove unnecessary dependencies

- [ ] **State Migration**
  - Convert in-memory state to JSON files
  - Replace databases with file storage
  - Implement file locking for atomicity

- [ ] **Agent Conversion**
  - Convert Python agents to shell scripts
  - Replace class hierarchies with simple functions
  - Use process-based parallelism

- [ ] **Workflow Adaptation**
  - Convert sequential chains to work queues
  - Replace complex orchestration with simple claims
  - Leverage natural shell parallelism

- [ ] **Monitoring Setup**
  - Enable OpenTelemetry spans
  - Set up telemetry dashboards
  - Configure health monitoring

---

## FAQ

### Q: What about complex LLM interactions?

**A:** SwarmSH integrates with both Claude and Ollama. Complex prompts become work items:
```bash
./coordination_helper.sh claim llm_task "Complex analysis prompt" high
# Agents use claude or ollama-pro for processing
```

### Q: How do I handle agent memory?

**A:** Simple file-based approach:
```bash
# Short-term memory
echo "$context" > memory/context.json

# Long-term memory  
echo "$important_fact" >> memory/facts.jsonl

# Semantic search via grep/ripgrep
rg "quantum" memory/
```

### Q: What about vector databases?

**A:** SwarmSH philosophy: You probably don't need them.
```bash
# Instead of complex embeddings
# Use simple text search
grep -r "similar concept" knowledge/

# For more advanced search
# Use ripgrep with context
rg -C 3 "quantum computing" docs/
```

### Q: How do I scale beyond one machine?

**A:** SwarmSH + Git worktrees + SSH:
```bash
# Distributed coordination via Git
git worktree add --track origin/agent1 ../agent1_work
ssh agent2.host "cd swarmsh && ./real_agent_worker.sh"
```

### Q: What about monitoring and debugging?

**A:** Built-in telemetry from day one:
```bash
# Real-time monitoring
make monitor-24h

# Debug specific operations
grep "operation_name" telemetry_spans.jsonl | jq '.'

# Visual dashboards
make diagrams-dashboard
```

---

## Getting Started

1. **Install SwarmSH**
   ```bash
   git clone https://github.com/your-org/swarmsh.git
   cd swarmsh
   chmod +x *.sh
   ```

2. **Try the Coordination System**
   ```bash
   # Create some work
   ./coordination_helper.sh claim task "My first SwarmSH task" high
   
   # Start an agent
   ./real_agent_worker.sh
   ```

3. **Monitor Progress**
   ```bash
   # In another terminal
   ./coordination_helper.sh dashboard
   ```

4. **Scale Up**
   ```bash
   # Start a full swarm
   ./quick_start_agent_swarm.sh 5
   ```

---

## Conclusion

Migrating to SwarmSH means:
- **Simplicity over complexity** - Shell scripts vs heavy frameworks
- **Speed over features** - 100x faster startup and execution  
- **Reliability over magic** - Explicit coordination vs hidden state
- **Observability from day one** - Built-in telemetry vs custom logging

Start small, migrate incrementally, and enjoy the simplicity of bash-based agent coordination!

---

*For more details, see the [main documentation](README.md) or join our community.*