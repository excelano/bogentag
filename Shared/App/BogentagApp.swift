// BogentagApp.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI
import UserNotifications

@main
struct BogentagApp: App {
    @State private var location = SunLocation()
    @State private var timing = Timing()

    init() {
        UNUserNotificationCenter.current().delegate = TimerAlert.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(location)
                .environment(timing)
                .preferredColorScheme(.dark)
        }
    }
}
