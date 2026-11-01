// Palette.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

/// The dial's colors, from the design mockups.
enum Palette {
    static let bezel = Color(hex: 0x0F1726)
    static let night = Color(hex: 0x0A1222)
    static let day = Color(hex: 0x4C86C4)
    static let civilTwilight = Color(hex: 0x2A4470)
    static let nauticalTwilight = Color(hex: 0x1B2D50)
    static let astronomicalTwilight = Color(hex: 0x121F38)
    static let line = Color(hex: 0xF2F5FA)
    static let minorTick = Color(hex: 0x8FA3BF)
    static let majorTick = Color(hex: 0xDDE6F2)
    static let sun = Color(hex: 0xFFE2A0)
    static let label = Color(hex: 0xA9B8CC)
    static let secondary = Color(hex: 0xC9D5E4)
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255, blue: Double(hex & 0xFF) / 255)
    }
}
