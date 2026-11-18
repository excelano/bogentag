// BogentagPhoneWidgets.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
import SwiftUI
import WidgetKit

@main
struct BogentagPhoneWidgets: WidgetBundle {
    var body: some Widget {
        PhoneDialWidget()
        PhoneReadingWidget()
        PhoneEighthWidget()
        PhoneGaugeWidget()
        PhoneHorizonWidget()
        TimerActivityWidget()
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
            Text("Open Bogentag to find the Sun")
        } else {
            GlyphView(.noon, radius: 10, lineWidth: 2.4, color: .primary)
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular])
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
                MiniDial(model: DialModel(reading: reading, variant: entry.variant))
                    .padding(2)
            case .systemMedium:
                DialCard(reading: reading, variant: entry.variant)
            case .systemLarge:
                DialView(model: DialModel(reading: reading, variant: entry.variant), precision: .low)
            default:
                DialComplication(reading: reading, variant: entry.variant, slot: slot(family), fullColor: renderingMode == .fullColor)
            }
        } else {
            Empty(family: family)
        }
    }
}

struct PhoneReadingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Reading", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, variant, slot in AnyView(ReadingComplication(reading: reading, variant: variant, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Reading")
        .description("The reading in the scale chosen in the app, beside its glyph.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct PhoneEighthWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Eighth", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, variant, slot in AnyView(EighthComplication(reading: reading, variant: variant, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Eighth")
        .description("The reading and the eighth of the day it falls in.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct PhoneGaugeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Gauge", provider: ArcProvider()) { entry in
            PhoneSlotView(entry: entry) { reading, variant, slot in AnyView(GaugeComplication(reading: reading, variant: variant, slot: slot)) }
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
            PhoneSlotView(entry: entry) { reading, variant, slot in AnyView(HorizonComplication(reading: reading, variant: variant, slot: slot)) }
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next")
        .description("What comes next on the arc and how far away it is.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

/// A Lock Screen widget built from one of the shared complication views.
struct PhoneSlotView: View {
    let entry: ArcEntry
    let make: (Reading, Scale, ComplicationSlot) -> AnyView
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let reading = entry.reading {
            make(reading, entry.variant, slot(family))
        } else {
            Empty(family: family)
        }
    }
}

struct TimerActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAttributes.self) { context in
            TimerActivityView(attributes: context.attributes, state: context.state, done: context.isStale)
                .activityBackgroundTint(Palette.night)
                .activitySystemActionForegroundColor(Palette.line)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        TimerActivityCaption(context.attributes.status(context.state, done: context.isStale))
                        TimerActivityCaption(AmountText.set(context.attributes.amount, context.attributes.unit).uppercased())
                    }
                    .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        TimerActivityCaption(context.attributes.headlineLabel(context.state, done: context.isStale))
                        TimerActivityHeadline(attributes: context.attributes, state: context.state, size: 24)
                    }
                    .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    TimerActivityBar(attributes: context.attributes, state: context.state, done: context.isStale)
                        .padding(.horizontal, 6)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(Palette.sun)
            } compactTrailing: {
                TimerActivityHeadline(attributes: context.attributes, state: context.state, size: 15, precision: .low)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(Palette.sun)
            }
            .keylineTint(Palette.sun)
        }
    }
}
