// DialView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI

/// The dial, drawn to the mockups' 450-unit design and scaled to the space
/// it is given: bezel and kilosecond ring, the sky with its horizon and
/// twilight bands, the Sun on its track, quarter ticks, the two anchors,
/// and the center readout.
struct DialView: View {
    let model: DialModel
    var showsReadout = true
    var showsDate = true
    var showsArcLengths = true

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let s = side / 450
            ZStack {
                Canvas { context, size in
                    draw(in: context, size: size, scale: s)
                }
                if showsReadout {
                    ReadoutView(reading: model.reading, scale: s, showsDate: showsDate)
                    if showsArcLengths && model.variant == .span {
                        arcLengths(scale: s)
                    }
                }
            }
            .frame(width: side, height: side)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func arcLengths(scale s: CGFloat) -> some View {
        VStack(spacing: 2) {
            if let tagbogen = model.reading.day.tagbogen {
                Text("TAGBOGEN \(ArcLengths.ks(tagbogen))")
            }
            if let night = ArcLengths.nachtbogen(of: model.reading) {
                Text("NACHTBOGEN \(ArcLengths.ks(night))")
            }
        }
        .font(.system(size: max(11 * s, 11), weight: .medium))
        .tracking(max(1 * s, 0.6))
        .foregroundStyle(Palette.label)
        .fixedSize()
        .offset(y: 135 * s)
    }

    private func draw(in context: GraphicsContext, size: CGSize, scale s: CGFloat) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        func point(_ angle: Double, _ radius: CGFloat) -> CGPoint {
            let a = angle * .pi / 180
            return CGPoint(x: c.x + radius * s * CGFloat(sin(a)), y: c.y - radius * s * CGFloat(cos(a)))
        }
        func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
            Path(ellipseIn: CGRect(x: center.x - radius * s, y: center.y - radius * s, width: 2 * radius * s, height: 2 * radius * s))
        }
        func line(_ from: CGPoint, _ to: CGPoint) -> Path {
            var p = Path()
            p.move(to: from)
            p.addLine(to: to)
            return p
        }

        context.fill(circle(c, 215), with: .color(Palette.bezel))

        for tick in model.ringTicks {
            let (inner, outer, width, color) = tick.major
                ? (CGFloat(198), CGFloat(212), 2.6 * s, Palette.majorTick)
                : (CGFloat(201), CGFloat(209), 1.4 * s, Palette.minorTick)
            context.stroke(line(point(tick.angle, inner), point(tick.angle, outer)), with: .color(color), lineWidth: width)
        }

        var sky = context
        sky.clip(to: circle(c, 195))
        sky.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.night))
        let track = 160 * s
        let skyTop = c.y - 195 * s
        let skyBottom = c.y + 195 * s
        func chordY(_ angle: Double) -> CGFloat {
            angle == 0 ? skyTop : c.y - track * CGFloat(cos(angle * .pi / 180))
        }
        let bands: [(Color, Double?)] = [
            (Palette.day, model.sunsetAngle),
            (Palette.civilTwilight, model.civilAngle),
            (Palette.nauticalTwilight, model.nauticalAngle),
            (Palette.astronomicalTwilight, model.astronomicalAngle),
        ]
        var top = skyTop
        for (color, angle) in bands {
            let bottom = angle.map(chordY) ?? skyBottom
            if bottom > top {
                sky.fill(Path(CGRect(x: 0, y: top, width: size.width, height: bottom - top)), with: .color(color))
            }
            top = max(top, bottom)
            if angle == nil { break }
        }
        if let h = model.sunsetAngle, h > 0 {
            let y = chordY(h)
            sky.stroke(line(CGPoint(x: 0, y: y), CGPoint(x: size.width, y: y)), with: .color(Palette.line.opacity(0.55)), lineWidth: 1.5 * s)
        }
        sky.stroke(circle(c, 160), with: .color(Palette.line.opacity(0.25)), lineWidth: 1 * s)

        for angle in model.quarterAngles {
            context.stroke(line(point(angle, 179), point(angle, 195)), with: .color(Palette.line.opacity(0.8)),
                           style: StrokeStyle(lineWidth: 2.5 * s, lineCap: .round))
        }

        AnchorGlyph.draw(.noon, in: context, at: point(0, 173), radius: 9 * s, lineWidth: 2.2 * s, color: Palette.line)
        AnchorGlyph.draw(.midnight, in: context, at: point(180, 173), radius: 9 * s, lineWidth: 2.2 * s, color: Palette.line)

        let sun = point(model.sunAngle, 160)
        context.fill(circle(sun, 20), with: .color(Palette.sun.opacity(0.25)))
        context.fill(circle(sun, 11), with: .color(Palette.sun))

        if showsReadout {
            let disc = ReadoutView.discRadius(scale: s)
            let path = Path(ellipseIn: CGRect(x: c.x - disc, y: c.y - disc, width: 2 * disc, height: 2 * disc))
            context.fill(path, with: .color(Palette.night.opacity(0.8)))
            context.stroke(path, with: .color(Palette.line.opacity(0.12)), lineWidth: 1 * s)
        }
    }
}

/// Today's arc lengths as the dial and the day page state them.
enum ArcLengths {
    /// Tonight: sunset to the next sunrise.
    static func nachtbogen(of reading: Reading) -> Double? {
        let day = reading.day
        let next = SolarDay(day.day.adding(days: 1), latitude: reading.latitude, longitude: reading.longitude)
        guard let evening = day.halfNightEvening, let morning = next.halfNightMorning else { return nil }
        return evening + morning
    }

    /// Kiloseconds to one decimal, floored like every readout.
    static func ks(_ seconds: Double) -> String {
        String(format: "%.1f ks", (seconds / 100).rounded(.down) / 10)
    }
}
