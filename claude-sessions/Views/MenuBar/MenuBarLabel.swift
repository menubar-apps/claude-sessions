//
//  MenuBarLabel.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct MenuBarLabel: View {
    let sessions: [ClaudeSession]
    let displayStyle: PreferencesManager.DisplayStyle

    var body: some View {
        Group {
            switch displayStyle {
            case .multipleCircles:
                MultipleCirclesView(sessions: sessions)
            case .singleIconWithBadge:
                SingleIconWithBadgeView(sessions: sessions)
            case .compactWithOverflow:
                CompactWithOverflowView(sessions: sessions)
            }
        }
        .padding(.horizontal, 4)
        .frame(minWidth: 20, minHeight: 18)
    }
}
