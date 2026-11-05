// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import XCTest
@testable import Bogentag_Watch_App

final class TimingTests: XCTestCase {
    private let houston = AppGroup.Place(latitude: 29.76, longitude: -95.37)
    private var day: SolarDay {
        SolarDay(CalendarDay(year: 2026, month: 11, day: 1)!, latitude: houston.latitude, longitude: houston.longitude)
    }

    func testSpanTimerAcrossSunsetTakesTheLongerNightSpans() {
        let start = day.instant(atPlace: 290)!
        let end = SpanTimer.end(after: 20, .spans, from: start, at: houston)!
        let expected = 10 * day.daySpan! + 10 * day.halfNightEvening! / 100
        XCTAssertEqual(end.timeIntervalSince(start), expected, accuracy: 0.01)
        XCTAssertGreaterThan(expected, 20 * day.daySpan! + 1)
    }

    func testSpanTimerCountsDownInSpans() {
        let start = day.noon
        let timer = SpanTimer(unit: .spans, amount: 20, place: houston,
                              end: SpanTimer.end(after: 20, .spans, from: start, at: houston), left: 20)
        XCTAssertEqual(timer.remaining(at: start), 20, accuracy: 1e-6)
        XCTAssertEqual(timer.remaining(at: start.addingTimeInterval(5 * day.daySpan!)), 15, accuracy: 1e-6)
        XCTAssertFalse(timer.isDone(at: start))
        XCTAssertTrue(timer.isDone(at: timer.end!))
    }

    func testKilosecondTimerIsFixedLength() {
        let start = day.noon
        XCTAssertEqual(SpanTimer.end(after: 1000, .kiloseconds, from: start, at: houston), start.addingTimeInterval(1000))
    }

    func testStopwatchAddsWhatPassedWhileRunning() {
        let start = day.noon
        var stopwatch = Stopwatch(place: houston, since: start)
        stopwatch.banked = Elapsed(from: start, to: start.addingTimeInterval(day.daySpan! * 3), at: houston)
        let elapsed = stopwatch.elapsed(at: start.addingTimeInterval(day.daySpan! * 2))
        XCTAssertEqual(elapsed.spans!, 5, accuracy: 1e-6)
        XCTAssertEqual(elapsed.seconds, day.daySpan! * 5, accuracy: 1e-6)
    }

    func testSweepIsFixedOnTheSpanDialAndFollowsTimeOnTheKilosecondDial() {
        let reading = Reading(at: day.noon, latitude: houston.latitude, longitude: houston.longitude)
        let elapsed = Elapsed(seconds: 4320, spans: 20)
        XCTAssertEqual(DialModel(reading: reading, variant: .spans).sweep(elapsed), 18, accuracy: 1e-9)
        XCTAssertEqual(DialModel(reading: reading, variant: .kiloseconds).sweep(elapsed), 18, accuracy: 1e-9)
        XCTAssertEqual(DialModel(reading: reading, variant: .kiloseconds).sweep(Elapsed(seconds: 4800, spans: 20)), 20, accuracy: 1e-9)
    }

    func testAmounts() {
        XCTAssertEqual(AmountText.number(12.31, .spans, .medium, .up), "12.4")
        XCTAssertEqual(AmountText.number(12.000_000_01, .spans, .medium, .up), "12.0")
        XCTAssertEqual(AmountText.number(12.399_999_99, .spans, .medium, .down), "12.4")
        XCTAssertEqual(AmountText.number(4320, .kiloseconds, .medium, .down), "4.32")
        XCTAssertEqual(AmountText.amount(1, .spans, .low, .down), "1 span")
        XCTAssertEqual(AmountText.set(20, .spans), "20 spans")
        XCTAssertEqual(AmountText.set(1500, .kiloseconds), "1.5 ks")
    }
}
