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
    @Environment(\.openWindow) var openWindow
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

                Menu {
                    Button(action: {
                        openWindow(id: "about")
                    }) {
                        Label("About Claude Sessions", systemImage: "info.circle")
                    }

                    SettingsLink {
                        Label("Settings...", systemImage: "gearshape")
                    }
                    .keyboardShortcut(",", modifiers: [.command])

                    Divider()

                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Label("Quit Claude Sessions", systemImage: "power")
                    }
                    .keyboardShortcut("q", modifiers: [.command])
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .frame(minWidth: 32, minHeight: 32)
                .contentShape(Rectangle())
                .accessibilityLabel("More options")
                .help("Settings and more")
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
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 6)

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

            SummaryView(sessions: filteredSessions)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(width: 400)
    }
}
