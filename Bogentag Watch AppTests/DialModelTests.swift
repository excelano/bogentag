// DialModelTests.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import XCTest
@testable import Bogentag_Watch_App

/// The dial geometry against the mockups, which were drawn for Houston on
/// 1 November 2026 at 11:08 CST.
final class DialModelTests: XCTestCase {
    private let houston = Reading(at: Date(rfc3339: "2026-11-01T17:08:00Z")!, latitude: 29.76, longitude: -95.37)

    func testKilosecondAnglesFollowTheClock() {
        let m = DialModel(reading: houston, variant: .kiloseconds)
        XCTAssertEqual(m.sunAngle, -14.27, accuracy: 0.05)
        XCTAssertEqual(m.sunsetAngle!, 82.64, accuracy: 0.05)
        XCTAssertEqual(m.eighthAngles[0], 41.32, accuracy: 0.05)
        XCTAssertEqual(m.eighthAngles[2], 131.32, accuracy: 0.05)
        XCTAssertEqual(m.ringTicks.count, 87)
        XCTAssertEqual(m.ringTicks.filter(\.major).count, 18)
        XCTAssertEqual(m.eighthArc!.start, 318.68, accuracy: 0.05)
        XCTAssertEqual(m.eighthArc!.end, 360)
        XCTAssertFalse(m.usesSpanGeometry)
    }

    func testSpanAnglesAreTheSameEveryDay() {
        let m = DialModel(reading: houston, variant: .spans)
        XCTAssertEqual(m.sunAngle, -15.55, accuracy: 0.05)
        XCTAssertEqual(m.sunsetAngle, 90)
        XCTAssertEqual(m.eighthAngles, [45, -45, 135, -135])
        XCTAssertEqual(m.civilAngle!, 95.69, accuracy: 0.1)
        XCTAssertEqual(m.ringTicks.count, 40)
        XCTAssertEqual(m.ringTicks.filter(\.major).map(\.angle), [0, 45, 90, 135, 180, 225, 270, 315])
        XCTAssertEqual(m.eighthArc?.start, 315)
        XCTAssertEqual(m.eighthArc?.end, 360)
        XCTAssertTrue(m.usesSpanGeometry)
    }

    func testPolarDayHasNoHorizonAndFallsBackToKiloseconds() {
        let tromso = Reading(at: Date(rfc3339: "2027-06-21T12:00:00Z")!, latitude: 69.65, longitude: 18.96)
        let fixed = DialModel(reading: tromso, variant: .kiloseconds)
        let span = DialModel(reading: tromso, variant: .spans)
        XCTAssertNil(fixed.sunsetAngle)
        XCTAssertTrue(fixed.eighthAngles.isEmpty)
        XCTAssertNil(fixed.eighthArc)
        XCTAssertEqual(span.sunAngle, fixed.sunAngle)
        XCTAssertFalse(span.usesSpanGeometry)
    }

    func testLabels() {
        XCTAssertEqual(Labels.utcOffset(-6 * 3600), "UTC\u{2212}6")
        XCTAssertEqual(Labels.utcOffset(5 * 3600 + 1800), "UTC+5:30")
        XCTAssertEqual(Labels.utcOffset(0), "UTC")
        XCTAssertEqual(Labels.utcClock(Date(rfc3339: "2026-11-01T17:08:59Z")!), "17:08")
    }
}
