// ReadoutView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The center of the dial: the Bogenzeit date, the span position with its
/// anchor glyph, the offset in brackets, and the quarter. The number sits on
/// the side of the glyph the positional rule gives it (Bogenzeit spec §3.2).
struct ReadoutView: View {
    let reading: Reading
    let scale: CGFloat

    var body: some View {
        VStack(spacing: 2 * scale) {
            caption(Labels.day(reading.day.day))
            position
            if reading.polar == nil {
                Text("[\(offsetKs)]")
                    .font(.system(size: 19 * scale, weight: .medium).monospacedDigit())
                    .foregroundStyle(Palette.secondary)
            }
            caption(context)
        }
    }

    private func caption(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13 * scale, weight: .medium))
            .tracking(1.5 * scale)
            .foregroundStyle(Palette.label)
            .lineLimit(1)
    }

    @ViewBuilder
    private var position: some View {
        let glyph = AnchorGlyphView(anchor: reading.anchor, radius: 21 * scale, lineWidth: 4.5 * scale)
        HStack(spacing: 8 * scale) {
            if let span = reading.displaySpan {
                if span < 0 {
                    big("\(-span)")
                    glyph
                } else if span == 0 {
                    glyph
                } else {
                    glyph
                    big("\(span)")
                }
            } else {
                let steps = reading.displayOffsetSteps
                if steps < 0 {
                    big(offsetKs)
                    glyph
                } else if steps == 0 {
                    glyph
                } else {
                    glyph
                    big(offsetKs)
                }
            }
        }
        .frame(height: 70 * scale)
    }

    private func big(_ text: String) -> some View {
        Text(text)
            .font(.system(size: (reading.polar == nil ? 64 : 40) * scale, weight: .semibold).monospacedDigit())
            .foregroundStyle(Palette.line)
    }

    private var offsetKs: String {
        let steps = abs(reading.displayOffsetSteps)
        return "\(steps / 10).\(steps % 10) ks"
    }

    private var context: String {
        if let quarter = reading.quarter {
            if let phase = reading.nightPhase, phase != .night {
                return "\(quarter.name) | \(phase.name)".uppercased()
            }
            return quarter.name.uppercased()
        }
        return reading.polar == .alwaysAbove ? "POLAR DAY" : "POLAR NIGHT"
    }
}
