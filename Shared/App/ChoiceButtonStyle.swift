// ChoiceButtonStyle.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

/// A capsule: the Sun's colour with dark text when chosen, dim otherwise.
struct ChoiceButtonStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.medium).monospacedDigit())
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(selected ? Palette.sun : Palette.line.opacity(0.12), in: Capsule())
            .foregroundStyle(selected ? Palette.night : Palette.line)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
