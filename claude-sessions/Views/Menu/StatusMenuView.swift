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
    @State private var searchText = ""

    private var filteredSessions: [ClaudeSession] {
        if searchText.isEmpty {
            return sessionManager.sessions
        } else {
            return sessionManager.sessions.filter { session in
                session.folderName.localizedCaseInsensitiveContains(searchText) ||
                session.displayName.localizedCaseInsensitiveContains(searchText) ||
                session.cwd.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Claude Sessions")
                    .font(.headline)
                Spacer()

                SettingsLink {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .frame(minWidth: 32, minHeight: 32)
                .contentShape(Rectangle())
                .keyboardShortcut(",", modifiers: [.command])
                .accessibilityLabel("Open preferences")
                .help("Preferences")

                Button(action: {
                    sessionManager.refreshSessions()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .frame(minWidth: 32, minHeight: 32)
                .contentShape(Rectangle())
                .keyboardShortcut("r", modifiers: [.command])
                .accessibilityLabel("Refresh sessions")
                .help("Refresh session data")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if !sessionManager.sessions.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))

                    TextField("Search sessions...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))

                Divider()
            }

            if sessionManager.sessions.isEmpty {
                EmptyStateView()
            } else if filteredSessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text("No sessions found")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Try a different search term")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSessions) { session in
                            SessionRowView(session: session, sessionManager: sessionManager)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 600)
            }

            Divider()

            HStack(alignment: .top, spacing: 12) {
                SummaryView(sessions: filteredSessions)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
                .keyboardShortcut("q", modifiers: [.command])
                .accessibilityLabel("Quit application")
                .help("Quit")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 400)
    }
}
