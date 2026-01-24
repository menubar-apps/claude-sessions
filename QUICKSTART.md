# Quick Start Guide

Get up and running with Claude Session Monitor in 5 minutes.

## Prerequisites

- macOS 13.0+ (Ventura or later)
- Xcode 15+ installed
- Claude Code installed
- `jq` installed (`brew install jq`)

## 1. Build the App (2 minutes)

```bash
cd /Users/caseyjones/homedev/claude-sessions
open claude-sessions.xcodeproj
```

In Xcode:
1. Select your development team in **Signing & Capabilities**
2. Press **⌘R** to build and run

The app will appear in your menubar.

## 2. Install Statusline Script (1 minute)

```bash
# Copy the script
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh

# Verify jq is installed
which jq || brew install jq
```

## 3. Configure Claude (1 minute)

Create or edit `~/.claude/settings.json`:

```bash
cat > ~/.claude/settings.json << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
EOF
```

## 4. Test It (1 minute)

```bash
# Start Claude in any project
cd ~/your-project
claude

# In another terminal, verify status files
ls -la /tmp/claude-status-*.json

# Check the menubar - you should see colored circles!
```

## 5. Configure Preferences

Click the menubar icon → **⚙️ Preferences** to customize:
- Display style
- Launch at login
- Refresh intervals

## Done! 🎉

You should now see:
- **Green circles** for active sessions
- **Yellow circles** for idle sessions  
- **Gray circles** for closed sessions

Click the menubar icon to see detailed session information.

## Troubleshooting

**No circles showing?**
```bash
# Check if status files exist
ls -la /tmp/claude-status-*.json

# Test the script manually
echo '{"session_id":"test","cwd":"/tmp"}' | ~/.claude/statusline.sh
```

**Need more help?** See [SETUP.md](SETUP.md) for detailed instructions.
