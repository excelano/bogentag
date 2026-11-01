// Labels.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

/// The words around the numbers: dates, civil times, zone names.
enum Labels {
    /// `SUN 1 NOV`, or with the year, for a Bogenzeit date.
    static func day(_ day: CalendarDay, withYear: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.setLocalizedDateFormatFromTemplate(withYear ? "EEEdMMMyyyy" : "EEEdMMM")
        return formatter.string(from: day.midnightUTC.addingTimeInterval(43_200)).uppercased()
    }

    /// The civil clock, in the zone and hour cycle of the device, to the
    /// minute that has begun.
    static func clock(_ date: Date) -> String {
        date.formatted(.dateTime.hour().minute())
    }

    /// `CST | UTC−6`, or the offset alone where the zone has no short name.
    static func zone(_ date: Date) -> String {
        let zone = TimeZone.current
        let offset = utcOffset(zone.secondsFromGMT(for: date))
        let style: TimeZone.NameStyle = zone.isDaylightSavingTime(for: date) ? .shortDaylightSaving : .shortStandard
        guard let name = zone.localizedName(for: style, locale: .current), !name.hasPrefix("GMT"), !name.hasPrefix("UTC") else {
            return offset
        }
        return "\(name) | \(offset)"
    }

    static func utcOffset(_ seconds: Int) -> String {
        if seconds == 0 { return "UTC" }
        let sign = seconds < 0 ? "\u{2212}" : "+"
        let hours = abs(seconds) / 3600
        let minutes = abs(seconds) % 3600 / 60
        return minutes == 0 ? "UTC\(sign)\(hours)" : String(format: "UTC%@%d:%02d", sign, hours, minutes)
    }

    /// `RISE 06:34 | SET 17:35`, or what a polar day has instead.
    static func horizon(_ day: SolarDay) -> String {
        guard let sunrise = day.sunrise, let sunset = day.sunset else {
            return day.polar == .alwaysAbove ? "SUN UP ALL DAY" : "SUN DOWN ALL DAY"
        }
        return "RISE \(clock(sunrise)) | SET \(clock(sunset))"
    }
}
