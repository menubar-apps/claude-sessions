//
//  SessionStatus.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

enum SessionStatus {
    case active   // Green
    case idle     // Yellow
    case closed   // Gray

    var color: Color {
        switch self {
        case .active: return .green
        case .idle: return .yellow
        case .closed: return .gray
        }
    }

    var emoji: String {
        switch self {
        case .active: return "🟢"
        case .idle: return "🟡"
        case .closed: return "⚪"
        }
    }
    
    var priority: Int {
        switch self {
        case .active: return 0
        case .idle: return 1
        case .closed: return 2
        }
    }
}
