// Complications.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The watch face slots a complication can fill, named without WidgetKit so
/// the iPhone app can render the same views on its Debug gallery page.
enum ComplicationSlot {
    case circular
    case corner
    case rectangular
    case inline
}

/// What a reading says comes next: the nearest event ahead, in spans and
/// seconds. Before ☉ it is ☉ itself; after it, sunset; and so on round.
/// What is left is rounded up, as it counts down rather than up.
struct NextEvent {
    let name: String
    let spans: Double?
    let seconds: Double

    init?(_ reading: Reading) {
        let day = reading.day
        switch reading.position {
        case .onArc(let span, let spanSeconds, _):
            if span < 0 {
                name = reading.anchor == .noon ? "Noon" : "Midnight"
                spans = -span
                seconds = -reading.offset
            } else {
                name = reading.anchor == .noon ? "Sunset" : "Sunrise"
                spans = 100 - span
                seconds = (100 - span) * spanSeconds
            }
        case .polar:
            if reading.offset < 0 {
                name = reading.anchor == .noon ? "Noon" : "Midnight"
                seconds = -reading.offset
            } else {
                name = reading.anchor == .noon ? "Midnight" : "Noon"
                seconds = (reading.anchor == .noon ? day.midnightEnd : day.noon).timeIntervalSince(reading.instant)
            }
            spans = nil
        }
    }

    /// What is left in the chosen scale: `23` and `spans`, or `2.6` and
    /// `ks` to the tenth a complication can keep up with (§5.2). A polar
    /// day has no spans and counts kiloseconds on either dial.
    func left(_ variant: DialVariant) -> (number: String, unit: String) {
        if variant == .spans, let spans {
            let whole = Int(spans.rounded(.up))
            return ("\(whole)", whole == 1 ? "span" : "spans")
        }
        let tenths = Int((seconds / 100).rounded(.up))
        return ("\(tenths / 10).\(tenths % 10)", "ks")
    }

    /// `Sunset in 23 spans`, `Sunset in 2.6 ks`.
    func sentence(_ variant: DialVariant) -> String {
        let (number, unit) = left(variant)
        return "\(name) in \(number) \(unit)"
    }
}

/// The number and the glyph, on the number's side, as vector shapes.
struct ReadingText: View {
    let reading: Reading
    let variant: DialVariant
    var size: CGFloat = 24
    var color: Color = .primary

    var body: some View {
        let shown = Complications.position(reading, variant)
        let glyph = GlyphView(glyph: shown.glyph, radius: size * 0.33, lineWidth: size * 0.085, color: color)
        HStack(spacing: size * 0.15) {
            if let number = shown.number {
                if shown.side == .before {
                    value(number, unit: shown.unit)
                    glyph
                } else {
                    glyph
                    value(number, unit: shown.unit)
                }
            } else {
                glyph
            }
        }
    }

    /// One line: a slot short of room shrinks the number rather than wrap its unit.
    private func value(_ number: String, unit: String?) -> some View {
        Numerals.text(number, unit: unit, size: size)
            .foregroundStyle(color)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
    }
}

enum Complications {
    /// The chosen scale at the low precision: a complication refreshes too
    /// rarely for a finer step (§5.2).
    static func position(_ reading: Reading, _ variant: DialVariant) -> DisplayedPosition {
        DisplayedPosition(reading, variant: variant, precision: .low)
    }

    /// Text-only slots cannot draw the glyph, so they carry the Unicode
    /// characters, the plain-text form the spec accepts (§3.1).
    static func plain(_ reading: Reading, _ variant: DialVariant) -> String {
        position(reading, variant).text
    }

    static func quarter(_ reading: Reading) -> String {
        reading.quarter?.name ?? (reading.polar == .alwaysAbove ? "Polar day" : "Polar night")
    }

    /// How far along its arc the Sun is, sunrise to sunset or sunset to sunrise.
    static func progress(_ reading: Reading) -> Double? {
        reading.span.map { ($0 + 100) / 200 }
    }
}

/// `86 ☉` or `3.4 ks ☉` and nothing else.
struct ReadingComplication: View {
    let reading: Reading
    let variant: DialVariant
    let slot: ComplicationSlot

