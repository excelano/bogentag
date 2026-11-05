// ReadoutView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
import SwiftUI

/// The center of the dial: the Bogenzeit date, the position in the dial's
/// own scale with its glyph, and the eighth. The number sits on the side of
/// the glyph the positional rule gives it (Bogenzeit spec §3.2).
struct ReadoutView: View {
    let reading: Reading
    let variant: Scale
    let scale: CGFloat
    var showsDate = true
    @AppStorage(Settings.precisionKey) private var storedPrecision = Precision.standard.rawValue
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    /// The disc the readout sits in: the mockups' 100 units, and never so
    /// small that watch-sized type does not fit.
    static func discRadius(scale: CGFloat) -> CGFloat {
        max(100 * scale, 50)
    }

    /// The stored choice, or Low while the screen is dimmed and refreshes
    /// about once a minute: no finer step than the refresh (§5.2).
    private var precision: Precision {
        if isLuminanceReduced { return .low }
        return Demo.precision ?? Precision(rawValue: storedPrecision) ?? .standard
    }

    var body: some View {
        VStack(spacing: 2 * scale) {
            if showsDate {
                caption(Labels.day(reading.day.day))
            }
            position
            caption(context)
        }
        .frame(width: 2 * Self.discRadius(scale: scale) - 6)
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.system(size: max(13 * scale, 11), weight: .medium))
            .tracking(max(1.5 * scale, 0.8))
            .foregroundStyle(Palette.label)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    @ViewBuilder
    private var position: some View {
        let shown = DisplayedPosition(reading, scale: variant, precision: precision)
        let glyph = GlyphView(shown.glyph, radius: 21 * scale, lineWidth: 4.5 * scale, color: Palette.line)
        HStack(spacing: 8 * scale) {
            if let number = shown.number {
                if shown.side == .before {
                    big(number, unit: shown.unit)
                    glyph
                } else {
                    glyph
                    big(number, unit: shown.unit)
                }
            } else {
                glyph
            }
        }
        .frame(height: 70 * scale)
    }

    /// The number at a size where the widest value of its scale and
    /// precision fits beside the glyph: `99.99` at the full size, since its
    /// decimals are smaller, and `43.1 ks`, `43.12 ks`, `43.123 ks` by precision.
    private func big(_ number: String, unit: String?) -> some View {
        let size = (unit == nil ? 64 : Self.offsetSizes[precision.rawValue]) * scale
        return Numerals.text(number, unit: unit, size: size)
            .foregroundStyle(Palette.line)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private static let offsetSizes: [CGFloat] = [60, 52, 46]

    private var context: String {
        if let eighth = reading.eighth {
            if let phase = reading.nightPhase, phase != .night {
                return "\(eighth.name) | \(phase.name)".uppercased()
            }
            return eighth.name.uppercased()
        }
        return reading.polar == .alwaysAbove ? "POLAR DAY" : "POLAR NIGHT"
    }
}
