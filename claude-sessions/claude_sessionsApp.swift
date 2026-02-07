//
//  claude_sessionsApp.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

@main
struct claude_sessionsApp: App {
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var preferencesManager = PreferencesManager.shared

    var body: some Scene {
        MenuBarExtra {
            StatusMenuView()
                .environmentObject(sessionManager)
                .environmentObject(preferencesManager)
        } label: {
            MenuBarLabel(sessions: sessionManager.sessions)
        }
        .menuBarExtraStyle(.window)

        Settings {
            PreferencesView()
                .environmentObject(preferencesManager)
        }

        Window("About Claude Sessions", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
