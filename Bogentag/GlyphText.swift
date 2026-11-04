// GlyphText.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
import SwiftUI
import UIKit

/// ☉, ○, △ and ▽ inside running text, drawn from the glyphs' one definition
/// as template images, so that they match each other and the type beside
/// them; the font's own characters come out at different sizes (Bogenzeit
/// spec §3.1).
enum GlyphText {
    /// The text with `{noon}`, `{midnight}`, `{sunrise}` and `{sunset}`
    /// replaced by drawn glyphs.
    static func text(_ markup: String, size: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize) -> Text {
        var result = Text("")
        var rest = Substring(markup)
        while let open = rest.firstIndex(of: "{"), let close = rest[open...].firstIndex(of: "}") {
            result = result + Text(rest[..<open])
            let glyph: Glyph? = switch rest[rest.index(after: open)..<close] {
            case "noon": .noon
            case "midnight": .midnight
            case "sunrise": .sunrise
            case "sunset": .sunset
            default: nil
            }
            if let glyph {
                result = result + Text(Image(uiImage: image(glyph, size: size))).baselineOffset(-size * 0.08)
            }
            rest = rest[rest.index(after: close)...]
        }
        return result + Text(rest)
    }

    private static func image(_ glyph: Glyph, size: CGFloat) -> UIImage {
        let side = size * 0.92
        let lineWidth = side * 0.12
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { context in
            let center = CGPoint(x: side / 2, y: side / 2)
            let radius = side / 2 - lineWidth / 2
            UIColor.black.setStroke()
            UIColor.black.setFill()
            let outline = UIBezierPath(cgPath: glyph.outline(center: center, radius: radius).cgPath)
            outline.lineWidth = lineWidth
            outline.lineJoinStyle = .round
            outline.stroke()
            if let dot = glyph.dot(center: center, radius: radius) {
                UIBezierPath(cgPath: dot.cgPath).fill()
            }
            _ = context
        }
        .withRenderingMode(.alwaysTemplate)
    }
}
