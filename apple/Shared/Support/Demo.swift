// Demo.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

/// Debug launch arguments for screenshots and simulator checks, which cannot
/// answer the location prompt:
///
///     --demo          Houston on 1 November 2026 at 17:08 UTC, the worked
///                     example of the Bogenzeit spec
///     --dial span     open on that dial variant (fixedTime, span)
///     --civil         open with the civil view over the dial
enum Demo {
    #if DEBUG
    static let active = CommandLine.arguments.contains("--demo")
    static let civil = CommandLine.arguments.contains("--civil")
    static let dial: DialVariant? = {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: "--dial"), index + 1 < arguments.count else { return nil }
        return DialVariant(rawValue: arguments[index + 1])
    }()
    #else
    static let active = false
    static let civil = false
    static let dial: DialVariant? = nil
    #endif

    static let place = AppGroup.Place(latitude: 29.76, longitude: -95.37)
    static let instant = Date(rfc3339: "2026-11-01T17:08:00Z")!

    static func now(_ date: Date) -> Date {
        active ? instant : date
    }
}