    var body: some View {
        switch slot {
        case .circular:
            ReadingText(reading: reading, variant: variant, size: 17)
                .minimumScaleFactor(0.7)
        case .corner:
            GlyphView(glyph: Complications.position(reading, variant).glyph, radius: 10, lineWidth: 2.4, color: .primary)
        case .rectangular:
            ReadingText(reading: reading, variant: variant, size: 30)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .inline:
            Text(Complications.plain(reading, variant))
        }
    }
}

/// The reading with the quarter it falls in.
struct QuarterComplication: View {
    let reading: Reading
    let variant: DialVariant
    let slot: ComplicationSlot

    var body: some View {
        switch slot {
        case .rectangular:
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center) {
                    ReadingText(reading: reading, variant: variant, size: 28)
                        .layoutPriority(1)
                    Spacer(minLength: 8)
                    Text(Complications.quarter(reading))
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                if let progress = Complications.progress(reading) {
                    Gauge(value: progress, in: 0...1) { EmptyView() }
                        .gaugeStyle(.accessoryLinear)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .circular:
            VStack(spacing: 0) {
                ReadingText(reading: reading, variant: variant, size: 15)
                Text(Complications.quarter(reading).uppercased())
                    .font(.system(size: 8, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        case .corner:
            GlyphView(glyph: Complications.position(reading, variant).glyph, radius: 10, lineWidth: 2.4, color: .primary)
        case .inline:
            Text("\(Complications.plain(reading, variant)) \(Complications.quarter(reading))")
        }
    }
}

/// The sky and the Sun, no words: the dial reduced to what a slot can hold.
struct DialComplication: View {
    let reading: Reading
    let variant: DialVariant
    let slot: ComplicationSlot
    /// False in the tinted and vibrant rendering modes, where the sky is one colour.
    var fullColor = true

    var body: some View {
        switch slot {
        case .inline:
            Text(Complications.plain(reading, variant))
        case .corner:
            MiniDial(model: DialModel(reading: reading, variant: variant), fullColor: fullColor)
        default:
            MiniDial(model: DialModel(reading: reading, variant: variant), fullColor: fullColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// The dial without ring or readout: bezel, sky with horizon and twilight,
/// the lit quarter, the Sun, and the two anchors.
struct MiniDial: View {
    let model: DialModel
    var fullColor = true

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            Canvas { context, size in
                draw(in: context, size: size, side: side)
            }
            .frame(width: side, height: side)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func draw(in context: GraphicsContext, size: CGSize, side: CGFloat) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let r = side / 2
        let line = fullColor ? Palette.line : Color.primary
        func point(_ angle: Double, _ radius: CGFloat) -> CGPoint {
            let a = angle * .pi / 180
            return CGPoint(x: c.x + radius * CGFloat(sin(a)), y: c.y - radius * CGFloat(cos(a)))
        }
        func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
        }

        context.fill(circle(c, r), with: .color(fullColor ? Palette.bezel : Color.primary.opacity(0.15)))
        if let arc = model.quarterArc {
            var lit = Path()
            lit.addArc(center: c, radius: r - r * 0.05, startAngle: .degrees(arc.start - 90), endAngle: .degrees(arc.end - 90), clockwise: false)
            context.stroke(lit, with: .color((fullColor ? Palette.sun : Color.primary).opacity(0.6)), lineWidth: r * 0.1)
        }

        let sky = r * 0.85
        var skyContext = context
        skyContext.clip(to: circle(c, sky))
        skyContext.fill(Path(CGRect(origin: .zero, size: size)), with: .color(fullColor ? Palette.night : Color.primary.opacity(0.1)))
        let track = r * 0.68
        func chordY(_ angle: Double) -> CGFloat {
            angle == 0 ? c.y - sky : c.y - track * CGFloat(cos(angle * .pi / 180))
        }
        let bands: [(Color, Double?)] = fullColor
            ? [(Palette.day, model.sunsetAngle), (Palette.civilTwilight, model.civilAngle), (Palette.nauticalTwilight, model.nauticalAngle), (Palette.astronomicalTwilight, model.astronomicalAngle)]
            : [(Color.primary.opacity(0.45), model.sunsetAngle), (Color.primary.opacity(0.3), model.civilAngle), (Color.primary.opacity(0.2), model.nauticalAngle), (Color.primary.opacity(0.15), model.astronomicalAngle)]
        var top = c.y - sky
        for (color, angle) in bands {
            let bottom = angle.map(chordY) ?? c.y + sky
            if bottom > top {
                skyContext.fill(Path(CGRect(x: 0, y: top, width: size.width, height: bottom - top)), with: .color(color))
            }
            top = max(top, bottom)
            if angle == nil { break }
        }
        if let h = model.sunsetAngle, h > 0 {
            let y = chordY(h)
            var horizon = Path()
            horizon.move(to: CGPoint(x: 0, y: y))
            horizon.addLine(to: CGPoint(x: size.width, y: y))
            skyContext.stroke(horizon, with: .color(line.opacity(0.6)), lineWidth: max(1, r * 0.03))
        }

        let glyph = r * 0.09
        Glyph.noon.draw(in: context, at: point(0, r * 0.76), radius: glyph, lineWidth: max(1, glyph * 0.3), color: line)
        Glyph.midnight.draw(in: context, at: point(180, r * 0.76), radius: glyph, lineWidth: max(1, glyph * 0.3), color: line)

        let sun = point(model.sunAngle, track)
        context.fill(circle(sun, r * 0.17), with: .color((fullColor ? Palette.sun : Color.primary).opacity(0.3)))
        context.fill(circle(sun, r * 0.1), with: .color(fullColor ? Palette.sun : Color.primary))
    }
}

/// The Sun's progress along its arc, with the reading inside.
struct GaugeComplication: View {
    let reading: Reading
    let variant: DialVariant
    let slot: ComplicationSlot

    var body: some View {
        let shown = Complications.position(reading, variant)
        switch slot {
        case .circular:
            if let progress = Complications.progress(reading) {
                Gauge(value: progress, in: 0...1) {
                    GlyphView(glyph: shown.glyph, radius: 4, lineWidth: 1.2, color: .primary)
                } currentValueLabel: {
                    Numerals.text(shown.number ?? "", unit: shown.unit, size: shown.unit == nil ? 18 : 14)
                        .minimumScaleFactor(0.6)
                }
                .gaugeStyle(.accessoryCircular)
            } else {
                ReadingText(reading: reading, variant: variant, size: 14)
            }
        default:
            Numerals.text(shown.number ?? "", unit: shown.unit, size: 20)
        }
    }
}

/// What comes next and how far away it is.
struct HorizonComplication: View {
    let reading: Reading
    let variant: DialVariant
    let slot: ComplicationSlot

    var body: some View {
        if let next = NextEvent(reading) {
            switch slot {
            case .rectangular:
                VStack(alignment: .leading, spacing: 1) {
                    Text(next.name.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    let left = next.left(variant)
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Numerals.text(left.number, size: 28)
                        Text(left.unit)
                            .font(.footnote)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            case .circular:
                VStack(spacing: 0) {
                    Text(next.name.prefix(4).uppercased())
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.secondary)
                    short(next, size: 17)
                        .minimumScaleFactor(0.6)
                }
            case .corner:
                short(next, size: 18)
                    .minimumScaleFactor(0.6)
            case .inline:
                Text(next.sentence(variant))
            }
        } else {
            ReadingText(reading: reading, variant: variant, size: 14)
        }
    }

    /// `23` or `2.6 ks`: spans are bare numbers, offsets carry their unit.
    private func short(_ next: NextEvent, size: CGFloat) -> Text {
        let left = next.left(variant)
        return Numerals.text(left.number, unit: left.unit == "ks" ? "ks" : nil, size: size)
    }
}

/// The dial beside the reading, the quarter, the offset and what comes
/// next: the Home Screen's medium widget.
struct DialCard: View {
    let reading: Reading
    let variant: DialVariant

    var body: some View {
        HStack(spacing: 16) {
            MiniDial(model: DialModel(reading: reading, variant: variant))
            VStack(alignment: .leading, spacing: 4) {
                ReadingText(reading: reading, variant: variant, size: 36, color: Palette.line)
                Text(Complications.quarter(reading).uppercased())
                    .font(.footnote.weight(.medium))
                    .tracking(1)
                    .foregroundStyle(Palette.label)
                if let next = NextEvent(reading) {
                    Text(next.sentence(variant))
                        .font(.footnote)
                        .foregroundStyle(Palette.label)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
