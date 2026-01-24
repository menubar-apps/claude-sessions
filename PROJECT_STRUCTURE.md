# Project Structure

Complete file structure for the Claude Session Monitor macOS app.

## Directory Tree

```
claude-sessions/
├── claude-sessions.xcodeproj/          # Xcode project file
├── claude-sessions/                    # Main source directory
│   ├── App/
│   │   └── (Xcode-managed files)
│   ├── Models/
│   │   ├── ClaudeSession.swift        # Main session model with computed properties
│   │   ├── StatuslineData.swift       # Raw JSON structure from statusline
│   │   └── SessionStatus.swift        # Enum for active/idle/closed states
│   ├── Managers/
│   │   ├── SessionManager.swift       # File monitoring, session loading, actions
│   │   └── PreferencesManager.swift   # UserDefaults, launch at login
│   ├── Views/
│   │   ├── MenuBar/
│   │   │   ├── MenuBarLabel.swift             # Main label switcher
│   │   │   ├── MultipleCirclesView.swift      # Display: ●●●○
│   │   │   ├── SingleIconWithBadgeView.swift  # Display: ◉ 5
│   │   │   └── CompactWithOverflowView.swift  # Display: ●●● +2
│   │   ├── Menu/
│   │   │   ├── StatusMenuView.swift    # Main dropdown container
│   │   │   ├── SessionRowView.swift    # Individual session row
│   │   │   ├── SummaryView.swift       # Cost & stats summary
│   │   │   └── EmptyStateView.swift    # No sessions placeholder
│   │   └── Preferences/
│   │       └── PreferencesView.swift   # Settings window
│   ├── claude_sessionsApp.swift        # @main entry point with MenuBarExtra
│   ├── ContentView.swift               # (Unused, from template)
│   ├── Info.plist                      # LSUIElement for menubar-only
│   ├── claude_sessions.entitlements    # Sandbox, /tmp access, AppleScript
│   └── Assets.xcassets/                # App icons
├── README.md                           # Main documentation
├── SETUP.md                            # Detailed setup guide
├── QUICKSTART.md                       # 5-minute quick start
├── PROJECT_STRUCTURE.md                # This file
├── LICENSE                             # MIT License
├── .gitignore                          # Xcode/Swift gitignore
└── statusline.sh                       # Example statusline script for users
```

## File Descriptions

### Models

**ClaudeSession.swift**
- Main data model representing a Claude session
- Computed `status` property based on `lastUpdateTime`
- Computed `displayName` property for abbreviated paths
- Contains nested structs: ModelInfo, ContextWindow, TokenUsage, Cost, CodeImpact

**StatuslineData.swift**
- Raw JSON structure matching statusline output
- Uses `CodingKeys` for snake_case to camelCase mapping
- Nested structs mirror the JSON structure exactly
- Decoded from `/tmp/claude-status-*.json` files

**SessionStatus.swift**
- Enum with cases: active, idle, closed
- Provides `color`, `emoji`, and `priority` computed properties
- Used for sorting and visual display

### Managers

**SessionManager.swift**
- `@Published var sessions: [ClaudeSession]` - main data source
- File system monitoring of `/tmp` directory
- Timer-based refresh (configurable interval)
- Session loading and JSON parsing
- Actions: removeSession, openInTerminal, openInFinder

**PreferencesManager.swift**
- Singleton pattern with `shared` instance
- `@Published` properties for all preferences
- UserDefaults persistence
- Launch at login via SMAppService (macOS 13+)
- Display styles: multipleCircles, singleIconWithBadge, compactWithOverflow

### Views - MenuBar

**MenuBarLabel.swift**
- Switches between display styles based on preferences
- Receives sessions array and displayStyle

**MultipleCirclesView.swift**
- Shows up to 4 colored circles
- Default display style

**SingleIconWithBadgeView.swift**
- Single circle (color of most active session) + count badge
- Compact alternative

**CompactWithOverflowView.swift**
- Shows 3 circles + overflow count (e.g., "+2")
- Balance between detail and space

### Views - Menu

**StatusMenuView.swift**
- Main dropdown container (400pt wide)
- Header with title and refresh button
- Scrollable session list (max 400pt height)
- Summary section
- Footer with Preferences and Quit buttons

**SessionRowView.swift**
- Individual session display with hover state
- Shows: emoji, path, model, tokens, cost, context bar, duration
- Context menu: Copy Path, Open in Terminal/Finder, Remove
- Color-coded context bar (green/orange/red)

**SummaryView.swift**
- Total cost across all sessions
- Session count breakdown (active/idle/closed)

**EmptyStateView.swift**
- Shown when no sessions exist
- Icon + helpful message

