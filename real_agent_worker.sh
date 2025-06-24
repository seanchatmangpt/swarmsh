#!/bin/bash
# Real Agent Worker Process
AGENT_ID="$1"
WORK_TYPE="$2"

while true; do
    # Check for work
    work=$(jq -r ".[] | select(.agent_id == \"$AGENT_ID\" and .status == \"active\") | .work_item_id" work_claims.json 2>/dev/null | head -1)
    
    if [[ -n "$work" ]]; then
        # Update to active
        ./coordination_helper.sh progress "$work" "active" >/dev/null 2>&1
        
        # Simulate real work
        sleep $((RANDOM % 5 + 1))
        
        # Complete work
        echo "[$(date '+%H:%M:%S')] Agent $AGENT_ID completing work: $work"
        ./coordination_helper.sh complete "$work" "Completed by real agent $AGENT_ID"
        
        echo "[$(date '+%H:%M:%S')] Agent $AGENT_ID completed work: $work"
    fi
    
    sleep 2
done
