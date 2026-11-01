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
    var showsDate = true
    @AppStorage(Settings.offsetDecimalsKey) private var storedDecimals = Settings.defaultOffsetDecimals

    /// The disc the readout sits in: the mockups' 100 units, and never so
    /// small that watch-sized type does not fit.
    static func discRadius(scale: CGFloat) -> CGFloat {
        max(100 * scale, 50)
    }

    var body: some View {
        VStack(spacing: 2 * scale) {
            if showsDate {
                caption(Labels.day(reading.day.day))
            }
            position
            if reading.polar == nil {
                Text("[\(offsetKs)]")
                    .font(.system(size: max(19 * scale, 15), weight: .medium).monospacedDigit())
                    .foregroundStyle(Palette.secondary)
            }
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
        Settings.offsetKs(reading.offset, decimals: Demo.decimals ?? storedDecimals)
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
