// TagbogenWidgets.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
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
            GlyphView(.noon, radius: 10, lineWidth: 2.4, color: .primary)
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
        .description("The reading in the scale chosen in the app, beside its glyph.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct ReadingWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner {
                ReadingComplication(reading: reading, variant: entry.variant, slot: .corner)
                    .widgetLabel(Complications.plain(reading, entry.variant))
            } else {
                ReadingComplication(reading: reading, variant: entry.variant, slot: slot(family))
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
                QuarterComplication(reading: reading, variant: entry.variant, slot: .corner)
                    .widgetLabel("\(Complications.plain(reading, entry.variant)) \(Complications.quarter(reading))")
            } else {
                QuarterComplication(reading: reading, variant: entry.variant, slot: slot(family))
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
                DialComplication(reading: reading, variant: entry.variant, slot: .corner, fullColor: renderingMode == .fullColor)
                    .widgetLabel(Complications.plain(reading, entry.variant))
            } else {
                DialComplication(reading: reading, variant: entry.variant, slot: slot(family), fullColor: renderingMode == .fullColor)
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
                GaugeComplication(reading: reading, variant: entry.variant, slot: .corner)
                    .widgetLabel {
                        Gauge(value: progress, in: 0...1) { EmptyView() }
                    }
            } else {
                GaugeComplication(reading: reading, variant: entry.variant, slot: slot(family))
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
        .description("What comes next on the arc and how far away it is.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
    }
}

struct HorizonWidgetView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            if family == .accessoryCorner, let next = NextEvent(reading) {
                HorizonComplication(reading: reading, variant: entry.variant, slot: .corner)
                    .widgetLabel(next.sentence(entry.variant))
            } else {
                HorizonComplication(reading: reading, variant: entry.variant, slot: slot(family))
            }
        } else {
            Empty(family: family)
        }
    }
}