### Views - Preferences

**PreferencesView.swift**
- SwiftUI Form with grouped sections
- Display settings (style, show closed)
- Behavior settings (launch at login, intervals)
- About section (version, link)

### App Entry Point

**claude_sessionsApp.swift**
- `@main` struct with SwiftUI App protocol
- `@StateObject` for SessionManager and PreferencesManager
- MenuBarExtra scene with label and content
- Settings scene for preferences window
- `.menuBarExtraStyle(.window)` for rich content

### Configuration Files

**Info.plist**
- `LSUIElement: true` - No dock icon, menubar only
- Copyright notice

**claude_sessions.entitlements**
- App Sandbox enabled
- `/tmp/` read access (temporary exception)
- AppleScript automation for Terminal/Finder

**Assets.xcassets**
- App icon (generated by Xcode)
- Can be customized with custom icon

## Data Flow

```
┌─────────────────────────────────────────────────┐
│ Claude Code Session                             │
│ (running in terminal)                           │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ ~/.claude/statusline.sh                         │
│ - Reads JSON from stdin                         │
│ - Adds timestamp                                │
│ - Writes to /tmp/claude-status-{cwd}.json       │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ SessionManager                                  │
│ - File system monitoring (/tmp)                 │
│ - Timer-based refresh (2s default)              │
│ - Reads & parses JSON files                     │
│ - Converts to ClaudeSession models              │
│ - Publishes to @Published sessions array        │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ MenuBarLabel (in menubar)                       │
│ - Observes sessions array                       │
│ - Displays colored circles                      │
│ - Updates automatically                         │
└─────────────────────────────────────────────────┘
                  │
                  ▼ (on click)
┌─────────────────────────────────────────────────┐
│ StatusMenuView (dropdown)                       │
│ - Shows detailed session list                   │
│ - Summary statistics                            │
│ - Actions & preferences                         │
└─────────────────────────────────────────────────┘
```

## Key Technologies

- **SwiftUI**: All UI components
- **MenuBarExtra**: Modern menubar integration (macOS 13+)
- **Combine**: @Published properties for reactive updates
- **DispatchSource**: File system monitoring
- **Timer**: Periodic refresh
- **UserDefaults**: Preferences persistence
- **SMAppService**: Launch at login (macOS 13+)
- **NSAppleScript**: Terminal/Finder integration
- **JSONDecoder**: Parsing statusline JSON

## Build Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+
- Swift 5.9+
- No external dependencies

## Runtime Requirements

- macOS 13.0+ (Ventura or later)
- Claude Code with statusline configured
- `jq` installed (for statusline script)

## Next Steps for Development

1. **Add to Xcode Project**: All Swift files need to be added to the Xcode project
2. **Configure Signing**: Set development team in Signing & Capabilities
3. **Test Build**: Build and run (⌘R)
4. **Test with Real Data**: Start Claude session with statusline configured
5. **Package for Distribution**: Archive and export with Developer ID

## Adding Files to Xcode

Since files were created outside Xcode, you need to add them:

1. Open `claude-sessions.xcodeproj` in Xcode
2. Right-click on `claude-sessions` group
3. Select "Add Files to 'claude-sessions'..."
4. Navigate to each folder (Models, Managers, Views)
5. Select all Swift files
6. Ensure "Copy items if needed" is unchecked (files are already in place)
7. Ensure "claude-sessions" target is checked
8. Click "Add"

Or use the terminal:
```bash
# This will be done manually in Xcode as it's more reliable
```

## Testing Checklist

- [ ] App builds without errors
- [ ] App launches and shows menubar icon
- [ ] Menubar icon displays when sessions exist
- [ ] Clicking menubar shows dropdown
- [ ] Sessions load from /tmp
- [ ] Status indicators are correct (🟢🟡⚪)
- [ ] Context bars render correctly
- [ ] All metrics display properly
- [ ] Copy path works
- [ ] Open in Terminal works
- [ ] Open in Finder works
- [ ] Remove session deletes file
- [ ] Preferences save and apply
- [ ] All three display styles work
- [ ] Launch at login works
- [ ] App works with 0 sessions
- [ ] App works with 10+ sessions
- [ ] App updates when new session starts
- [ ] App updates when session closes

## Known Limitations

1. **macOS 13+ Only**: MenuBarExtra requires Ventura or later
2. **Sandbox Restrictions**: Requires temporary exception for /tmp access
3. **No App Store**: Sandbox exceptions prevent App Store distribution
4. **Developer ID Required**: For distribution outside development
5. **jq Dependency**: Users must install jq for statusline script

## Future Improvements

See README.md Roadmap section for planned features.
