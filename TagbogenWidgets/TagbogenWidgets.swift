// TagbogenWidgets.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI
import WidgetKit

@main
struct TagbogenWidgets: WidgetBundle {
    var body: some Widget {
        ReadingWidget()
        QuarterWidget()
        DialWidget()
        GaugeWidget()
        HorizonWidget()
    }
}

struct ArcEntry: TimelineEntry {
    let date: Date
    let reading: Reading?
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

/// The slot WidgetKit is rendering, in the shared views' terms.
private func slot(_ family: WidgetFamily) -> ComplicationSlot {
    switch family {
    case .accessoryCorner: .corner
    case .accessoryRectangular: .rectangular
    case .accessoryInline: .inline
    default: .circular
    }
}

/// What a slot shows before the app has a place: the glyph, or a sentence inline.
private struct Empty: View {
    let family: WidgetFamily

    var body: some View {
        if family == .accessoryInline {
            Text("Open Tagbogen to find the Sun")
        } else {
            AnchorGlyphView(anchor: .noon, radius: 10, lineWidth: 2.4, color: .primary)
        }
    }
}

struct ReadingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Reading", provider: ArcProvider()) { entry in
            ReadingWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Reading")
        .description("Spans from solar noon or solar midnight, beside its glyph.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct ReadingWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner {
                ReadingComplication(reading: reading, slot: .corner)
                    .widgetLabel(Complications.plain(reading))
            } else {
                ReadingComplication(reading: reading, slot: slot(family))
            }
        } else {
            Empty(family: family)
        }
    }
}

struct QuarterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Quarter", provider: ArcProvider()) { entry in
            QuarterWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quarter")
        .description("The reading and the quarter of the day it falls in.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct QuarterWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner {
                QuarterComplication(reading: reading, slot: .corner)
                    .widgetLabel("\(Complications.plain(reading)) \(Complications.quarter(reading))")
            } else {
                QuarterComplication(reading: reading, slot: slot(family))
            }
        } else {
            Empty(family: family)
        }
    }
}

struct DialWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Dial", provider: ArcProvider()) { entry in
            DialWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Dial")
        .description("The sky and the Sun on its arc, without words.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular])
    }
}

struct DialWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner {
                DialComplication(reading: reading, slot: .corner, fullColor: renderingMode == .fullColor)
                    .widgetLabel(Complications.plain(reading))
            } else {
                DialComplication(reading: reading, slot: slot(family), fullColor: renderingMode == .fullColor)
            }
        } else {
            Empty(family: family)
        }
    }
}

struct GaugeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Gauge", provider: ArcProvider()) { entry in
            GaugeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Gauge")
        .description("How far along its arc the Sun is, with the reading inside.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}

struct GaugeWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner, let progress = Complications.progress(reading) {
                GaugeComplication(reading: reading, slot: .corner)
                    .widgetLabel {
                        Gauge(value: progress, in: 0...1) { EmptyView() }
                    }
            } else {
                GaugeComplication(reading: reading, slot: slot(family))
            }
        } else {
            Empty(family: family)
        }
    }
}

struct HorizonWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Horizon", provider: ArcProvider()) { entry in
            HorizonWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next")
        .description("What comes next on the arc and how many spans away it is.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct HorizonWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner, let next = NextEvent(reading) {
                HorizonComplication(reading: reading, slot: .corner)
                    .widgetLabel(next.wholeSpans.map { "\(next.name) in \($0)" } ?? "\(next.name) in \(next.ks)")
            } else {
                HorizonComplication(reading: reading, slot: slot(family))
            }
        } else {
            Empty(family: family)
        }
    }
}
