//
//  SessionManager.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import Foundation
import AppKit
import Combine

// SessionsIndex represents the structure of sessions-index.json in Claude project directories
struct SessionsIndex: Codable {
    let entries: [SessionEntry]
    
    struct SessionEntry: Codable {
        let sessionId: String
        let customTitle: String?
        let summary: String?
        let firstPrompt: String?
    }
}

// Holds session metadata extracted from sessions-index.json
struct SessionIndexInfo {
    let name: String
    let firstPrompt: String
}

class SessionManager: ObservableObject {
    @Published var sessions: [ClaudeSession] = []

    private var fileMonitor: DispatchSourceFileSystemObject?
    private var refreshTimer: Timer?
    private let sessionDirectory: String
    private let statusFilePrefix = "claude-status"
    private let preferencesManager: PreferencesManager
    private var cancellables = Set<AnyCancellable>()
    
    // Cache for session index files to avoid redundant reads
    private var sessionIndexCache: [String: SessionsIndex] = [:]
    
    // Background queue for file I/O operations
    private let backgroundQueue = DispatchQueue(label: "com.claude-sessions.fileio", qos: .utility)

    init(preferencesManager: PreferencesManager = .shared) {
        self.preferencesManager = preferencesManager
        
        // Expand ~/.claude_sessions to full path
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        self.sessionDirectory = "\(homeDirectory)/.claude_sessions"

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            atPath: sessionDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        setupPreferenceObservers()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }
    
    private func setupPreferenceObservers() {
        // Observe refresh interval changes and restart timer
        preferencesManager.$refreshInterval
            .dropFirst() // Skip initial value
            .removeDuplicates()
            .sink { [weak self] newInterval in
                self?.restartTimer(with: newInterval)
            }
            .store(in: &cancellables)
    }

    func startMonitoring() {
        // Initial refresh on background queue
        backgroundQueue.async { [weak self] in
            self?.refreshSessions()
        }

        restartTimer(with: preferencesManager.refreshInterval)
        setupFileSystemMonitoring()
    }
    
