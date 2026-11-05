// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

struct TimerScreen: View {
    @Environment(SunLocation.self) private var location
    @Environment(Timing.self) private var timing
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue
    @AppStorage("timerSpans") private var spanAmount = 5.0
    @AppStorage("timerKiloseconds") private var kilosecondAmount = 1.0

    private var precision: Precision {
        isLuminanceReduced ? .low : .high
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let now = Demo.now(context.date)
            if let place = location.place {
                ScrollView {
                    VStack(spacing: 10) {
                        if let timer = timing.timer {
                            running(timer, now: now, place: place)
                        } else {
                            setter(now: now, place: place)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                WaitingView(status: location.status)
            }
        }
    }

    @ViewBuilder
    private func running(_ timer: SpanTimer, now: Date, place: AppGroup.Place) -> some View {
        let done = timer.isDone(at: now)
        let left = timer.remaining(at: now)
        let shown = AmountText.number(left, timer.unit, precision, .up)
        TimingCaption(timer.end == nil ? "PAUSED" : done ? "DONE" : "TIMER")
        Numerals.text(shown, unit: AmountText.unit(shown, timer.unit), size: TimingSize.big)
            .foregroundStyle(done ? Palette.sun : Palette.line)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        if let end = timer.end, !done {
            HStack(spacing: 6) {
                TimingCaption("ENDS AT")
                PositionView(shown: DisplayedPosition(Reading(at: end, latitude: timer.place.latitude, longitude: timer.place.longitude),
                                                      scale: timer.unit.scale, precision: precision),
                             size: TimingSize.small, glyphRadius: TimingSize.small * 0.35,
                             lineWidth: TimingSize.small * 0.08, spacing: 4, color: Palette.secondary)
            }
        }
        HStack(spacing: 6) {
            if done {
                Button("Again") { timing.startTimer(timer.amount, timer.unit, at: now, place: place) }
                    .buttonStyle(ChoiceButtonStyle(selected: true))
                    .disabled(SpanTimer.end(after: timer.amount, timer.unit, from: now, at: place) == nil)
                Button("Clear") { timing.clearTimer() }
                    .buttonStyle(ChoiceButtonStyle(selected: false))
            } else if timer.end == nil {
                Button("Resume") { timing.resumeTimer(at: now, place: place) }
                    .buttonStyle(ChoiceButtonStyle(selected: true))
                    .disabled(SpanTimer.end(after: timer.left, timer.unit, from: now, at: place) == nil)
                Button("Cancel") { timing.clearTimer() }
                    .buttonStyle(ChoiceButtonStyle(selected: false))
            } else {
                Button("Pause") { timing.pauseTimer(at: now) }
                    .buttonStyle(ChoiceButtonStyle(selected: true))
                Button("Cancel") { timing.clearTimer() }
                    .buttonStyle(ChoiceButtonStyle(selected: false))
            }
        }
        .sensoryFeedback(.success, trigger: done) { _, isDone in isDone }
    }

    @ViewBuilder
    private func setter(now: Date, place: AppGroup.Place) -> some View {
        let polar = Reading(at: now, latitude: place.latitude, longitude: place.longitude).polar != nil
        let unit = polar ? .kiloseconds : TimerUnit(Scale(rawValue: variant) ?? .spans)
        let amount = self.amount(unit)
        let end = SpanTimer.end(after: amount.wrappedValue, unit, from: now, at: place)
        TimingCaption("TIMER")
        if polar {
            TimingCaption("NO SPANS ON A POLAR DAY")
        }
        AmountDial(amount: amount, unit: unit, precision: precision)
        Button("Start") { timing.startTimer(amount.wrappedValue, unit, at: now, place: place) }
            .buttonStyle(ChoiceButtonStyle(selected: true))
            .disabled(end == nil)
    }

    private func amount(_ unit: TimerUnit) -> Binding<Double> {
        unit == .spans
            ? $spanAmount
            : Binding { kilosecondAmount * 1000 } set: { kilosecondAmount = $0 / 1000 }
    }
}

struct AmountDial: View {
    @Binding var amount: Double
    let unit: TimerUnit
    let precision: Precision
    #if !os(watchOS)
    @State private var editing = false
    @State private var draft = ""
    @FocusState private var typing: Bool
    #endif

    private var step: Double { unit == .spans ? 0.1 : 100 }

    private var resolution: Double { unit == .spans ? 0.01 : 1 }

    private var most: Double { unit == .spans ? 400 : 86_400 }

    var body: some View {
        let shown = AmountText.number(amount, unit, precision, .toNearestOrAwayFromZero)
        let numerals = Numerals.text(shown, unit: AmountText.unit(shown, unit), size: TimingSize.big)
            .foregroundStyle(Palette.line)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        #if os(watchOS)
        numerals
            .focusable()
            .digitalCrownRotation(Binding { amount } set: { amount = clamped($0) },
                                  from: resolution, through: most, by: step, sensitivity: .high,
                                  isContinuous: false, isHapticFeedbackEnabled: true)
        #else
        HStack(spacing: 12) {
            nudge("minus", -1)
            Group {
                if editing {
                    field
                } else {
                    Button {
                        draft = AmountText.trimmed(amount, unit)
                        editing = true
                    } label: { numerals }
                    .buttonStyle(.plain)
                    .accessibilityHint("Type an amount")
                }
            }
            .frame(maxWidth: .infinity)
            nudge("plus", 1)
        }
        HStack(spacing: 6) {
            ForEach(presets, id: \.self) { preset in
                Button(AmountText.trimmed(preset, unit)) {
                    editing = false
                    amount = preset
                }
                .buttonStyle(ChoiceButtonStyle(selected: !editing && abs(amount - preset) < resolution / 2))
            }
        }
        #endif
    }

    private func clamped(_ value: Double) -> Double {
        min(max((value / resolution).rounded() * resolution, resolution), most)
    }

    #if !os(watchOS)
    private var presets: [Double] {
        unit == .spans ? [1, 2, 5, 10] : [200, 500, 1000, 2000]
    }

    private var field: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            TextField("0", text: $draft)
                .keyboardType(.decimalPad)
                .font(.system(size: TimingSize.big, weight: .semibold).monospacedDigit())
                .foregroundStyle(Palette.line)
                .multilineTextAlignment(.trailing)
                .focused($typing)
            Text(unit == .spans ? "spans" : "ks")
                .font(.system(size: TimingSize.big * Numerals.unitRatio, weight: .medium))
                .foregroundStyle(Palette.line)
        }
        .onAppear { typing = true }
        .onChange(of: draft) {
            guard let typed = try? Double(draft, format: .number) else { return }
            amount = clamped(unit == .spans ? typed : typed * 1000)
        }
        .onChange(of: typing) {
            if !typing { editing = false }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Set") { typing = false }
            }
        }
    }

    private func nudge(_ symbol: String, _ steps: Double) -> some View {
        Button {
            editing = false
            amount = clamped(amount + steps * step)
        } label: {
            Image(systemName: symbol)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.bordered)
        .buttonRepeatBehavior(.enabled)
        .tint(Palette.sun)
        .accessibilityLabel(steps < 0 ? "Less" : "More")
    }
    #endif
}

struct TimingCaption: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .tracking(0.8)
            .foregroundStyle(Palette.label)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}

enum TimingSize {
    #if os(watchOS)
    static let big: CGFloat = 40
    static let small: CGFloat = 15
    #else
    static let big: CGFloat = 64
    static let small: CGFloat = 20
    #endif
}
