// SettingsScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI
import WidgetKit

struct SettingsScreen: View {
    #if os(iOS)
    @Environment(SunLocation.self) private var location
    @State private var showsTour = false
    #endif

    var body: some View {
        #if os(watchOS)
        NavigationStack { form }
        #else
        form
            .sheet(isPresented: $showsTour) {
                TourView().environment(location)
            }
        #endif
    }

    private var form: some View {
        Form {
            Section {
                DialVariantChoice()
                PrecisionChoice()
            }
            #if os(iOS)
            Section {
                Button("About Bogenzeit") { showsTour = true }
                WatchFaceButton()
            }
            #endif
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
    }
}

/// Spans or Kiloseconds dial. The widgets show the same scale, so they are
/// redrawn when it changes.
struct DialVariantChoice: View {
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue

    var body: some View {
        Picker("Dial", selection: $variant) {
            ForEach(Scale.allCases) { Text($0.title).tag($0.rawValue) }
        }
        .onChange(of: variant) { WidgetCenter.shared.reloadAllTimelines() }
    }
}

struct PrecisionChoice: View {
    @AppStorage(Settings.precisionKey) private var precision = Precision.standard.rawValue

    var body: some View {
        Picker("Precision", selection: $precision) {
            ForEach(Precision.allCases) { Text($0.title).tag($0.rawValue) }
        }
    }
}
