# claude-optimize-assignments

## Overview
AI-powered agent assignment optimization executable that analyzes current work distribution and provides intelligent rebalancing recommendations.

## Purpose
- Optimize work assignments across available agents
- Balance workload distribution for maximum efficiency
- Match agent skills to work requirements
- Reduce coordination overhead and bottlenecks

## Usage
```bash
# Optimize all teams
./claude/claude-optimize-assignments

# Optimize specific team
./claude/claude-optimize-assignments phoenix-team

# Get optimization score only
./claude/claude-optimize-assignments | jq '.optimization_score'
```

## Key Features
- **Skill-Based Matching**: Aligns agent capabilities with work requirements
- **Load Balancing**: Distributes work evenly across available capacity
- **Efficiency Optimization**: Minimizes coordination overhead
- **Real-time Analysis**: Current state assessment and improvement recommendations

## Output Format
```json
{
  "optimization_type": "assignment_optimization",
  "current_efficiency": 0.75,
  "optimized_efficiency": 0.89,
  "potential_improvement": 0.14,
  "analysis_timestamp": "2025-06-24T14:30:22Z",
  "assignment_changes": [
    {
      "work_item": "feature_authentication",
      "current_agent": "agent_001",
      "recommended_agent": "agent_005",
      "confidence": 0.92,
      "reasoning": "Better skill match: security expertise",
      "expected_improvement": "25% faster completion"
    }
  ],
  "team_analysis": {
    "phoenix-team": {
      "current_utilization": 0.85,
      "optimal_utilization": 0.78,
      "bottlenecks": ["backend development"],
      "recommendations": ["Add backend specialist", "Cross-train frontend developers"]
    }
  },
  "optimization_score": 0.89
}
```

## Optimization Criteria

### Skill Matching
- Agent expertise vs. work requirements
- Learning curve considerations
- Certification and experience levels
- Historical performance on similar tasks

### Load Distribution
- Current workload per agent
- Capacity availability
- Peak usage patterns
- Sustainable work pace

### Coordination Efficiency
- Communication patterns
- Dependency management
- Handoff requirements
- Cross-team collaboration needs

## Assignment Changes
Each recommended change includes:
- **Work Item**: Specific task to reassign
- **Current Agent**: Who currently has the work
- **Recommended Agent**: Optimal assignment target
- **Confidence Score**: AI confidence in recommendation (0.0-1.0)
- **Reasoning**: Explanation of why change is beneficial
- **Expected Improvement**: Quantified benefit estimate

## Integration Examples
```bash
# Apply optimization recommendations
./claude/claude-optimize-assignments | jq -r '.assignment_changes[] | 
  "Move \(.work_item) from \(.current_agent) to \(.recommended_agent)"'

# Check team utilization
./claude/claude-optimize-assignments phoenix-team | jq '.team_analysis'

# Monitor optimization effectiveness
optimization_score=$(./claude/claude-optimize-assignments | jq -r '.optimization_score')
echo "Current optimization: $(echo "$optimization_score * 100" | bc)%"
```

## Team-Specific Analysis
```bash
# Analyze specific teams
./claude/claude-optimize-assignments coordination-team
./claude/claude-optimize-assignments development-team
./claude/claude-optimize-assignments platform-team

# Compare team performance
for team in coordination development platform; do
    score=$(./claude/claude-optimize-assignments ${team}-team | jq -r '.optimization_score')
    echo "$team: $score"
done
```

## Automation Workflow
```bash
# Daily optimization check
optimization_data=$(./claude/claude-optimize-assignments)
improvement=$(echo "$optimization_data" | jq -r '.potential_improvement')

if (( $(echo "$improvement > 0.1" | bc -l) )); then
    echo "Significant optimization opportunity: $improvement"
    echo "$optimization_data" | jq -r '.assignment_changes[] | 
      "Consider: \(.work_item) → \(.recommended_agent) (\(.reasoning))"'
fi
```

## Performance Impact
- **Efficiency Gains**: 10-30% improvement in task completion times
- **Reduced Bottlenecks**: Better distribution prevents overload
- **Skill Development**: Optimal matching improves learning
- **Team Satisfaction**: Balanced workload improves morale

## Dependencies
- Claude AI CLI (optional)
- jq for JSON processing
- bc for numerical calculations
- Current agent status and work assignment data
- Historical performance metrics