//
//  StatuslineData.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import Foundation

struct StatuslineData: Codable {
    let sessionId: String
    let cwd: String
    let model: ModelData
    let contextWindow: ContextWindowData
    let tokenUsage: TokenUsageData
    let cost: CostData
    let duration: DurationData
    let codeImpact: CodeImpactData?
    let statuslineUpdateTime: Int64

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cwd
        case model
        case contextWindow = "context_window"
        case tokenUsage = "token_usage"
        case cost
        case duration
        case codeImpact = "code_impact"
        case statuslineUpdateTime = "_statusline_update_time"
    }

    struct ModelData: Codable {
        let displayName: String
        let id: String

        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case id
        }
    }

    struct ContextWindowData: Codable {
        let usedPercentage: Double
        let maxTokens: Int

        enum CodingKeys: String, CodingKey {
            case usedPercentage = "used_percentage"
            case maxTokens = "max_tokens"
        }
    }

    struct TokenUsageData: Codable {
        let input: Int
        let output: Int
    }

    struct CostData: Codable {
        let total: Double
        let input: Double
        let output: Double
    }

    struct DurationData: Codable {
        let totalSeconds: Double

        enum CodingKeys: String, CodingKey {
            case totalSeconds = "total_seconds"
        }
    }

    struct CodeImpactData: Codable {
        let linesAdded: Int
        let linesRemoved: Int

        enum CodingKeys: String, CodingKey {
            case linesAdded = "lines_added"
            case linesRemoved = "lines_removed"
        }
    }
}
