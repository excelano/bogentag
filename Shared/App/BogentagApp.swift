// BogentagApp.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

@main
struct BogentagApp: App {
    @State private var location = SunLocation()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(location)
                .preferredColorScheme(.dark)
        }
    }
}
