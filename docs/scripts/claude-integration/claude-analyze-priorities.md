# claude-analyze-priorities

## Overview
AI-powered work priority analysis executable that provides intelligent recommendations for Scrum at Scale coordination.

## Purpose
- Analyze current work items and provide priority recommendations
- Identify critical path items and dependencies
- Suggest optimal work ordering based on business value
- Provide structured JSON output for integration

## Usage
```bash
# Basic priority analysis
./claude/claude-analyze-priorities

# Pipe to jq for formatted output
./claude/claude-analyze-priorities | jq .
```

## Key Features
- **Intelligent Prioritization**: AI analysis of work importance and dependencies
- **Structured Output**: JSON format for programmatic consumption
- **80/20 Implementation**: Minimal but effective AI integration
- **Fallback Support**: Works without Claude AI available

## Output Format
```json
{
  "analysis_timestamp": "2025-06-24T14:30:22Z",
  "system_health": "healthy",
  "priorities": {
    "critical": ["work_item_123", "work_item_456"],
    "high": ["work_item_789"],
    "medium": ["work_item_101", "work_item_102"],
    "low": ["work_item_103"]
  },
  "recommendations": {
    "immediate": ["Focus on critical path items", "Address blocking dependencies"],
    "short_term": ["Balance team workload"],
    "long_term": ["Optimize coordination patterns"]
  },
  "confidence_score": 0.85
}
```

## Analysis Criteria
- **Business Value**: Impact on customer outcomes
- **Dependencies**: Blocking relationships between work items
- **Team Capacity**: Current agent availability and specialization
- **Risk Assessment**: Potential blockers and mitigation needs

## Integration
```bash
# Use with coordination helper
./coordination_helper.sh claude-analyze-priorities

# Combine with other tools
./claude/claude-analyze-priorities | jq '.recommendations.immediate[]'
```

## Implementation Details
- **Minimal Design**: Single-purpose executable following Unix philosophy
- **Claude Integration**: Uses Claude API when available
- **Graceful Degradation**: Provides basic analysis without AI
- **Performance**: Fast execution for real-time insights

## Example Workflow
```bash
# 1. Analyze priorities
./claude/claude-analyze-priorities > priorities.json

# 2. Extract immediate actions
jq -r '.recommendations.immediate[]' priorities.json

# 3. List critical items
jq -r '.priorities.critical[]' priorities.json

# 4. Check confidence score
jq '.confidence_score' priorities.json
```

## Error Handling
- Returns empty arrays if no work items found
- Provides fallback analysis if Claude unavailable
- Includes confidence scores for reliability assessment
- Logs errors to stderr while maintaining JSON stdout

## Dependencies
- Claude AI CLI (optional)
- jq for JSON processing
- Access to coordination data files
- Internet connection for AI analysis (when available)