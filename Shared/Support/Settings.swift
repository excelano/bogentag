// Settings.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import Foundation

/// What the person chooses about the readout. The standard fixes the
/// values; these choose the scale and how finely it is shown. The dial
/// lives in the App Group, so the complications and widgets follow it;
/// they show the low precision whatever is chosen, as they refresh rarely.
enum Settings {
    static let dialVariantKey = "dialVariant"
    static let precisionKey = "precision"

    static var dialVariant: Scale {
        AppGroup.defaults.string(forKey: dialVariantKey).flatMap(Scale.init) ?? .spans
    }
}
