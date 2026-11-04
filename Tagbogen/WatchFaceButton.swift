// WatchFaceButton.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import ClockKit
import SwiftUI
import UIKit

/// Offers the bundled `Tagbogen.watchface`, an Apple face preset carrying the
/// Tagbogen complications, for adding to the paired watch. The button exists
/// only on an iPhone, the one device a watch pairs with, and only when the
/// file is in the bundle. Apple accepts a face only when its
/// complications come from an app with an App Store id, so the file is made
/// from a TestFlight or App Store build and never from a development one.
struct WatchFaceButton: View {
    private static let face = Bundle.main.url(forResource: "Tagbogen", withExtension: "watchface")

    @State private var failure: String?

    var body: some View {
        if let face = Self.face, UIDevice.current.userInterfaceIdiom == .phone {
            Button("Add the Tagbogen watch face") {
                CLKWatchFaceLibrary().addWatchFace(at: face) { error in
                    let message = error?.localizedDescription
                    Task { @MainActor in failure = message }
                }
            }
            .buttonStyle(.bordered)
            .alert("The face could not be added", isPresented: Binding(get: { failure != nil }, set: { if !$0 { failure = nil } })) {
                Button("OK") { failure = nil }
            } message: {
                Text(failure ?? "")
            }
        }
    }
}
