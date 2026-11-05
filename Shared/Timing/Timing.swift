// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation
import Observation
import UserNotifications

struct Elapsed: Codable, Equatable, Sendable {
    var seconds: Double
    var spans: Double?

    static let zero = Elapsed(seconds: 0, spans: 0)

    init(seconds: Double, spans: Double?) {
        self.seconds = seconds
        self.spans = spans
    }

    init(from start: Date, to end: Date, at place: AppGroup.Place) {
        let duration = SolarDuration(from: start, to: end, latitude: place.latitude, longitude: place.longitude)
        self.init(seconds: duration.seconds, spans: duration.spans)
    }

    static func + (a: Elapsed, b: Elapsed) -> Elapsed {
        Elapsed(seconds: a.seconds + b.seconds, spans: a.spans.flatMap { x in b.spans.map { x + $0 } })
    }

    static func - (a: Elapsed, b: Elapsed) -> Elapsed {
        Elapsed(seconds: a.seconds - b.seconds, spans: a.spans.flatMap { x in b.spans.map { x - $0 } })
    }
}

enum TimerUnit: String, Codable, CaseIterable, Sendable {
    case spans
    case kiloseconds

    init(_ scale: Scale) {
        self = scale == .spans ? .spans : .kiloseconds
    }

    var scale: Scale { self == .spans ? .spans : .kiloseconds }
}

struct SpanTimer: Codable, Equatable, Sendable {
    let unit: TimerUnit
    let amount: Double
    var place: AppGroup.Place
    var end: Date?
    var left: Double

    static func end(after amount: Double, _ unit: TimerUnit, from now: Date, at place: AppGroup.Place) -> Date? {
        switch unit {
        case .spans:
            Reading(at: now, latitude: place.latitude, longitude: place.longitude).after(spans: amount)
        case .kiloseconds:
            now.addingTimeInterval(amount)
        }
    }

    func remaining(at now: Date) -> Double {
        guard let end else { return left }
        guard now < end else { return 0 }
        switch unit {
        case .spans: return max(0, Elapsed(from: now, to: end, at: place).spans ?? 0)
        case .kiloseconds: return end.timeIntervalSince(now)
        }
    }

    func isDone(at now: Date) -> Bool {
        end.map { now >= $0 } ?? false
    }
}

struct Stopwatch: Codable, Equatable, Sendable {
    var place: AppGroup.Place
    var since: Date?
    var banked = Elapsed.zero
    var laps: [Elapsed] = []

    func elapsed(at now: Date) -> Elapsed {
        guard let since else { return banked }
        return banked + Elapsed(from: since, to: now, at: place)
    }
}

@MainActor @Observable
final class Timing {
    private(set) var timer: SpanTimer? {
        didSet { save(timer, Self.timerKey) }
    }
    private(set) var stopwatch: Stopwatch? {
        didSet { save(stopwatch, Self.stopwatchKey) }
    }

    private static let timerKey = "timer"
    private static let stopwatchKey = "stopwatch"
    private static let alertID = "timer"

    init() {
        timer = Self.load(Self.timerKey)
        stopwatch = Self.load(Self.stopwatchKey)
    }

    func startTimer(_ amount: Double, _ unit: TimerUnit, at now: Date, place: AppGroup.Place) {
        guard let end = SpanTimer.end(after: amount, unit, from: now, at: place) else { return }
        let started = SpanTimer(unit: unit, amount: amount, place: place, end: end, left: amount)
        timer = started
        announce(started)
    }

    func pauseTimer(at now: Date) {
        guard var paused = timer, paused.end != nil else { return }
        paused.left = paused.remaining(at: now)
        paused.end = nil
        timer = paused
        withdraw()
    }

    func resumeTimer(at now: Date, place: AppGroup.Place) {
        guard var resumed = timer, resumed.end == nil,
              let end = SpanTimer.end(after: resumed.left, resumed.unit, from: now, at: place) else { return }
        resumed.place = place
        resumed.end = end
        timer = resumed
        announce(resumed)
    }

    func clearTimer() {
        timer = nil
        withdraw()
    }

    func runStopwatch(at now: Date, place: AppGroup.Place) {
        var running = stopwatch ?? Stopwatch(place: place)
        guard running.since == nil else { return }
        running.since = now
        stopwatch = running
    }

