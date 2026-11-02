// Glyph.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// ☉, ○, △ and ▽ from one definition (Bogenzeit spec §3.1): ☉ is the circle
/// with its center dot, ○ the circle alone, and △ and ▽ a triangle filling
/// the circle's square, apex up or down. Never a font glyph.
enum Glyph: Equatable {
    case noon
    case midnight
    case sunrise
    case sunset

    init(_ anchor: SolarAnchor) {
        self = anchor == .noon ? .noon : .midnight
    }

    /// The glyph written for the 100-span position before the anchor (§3.2).
    static func horizon(before anchor: SolarAnchor) -> Glyph {
        anchor == .noon ? .sunrise : .sunset
    }

    /// The dot's radius as a share of the circle's.
    static let dotRatio = 2.6 / 9

    var character: Character {
        switch self {
        case .noon: "☉"
        case .midnight: "○"
        case .sunrise: "△"
        case .sunset: "▽"
        }
    }

    var name: String {
        switch self {
        case .noon: "solar noon"
        case .midnight: "solar midnight"
        case .sunrise: "sunrise"
        case .sunset: "sunset"
        }
    }

    /// The stroked outline: the circle, or the triangle in its square.
    func outline(center: CGPoint, radius: CGFloat) -> Path {
        switch self {
        case .noon, .midnight:
            return Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
        case .sunrise, .sunset:
            let apex = self == .sunrise ? -radius : radius
            var path = Path()
            path.move(to: CGPoint(x: center.x, y: center.y + apex))
            path.addLine(to: CGPoint(x: center.x - radius, y: center.y - apex))
            path.addLine(to: CGPoint(x: center.x + radius, y: center.y - apex))
            path.closeSubpath()
            return path
        }
    }

    /// ☉'s center dot; nil for the others.
    func dot(center: CGPoint, radius: CGFloat) -> Path? {
        guard self == .noon else { return nil }
        let r = radius * Self.dotRatio
        return Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r))
    }

    func draw(in context: GraphicsContext, at center: CGPoint, radius: CGFloat, lineWidth: CGFloat, color: Color) {
        context.stroke(outline(center: center, radius: radius), with: .color(color),
                       style: StrokeStyle(lineWidth: lineWidth, lineJoin: .round))
        if let dot = dot(center: center, radius: radius) {
            context.fill(dot, with: .color(color))
        }
    }
}

/// The glyph as a view, for readouts and widgets.
struct GlyphView: View {
    let glyph: Glyph
    let radius: CGFloat
    let lineWidth: CGFloat
    var color: Color = Palette.line

    var body: some View {
        Canvas { context, size in
            glyph.draw(in: context, at: CGPoint(x: size.width / 2, y: size.height / 2), radius: radius,
                       lineWidth: lineWidth, color: color)
        }
        .frame(width: 2 * radius + lineWidth, height: 2 * radius + lineWidth)
        .accessibilityLabel(glyph.name)
    }
}
