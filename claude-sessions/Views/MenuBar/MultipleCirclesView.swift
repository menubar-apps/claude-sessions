//
//  MultipleCirclesView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct MultipleCirclesView: View {
    let sessions: [ClaudeSession]
    let maxCircles = 4

    var body: some View {
        HStack(spacing: 4) {
            if sessions.isEmpty {
                Image(systemName: "circle.dotted")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .accessibilityLabel("No active sessions")
            } else {
                ForEach(Array(sessions.prefix(maxCircles).enumerated()), id: \.offset) { index, session in
                    Circle()
                        .fill(session.status.color)
                        .frame(width: 8, height: 8)
                        .accessibilityLabel("\(session.status.emoji) session")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private var accessibilityLabel: String {
        if sessions.isEmpty {
            return "No Claude sessions"
        }
        let active = sessions.filter { $0.status == .active }.count
        let idle = sessions.filter { $0.status == .idle }.count
        let closed = sessions.filter { $0.status == .closed }.count
        return "\(active) active, \(idle) idle, \(closed) closed sessions"
    }
}
