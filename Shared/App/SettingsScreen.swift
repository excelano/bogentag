// SettingsScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("SETTINGS")
                    .font(.headline)
                    .foregroundStyle(Palette.line)
                setting("Dial") { DialVariantChoice() }
                setting("Kilosecond decimals") { OffsetDecimalsChoice() }
            }
            .padding(.horizontal)
        }
    }

    private func setting(_ title: String, @ViewBuilder control: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(Palette.label)
            control()
        }
    }
}

/// Fixed-time or span dial.
struct DialVariantChoice: View {
    @AppStorage(Settings.dialVariantKey) private var variant = DialVariant.spans.rawValue

    var body: some View {
        ChoiceButtons(choices: DialVariant.allCases.map { ($0.rawValue, $0.title) }, selection: $variant)
    }
}

/// One, two or three decimals on the offset line: 100 s, 10 s or 1 s steps.
struct OffsetDecimalsChoice: View {
    @AppStorage(Settings.offsetDecimalsKey) private var decimals = Settings.defaultOffsetDecimals

    var body: some View {
        ChoiceButtons(choices: Settings.offsetDecimalsChoices.map { ($0, "0." + String(repeating: "0", count: $0)) },
                      selection: $decimals)
    }
}

/// A row of buttons, one lit: the choice control that reads the same on the
/// watch and the phone.
struct ChoiceButtons<Value: Hashable>: View {
    let choices: [(Value, String)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 6) {
            ForEach(choices, id: \.0) { value, label in
                Button(label) { selection = value }
                    .buttonStyle(ChoiceButtonStyle(selected: value == selection))
            }
        }
    }
}

/// A capsule: the Sun's colour with dark text when chosen, dim otherwise.
struct ChoiceButtonStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.medium).monospacedDigit())
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(selected ? Palette.sun : Palette.line.opacity(0.12), in: Capsule())
            .foregroundStyle(selected ? Palette.night : Palette.line)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