    private func restartTimer(with interval: TimeInterval) {
        refreshTimer?.invalidate()
        
        // Timer fires on main thread, but work is dispatched to background
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.backgroundQueue.async {
                self?.refreshSessions()
            }
        }
    }

    func stopMonitoring() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        fileMonitor?.cancel()
        fileMonitor = nil
        cancellables.removeAll()
    }

    func refreshSessions() {
        // Clear the session index cache on each refresh
        sessionIndexCache.removeAll()
        
        let fileManager = FileManager.default

        do {
            let sessionContents = try fileManager.contentsOfDirectory(atPath: sessionDirectory)
            let statusFiles = sessionContents.filter { $0.hasPrefix(statusFilePrefix) && $0.hasSuffix(".json") }

            var loadedSessions: [ClaudeSession] = []

            for filename in statusFiles {
                let filePath = "\(sessionDirectory)/\(filename)"

                if let session = loadSession(from: filePath) {
                    loadedSessions.append(session)
                }
            }

            loadedSessions.sort { s1, s2 in
                if s1.status != s2.status {
                    return s1.status.priority < s2.status.priority
                }
                return s1.lastUpdateTime > s2.lastUpdateTime
            }

            // Always dispatch to main thread for UI updates
            DispatchQueue.main.async {
                self.sessions = loadedSessions
            }

        } catch {
            print("Error reading ~/.claude_sessions directory: \(error)")
        }
    }

    private func loadSession(from filePath: String) -> ClaudeSession? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let statuslineData = try JSONDecoder().decode(StatuslineData.self, from: data)
            return convertToSession(statuslineData)
        } catch {
            print("Error loading session from \(filePath): \(error)")
            return nil
        }
    }

    // getSessionInfo looks up session metadata from sessions-index.json with caching
    private func getSessionInfo(transcriptPath: String?, sessionId: String) -> SessionIndexInfo {
        // If transcript path is empty, can't look up the info
        guard let transcriptPath = transcriptPath, !transcriptPath.isEmpty else {
            return SessionIndexInfo(name: "", firstPrompt: "")
        }
        
        // Get the project directory (parent of transcript file)
        let projectDir = (transcriptPath as NSString).deletingLastPathComponent
        
        // Check cache first
        if let cachedIndex = sessionIndexCache[projectDir] {
            return findSessionInfo(in: cachedIndex, sessionId: sessionId)
        }
        
        let indexPath = (projectDir as NSString).appendingPathComponent("sessions-index.json")
        
        // Read and cache sessions-index.json
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: indexPath)),
              let index = try? JSONDecoder().decode(SessionsIndex.self, from: data) else {
            // Silently fail - file might not exist or be readable
            return SessionIndexInfo(name: "", firstPrompt: "")
        }
        
        // Cache the index for this project directory
        sessionIndexCache[projectDir] = index
        
        return findSessionInfo(in: index, sessionId: sessionId)
    }
    
    private func findSessionInfo(in index: SessionsIndex, sessionId: String) -> SessionIndexInfo {
        // Find matching session entry
        for entry in index.entries {
            if entry.sessionId == sessionId {
                // Prefer customTitle (set via /rename) over summary (auto-generated)
                let name: String
                if let customTitle = entry.customTitle, !customTitle.isEmpty {
                    name = customTitle
                } else {
                    name = entry.summary ?? ""
                }
                
                let firstPrompt = entry.firstPrompt ?? ""
                return SessionIndexInfo(name: name, firstPrompt: firstPrompt)
            }
        }
        
        // Session not found in index
        return SessionIndexInfo(name: "", firstPrompt: "")
    }
    
    private func convertToSession(_ data: StatuslineData) -> ClaudeSession {
        // Calculate used percentage if not provided
        let usedPercentage: Double
        if let percentage = data.contextWindow.usedPercentage {
            usedPercentage = Double(percentage)
        } else {
            let totalTokens = data.contextWindow.totalInputTokens + data.contextWindow.totalOutputTokens
            let maxTokens = data.contextWindow.contextWindowSize
            usedPercentage = maxTokens > 0 ? (Double(totalTokens) / Double(maxTokens)) * 100.0 : 0.0
        }

        // Determine project directory
        let projectDir = data.workspace?.projectDir ?? data.cwd
        
        // Determine project name from project directory
        let projectName = (projectDir as NSString).lastPathComponent.isEmpty ? 
            projectDir : (projectDir as NSString).lastPathComponent
        
        // Get session info from sessions-index.json
        let sessionInfo = getSessionInfo(transcriptPath: data.transcriptPath, sessionId: data.sessionId)

        return ClaudeSession(
            id: data.sessionId,
            cwd: data.cwd,
            sessionId: data.sessionId,
            sessionName: sessionInfo.name,
            firstPrompt: sessionInfo.firstPrompt,
            projectDir: projectDir,
            projectName: projectName,
            model: ModelInfo(
                displayName: data.model.displayName,
                id: data.model.id
            ),
            contextWindow: ContextWindow(
                usedPercentage: usedPercentage,
                maxTokens: data.contextWindow.contextWindowSize
            ),
            tokenUsage: TokenUsage(
                input: data.contextWindow.totalInputTokens,
                output: data.contextWindow.totalOutputTokens
            ),
            cost: Cost(
                total: data.cost.totalCostUsd,
                input: 0.0,  // Not available in new format
                output: 0.0  // Not available in new format
            ),
            duration: Double(data.cost.totalDurationMs) / 1000.0,  // Convert ms to seconds
            codeImpact: CodeImpact(
                linesAdded: data.cost.totalLinesAdded,
                linesRemoved: data.cost.totalLinesRemoved
            ),
            lastUpdateTime: Date(timeIntervalSince1970: TimeInterval(data.statuslineUpdateTime) / 1000.0)
        )
    }

    private func setupFileSystemMonitoring() {
        let descriptor = open(sessionDirectory, O_EVTONLY)

        guard descriptor >= 0 else {
            print("Failed to open ~/.claude_sessions for monitoring")
            return
        }

        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .delete, .rename],
            queue: backgroundQueue  // Use our background queue
        )

        fileMonitor?.setEventHandler { [weak self] in
            self?.refreshSessions()
        }

        fileMonitor?.setCancelHandler {
            close(descriptor)
        }

        fileMonitor?.resume()
    }

    func removeSession(_ session: ClaudeSession) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            let filename = "claude-status-\(session.cwd.replacingOccurrences(of: "/", with: "-")).json"
            let filePath = "\(self.sessionDirectory)/\(filename)"

            do {
                try FileManager.default.removeItem(atPath: filePath)
                self.refreshSessions()
            } catch {
                print("Error removing session file: \(error)")
            }
        }
    }

    func openInTerminal(_ session: ClaudeSession) {
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(session.cwd)' && clear"
        end tell
        """

        executeAppleScriptAsync(script)
    }

    func openInFinder(_ session: ClaudeSession) {
        // NSWorkspace is main-thread safe and fast
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: session.cwd)
    }

    func resumeInTerminal(_ session: ClaudeSession) {
        let command = "cd '\(session.cwd)' && claude -r \(session.sessionId)"
        let script = """
        tell application "Terminal"
            activate
            do script "\(command)"
        end tell
        """

        executeAppleScriptAsync(script)
    }

    func copyResumeCommand(_ session: ClaudeSession) {
        let command = "cd '\(session.cwd)' && claude -r \(session.sessionId)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
    }
    
    // MARK: - Private Helpers
    
    private func executeAppleScriptAsync(_ source: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let appleScript = NSAppleScript(source: source) else {
                print("Failed to create AppleScript")
                return
            }
            
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)

            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }
}
