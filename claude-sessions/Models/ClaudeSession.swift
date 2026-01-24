//
//  ClaudeSession.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import Foundation

struct ClaudeSession: Identifiable, Codable {
    let id: String
    let cwd: String
    let sessionId: String
    let model: ModelInfo
    let contextWindow: ContextWindow
    let tokenUsage: TokenUsage
    let cost: Cost
    let duration: TimeInterval
    let codeImpact: CodeImpact?
    let lastUpdateTime: Date

    var status: SessionStatus {
        let timeSinceUpdate = Date().timeIntervalSince(lastUpdateTime)
        if timeSinceUpdate < 3 {
            return .active
        } else if timeSinceUpdate < 3600 {
            return .idle
        } else {
            return .closed
        }
    }

    var displayName: String {
        return cwd.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

struct ModelInfo: Codable {
    let displayName: String
    let id: String
}

struct ContextWindow: Codable {
    let usedPercentage: Double
    let maxTokens: Int
}

struct TokenUsage: Codable {
    let input: Int
    let output: Int

    var total: Int { input + output }
}

struct Cost: Codable {
    let total: Double
    let input: Double
    let output: Double
}

struct CodeImpact: Codable {
    let linesAdded: Int
    let linesRemoved: Int

    var netChange: Int { linesAdded - linesRemoved }
}
