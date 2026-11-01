// RootView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

/// The dials, and the location they need while the app is on screen.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SunLocation.self) private var location
    @State private var variant: DialVariant = Demo.dial ?? .fixedTime

    var body: some View {
        content
            .background(Palette.night)
            .onChange(of: scenePhase, initial: true) {
                if scenePhase == .active {
                    location.start()
                } else {
                    location.stop()
                }
            }
    }

    #if os(watchOS)
    /// One page per dial variant, turned with the Digital Crown.
    private var content: some View {
        TabView(selection: $variant) {
            ForEach(DialVariant.allCases) { variant in
                DialScreen(variant: variant).tag(variant)
            }
        }
        .tabViewStyle(.verticalPage)
        .ignoresSafeArea()
    }
    #else
    private var content: some View {
        VStack {
            DialScreen(variant: variant)
                .padding()
            Picker("Dial", selection: $variant) {
                ForEach(DialVariant.allCases) { variant in
                    Text(variant.title).tag(variant)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .bottom])
        }
    }
    #endif
}
