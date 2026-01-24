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
    private let tmpDirectory = "/tmp"
    private let statusFilePrefix = "claude-status"

    init() {
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
            let tmpContents = try fileManager.contentsOfDirectory(atPath: tmpDirectory)
            let statusFiles = tmpContents.filter { $0.hasPrefix(statusFilePrefix) && $0.hasSuffix(".json") }

            var loadedSessions: [ClaudeSession] = []

            for filename in statusFiles {
                let filePath = "\(tmpDirectory)/\(filename)"

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
            print("Error reading /tmp directory: \(error)")
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
        return ClaudeSession(
            id: data.sessionId,
            cwd: data.cwd,
            sessionId: data.sessionId,
            model: ModelInfo(
                displayName: data.model.displayName,
                id: data.model.id
            ),
            contextWindow: ContextWindow(
                usedPercentage: data.contextWindow.usedPercentage,
                maxTokens: data.contextWindow.maxTokens
            ),
            tokenUsage: TokenUsage(
                input: data.tokenUsage.input,
                output: data.tokenUsage.output
            ),
            cost: Cost(
                total: data.cost.total,
                input: data.cost.input,
                output: data.cost.output
            ),
            duration: data.duration.totalSeconds,
            codeImpact: data.codeImpact.map { CodeImpact(
                linesAdded: $0.linesAdded,
                linesRemoved: $0.linesRemoved
            )},
            lastUpdateTime: Date(timeIntervalSince1970: TimeInterval(data.statuslineUpdateTime) / 1000.0)
        )
    }

    private func setupFileSystemMonitoring() {
        let tmpURL = URL(fileURLWithPath: tmpDirectory)
        let descriptor = open(tmpDirectory, O_EVTONLY)

        guard descriptor >= 0 else {
            print("Failed to open /tmp for monitoring")
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
        let filePath = "\(tmpDirectory)/\(filename)"

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
}
