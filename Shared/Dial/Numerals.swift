// Numerals.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

/// A number as the readouts set it: the whole part at full size, the decimal
/// point and decimals smaller on the same baseline, and the unit smaller
/// still. The whole part is the glance; the decimals are the detail. Neither
/// goes below a size a small complication can still be read at.
enum Numerals {
    static let decimalRatio: CGFloat = 0.6
    static let unitRatio: CGFloat = 0.4
    static let smallest: CGFloat = 9

    static func text(_ number: String, unit: String? = nil, size: CGFloat, weight: Font.Weight = .semibold) -> Text {
        let point = number.firstIndex(of: ".") ?? number.endIndex
        var text = Text(number[..<point]).font(.system(size: size, weight: weight).monospacedDigit())
        if point < number.endIndex {
            text = text + Text(number[point...]).font(.system(size: max(size * decimalRatio, smallest), weight: weight).monospacedDigit())
        }
        if let unit {
            text = text + Text(" \(unit)").font(.system(size: max(size * unitRatio, smallest), weight: .medium))
        }
        return text
    }
}
