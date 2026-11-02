// ArcProvider.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import WidgetKit

struct ArcEntry: TimelineEntry {
    let date: Date
    let reading: Reading?
    /// The scale chosen in the app, which every complication shows.
    var variant = Settings.dialVariant
}

/// Readings for the place the watch app left in the App Group, one entry per
/// change of the displayed span or kilosecond, so a complication steps on the
/// boundary like the dial does.
struct ArcProvider: TimelineProvider {
    private static let sample = Reading(at: Date(rfc3339: "2026-11-01T17:08:00Z")!, latitude: 29.76, longitude: -95.37)

    func placeholder(in context: Context) -> ArcEntry {
        ArcEntry(date: .now, reading: Self.sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (ArcEntry) -> Void) {
        let now = Date.now
        if let place = AppGroup.loadPlace() {
            completion(ArcEntry(date: now, reading: Reading(at: now, latitude: place.latitude, longitude: place.longitude)))
        } else {
            completion(ArcEntry(date: now, reading: context.isPreview ? Self.sample : nil))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ArcEntry>) -> Void) {
        guard let place = AppGroup.loadPlace() else {
            completion(Timeline(entries: [ArcEntry(date: .now, reading: nil)], policy: .never))
            return
        }
        var entries: [ArcEntry] = []
        var t = Date.now
        for _ in 0..<48 {
            let reading = Reading(at: t, latitude: place.latitude, longitude: place.longitude)
            entries.append(ArcEntry(date: t, reading: reading))
            t = Self.nextChange(after: reading)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// The first instant after the reading at which its displayed span or
    /// one-decimal kilosecond offset changes.
    static func nextChange(after reading: Reading) -> Date {
        let intoStep = reading.offset - (reading.offset / 100).rounded(.down) * 100
        var ahead = 100 - intoStep
        if let span = reading.span, let spanSeconds = reading.spanSeconds {
            ahead = min(ahead, (span.rounded(.down) + 1 - span) * spanSeconds)
        }
        return reading.instant.addingTimeInterval(max(1, ahead) + 0.01)
    }
}

