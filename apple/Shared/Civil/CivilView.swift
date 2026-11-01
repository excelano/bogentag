// CivilView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The tapped view (Tagbogen spec §2): UTC, the reference every reading is
/// computed from, large; the local clock with its zone and offset under it;
/// the civil date; and today's sunrise and sunset as the local clock says them.
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
                    .frame(width: max(240 * s, 112), height: max(240 * s, 112))
                VStack(spacing: 8 * s) {
                    caption(now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year()).uppercased(), s)
                    HStack(alignment: .firstTextBaseline, spacing: 6 * s) {
                        Text(Labels.utcClock(now))
                            .font(.system(size: 64 * s, weight: .semibold).monospacedDigit())
                            .foregroundStyle(Palette.line)
                        Text("UTC")
                            .font(.system(size: max(15 * s, 13), weight: .medium))
                            .foregroundStyle(Palette.secondary)
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    Text(Labels.localClock(now))
                        .font(.system(size: max(15 * s, 13), weight: .medium))
                        .foregroundStyle(Palette.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    caption(Labels.horizon(reading.day), s)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func caption(_ text: String, _ s: CGFloat) -> some View {
        Text(text)
            .font(.system(size: max(13 * s, 11), weight: .medium))
            .tracking(max(1 * s, 0.6))
            .foregroundStyle(Palette.label)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
