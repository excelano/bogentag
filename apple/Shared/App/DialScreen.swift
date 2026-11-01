// DialScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// One dial, read for the place in use once a second, and the civil view a
/// tap puts over it (Tagbogen spec §2).
struct DialScreen: View {
    let variant: DialVariant
    @Environment(SunLocation.self) private var location
    @State private var showsCivil = Demo.civil

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = Demo.now(context.date)
            if let place = location.place {
                let reading = Reading(at: now, latitude: place.latitude, longitude: place.longitude)
                ZStack {
                    DialView(model: DialModel(reading: reading, variant: variant), showsReadout: !showsCivil)
                        .opacity(showsCivil ? 0.35 : 1)
                    if showsCivil {
                        CivilView(reading: reading, now: now)
                    }
                }
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { showsCivil.toggle() }
                .accessibilityLabel(showsCivil ? Labels.clock(now) : reading.timestamp)
            } else {
                WaitingView(status: location.status)
            }
        }
    }
}

/// What the dial shows until there is a place to compute it for.
struct WaitingView: View {
    let status: SunLocation.Status

    var body: some View {
        VStack(spacing: 12) {
            AnchorGlyphView(anchor: .noon, radius: 18, lineWidth: 3.5)
            Text(status == .denied
                 ? "Tagbogen needs your location to find the Sun's arc. Allow Location for Tagbogen in Settings."
                 : "Finding the Sun's arc for where you are.")
                .font(.footnote)
                .foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