    func stopStopwatch(at now: Date) {
        guard var stopped = stopwatch, stopped.since != nil else { return }
        stopped.banked = stopped.elapsed(at: now)
        stopped.since = nil
        stopwatch = stopped
    }

    func lap(at now: Date) {
        guard let total = stopwatch?.elapsed(at: now) else { return }
        stopwatch?.laps.append(total)
    }

    func resetStopwatch() {
        stopwatch = nil
    }

    private func announce(_ timer: SpanTimer) {
        guard let end = timer.end else { return }
        let body = AmountText.set(timer.amount, timer.unit)
        Task {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [Self.alertID])
            guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true,
                  self.timer?.end == end else { return }
            let content = UNMutableNotificationContent()
            content.title = "Timer done"
            content.body = body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, end.timeIntervalSinceNow), repeats: false)
            try? await center.add(UNNotificationRequest(identifier: Self.alertID, content: content, trigger: trigger))
        }
    }

    private func withdraw() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.alertID])
        center.removeDeliveredNotifications(withIdentifiers: [Self.alertID])
    }

    private func save<Value: Encodable>(_ value: Value?, _ key: String) {
        UserDefaults.standard.set(value.flatMap { try? JSONEncoder().encode($0) }, forKey: key)
    }

    private static func load<Value: Decodable>(_ key: String) -> Value? {
        UserDefaults.standard.data(forKey: key).flatMap { try? JSONDecoder().decode(Value.self, from: $0) }
    }

    func arcs(on model: DialModel, at now: Date) -> [TimingArc] {
        var arcs: [TimingArc] = []
        if let timer, let end = timer.end, now < end {
            let sweep = model.sweep(Elapsed(from: now, to: end, at: timer.place))
            arcs.append(TimingArc(kind: .timer, from: model.sunAngle, to: model.sunAngle + sweep))
        }
        if let stopwatch, stopwatch.since != nil {
            let sweep = model.sweep(stopwatch.elapsed(at: now))
            arcs.append(TimingArc(kind: .stopwatch, from: model.sunAngle - sweep, to: model.sunAngle))
        }
        return arcs
    }
}

final class TimerAlert: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = TimerAlert()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}

enum AmountText {
    static func number(_ amount: Double, _ unit: TimerUnit, _ precision: Precision,
                       _ rounding: FloatingPointRoundingRule) -> String {
        let value = unit == .spans ? amount : amount / 1000
        let decimals = precision.decimals(for: unit.scale)
        let factor = pow(10, Double(decimals))
        let nudge = rounding == .up ? -1e-6 : 1e-6
        let steps = max(0, (value * factor + nudge).rounded(rounding))
        return String(format: "%.\(decimals)f", steps / factor)
    }

    static func unit(_ number: String, _ unit: TimerUnit) -> String {
        guard unit == .spans else { return "ks" }
        return number == "1" ? "span" : "spans"
    }

    static func trimmed(_ amount: Double, _ unit: TimerUnit) -> String {
        var shown = number(amount, unit, .high, .toNearestOrAwayFromZero)
        while shown.contains("."), shown.hasSuffix("0") || shown.hasSuffix(".") {
            shown.removeLast()
        }
        return shown
    }

    static func set(_ amount: Double, _ unit: TimerUnit) -> String {
        let shown = trimmed(amount, unit)
        return "\(shown) \(self.unit(shown, unit))"
    }

    static func amount(_ amount: Double, _ unit: TimerUnit, _ precision: Precision,
                       _ rounding: FloatingPointRoundingRule) -> String {
        let shown = number(amount, unit, precision, rounding)
        return "\(shown) \(self.unit(shown, unit))"
    }
}

struct TimingArc: Equatable {
    enum Kind {
        case timer
        case stopwatch
    }

    let kind: Kind
    let from: Double
    let to: Double
}

extension DialModel {
    func sweep(_ elapsed: Elapsed) -> Double {
        let degrees = usesSpanGeometry ? (elapsed.spans.map { $0 * 0.9 } ?? elapsed.seconds / 240) : elapsed.seconds / 240
        return min(359.5, max(0, degrees))
    }
}
