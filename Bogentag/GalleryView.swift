// GalleryView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

#if DEBUG
import Bogenzeit
import SwiftUI

/// Every complication at its slot sizes, for checking layouts without
/// configuring a watch face by hand. `--page gallery` opens it.
struct GalleryView: View {
    let reading: Reading

    private let kinds: [(String, (Reading, ComplicationSlot) -> AnyView)] = [
        ("Reading", { AnyView(ReadingComplication(reading: $0, variant: Settings.dialVariant, slot: $1)) }),
        ("Eighth", { AnyView(EighthComplication(reading: $0, variant: Settings.dialVariant, slot: $1)) }),
        ("Dial", { AnyView(DialComplication(reading: $0, variant: Settings.dialVariant, slot: $1)) }),
        ("Gauge", { AnyView(GaugeComplication(reading: $0, variant: Settings.dialVariant, slot: $1)) }),
        ("Next", { AnyView(HorizonComplication(reading: $0, variant: Settings.dialVariant, slot: $1)) }),
    ]

    private var timerAttributes: TimerAttributes {
        TimerAttributes(unit: TimerUnit(Settings.dialVariant), amount: Settings.dialVariant == .spans ? 20 : 2000, place: Demo.place)
    }

    private var timerSamples: [(state: TimerAttributes.ContentState, done: Bool)] {
        let now = reading.instant
        let end = SpanTimer.end(after: timerAttributes.amount, timerAttributes.unit, from: now, at: Demo.place) ?? now
        let run = now.addingTimeInterval(-end.timeIntervalSince(now) / 3)...end
        return [
            (TimerAttributes.ContentState(run: run, left: timerAttributes.amount), false),
            (TimerAttributes.ContentState(run: nil, left: timerAttributes.amount * 0.6), false),
            (TimerAttributes.ContentState(run: run, left: timerAttributes.amount), true),
        ]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Home Screen").font(.headline)
                MiniDial(model: DialModel(reading: reading, variant: Settings.dialVariant))
                    .padding(14)
                    .frame(width: 158, height: 158)
                    .background(RoundedRectangle(cornerRadius: 22).fill(Palette.night).stroke(Palette.line.opacity(0.2)))
                DialCard(reading: reading, variant: Settings.dialVariant)
                    .padding(16)
                    .frame(width: 338, height: 158)
                    .background(RoundedRectangle(cornerRadius: 22).fill(Palette.night).stroke(Palette.line.opacity(0.2)))
                DialView(model: DialModel(reading: reading, variant: Settings.dialVariant), precision: .low)
                    .padding(16)
                    .frame(width: 338, height: 354)
                    .background(RoundedRectangle(cornerRadius: 22).fill(Palette.night).stroke(Palette.line.opacity(0.2)))
                Text("Live Activity").font(.headline)
                ForEach(Array(timerSamples.enumerated()), id: \.offset) { _, sample in
                    TimerActivityView(attributes: timerAttributes, state: sample.state, done: sample.done)
                        .frame(width: 360)
                        .background(RoundedRectangle(cornerRadius: 22).fill(Palette.night).stroke(Palette.line.opacity(0.2)))
                }
                ForEach(kinds, id: \.0) { name, make in
                    Text(name).font(.headline)
                    HStack(alignment: .center, spacing: 14) {
                        make(reading, .circular)
                            .frame(width: 50, height: 50)
                            .background(Circle().fill(Palette.line.opacity(0.12)))
                        make(reading, .corner)
                            .frame(width: 40, height: 40)
                        make(reading, .rectangular)
                            .frame(width: 172, height: 66)
                            .padding(.horizontal, 6)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Palette.line.opacity(0.12)))
                    }
                    make(reading, .inline)
                        .font(.footnote)
                }
            }
            .padding()
        }
        .background(Palette.night)
        .foregroundStyle(Palette.line)
    }
}
#endif
