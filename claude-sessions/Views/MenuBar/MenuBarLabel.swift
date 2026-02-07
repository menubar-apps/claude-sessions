//
//  MenuBarLabel.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import SwiftUI

struct MenuBarLabel: View {
    let sessions: [ClaudeSession]

    var body: some View {
        SingleIconWithBadgeView(sessions: sessions)
            .padding(.horizontal, 2)
            .frame(maxHeight: 16)
    }
}
