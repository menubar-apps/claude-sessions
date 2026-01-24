# Setup Guide - Claude Session Monitor

This guide will help you set up the Claude Session Monitor menubar app.

## Step 1: Install the App

### Option A: Build from Source (Recommended for now)

1. Open the project in Xcode:
   ```bash
   cd /path/to/claude-sessions
   open claude-sessions.xcodeproj
   ```

2. In Xcode:
   - Select your development team in Signing & Capabilities
   - Build the app (⌘B)
   - Run the app (⌘R)

3. The app will appear in your menubar (top-right corner)

### Option B: Download Pre-built (Coming Soon)

Download from the Releases page and drag to Applications folder.

## Step 2: Configure Statusline Script

The app reads session data from `/tmp/claude-status-*.json` files. You need to set up a statusline script.

### 2.1 Create the Script Directory

```bash
mkdir -p ~/.claude
```

### 2.2 Copy the Statusline Script

Copy the provided `statusline.sh` to your Claude directory:

```bash
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

Or create it manually:

```bash
cat > ~/.claude/statusline.sh << 'EOF'
#!/bin/bash
# Read JSON from stdin
json_data=$(cat)

# Extract session info
session_id=$(echo "$json_data" | jq -r '.session_id // "unknown"')
cwd=$(echo "$json_data" | jq -r '.cwd // "unknown"')

# Add timestamp
timestamp=$(date +%s)000
json_with_timestamp=$(echo "$json_data" | jq ". + {\"_statusline_update_time\": $timestamp}")

# Write to temp file
safe_cwd=$(echo "$cwd" | tr '/' '-')
temp_file="/tmp/claude-status-${safe_cwd}.json"
echo "$json_with_timestamp" > "$temp_file"

# Output empty string
echo ""
EOF

chmod +x ~/.claude/statusline.sh
```

### 2.3 Install jq (if not already installed)

The statusline script requires `jq` for JSON processing:

```bash
# Using Homebrew
brew install jq

# Or using MacPorts
sudo port install jq
```

## Step 3: Configure Claude Code

Add the statusline configuration to your Claude settings file.

### 3.1 Locate or Create Settings File

Claude settings are typically at `~/.claude/settings.json`. If it doesn't exist, create it:

```bash
mkdir -p ~/.claude
touch ~/.claude/settings.json
```

### 3.2 Add Statusline Configuration

Edit `~/.claude/settings.json` and add:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

If you already have other settings, just add the `statusLine` section:

```json
{
  "existingSetting": "value",
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

## Step 4: Verify Setup

### 4.1 Start a Claude Code Session

Open a new terminal and start Claude Code in any project:

```bash
cd ~/your-project
claude
```

### 4.2 Check Status Files

In another terminal, verify that status files are being created:

```bash
ls -la /tmp/claude-status-*.json
```

You should see one or more JSON files.

### 4.3 Inspect the JSON

Check that the JSON format is correct:

```bash
cat /tmp/claude-status-*.json | jq .
```

You should see output like:

```json
{
  "session_id": "abc123",
  "cwd": "/Users/you/project",
  "model": {
    "display_name": "Sonnet 4.5",
    "id": "claude-sonnet-4-5-..."
  },
  "context_window": {
    "used_percentage": 15.5,
    "max_tokens": 200000
  },
  "token_usage": {
    "input": 1000,
    "output": 500
  },
  "cost": {
    "total": 0.05,
    "input": 0.03,
    "output": 0.02
  },
  "duration": {
    "total_seconds": 300
  },
  "_statusline_update_time": 1706025600000
}
```

### 4.4 Check the Menubar App

Look at your menubar (top-right corner). You should see:
- Colored circles representing your sessions
- Green = active, Yellow = idle, Gray = closed

Click the menubar icon to see the dropdown with session details.

## Step 5: Grant Permissions (if needed)

### 5.1 Automation Permissions

If you want to use "Open in Terminal" or "Open in Finder" features:

1. Go to **System Settings → Privacy & Security → Automation**
2. Find "claude-sessions" in the list
3. Enable permissions for Terminal and Finder

### 5.2 File Access

The app needs to read `/tmp` directory. This should work automatically with the entitlements, but if you have issues:

1. Go to **System Settings → Privacy & Security → Files and Folders**
2. Ensure the app has necessary permissions

## Step 6: Configure Preferences

Click the menubar icon and select "⚙️ Preferences..." to customize:

- **Display Style**: Choose how sessions appear in menubar
- **Launch at Login**: Auto-start the app
- **Refresh Interval**: How often to check for updates (default: 2 seconds)
- **Activity Threshold**: When to mark sessions as idle (default: 3 seconds)
- **Closed Threshold**: When to mark sessions as closed (default: 60 minutes)

## Troubleshooting

### No Sessions Showing

**Problem**: Menubar shows no circles or "No Claude Sessions"

**Solutions**:
1. Verify statusline script exists and is executable:
   ```bash
   ls -la ~/.claude/statusline.sh
   ```

2. Check that jq is installed:
   ```bash
   which jq
   ```

3. Verify status files are being created:
   ```bash
   ls -la /tmp/claude-status-*.json
   ```

4. Check Claude settings:
   ```bash
   cat ~/.claude/settings.json
   ```

### Script Errors

**Problem**: Statusline script fails

**Solutions**:
1. Test the script manually:
   ```bash
   echo '{"session_id":"test","cwd":"/tmp"}' | ~/.claude/statusline.sh
   ```

2. Check for jq errors:
   ```bash
   echo '{"test":"value"}' | jq .
   ```

3. Verify file permissions:
   ```bash
   chmod +x ~/.claude/statusline.sh
   ```

### App Won't Launch

**Problem**: App crashes or won't start

**Solutions**:
1. Check macOS version (must be 13.0+):
   ```bash
   sw_vers
   ```

2. Check Console.app for error messages:
   - Open Console.app
   - Search for "claude-sessions"
   - Look for error messages

3. Rebuild the app in Xcode with clean build folder

### Permissions Issues

**Problem**: "Open in Terminal" or "Open in Finder" doesn't work

**Solutions**:
1. Grant automation permissions (see Step 5.1 above)
2. Try running the app from Applications folder (not from Xcode)
3. Check System Settings → Privacy & Security → Automation

## Advanced Configuration

### Custom Status File Location

If you want to use a different location for status files, modify the statusline script:

```bash
# Change this line in statusline.sh
temp_file="/your/custom/path/claude-status-${safe_cwd}.json"
```

Then update `SessionManager.swift`:
```swift
private let tmpDirectory = "/your/custom/path"
```

### Multiple Claude Instances

The app automatically handles multiple Claude sessions. Each session creates its own status file based on the working directory.

### Cleanup Old Sessions

Status files persist in `/tmp` until manually removed. To clean up:

```bash
# Remove all Claude status files
rm /tmp/claude-status-*.json
```

Or use the "Remove from View" option in the app's context menu.

## Next Steps

- Explore the preferences to customize the app
- Try different display styles
- Set up launch at login for always-on monitoring
- Check the main README.md for feature details

## Getting Help

If you encounter issues:

1. Check this setup guide
2. Review the main README.md
3. Check existing GitHub issues
4. Create a new issue with:
   - macOS version
   - Xcode version
   - Error messages from Console.app
   - Contents of `~/.claude/settings.json`
   - Output of `ls -la /tmp/claude-status-*.json`

---

**Happy monitoring! 🎉**
