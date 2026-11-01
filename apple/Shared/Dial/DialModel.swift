// DialModel.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

enum DialVariant: String, CaseIterable, Identifiable {
    /// One turn is 86.4 ks; the horizon moves with the season (Tagbogen spec §4.1).
    case fixedTime
    /// One quarter is 45°; the horizon is level every day (Tagbogen spec §4.2).
    case span

    var id: String { rawValue }

    var title: String {
        switch self {
        case .fixedTime: "Fixed time"
        case .span: "Span"
        }
    }
}

/// The geometry of one dial for one reading. Angles are degrees clockwise
/// from the top, where ☉ sits; ○ is at 180, sunset on the right, sunrise on
/// the left. A chord angle is the angle at which the Sun crosses that height
/// in the evening, nil when it never gets that low today, and 0 when it is
/// that low even at noon.
struct DialModel {
    struct Tick: Equatable {
        let angle: Double
        let major: Bool
    }

    let reading: Reading
    let variant: DialVariant
    let sunAngle: Double
    let sunsetAngle: Double?
    let civilAngle: Double?
    let nauticalAngle: Double?
    let astronomicalAngle: Double?
    let quarterAngles: [Double]
    let ringTicks: [Tick]

    /// The span dial has no span geometry on a polar day and draws fixed time instead.
    var usesSpanGeometry: Bool { variant == .span && reading.polar == nil }

    init(reading: Reading, variant: DialVariant) {
        self.reading = reading
        self.variant = variant
        let day = reading.day
        let spanGeometry = variant == .span && day.polar == nil

        func evening(_ arc: Solar.HalfArc) -> Double? {
            switch arc {
            case .alwaysAbove: return nil
            case .alwaysBelow: return 0
            case .seconds(let s):
                if spanGeometry, let halfDay = day.halfDay, let halfNight = day.halfNightEvening {
                    if s <= halfDay { return s / halfDay * 90 }
                    return min(180, 90 + (s - halfDay) / halfNight * 90)
                }
                return s / 86_400 * 360
            }
        }
        sunsetAngle = evening(day.horizon)
        civilAngle = evening(day.civil)
        nauticalAngle = evening(day.nautical)
        astronomicalAngle = evening(day.astronomical)

        if spanGeometry, case .onArc(let span, _, _) = reading.position {
            sunAngle = reading.anchor == .noon ? span * 0.9 : 180 + span * 0.9
        } else {
            sunAngle = reading.instant.timeIntervalSince(day.noon) / 86_400 * 360
        }

        if let h = sunsetAngle, day.polar == nil {
            quarterAngles = [h / 2, -h / 2, (180 + h) / 2, -(180 + h) / 2]
        } else {
            quarterAngles = []
        }

        var ticks: [Tick] = []
        if spanGeometry, let halfDay = day.halfDay, let morning = day.halfNightMorning, let evening = day.halfNightEvening {
            for i in 0..<Int(halfDay / 1000) + 1 where Double(i) * 1000 < halfDay {
                let a = Double(i) * 1000 / halfDay * 90
                ticks.append(Tick(angle: a, major: i % 5 == 0))
                if i > 0 { ticks.append(Tick(angle: -a, major: i % 5 == 0)) }
            }
            for i in 0..<Int(evening / 1000) + 1 where Double(i) * 1000 < evening {
                ticks.append(Tick(angle: 180 - Double(i) * 1000 / evening * 90, major: i % 5 == 0))
            }
            for i in 1..<Int(morning / 1000) + 1 where Double(i) * 1000 < morning {
                ticks.append(Tick(angle: 180 + Double(i) * 1000 / morning * 90, major: i % 5 == 0))
            }
        } else {
            for i in 0..<87 {
                let a = Double(i) * 1000 / 86_400 * 360
                if a < 360 { ticks.append(Tick(angle: a, major: i % 5 == 0)) }
            }
        }
        ringTicks = ticks
    }
}
