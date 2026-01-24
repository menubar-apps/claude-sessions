//
//  SessionRowView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI
import AppKit

struct SessionRowView: View {
    let session: ClaudeSession
    let sessionManager: SessionManager

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                HStack(spacing: 4) {
                    Text(session.status.emoji)
                        .accessibilityLabel(statusAccessibilityLabel)
                    
                    Text(session.displayName)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .help(session.cwd)
                }
                .layoutPriority(1)
                
                Spacer(minLength: 0)

                Menu {
                    Button("Copy Path") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(session.cwd, forType: .string)
                    }
                    .keyboardShortcut("c", modifiers: [.command])

                    Button("Open in Terminal") {
                        sessionManager.openInTerminal(session)
                    }
                    .keyboardShortcut("t", modifiers: [.command])

                    Button("Open in Finder") {
                        sessionManager.openInFinder(session)
                    }
                    .keyboardShortcut("f", modifiers: [.command])

                    Divider()

                    Button("Remove from View", role: .destructive) {
                        sessionManager.removeSession(session)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16))
                        .frame(width: 20, height: 20)
                }
                .menuStyle(.borderlessButton)
                .buttonStyle(.plain)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
                .accessibilityLabel("Session actions")
                .opacity(isHovered ? 1.0 : 0.5)
            }

            HStack(spacing: 8) {
                Text(session.model.displayName)
                Text("•")
                Text("\(FormatHelpers.formatNumber(session.tokenUsage.total)) tokens")
                Text("•")
                Text(FormatHelpers.formatCurrency(session.cost.total))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(metadataAccessibilityLabel)

            HStack(spacing: 6) {
                Text("Context: \(Int(session.contextWindow.usedPercentage))%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                ProgressView(value: session.contextWindow.usedPercentage, total: 100)
                    .progressViewStyle(.linear)
                    .tint(contextColor(for: session.contextWindow.usedPercentage))
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Context usage: \(Int(session.contextWindow.usedPercentage)) percent")
            .accessibilityValue(contextAccessibilityValue)

            Text("Duration: \(FormatHelpers.formatDuration(session.duration))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Session: \(session.displayName)")
    }

    private func contextColor(for percentage: Double) -> Color {
        if percentage > 80 {
            return .red
        } else if percentage > 50 {
            return .orange
        } else {
            return .green
        }
    }

    private var statusAccessibilityLabel: String {
        switch session.status {
        case .active: return "Active session"
        case .idle: return "Idle session"
        case .closed: return "Closed session"
        }
    }
    
    private var metadataAccessibilityLabel: String {
        "Model \(session.model.displayName), \(FormatHelpers.formatNumber(session.tokenUsage.total)) tokens, cost \(FormatHelpers.formatCurrency(session.cost.total))"
    }
    
    private var contextAccessibilityValue: String {
        let percentage = Int(session.contextWindow.usedPercentage)
        if percentage > 80 {
            return "High usage, \(percentage) percent"
        } else if percentage > 50 {
            return "Moderate usage, \(percentage) percent"
        } else {
            return "Low usage, \(percentage) percent"
        }
    }
}
