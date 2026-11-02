// TagbogenWidgets.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI
import WidgetKit

@main
struct TagbogenWidgets: WidgetBundle {
    var body: some Widget {
        ArcWidget()
    }
}

struct ArcEntry: TimelineEntry {
    let date: Date
    let reading: Reading?
}

/// Readings for the place the watch app left in the App Group, one entry per
/// change of the displayed span or kilosecond, so the complication steps on
/// the boundary like the dial does.
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

struct ArcWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Arc", provider: ArcProvider()) { entry in
            ArcWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Tagbogen")
        .description("Where the Sun is on its arc: spans from solar noon or solar midnight, and the quarter.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct ArcWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            switch family {
            case .accessoryRectangular:
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .center) {
                        position(reading, size: 28, glyph: 9, line: 2.2)
                        Spacer(minLength: 8)
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(reading.quarter?.name ?? (reading.polar == .alwaysAbove ? "Polar day" : "Polar night"))
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            if reading.span != nil {
                                Text("[\(ksText(reading))]")
                                    .font(.footnote.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if let progress = progress(reading) {
                        Gauge(value: progress, in: 0...1) { EmptyView() }
                            .gaugeStyle(.accessoryLinear)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            case .accessoryInline:
                Text(inlineText(reading))
            case .accessoryCorner:
                AnchorGlyphView(anchor: reading.anchor, radius: 10, lineWidth: 2.4, color: .primary)
                    .widgetLabel(inlineText(reading))
            default:
                if let progress = progress(reading) {
                    Gauge(value: progress, in: 0...1) {
                        AnchorGlyphView(anchor: reading.anchor, radius: 4, lineWidth: 1.2, color: .primary)
                    } currentValueLabel: {
                        Text(reading.displaySpan.map { "\(abs($0))" } ?? "")
                            .font(.system(size: 18, weight: .semibold).monospacedDigit())
                    }
                    .gaugeStyle(.accessoryCircular)
                } else {
                    ZStack {
                        AccessoryWidgetBackground()
                        VStack(spacing: 1) {
                            AnchorGlyphView(anchor: reading.anchor, radius: 6, lineWidth: 1.6, color: .primary)
                            Text(ksText(reading))
                                .font(.caption2.monospacedDigit())
                        }
                    }
                }
            }
        } else {
            switch family {
            case .accessoryInline:
                Text("Open Tagbogen to find the Sun")
            default:
                AnchorGlyphView(anchor: .noon, radius: 10, lineWidth: 2.4, color: .primary)
            }
        }
    }

    /// The span with its glyph on its side of the number, as vector shapes.
    private func position(_ reading: Reading, size: CGFloat, glyph: CGFloat, line: CGFloat) -> some View {
        HStack(spacing: 4) {
            let glyphView = AnchorGlyphView(anchor: reading.anchor, radius: glyph, lineWidth: line, color: .primary)
            let number = Text(reading.displaySpan.map { "\(abs($0))" } ?? ksText(reading))
                .font(.system(size: size, weight: .semibold).monospacedDigit())
            let before = (reading.displaySpan ?? reading.displayOffsetSteps) < 0
            let at = (reading.displaySpan ?? reading.displayOffsetSteps) == 0
            if before {
                number
                glyphView
            } else if at {
                glyphView
            } else {
                glyphView
                number
            }
        }
    }

    /// Text-only families cannot draw the glyph, so they carry the Unicode
    /// characters, the plain-text form the spec accepts (§3.1).
    private func inlineText(_ reading: Reading) -> String {
        let form = reading.spanForm ?? reading.offsetForm
        return reading.quarter.map { "\(form) \($0.name)" } ?? form
    }

    /// One decimal, floored: a complication cannot step every ten seconds,
    /// which the spec allows (§5.2).
    private func ksText(_ reading: Reading) -> String {
        let tenths = abs(Int((reading.offset / 100).rounded(.down)))
        return "\(tenths / 10).\(tenths % 10) ks"
    }

    /// How far along its arc the Sun is, sunrise to sunset or sunset to sunrise.
    private func progress(_ reading: Reading) -> Double? {
        reading.span.map { ($0 + 100) / 200 }
    }
}
