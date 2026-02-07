# Claude Session Monitor - macOS Menubar App

A native macOS menubar application that provides always-visible monitoring of Claude Code sessions. The app displays session status through visual indicators in the menubar and provides detailed analytics in a dropdown panel.

![Claude Session Monitor](https://via.placeholder.com/800x400?text=Claude+Session+Monitor+Screenshot)

## Features

- **Always Visible**: Monitor Claude sessions without invoking external tools
- **Lightweight**: Minimal resource usage, native Swift/SwiftUI
- **At-a-Glance Status**: Instantly see if Claude is working across all sessions
- **Quick Access**: Click for detailed session analytics
- **Non-Intrusive**: Clean, minimal menubar presence
- **Multiple Display Styles**: Choose between multiple circles, single icon with badge, or compact with overflow
- **Session Actions**: Copy path, open in Terminal/Finder, remove from view
- **Cost Tracking**: Real-time cost monitoring across all sessions
- **Context Usage**: Visual progress bars showing context window usage

## Requirements

- macOS 15.0 (Sequoia) or later
- Claude Code installed
- Statusline configured (see setup below)

## Quick Start

> **Tip**: Just ask Claude Code to install this for you! Share this repo URL with Claude and say: "Install claude-anywhere from https://github.com/streetturtle/claude-anywhere"

## Prerequisites

Set up a statusline script that captures session data.

### 1. Install `jq` if you don't have it

```bash
brew install jq
```

### 2. Create the session writer script

Create `~/.claude/write-status.sh` with the following content:

```bash
#!/bin/bash

# Read the JSON input from stdin
input=$(cat)

# Extract session ID
session_id=$(echo "$input" | jq -r '.session_id // "unknown"')

# Create sessions directory if it doesn't exist
sessions_dir="$HOME/.claude_sessions"
mkdir -p "$sessions_dir"

# Use session_id as the filename to support multiple sessions from the same folder
status_file="$sessions_dir/claude-status-${session_id}.json"

# Write the status data to file with timestamp
# Use milliseconds - on macOS, date doesn't support %N, so we append 000 to convert seconds to ms
echo "$input" | jq ". + {\"_statusline_update_time\": $(date +%s)000}" > "$status_file"

# Pass the input to stdout for the next script in the pipe
echo "$input"
```

Make it executable:

```bash
chmod +x ~/.claude/write-status.sh
```

### 3. Configure Claude Code statusline

Edit `~/.claude/settings.json` and add or update the `statusLine` configuration:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/write-status.sh | ~/.claude/your-existing-statusline-script.sh",
    "padding": 0
  }
}
```

If you don't have an existing statusline script, you can use just the writer:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/write-status.sh",
    "padding": 0
  }
}
```

### 4. Restart Claude Code

Restart Claude Code to apply the changes. Session data will now be written to `~/.claude_sessions/`.

## Usage

### Menubar Display

The app shows session status in the menubar using colored circles:

- **Green (●)**: Active session (updated within 3 seconds)
- **Yellow (●)**: Idle session (3 seconds to 1 hour)
- **Gray (●)**: Closed session (over 1 hour)

### Dropdown Menu

Click the menubar icon to see:

- **Session List**: All active, idle, and closed sessions
- **Session Details**: Model, tokens, cost, context usage, duration
- **Session Actions**: Right-click or hover for context menu
  - Copy Path
  - Open in Terminal
  - Open in Finder
  - Remove from View
- **Summary**: Total cost and session count breakdown
- **Preferences**: Configure display style and behavior
- **Quit**: Exit the application

### Preferences

Access preferences via the dropdown menu or ⌘, to configure:

- **Display Style**: Choose between multiple circles, single icon with badge, or compact with overflow
- **Launch at Login**: Automatically start the app when you log in
- **Show Closed Sessions**: Toggle visibility of closed sessions in the menu
- **Refresh Interval**: How often to check for updates (default: 2 seconds)
- **Activity Threshold**: Time before a session is considered idle (default: 3 seconds)
- **Closed Threshold**: Time before a session is considered closed (default: 60 minutes)

