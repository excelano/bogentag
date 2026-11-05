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
        Precision.shown(storedPrecision, dimmed: isLuminanceReduced)
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

    private var position: some View {
        let shown = DisplayedPosition(reading, scale: variant, precision: precision)
        let size = (shown.unit == nil ? 64 : Self.offsetSizes[precision.rawValue]) * scale
        return PositionView(shown: shown, size: size, glyphRadius: 21 * scale, lineWidth: 4.5 * scale, spacing: 8 * scale)
            .frame(height: 70 * scale)
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

extension Precision {
    static func shown(_ stored: Int, dimmed: Bool) -> Precision {
        if dimmed { return .low }
        return Demo.precision ?? Precision(rawValue: stored) ?? .standard
    }
}

struct PositionView: View {
    let shown: DisplayedPosition
    let size: CGFloat
    let glyphRadius: CGFloat
    let lineWidth: CGFloat
    let spacing: CGFloat
    var color = Palette.line

    var body: some View {
        let glyph = GlyphView(shown.glyph, radius: glyphRadius, lineWidth: lineWidth, color: color)
        HStack(spacing: spacing) {
            if let number = shown.number {
                if shown.side == .before {
                    numerals(number)
                    glyph
                } else {
                    glyph
                    numerals(number)
                }
            } else {
                glyph
            }
        }
    }

    private func numerals(_ number: String) -> some View {
        Numerals.text(number, unit: shown.unit, size: size)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}
