// TourView.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import BogenzeitUI
import SwiftUI

/// The explainer (Bogentag spec §5): nine pages, one per topic, each with
/// a live piece of the dial computed for the place in use, so the numbers on
/// the page are the reader's own.
struct TourView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SunLocation.self) private var location
    @State private var page = Demo.tourPage ?? 0

    var body: some View {
        let place = location.place ?? Demo.place
        let now = Demo.now(.now)
        let reading = Reading(at: now, latitude: place.latitude, longitude: place.longitude)
        let pages = pages(reading)
        let last = pages.count - 1
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    page.tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            Button(page == last ? "Done" : "Skip") { dismiss() }
                .buttonStyle(ChoiceButtonStyle(selected: page == last))
                .padding()
        }
        .background(Palette.night)
        .preferredColorScheme(.dark)
    }

    private func pages(_ reading: Reading) -> [TourPage] {
        let day = reading.day
        let june = SolarDay(CalendarDay(year: day.day.year, month: 6, day: 21)!, latitude: reading.latitude, longitude: reading.longitude)
        let december = SolarDay(CalendarDay(year: day.day.year, month: 12, day: 21)!, latitude: reading.latitude, longitude: reading.longitude)
        let spanToday = day.daySpan.map { "\(Int($0.rounded(.down))) s" } ?? "undefined, the Sun never crosses the horizon"
        let spanJune = june.daySpan.map { "\(Int($0.rounded(.down))) s" } ?? "none"
        let spanDecember = december.daySpan.map { "\(Int($0.rounded(.down))) s" } ?? "none"
        return [
            TourPage(title: "Time on the Sun's arc", text: """
            Every day the Sun rises, climbs to its highest point, sets, and passes beneath you to its lowest. Bogenzeit reads time off that arc: where the Sun is now, between those four events. The day arc runs from sunrise to sunset and the night arc from sunset to sunrise. The day arc is the Tagbogen in German; the app's name, Bogentag, turns it around.
            """) {
                DialView(model: DialModel(reading: reading, variant: .spans))
            },
            TourPage(title: "Two anchors", text: """
            {noon} is solar noon, the Sun at its highest. {midnight} is solar midnight, the Sun at its lowest. A clock puts noon at 12:00 for a whole zone; the Sun keeps its own time at your longitude. Here, today, solar noon is at \(Labels.clock(day.noon)) and solar midnight at \(Labels.clock(day.midnightEnd)).
            """) {
                HStack(spacing: 60) {
                    VStack(spacing: 12) {
                        GlyphView(.noon, radius: 36, lineWidth: 7, color: Palette.line)
                        Text("solar noon").foregroundStyle(Palette.label)
                    }
                    VStack(spacing: 12) {
                        GlyphView(.midnight, radius: 36, lineWidth: 7, color: Palette.line)
                        Text("solar midnight").foregroundStyle(Palette.label)
                    }
                }
            },
            TourPage(title: "Spans", text: """
            Each half of an arc is 100 spans: sunrise to {noon}, {noon} to sunset, and the same on either side of {midnight}. A span stretches and shrinks with the season. Here a day span is \(spanToday) today, \(spanJune) in June and \(spanDecember) in December. The span dial draws every day the same shape; the season shows in the numbers.
            """) {
                DialView(model: DialModel(reading: reading, variant: .spans))
            },
            TourPage(title: "Kiloseconds", text: """
            The fixed scale, the other way to read the same moment. A kilosecond is 1,000 seconds, a little under seventeen minutes; a day is 86.4 of them. The Kiloseconds dial gives the time from the nearest anchor in kiloseconds, so two readings can be compared and a duration added up. Each dial shows its own scale, and Precision sets how many decimals.
            """) {
                let shown = DisplayedPosition(reading, scale: .kiloseconds, precision: .standard)
                NotationExample(number: shown.number, unit: shown.unit, glyph: shown.glyph, before: shown.side == .before,
                                meaning: "\(shown.side == .before ? "before" : "after") \(Glyph(reading.anchor).name)")
            },
            TourPage(title: "Reading the notation", text: """
            The number sits on the side of the glyph where that moment lies. Left of the glyph, the anchor is still to come: 18 {noon} is eighteen spans before solar noon. Right of it, the anchor has passed: {noon} 3 is three spans after. No plus, no minus. At night the same reading runs against {midnight}. Sunrise and sunset have glyphs of their own, {sunrise} and {sunset}, shown in place of the 100 that starts each arc.
            """) {
                VStack(spacing: 18) {
                    NotationExample(number: "18", glyph: .noon, before: true, meaning: "before solar noon")
                    NotationExample(number: "3", glyph: .noon, before: false, meaning: "after solar noon")
                    NotationExample(number: nil, glyph: .sunrise, before: false, meaning: "sunrise")
                    NotationExample(number: nil, glyph: .sunset, before: false, meaning: "sunset")
                }
            },
            TourPage(title: "Four quarters", text: """
            Before and after each anchor are the parts of the day you already name: before {noon} the morning, after it the afternoon; before {midnight} the evening, after it the night. The reading gives you these four quarters on its own, in the glyph and the side the number sits on.
            """) {
                ArcWheel(names: ArcWheel.quarters)
            },
            TourPage(title: "Eight eighths", text: """
            Halve each quarter at its 50-span mark and you have the eight eighths the dial labels, each named for the nearest event: Fore- before it, After- after it. By day: Afterrise, Forenoon, Afternoon, Foreset. By night: Afterset, Foremid, Aftermid, Forerise.
            """) {
                ArcWheel(names: ArcWheel.eighths)
            },
            TourPage(title: "The date turns at solar midnight", text: """
            A Bogenzeit day runs from one solar midnight to the next, so the date changes at {midnight} rather than at 00:00. Tonight {midnight} falls at \(Labels.clock(day.midnightEnd)); until then it is still \(Labels.day(day.day)) here, whatever the calendar says.
            """) {
                VStack(spacing: 10) {
                    GlyphView(.midnight, radius: 36, lineWidth: 7, color: Palette.line)
                    Text(Labels.day(day.day))
                        .font(.title2.weight(.semibold))
                    Text("until \(Labels.clock(day.midnightEnd))")
                        .foregroundStyle(Palette.label)
                }
            },
            TourPage(title: "Tap for the clock", text: """
            The dial shows no hours and no minutes. When you need them, tap it: UTC, the reference every reading is computed from, then the local clock with its zone, the date, and today's sunrise and sunset, over the dimmed dial. Tap again to return to the Sun.
            """) {
                ZStack {
                    DialView(model: DialModel(reading: reading, variant: .kiloseconds), showsReadout: false)
                        .opacity(0.35)
                    CivilView(reading: reading, now: reading.instant)
                }
            },
        ]
    }
}

