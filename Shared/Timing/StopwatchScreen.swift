// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

struct StopwatchScreen: View {
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue

    private var precision: Precision {
        isLuminanceReduced ? .low : .high
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = Demo.now(context.date)
            if let place = location.place {
                ScrollView {
                    VStack(spacing: 10) {
                        content(now: now, place: place)
                    }
                    .padding(.horizontal)
                }
            } else {
                WaitingView(status: location.status)
            }
        }
    }

    @ViewBuilder
    private func content(now: Date, place: AppGroup.Place) -> some View {
        let stopwatch = timing.stopwatch
        let elapsed = stopwatch?.elapsed(at: now) ?? .zero
        let running = stopwatch?.since != nil
        TimingCaption("STOPWATCH")
        let shown = AmountText.number(amount(elapsed), unit(elapsed), precision, .down)
        Numerals.text(shown, unit: AmountText.unit(shown, unit(elapsed)), size: TimingSize.big)
            .foregroundStyle(Palette.line)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        HStack(spacing: 6) {
            if running {
                Button("Stop") { timing.stopStopwatch(at: now) }
                    .buttonStyle(ChoiceButtonStyle(selected: true))
                Button("Lap") { timing.lap(at: now) }
                    .buttonStyle(ChoiceButtonStyle(selected: false))
            } else {
                Button("Start") { timing.runStopwatch(at: now, place: place) }
                    .buttonStyle(ChoiceButtonStyle(selected: true))
                Button("Reset") { timing.resetStopwatch() }
                    .buttonStyle(ChoiceButtonStyle(selected: false))
                    .disabled(stopwatch == nil)
            }
        }
        if let laps = stopwatch?.laps, !laps.isEmpty {
            Divider()
            ForEach(Array(laps.enumerated().reversed()), id: \.offset) { index, total in
                lap(index + 1, total - (index > 0 ? laps[index - 1] : .zero))
            }
        }
    }

    private func unit(_ elapsed: Elapsed) -> TimerUnit {
        elapsed.spans == nil ? .kiloseconds : TimerUnit(Scale(rawValue: variant) ?? .spans)
    }

    private func amount(_ elapsed: Elapsed) -> Double {
        unit(elapsed) == .spans ? elapsed.spans ?? 0 : elapsed.seconds
    }

    private func lap(_ number: Int, _ split: Elapsed) -> some View {
        HStack {
            Text("Lap \(number)")
                .foregroundStyle(Palette.label)
            Spacer()
            Text(AmountText.amount(amount(split), unit(split), precision, .down))
                .foregroundStyle(Palette.line)
        }
        .font(.footnote.monospacedDigit())
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}
