//
//  StatusMenuView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI
import AppKit

struct StatusMenuView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Claude Sessions")
                    .font(.headline)
                Spacer()
                Button(action: {
                    sessionManager.refreshSessions()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityLabel("Refresh sessions")
                .help("Refresh session data")
            }
            .padding()

            Divider()

            if sessionManager.sessions.isEmpty {
                EmptyStateView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sessionManager.sessions) { session in
                            SessionRowView(session: session, sessionManager: sessionManager)
                        }
                    }
                    .padding()
                }
                .frame(minHeight: 400, maxHeight: 800)
            }

            Divider()

            SummaryView(sessions: sessionManager.sessions)
                .padding()

            Divider()

            VStack(spacing: 4) {
                SettingsLink {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Preferences...")
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, minHeight: 32)
                .keyboardShortcut(",", modifiers: [.command])
                .accessibilityLabel("Open preferences")

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("Quit")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, minHeight: 32)
                .keyboardShortcut("q", modifiers: [.command])
                .accessibilityLabel("Quit application")
            }
            .padding()
        }
        .frame(width: 400)
    }
}