struct TourPage: View {
    let title: String
    let text: String
    let visual: AnyView

    init(title: String, text: String, @ViewBuilder visual: () -> some View) {
        self.title = title
        self.text = text
        self.visual = AnyView(visual())
    }

    var body: some View {
        VStack(spacing: 20) {
            visual
                .frame(maxWidth: .infinity)
                .frame(height: 300)
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Palette.line)
            GlyphText.text(text)
                .font(.body)
                .foregroundStyle(Palette.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .padding(.top, 24)
        .padding(.bottom, 40)
    }
}

/// One line of notation with the number, if any, on its side of the glyph.
struct NotationExample: View {
    let number: String?
    var unit: String?
    let glyph: Glyph
    let before: Bool
    let meaning: String

    var body: some View {
        HStack(spacing: 10) {
            if before, let number { digits(number) }
            GlyphView(glyph, radius: 14, lineWidth: 3, color: Palette.line)
            if !before, let number { digits(number) }
            Spacer()
            Text(meaning)
                .foregroundStyle(Palette.label)
        }
        .frame(maxWidth: 320)
    }

    private func digits(_ number: String) -> some View {
        Numerals.text(number, unit: unit, size: 40)
            .foregroundStyle(Palette.line)
    }
}

/// The day's parts around a ring, ☉ on top and ○ below, each name at its
/// angle clockwise from ☉; the quarter boundaries solid, the eighth ones dotted.
struct ArcWheel: View {
    static let quarters: [(String, Double)] = [
        ("Morning", -45), ("Afternoon", 45), ("Evening", 135), ("Night", 225),
    ]
    static let eighths: [(String, Double)] = [
        ("Forenoon", -22.5), ("Afternoon", 22.5), ("Foreset", 67.5), ("Afterset", 112.5),
        ("Foremid", 157.5), ("Aftermid", 202.5), ("Forerise", 247.5), ("Afterrise", 292.5),
    ]

    let names: [(String, Double)]

    var body: some View {
        GeometryReader { geometry in
            let c = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let r = min(geometry.size.width, geometry.size.height) / 2 - 44
            ZStack {
                Circle().stroke(Palette.line.opacity(0.25), lineWidth: 1).frame(width: 2 * r, height: 2 * r)
                Rectangle().fill(Palette.line.opacity(0.5)).frame(width: 2 * r, height: 1)
                Rectangle().fill(Palette.line.opacity(0.5)).frame(width: 1, height: 2 * r)
                ForEach(names.count == 8 ? [45.0, 135.0] : [], id: \.self) { angle in
                    Path { p in
                        p.move(to: CGPoint(x: c.x, y: c.y - r))
                        p.addLine(to: CGPoint(x: c.x, y: c.y + r))
                    }
                    .stroke(Palette.line.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [2, 3]))
                    .rotationEffect(.degrees(angle))
                }
                GlyphView(.noon, radius: 9, lineWidth: 2.2, color: Palette.line).position(x: c.x, y: c.y - r - 16)
                GlyphView(.midnight, radius: 9, lineWidth: 2.2, color: Palette.line).position(x: c.x, y: c.y + r + 16)
                GlyphView(.sunrise, radius: 9, lineWidth: 2.2, color: Palette.line).position(x: c.x - r - 16, y: c.y)
                GlyphView(.sunset, radius: 9, lineWidth: 2.2, color: Palette.line).position(x: c.x + r + 16, y: c.y)
                ForEach(names, id: \.0) { name, angle in
                    let a = angle * .pi / 180
                    Text(name)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(angle > 90 && angle < 270 ? Palette.label : Palette.line)
                        .position(x: c.x + (r + 34) * sin(a), y: c.y - (r + 22) * cos(a))
                }
            }
        }
    }
}
