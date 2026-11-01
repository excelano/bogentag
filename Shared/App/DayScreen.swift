// DayScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// Today in numbers: the two arcs and their span lengths, and the four
/// events of the day with the civil clock's time for each.
struct DayScreen: View {
    @Environment(SunLocation.self) private var location

    var body: some View {
        TimelineView(.everyMinute) { context in
            let now = Demo.now(context.date)
            if let place = location.place {
                let reading = Reading(at: now, latitude: place.latitude, longitude: place.longitude)
                DayView(reading: reading)
            } else {
                WaitingView(status: location.status)
            }
        }
    }
}

struct DayView: View {
    let reading: Reading

    var body: some View {
        let day = reading.day
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(Labels.day(day.day))
                    .font(.headline)
                    .foregroundStyle(Palette.line)
                if let tagbogen = day.tagbogen, let span = day.daySpan {
                    arc("DAY ARC", length: tagbogen, span: span)
                }
                if let night = ArcLengths.nachtbogen(of: reading), let span = day.halfNightEvening {
                    arc("NIGHT ARC", length: night, span: span / 100)
                }
                if let polar = day.polar {
                    Text(polar == .alwaysAbove ? "POLAR DAY" : "POLAR NIGHT")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Palette.label)
                }
                Divider()
                event("sunrise", number: "100", glyph: .noon, before: true, at: day.sunrise)
                event("noon", number: nil, glyph: .noon, before: false, at: day.noon)
                event("sunset", number: "100", glyph: .noon, before: false, at: day.sunset)
                event("midnight", number: nil, glyph: .midnight, before: false, at: day.midnightEnd)
            }
            .padding(.horizontal)
        }
    }

    private func arc(_ name: String, length: Double, span: Double) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(name)
                .font(.caption2.weight(.medium))
                .tracking(0.8)
                .foregroundStyle(Palette.label)
            HStack {
                Text(ArcLengths.ks(length))
                Spacer()
                Text("span \(Int(span.rounded(.down))) s")
                    .foregroundStyle(Palette.secondary)
            }
            .font(.body.monospacedDigit())
        }
    }

    /// One event: its name, its Bogenzeit notation, and the clock's time for it.
    private func event(_ label: String, number: String?, glyph: SolarAnchor, before: Bool, at instant: Date?) -> some View {
        HStack(alignment: .top) {
            Text(label)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    if before, let number { Text(number) }
                    AnchorGlyphView(anchor: glyph, radius: 7, lineWidth: 1.8)
                    if !before, let number { Text(number) }
                }
                .font(.body.weight(.medium).monospacedDigit())
                Text(instant.map(Labels.clock) ?? "none")
                    .font(.footnote)
                    .foregroundStyle(Palette.secondary)
                    .monospacedDigit()
            }
        }
        .font(.body)
    }
}
