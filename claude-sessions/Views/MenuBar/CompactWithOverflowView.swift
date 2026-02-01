//
//  CompactWithOverflowView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct CompactWithOverflowView: View {
    let sessions: [ClaudeSession]
    let maxCircles = 3

    var body: some View {
        HStack(spacing: 3) {
            if sessions.isEmpty {
                Image(systemName: "circle.dotted")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                ForEach(Array(sessions.prefix(maxCircles).enumerated()), id: \.offset) { index, session in
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(session.status.color)
                        .accessibilityLabel("\(session.status.emoji) session")
                }

                if sessions.count > maxCircles {
                    Text("+\(sessions.count - maxCircles)")
                        .font(.system(size: 11, weight: .medium))
                        .accessibilityLabel("Plus \(sessions.count - maxCircles) more sessions")
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
        return "\(sessions.count) total sessions: \(active) active, \(idle) idle, \(closed) closed"
    }
}
