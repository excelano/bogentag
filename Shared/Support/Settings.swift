// Settings.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation
import SwiftUI

/// What the person chooses about the readout. The standard fixes the
/// values; these choose how finely the dial shows them.
enum Settings {
    /// Decimals of the kilosecond offset on the dial: one is the spec's
    /// display resolution (§5.2), three is exact to the second (§3.7).
    static let dialVariantKey = "dialVariant"
    static let offsetDecimalsKey = "offsetDecimals"
    static let offsetDecimalsChoices = [1, 2, 3]
    /// Two on the dials; the written forms and the widgets keep the spec's one.
    static let defaultOffsetDecimals = 2

    /// The offset's magnitude as `3.5 ks`, `3.52 ks` or `3.525 ks`, floored
    /// toward the past at that resolution like every readout.
    static func offsetKs(_ offset: Double, decimals: Int) -> String {
        let unit = pow(10.0, Double(3 - decimals))
        let units = abs(Int((offset / unit).rounded(.down)))
        let scale = Int(pow(10.0, Double(decimals)))
        return String(format: "%d.%0\(decimals)d ks", units / scale, units % scale)
    }
}