## Architecture

### Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: Pure SwiftUI with MenuBarExtra
- **Minimum OS**: macOS 13.0 (Ventura)
- **Build System**: Xcode 15+
- **Dependencies**: None (pure Swift/SwiftUI)

### Project Structure

```
claude-sessions/
├── Models/
│   ├── ClaudeSession.swift          # Session data model
│   ├── StatuslineData.swift         # Raw JSON model
│   └── SessionStatus.swift          # Status enum
├── Managers/
│   ├── SessionManager.swift         # Session loading/monitoring
│   └── PreferencesManager.swift     # User preferences
├── Views/
│   ├── MenuBar/
│   │   ├── MenuBarLabel.swift       # Menubar icon views
│   │   ├── MultipleCirclesView.swift
│   │   ├── SingleIconWithBadgeView.swift
│   │   └── CompactWithOverflowView.swift
│   ├── Menu/
│   │   ├── StatusMenuView.swift     # Main dropdown menu
│   │   ├── SessionRowView.swift     # Session row component
│   │   ├── SummaryView.swift        # Summary section
│   │   └── EmptyStateView.swift     # No sessions view
│   └── Preferences/
│       └── PreferencesView.swift    # Preferences view
└── claude_sessionsApp.swift         # App entry point
```

### Key Design Decisions

**MenuBarExtra**: This app uses SwiftUI's `MenuBarExtra` (introduced in macOS 13) for the menubar integration. This is the modern, recommended approach that provides:

- Pure SwiftUI - No AppKit bridging needed
- Declarative label/content definition
- Built-in popover behavior
- Automatic light/dark mode support
- Simpler state management

## Development

### Building

```bash
# Open in Xcode
open claude-sessions.xcodeproj

# Build from command line
xcodebuild -scheme claude-sessions -configuration Release
```

### Testing

1. Ensure you have Claude Code running with statusline configured
2. Build and run the app in Xcode
3. Verify the menubar icon appears
4. Click to open the dropdown and verify sessions are displayed
5. Test all session actions (copy, open in Terminal/Finder, remove)
6. Test preferences changes

### Code Signing

For distribution, you'll need to sign the app with a Developer ID certificate:

1. Enroll in Apple Developer Program ($99/year)
2. Create a Developer ID Application certificate
3. Configure signing in Xcode project settings
4. Archive and export with Developer ID signing

## Troubleshooting

### No Sessions Showing

1. Verify statusline script is configured:
   ```bash
   cat ~/.claude/statusline.sh
   ```

2. Check that status files are being created:
   ```bash
   ls -la /tmp/claude-status-*.json
   ```

3. Verify the JSON format is correct:
   ```bash
   cat /tmp/claude-status-*.json | jq .
   ```

### App Won't Launch

1. Check macOS version (must be 13.0+)
2. Verify app is signed properly
3. Check Console.app for error messages

### Terminal/Finder Actions Not Working

The app needs AppleScript automation permissions. Go to:
**System Settings → Privacy & Security → Automation** and ensure the app has permission to control Terminal and Finder.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and MenuBarExtra
- Inspired by the need for always-visible Claude session monitoring
- Uses the same statusline infrastructure as the Raycast extension

## Roadmap

### v1.1
- [ ] Notifications when session state changes
- [ ] Cost threshold alerts
- [ ] Session history view
- [ ] Export session data to CSV/JSON

### v1.2
- [ ] Widgets for macOS 14+
- [ ] Customizable menubar colors
- [ ] Sound effects for state changes

### v1.3
- [ ] Multiple workspace support
- [ ] Session grouping by project
- [ ] Tags and labels for sessions
- [ ] Search/filter in dropdown

## Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Search [existing issues](https://github.com/yourusername/claude-session-monitor-macos/issues)
3. Create a [new issue](https://github.com/yourusername/claude-session-monitor-macos/issues/new) with details

---

**Made with ❤️ for Claude Code users**
