// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

enum TimerUnit: String, Codable, CaseIterable, Sendable {
    case spans
    case kiloseconds

    init(_ scale: Scale) {
        self = scale == .spans ? .spans : .kiloseconds
    }

    var scale: Scale { self == .spans ? .spans : .kiloseconds }
}

enum AmountText {
    static func number(_ amount: Double, _ unit: TimerUnit, _ precision: Precision,
                       _ rounding: FloatingPointRoundingRule) -> String {
        let value = unit == .spans ? amount : amount / 1000
        let decimals = precision.decimals(for: unit.scale)
        let factor = pow(10, Double(decimals))
        let nudge = rounding == .up ? -1e-6 : 1e-6
        let rounded = (value * factor + nudge).rounded(rounding)
        let steps = rounded > 0 ? rounded : 0
        return String(format: "%.\(decimals)f", steps / factor)
    }

    static func unit(_ number: String, _ unit: TimerUnit) -> String {
        guard unit == .spans else { return "ks" }
        return number == "1" ? "span" : "spans"
    }

    static func trimmed(_ amount: Double, _ unit: TimerUnit) -> String {
        var shown = number(amount, unit, .high, .toNearestOrAwayFromZero)
        while shown.contains("."), shown.hasSuffix("0") || shown.hasSuffix(".") {
            shown.removeLast()
        }
        return shown
    }

    static func set(_ amount: Double, _ unit: TimerUnit) -> String {
        let shown = trimmed(amount, unit)
        return "\(shown) \(self.unit(shown, unit))"
    }

    static func amount(_ amount: Double, _ unit: TimerUnit, _ precision: Precision,
                       _ rounding: FloatingPointRoundingRule) -> String {
        let shown = number(amount, unit, precision, rounding)
        return "\(shown) \(self.unit(shown, unit))"
    }
}
