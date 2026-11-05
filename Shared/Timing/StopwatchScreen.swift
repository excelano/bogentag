// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

struct StopwatchScreen: View {
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @AppStorage(Settings.precisionKey) private var storedPrecision = Precision.standard.rawValue

    private var precision: Precision {
        Precision.shown(storedPrecision, dimmed: isLuminanceReduced)
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
        big(elapsed)
        if elapsed.spans != nil {
            TimingCaption(AmountText.amount(elapsed.seconds, .kiloseconds, precision, .down))
        }
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

    private func big(_ elapsed: Elapsed) -> some View {
        let unit: TimerUnit = elapsed.spans == nil ? .kiloseconds : .spans
        let shown = AmountText.number(elapsed.spans ?? elapsed.seconds, unit, precision, .down)
        return Numerals.text(shown, unit: AmountText.unit(shown, unit), size: TimingSize.big)
            .foregroundStyle(Palette.line)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }

    private func lap(_ number: Int, _ split: Elapsed) -> some View {
        HStack {
            Text("Lap \(number)")
                .foregroundStyle(Palette.label)
            Spacer()
            if let spans = split.spans {
                Text(AmountText.amount(spans, .spans, precision, .down))
                    .foregroundStyle(Palette.line)
            }
            Text(AmountText.amount(split.seconds, .kiloseconds, precision, .down))
                .foregroundStyle(Palette.secondary)
        }
        .font(.footnote.monospacedDigit())
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
}
