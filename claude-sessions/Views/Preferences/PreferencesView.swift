//
//  PreferencesView.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var preferencesManager: PreferencesManager

    var body: some View {
        Form {
            Section {
                Toggle("Show closed sessions in menu", isOn: $preferencesManager.showClosedSessions)
                    .help("Display sessions that have been inactive for over an hour")
            } header: {
                Text("Display")
            }

            Section {
                Toggle("Launch at login", isOn: $preferencesManager.launchAtLogin)
                    .help("Automatically start the app when you log in")

                LabeledContent("Refresh interval:") {
                    HStack(spacing: 4) {
                        TextField("", value: $preferencesManager.refreshInterval, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                        Text("seconds")
                            .foregroundStyle(.secondary)
                    }
                }
                .help("How often to check for session updates (1-60 seconds)")

                LabeledContent("Activity threshold:") {
                    HStack(spacing: 4) {
                        TextField("", value: $preferencesManager.activityThreshold, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                        Text("seconds")
                            .foregroundStyle(.secondary)
                    }
                }
                .help("Time before a session is marked as idle (1-60 seconds)")

                LabeledContent("Closed threshold:") {
                    HStack(spacing: 4) {
                        TextField("", value: $preferencesManager.closedThreshold, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.trailing)
                        Text("minutes")
                            .foregroundStyle(.secondary)
                    }
                }
                .help("Time before a session is marked as closed (1-1440 minutes)")
            } header: {
                Text("Behavior")
            } footer: {
                Text("Lower refresh intervals provide more real-time updates but use more resources.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Version:") {
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Monitor Claude Code sessions from your menubar")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Link("View on GitHub", destination: URL(string: "https://github.com/yourusername/claude-session-monitor-macos")!)
                        .font(.caption)
                }
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 500, minHeight: 450)
        .fixedSize()
    }
}
