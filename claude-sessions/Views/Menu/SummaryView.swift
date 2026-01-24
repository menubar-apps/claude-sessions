//
//  SummaryView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct SummaryView: View {
    let sessions: [ClaudeSession]

    private var totalCost: Double {
        sessions.reduce(0) { $0 + $1.cost.total }
    }

    private var activeSessions: Int {
        sessions.filter { $0.status == .active }.count
    }

    private var idleSessions: Int {
        sessions.filter { $0.status == .idle }.count
    }

    private var closedSessions: Int {
        sessions.filter { $0.status == .closed }.count
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Label("Total Cost", systemImage: "dollarsign.circle")
                    .labelStyle(.titleOnly)
                Spacer()
                Text(FormatHelpers.formatCurrency(totalCost))
                    .fontWeight(.semibold)
            }
            .font(.caption)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Total cost: \(FormatHelpers.formatCurrency(totalCost))")

            HStack {
                Label("Session Summary", systemImage: "chart.bar")
                    .labelStyle(.titleOnly)
                Text("Active: \(activeSessions) • Idle: \(idleSessions) • Closed: \(closedSessions)")
                Spacer()
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(activeSessions) active sessions, \(idleSessions) idle sessions, \(closedSessions) closed sessions")
        }
    }
}
