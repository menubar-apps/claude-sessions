//
//  SingleIconWithBadgeView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct SingleIconWithBadgeView: View {
    let sessions: [ClaudeSession]

    private var statusColor: Color {
        if sessions.isEmpty {
            return .gray
        } else if sessions.contains(where: { $0.status == .active }) {
            return .green
        } else if sessions.contains(where: { $0.status == .idle }) {
            return .yellow
        } else {
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .opacity(sessions.isEmpty ? 0.5 : 1.0)

            if !sessions.isEmpty {
                Text("\(sessions.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(statusColor)
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
