// CivilView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The tapped view (Tagbogen spec §2): civil time, zone and UTC offset, the
/// civil date, and today's sunrise and sunset as the clock would say them.
struct CivilView: View {
    let reading: Reading
    let now: Date

    var body: some View {
        GeometryReader { geometry in
            let s = min(geometry.size.width, geometry.size.height) / 450
            ZStack {
                Circle()
                    .fill(Palette.night.opacity(0.92))
                    .overlay(Circle().stroke(Palette.line.opacity(0.12), lineWidth: 1 * s))
                    .frame(width: 240 * s, height: 240 * s)
                VStack(spacing: 8 * s) {
                    caption(now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year()).uppercased(), s)
                    Text(Labels.clock(now))
                        .font(.system(size: 64 * s, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Palette.line)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(Labels.zone(now))
                        .font(.system(size: 15 * s, weight: .medium))
                        .foregroundStyle(Palette.secondary)
                    caption(Labels.horizon(reading.day), s)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func caption(_ text: String, _ s: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 13 * s, weight: .medium))
            .tracking(1 * s)
            .foregroundStyle(Palette.label)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
