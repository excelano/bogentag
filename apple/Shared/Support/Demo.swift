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
///     --page span     open on that dial (fixedTime, span), or on the watch's
///                     day or settings page
///     --civil         open with the civil view over the dial
///     --decimals 3    show the kilosecond offset with that many decimals
///     --page tour --tour-page 5
///                     open the explainer on that page, counted from 0 (iPhone)
enum Demo {
    #if DEBUG
    static let active = CommandLine.arguments.contains("--demo")
    static let civil = CommandLine.arguments.contains("--civil")
    static let page: String? = argument(after: "--page")
    static let decimals: Int? = argument(after: "--decimals").flatMap(Int.init)
    static let tourPage: Int? = argument(after: "--tour-page").flatMap(Int.init)

    private static func argument(after flag: String) -> String? {
        let arguments = CommandLine.arguments
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
        return arguments[index + 1]
    }
    #else
    static let active = false
    static let civil = false
    static let page: String? = nil
    static let decimals: Int? = nil
    static let tourPage: Int? = nil
    #endif

    static let place = AppGroup.Place(latitude: 29.76, longitude: -95.37)
    static let instant = Date(rfc3339: "2026-11-01T17:08:00Z")!

    static func now(_ date: Date) -> Date {
        active ? instant : date
    }
}
