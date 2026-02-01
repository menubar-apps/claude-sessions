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
    let cost: CostData
    let statuslineUpdateTime: Int64

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case cwd
        case model
        case contextWindow = "context_window"
        case cost
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
        let totalInputTokens: Int
        let totalOutputTokens: Int
        let contextWindowSize: Int
        let usedPercentage: Int?

        enum CodingKeys: String, CodingKey {
            case totalInputTokens = "total_input_tokens"
            case totalOutputTokens = "total_output_tokens"
            case contextWindowSize = "context_window_size"
            case usedPercentage = "used_percentage"
        }
    }

    struct CostData: Codable {
        let totalCostUsd: Double
        let totalDurationMs: Int64
        let totalLinesAdded: Int
        let totalLinesRemoved: Int

        enum CodingKeys: String, CodingKey {
            case totalCostUsd = "total_cost_usd"
            case totalDurationMs = "total_duration_ms"
            case totalLinesAdded = "total_lines_added"
            case totalLinesRemoved = "total_lines_removed"
        }
    }
}
