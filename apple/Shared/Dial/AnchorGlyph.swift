// AnchorGlyph.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// ☉ and ○ from one circle definition (Bogenzeit spec §3.1): the ring is the
/// same for both, and ☉ adds the center dot. Never a font glyph.
enum AnchorGlyph {
    /// The dot's radius as a share of the ring's.
    static let dotRatio = 2.6 / 9

    static func ring(center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
    }

    static func dot(center: CGPoint, radius: CGFloat) -> Path {
        let r = radius * dotRatio
        return Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r))
    }

    static func draw(_ anchor: SolarAnchor, in context: GraphicsContext, at center: CGPoint, radius: CGFloat, lineWidth: CGFloat, color: Color) {
        context.stroke(ring(center: center, radius: radius), with: .color(color), lineWidth: lineWidth)
        if anchor == .noon {
            context.fill(dot(center: center, radius: radius), with: .color(color))
        }
    }
}

/// The glyph as a view, for readouts and widgets.
struct AnchorGlyphView: View {
    let anchor: SolarAnchor
    let radius: CGFloat
    let lineWidth: CGFloat
    var color: Color = Palette.line

    var body: some View {
        ZStack {
            Circle().stroke(color, lineWidth: lineWidth)
            if anchor == .noon {
                Circle().fill(color).frame(width: 2 * radius * AnchorGlyph.dotRatio, height: 2 * radius * AnchorGlyph.dotRatio)
            }
        }
        .frame(width: 2 * radius, height: 2 * radius)
        .padding(lineWidth / 2)
        .accessibilityLabel(anchor == .noon ? "solar noon" : "solar midnight")
    }
}
