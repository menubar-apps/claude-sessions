//
//  AboutView.swift
//  claude-sessions
//
//  Created by Claude on 2026-02-07.
//

import SwiftUI

struct AboutView: View {
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    @Environment(\.openURL) var openURL

    var body: some View {
        VStack(spacing: 12) {
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 128, height: 128)
            }

            Text("Claude Sessions")
                .font(.title)
                .fontWeight(.semibold)

            Text("version \(currentVersion)")
                .font(.footnote)
                .foregroundStyle(.tertiary)


            Divider()
                .padding(.vertical, 4)

            Button(action: {
                if let url = URL(string: "https://github.com/yourusername/claude-sessions") {
                    openURL(url)
                }
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Home Page")
                }
                .frame(maxWidth: 160)
            }
            .buttonStyle(.borderless)
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1)
            )

            Button(action: {
                if let url = URL(string: "https://github.com/yourusername/claude-sessions/issues/new?template=feature_request.md") {
                    openURL(url)
                }
            }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Request a Feature")
                }
                .frame(maxWidth: 160)
            }
            .buttonStyle(.borderless)
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1)
            )

            Button(action: {
                if let url = URL(string: "https://github.com/yourusername/claude-sessions/issues/new?template=bug_report.md") {
                    openURL(url)
                }
            }) {
                HStack {
                    Image(systemName: "ladybug.fill")
                    Text("Report a Bug")
                }
                .frame(maxWidth: 160)
            }
            .buttonStyle(.borderless)
            .padding(4)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1)
            )
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    AboutView()
        .frame(height: 400)
}
