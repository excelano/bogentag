// TagbogenPhoneWidgets.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI
import WidgetKit

@main
struct TagbogenPhoneWidgets: WidgetBundle {
    var body: some Widget {
        PhoneDialWidget()
        PhoneReadingWidget()
        PhoneQuarterWidget()
        PhoneGaugeWidget()
        PhoneHorizonWidget()
    }
}

/// The slot WidgetKit is rendering, in the shared views' terms.
private func slot(_ family: WidgetFamily) -> ComplicationSlot {
    switch family {
    case .accessoryRectangular: .rectangular
    case .accessoryInline: .inline
    default: .circular
    }
}

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

/// The dial on the Home Screen, small as the sky alone and medium with the
/// reading beside it, and on the Lock Screen.
struct PhoneDialWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Dial", provider: ArcProvider()) { entry in
            PhoneDialView(entry: entry)
                .containerBackground(Palette.night, for: .widget)
        }
        .configurationDisplayName("Dial")
        .description("The sky and the Sun on its arc.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct PhoneDialView: View {
    let entry: ArcEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        if let reading = entry.reading {
            switch family {
            case .systemSmall:
                MiniDial(model: DialModel(reading: reading, variant: .spans))
                    .padding(2)
            case .systemMedium:
                DialCard(reading: reading)
            default:
                DialComplication(reading: reading, slot: slot(family), fullColor: renderingMode == .fullColor)
            }
        } else {
            Empty(family: family)
        }
    }
}

struct PhoneReadingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Reading", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, slot in AnyView(ReadingComplication(reading: reading, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Reading")
        .description("Spans from solar noon or solar midnight, beside its glyph.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct PhoneQuarterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Quarter", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, slot in AnyView(QuarterComplication(reading: reading, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quarter")
        .description("The reading and the quarter of the day it falls in.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct PhoneGaugeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Gauge", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, slot in AnyView(GaugeComplication(reading: reading, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Gauge")
        .description("How far along its arc the Sun is, with the reading inside.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct PhoneHorizonWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Horizon", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, slot in AnyView(HorizonComplication(reading: reading, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next")
        .description("What comes next on the arc and how many spans away it is.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

/// A Lock Screen widget built from one of the shared complication views.
struct PhoneSlotView: View {
    let entry: ArcEntry
    let make: (Reading, ComplicationSlot) -> AnyView
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            make(reading, slot(family))
        } else {
            Empty(family: family)
        }
    }
}
