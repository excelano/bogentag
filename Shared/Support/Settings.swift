// Settings.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

/// What the person chooses about the readout. The standard fixes the
/// values; these choose the scale and how finely it is shown. The dial
/// lives in the App Group, so the complications and widgets follow it;
/// they show the low precision whatever is chosen, as they refresh rarely.
enum Settings {
    static let dialVariantKey = "dialVariant"
    static let precisionKey = "precision"

    static var dialVariant: DialVariant {
        AppGroup.defaults.string(forKey: dialVariantKey).flatMap(DialVariant.init) ?? .spans
    }
}

/// How finely a readout shows its scale. The steps pair up across the two
/// scales (Bogenzeit spec §5.2): whole spans with one decimal of ks, one
/// decimal of spans with two of ks, two with three.
enum Precision: Int, CaseIterable {
    case low
    case medium
    case high

    static let standard = Precision.medium

    func decimals(for variant: DialVariant) -> Int {
        variant == .spans ? rawValue : rawValue + 1
    }
}

/// A reading as one scale shows it at one precision: the glyph, and the
/// number on the side of it the positional rule gives (Bogenzeit spec §3.2),
/// floored toward the past (§5.2). A span position of 100 is the horizon
/// glyph alone, and a polar day, which has no spans, shows kiloseconds.
struct DisplayedPosition {
    enum Side {
        case before
        case after
    }

    let glyph: Glyph
    /// Nil when the glyph stands alone.
    let number: String?
    let side: Side
    /// `ks` after an offset; spans are bare numbers.
    let unit: String?

    init(_ reading: Reading, variant: DialVariant, precision: Precision) {
        if variant == .spans, let span = reading.span {
            let decimals = precision.decimals(for: .spans)
            let scale = Self.power(decimals)
            let steps = Int((span * Double(scale)).rounded(.down))
            unit = nil
            side = steps < 0 ? .before : .after
            if steps == -100 * scale {
                glyph = .horizon(before: reading.anchor)
                number = nil
            } else {
                glyph = Glyph(reading.anchor)
                number = steps == 0 ? nil : Self.decimal(abs(steps), decimals: decimals)
            }
        } else {
            let decimals = precision.decimals(for: .kiloseconds)
            let steps = Int((reading.offset / Double(Self.power(3 - decimals))).rounded(.down))
            glyph = Glyph(reading.anchor)
            unit = "ks"
            side = steps < 0 ? .before : .after
            number = steps == 0 ? nil : Self.decimal(abs(steps), decimals: decimals)
        }
    }

    /// The plain-text form, `59.3 ☉`, `☉ 11.77 ks` or `△`, for slots that
    /// cannot draw the glyph (§3.1 accepts the Unicode characters there).
    var text: String {
        let g = String(glyph.character)
        guard let number else { return g }
        let value = unit.map { "\(number) \($0)" } ?? number
        return side == .before ? "\(value) \(g)" : "\(g) \(value)"
    }

    private static func power(_ n: Int) -> Int {
        (0..<n).reduce(1) { result, _ in result * 10 }
    }

    private static func decimal(_ steps: Int, decimals: Int) -> String {
        guard decimals > 0 else { return "\(steps)" }
        let scale = power(decimals)
        return String(format: "%d.%0\(decimals)d", steps / scale, steps % scale)
    }
}
