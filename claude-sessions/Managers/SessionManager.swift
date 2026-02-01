//
//  SessionManager.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import Foundation
import AppKit

class SessionManager: ObservableObject {
    @Published var sessions: [ClaudeSession] = []

    private var fileMonitor: DispatchSourceFileSystemObject?
    private var refreshTimer: Timer?
    private let sessionDirectory: String
    private let statusFilePrefix = "claude-status"

    init() {
        // Expand ~/.claude_sessions to full path
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
        self.sessionDirectory = "\(homeDirectory)/.claude_sessions"

        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            atPath: sessionDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        refreshSessions()

        let interval = PreferencesManager.shared.refreshInterval
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: true
        ) { [weak self] _ in
            self?.refreshSessions()
        }

        setupFileSystemMonitoring()
    }

    func stopMonitoring() {
        refreshTimer?.invalidate()
        fileMonitor?.cancel()
    }

    func refreshSessions() {
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

        return ClaudeSession(
            id: data.sessionId,
            cwd: data.cwd,
            sessionId: data.sessionId,
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
        let sessionURL = URL(fileURLWithPath: sessionDirectory)
        let descriptor = open(sessionDirectory, O_EVTONLY)

        guard descriptor >= 0 else {
            print("Failed to open ~/.claude_sessions for monitoring")
            return
        }

        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: descriptor,
            eventMask: [.write, .delete, .rename],
            queue: DispatchQueue.global(qos: .background)
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
        let filename = "claude-status-\(session.cwd.replacingOccurrences(of: "/", with: "-")).json"
        let filePath = "\(sessionDirectory)/\(filename)"

        do {
            try FileManager.default.removeItem(atPath: filePath)
            refreshSessions()
        } catch {
            print("Error removing session file: \(error)")
        }
    }

    func openInTerminal(_ session: ClaudeSession) {
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(session.cwd)' && clear"
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)

            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }

    func openInFinder(_ session: ClaudeSession) {
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

        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            appleScript.executeAndReturnError(&error)

            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }

    func copyResumeCommand(_ session: ClaudeSession) {
        let command = "cd '\(session.cwd)' && claude -r \(session.sessionId)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
    }
}
