#!/bin/bash
# Simulates an active Claude session by updating the timestamp every 2 seconds

# Create session directory if it doesn't exist
mkdir -p "$HOME/.claude_sessions"

SESSION_FILE="$HOME/.claude_sessions/claude-status--Users-caseyjones-homedev-claude-sessions.json"

echo "Simulating active Claude session..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
    # Get current timestamp in milliseconds
    timestamp=$(date +%s)000
    
    # Update the JSON file with new timestamp
    cat > "$SESSION_FILE" << EOF
{
  "session_id": "session-abc123",
  "cwd": "/Users/caseyjones/homedev/claude-sessions",
  "model": {
    "display_name": "Sonnet 4.5",
    "id": "claude-sonnet-4-20250514"
  },
  "context_window": {
    "used_percentage": 35.5,
    "max_tokens": 200000
  },
  "token_usage": {
    "input": 45000,
    "output": 26000
  },
  "cost": {
    "total": 0.23,
    "input": 0.135,
    "output": 0.095
  },
  "duration": {
    "total_seconds": 4980
  },
  "code_impact": {
    "lines_added": 1200,
    "lines_removed": 350
  },
  "_statusline_update_time": $timestamp
}
EOF
    
    echo "Updated session at $(date '+%H:%M:%S')"
    sleep 2
done
