// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

#if os(iOS)
import ActivityKit
import Bogenzeit
import SwiftUI

struct TimerAttributes: ActivityAttributes, Equatable {
    struct ContentState: Codable, Hashable {
        var run: ClosedRange<Date>?
        var left: Double
    }

    let unit: TimerUnit
    let amount: Double
    let place: AppGroup.Place

    func status(_ state: ContentState, done: Bool) -> String {
        done ? "DONE" : state.run == nil ? "PAUSED" : "TIMER"
    }

    func headlineLabel(_ state: ContentState, done: Bool) -> String {
        done ? "ENDED AT" : state.run == nil ? "LEFT" : "ENDS AT"
    }
}

struct TimerActivityHeadline: View {
    let attributes: TimerAttributes
    let state: TimerAttributes.ContentState
    let size: CGFloat
    var precision = Precision.high

    var body: some View {
        if let run = state.run {
            let end = Reading(at: run.upperBound, latitude: attributes.place.latitude, longitude: attributes.place.longitude)
            PositionView(shown: DisplayedPosition(end, scale: attributes.unit.scale, precision: precision),
                         size: size, glyphRadius: size * 0.35, lineWidth: size * 0.08, spacing: size * 0.2)
        } else {
            let shown = AmountText.number(state.left, attributes.unit, precision, .up)
            Numerals.text(shown, unit: AmountText.unit(shown, attributes.unit), size: size)
                .foregroundStyle(Palette.line)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }
}

struct TimerActivityBar: View {
    let attributes: TimerAttributes
    let state: TimerAttributes.ContentState
    let done: Bool

    var body: some View {
        Group {
            if let run = state.run, !done {
                ProgressView(timerInterval: run, countsDown: false) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
            } else {
                ProgressView(value: done ? 1 : 1 - state.left / attributes.amount)
            }
        }
        .tint(Palette.sun)
    }
}

struct TimerActivityCaption: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .tracking(1)
            .foregroundStyle(Palette.label)
            .lineLimit(1)
    }
}

struct TimerActivityView: View {
    let attributes: TimerAttributes
    let state: TimerAttributes.ContentState
    let done: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                TimerActivityCaption(attributes.status(state, done: done))
                Spacer()
                TimerActivityCaption(AmountText.set(attributes.amount, attributes.unit).uppercased())
            }
            HStack(alignment: .center, spacing: 10) {
                TimerActivityCaption(attributes.headlineLabel(state, done: done))
                TimerActivityHeadline(attributes: attributes, state: state, size: 34)
            }
            TimerActivityBar(attributes: attributes, state: state, done: done)
        }
        .padding(16)
    }
}
#endif
