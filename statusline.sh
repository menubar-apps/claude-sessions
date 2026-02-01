#!/bin/bash
# Claude Code Statusline Script
# This script is called by Claude Code to generate statusline data
# It writes session information to ~/.claude_sessions for the menubar app to read

# Read the JSON data from stdin
json_data=$(cat)

# Extract session info
session_id=$(echo "$json_data" | jq -r '.session_id // "unknown"')
cwd=$(echo "$json_data" | jq -r '.cwd // "unknown"')

# Add timestamp (milliseconds since epoch)
timestamp=$(date +%s)000
json_with_timestamp=$(echo "$json_data" | jq ". + {\"_statusline_update_time\": $timestamp}")

# Create session directory if it doesn't exist
session_dir="$HOME/.claude_sessions"
mkdir -p "$session_dir"

# Write to session file for the menubar app to read
# Sanitize the cwd for filename (replace / with -)
safe_cwd=$(echo "$cwd" | tr '/' '-')
temp_file="$session_dir/claude-status-${safe_cwd}.json"
echo "$json_with_timestamp" > "$temp_file"

# Output empty string (no statusline display in terminal)
echo ""
