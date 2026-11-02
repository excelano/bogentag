// RootView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The pages, and the location they need while the app is on screen.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SunLocation.self) private var location

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
    enum Page: String {
        case dial
        case day
        case settings
    }

    @State private var page: Page = Demo.page.flatMap(Page.init) ?? .dial

    /// Pages turned with the Digital Crown. The dials take the whole screen,
    /// under the clock watchOS draws in the corner of every app.
    private var content: some View {
        TabView(selection: $page) {
            DialScreen().tag(Page.dial)
            DayScreen().tag(Page.day)
            SettingsScreen().tag(Page.settings)
        }
        .tabViewStyle(.verticalPage)
    }
    #else
    @AppStorage("tourSeen") private var tourSeen = false
    @State private var showsTour = false

    @ViewBuilder
    private var content: some View {
        #if DEBUG
        if Demo.page == "gallery" {
            GalleryView(reading: Reading(at: Demo.now(.now), latitude: Demo.place.latitude, longitude: Demo.place.longitude))
        } else {
            phone
        }
        #else
        phone
        #endif
    }

    private var phone: some View {
        VStack(spacing: 12) {
            DialScreen()
                .padding()
            DialVariantChoice()
            OffsetDecimalsChoice()
            Button("About Bogenzeit") { showsTour = true }
                .buttonStyle(ChoiceButtonStyle(selected: false))
            WatchFaceButton()
                .padding(.bottom)
        }
        .padding(.horizontal)
        .onAppear {
            if (!tourSeen && !Demo.active) || Demo.page == "tour" { showsTour = true }
        }
        .sheet(isPresented: $showsTour, onDismiss: { tourSeen = true }) {
            TourView().environment(location)
        }
    }
    #endif
}
