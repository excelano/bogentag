// DialModelTests.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import XCTest
@testable import Tagbogen_Watch_App

/// The dial geometry against the mockups, which were drawn for Houston on
/// 1 November 2026 at 11:08 CST.
final class DialModelTests: XCTestCase {
    private let houston = Reading(at: Date(rfc3339: "2026-11-01T17:08:00Z")!, latitude: 29.76, longitude: -95.37)

    func testFixedTimeAnglesFollowTheClock() {
        let m = DialModel(reading: houston, variant: .fixedTime)
        XCTAssertEqual(m.sunAngle, -14.27, accuracy: 0.05)
        XCTAssertEqual(m.sunsetAngle!, 82.64, accuracy: 0.05)
        XCTAssertEqual(m.quarterAngles[0], 41.32, accuracy: 0.05)
        XCTAssertEqual(m.quarterAngles[2], 131.32, accuracy: 0.05)
        XCTAssertEqual(m.ringTicks.count, 87)
        XCTAssertEqual(m.ringTicks.filter(\.major).count, 18)
        XCTAssertFalse(m.usesSpanGeometry)
    }

    func testSpanAnglesAreTheSameEveryDay() {
        let m = DialModel(reading: houston, variant: .span)
        XCTAssertEqual(m.sunAngle, -15.55, accuracy: 0.05)
        XCTAssertEqual(m.sunsetAngle, 90)
        XCTAssertEqual(m.quarterAngles, [45, -45, 135, -135])
        XCTAssertEqual(m.civilAngle!, 95.69, accuracy: 0.1)
        XCTAssertTrue(m.ringTicks.contains(DialModel.Tick(angle: 0, major: true)))
        XCTAssertTrue(m.ringTicks.contains(DialModel.Tick(angle: 180, major: true)))
        XCTAssertTrue(m.usesSpanGeometry)
    }

    func testPolarDayHasNoHorizonAndFallsBackToFixedTime() {
        let tromso = Reading(at: Date(rfc3339: "2027-06-21T12:00:00Z")!, latitude: 69.65, longitude: 18.96)
        let fixed = DialModel(reading: tromso, variant: .fixedTime)
        let span = DialModel(reading: tromso, variant: .span)
        XCTAssertNil(fixed.sunsetAngle)
        XCTAssertTrue(fixed.quarterAngles.isEmpty)
        XCTAssertEqual(span.sunAngle, fixed.sunAngle)
        XCTAssertFalse(span.usesSpanGeometry)
    }

    func testLabels() {
        XCTAssertEqual(Labels.utcOffset(-6 * 3600), "UTC\u{2212}6")
        XCTAssertEqual(Labels.utcOffset(5 * 3600 + 1800), "UTC+5:30")
        XCTAssertEqual(Labels.utcOffset(0), "UTC")
    }
}
