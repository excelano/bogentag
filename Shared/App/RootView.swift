// RootView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The pages, and the location they need while the app is on screen.
struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing

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
        case timer
        case stopwatch
        case day
        case settings
    }

    @State private var page: Page = Demo.page.flatMap(Page.init) ?? .dial

    /// Pages turned with the Digital Crown. The dials take the whole screen,
    /// under the clock watchOS draws in the corner of every app.
    private var content: some View {
        TabView(selection: $page) {
            DialScreen().tag(Page.dial)
            TimerScreen().tag(Page.timer)
            StopwatchScreen().tag(Page.stopwatch)
            DayScreen().tag(Page.day)
            SettingsScreen().tag(Page.settings)
        }
        .tabViewStyle(.verticalPage)
    }
    #else
    @AppStorage("tourSeen") private var tourSeen = false
    @State private var showsTour = false
    @State private var panel: Panel?

    enum Panel: String, Identifiable {
        case timer
        case stopwatch
        case settings

        var id: String { rawValue }
    }

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

    /// The dial above its buttons, or beside them in a window wider than tall.
    private var phone: some View {
        NavigationStack {
            dialAndButtons
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { panel = .settings } label: { Image(systemName: "gearshape") }
                            .accessibilityLabel("Settings")
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .background(Palette.night)
        }
        .tint(Palette.sun)
    }

    private var dialAndButtons: some View {
        GeometryReader { geometry in
            let layout = geometry.size.width > geometry.size.height
                ? AnyLayout(HStackLayout(spacing: 24))
                : AnyLayout(VStackLayout(spacing: 12))
            layout {
                DialScreen()
                    .padding()
                HStack(spacing: 6) {
                    Button("Timer") { panel = .timer }
                        .buttonStyle(ChoiceButtonStyle(selected: timing.timer != nil))
                    Button("Stopwatch") { panel = .stopwatch }
                        .buttonStyle(ChoiceButtonStyle(selected: timing.stopwatch != nil))
                }
                .padding(.bottom)
                .frame(maxWidth: 480)
            }
        }
        .padding(.horizontal)
        .onAppear {
            if (!tourSeen && !Demo.active) || Demo.page == "tour" { showsTour = true }
            panel = Demo.page.flatMap(Panel.init)
        }
        .sheet(isPresented: $showsTour, onDismiss: { tourSeen = true }) {
            TourView().environment(location)
        }
        .sheet(item: $panel) { panel in
            NavigationStack {
                Group {
                    switch panel {
                    case .timer: TimerScreen()
                    case .stopwatch: StopwatchScreen()
                    case .settings: SettingsScreen()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { self.panel = nil }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .background(Palette.bezel)
            }
            .tint(Palette.sun)
            .environment(location)
            .environment(timing)
            .presentationDetents([.medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationBackground(Palette.bezel)
            .presentationDragIndicator(.visible)
        }
    }
    #endif
}
