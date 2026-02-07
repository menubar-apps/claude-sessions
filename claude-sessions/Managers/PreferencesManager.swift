//
//  PreferencesManager.swift
//  claude-sessions
//
//  Created by Pavel Makhov on 2026-01-23.
//

import Foundation
import ServiceManagement

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    private let defaults = UserDefaults.standard

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: "launchAtLogin")
            setLaunchAtLogin(enabled: launchAtLogin)
        }
    }

    @Published var showClosedSessions: Bool {
        didSet {
            defaults.set(showClosedSessions, forKey: "showClosedSessions")
        }
    }

    @Published var refreshInterval: TimeInterval {
        didSet {
            defaults.set(refreshInterval, forKey: "refreshInterval")
        }
    }

    @Published var activityThreshold: TimeInterval {
        didSet {
            defaults.set(activityThreshold, forKey: "activityThreshold")
        }
    }

    @Published var closedThreshold: TimeInterval {
        didSet {
            defaults.set(closedThreshold, forKey: "closedThreshold")
        }
    }

    private init() {
        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        self.showClosedSessions = defaults.bool(forKey: "showClosedSessions")
        self.refreshInterval = defaults.double(forKey: "refreshInterval") != 0 ? defaults.double(forKey: "refreshInterval") : 2.0
        self.activityThreshold = defaults.double(forKey: "activityThreshold") != 0 ? defaults.double(forKey: "activityThreshold") : 3.0
        self.closedThreshold = defaults.double(forKey: "closedThreshold") != 0 ? defaults.double(forKey: "closedThreshold") : 3600.0
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            do {
                if enabled {
                    if service.status == .notRegistered {
                        try service.register()
                    }
                } else {
                    if service.status == .enabled {
                        try service.unregister()
                    }
                }
            } catch {
                print("Failed to \(enabled ? "register" : "unregister") launch at login: \(error)")
            }
        }
    }
}
