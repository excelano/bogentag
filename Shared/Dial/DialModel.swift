// DialModel.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

/// The geometry of one dial for one reading. Angles are degrees clockwise
/// from the top, where ☉ sits; ○ is at 180, sunset on the right, sunrise on
/// the left. A chord angle is the angle at which the Sun crosses that height
/// in the evening, nil when it never gets that low today, and 0 when it is
/// that low even at noon. The ring's ticks are what the dial's angle
/// measures: a kilosecond each on the kilosecond dial, ten spans each on the
/// span dial, with the eighth boundaries long.
struct DialModel {
    struct Tick: Equatable {
        let angle: Double
        let major: Bool
    }

    let reading: Reading
    let variant: Scale
    let sunAngle: Double
    let sunsetAngle: Double?
    let civilAngle: Double?
    let nauticalAngle: Double?
    let astronomicalAngle: Double?
    let eighthAngles: [Double]
    let ringTicks: [Tick]
    /// The current eighth's start and end angles, clockwise, for lighting its arc.
    let eighthArc: (start: Double, end: Double)?

    /// The span dial has no span geometry on a polar day and draws kiloseconds instead.
    var usesSpanGeometry: Bool { variant == .spans && reading.polar == nil }

    init(reading: Reading, variant: Scale) {
        self.reading = reading
        self.variant = variant
        let day = reading.day
        let spanGeometry = variant == .spans && day.polar == nil

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
            eighthAngles = [h / 2, -h / 2, (180 + h) / 2, -(180 + h) / 2]
        } else {
            eighthAngles = []
        }

        var ticks: [Tick] = []
        if spanGeometry {
            for i in 0..<40 {
                ticks.append(Tick(angle: Double(i) * 9, major: i % 5 == 0))
            }
        } else {
            for i in 0..<87 {
                let a = Double(i) * 1000 / 86_400 * 360
                if a < 360 { ticks.append(Tick(angle: a, major: i % 5 == 0)) }
            }
        }
        ringTicks = ticks

        if let h = sunsetAngle, day.polar == nil, let eighth = reading.eighth {
            let rise = 360 - h
            eighthArc = switch eighth {
            case .afterrise: (rise, (rise + 360) / 2)
            case .forenoon: ((rise + 360) / 2, 360)
            case .afternoon: (0, h / 2)
            case .foreset: (h / 2, h)
            case .afterset: (h, (180 + h) / 2)
            case .foremid: ((180 + h) / 2, 180)
            case .aftermid: (180, (180 + rise) / 2)
            case .forerise: ((180 + rise) / 2, rise)
            }
        } else {
            eighthArc = nil
        }
    }
}
