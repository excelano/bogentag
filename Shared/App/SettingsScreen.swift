// SettingsScreen.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Bogenzeit
import SwiftUI
import WidgetKit

struct SettingsScreen: View {
    #if os(iOS)
    @Environment(SunLocation.self) private var location
    @State private var showsTour = false
    #endif

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("SETTINGS")
                    .font(.headline)
                    .foregroundStyle(Palette.line)
                setting("Dial") { DialVariantChoice() }
                setting("Precision") { PrecisionChoice() }
                #if os(iOS)
                Button("About Bogenzeit") { showsTour = true }
                    .buttonStyle(ChoiceButtonStyle(selected: false))
                WatchFaceButton()
                    .frame(maxWidth: .infinity)
                #endif
            }
            .padding(.horizontal)
        }
        #if os(iOS)
        .sheet(isPresented: $showsTour) {
            TourView().environment(location)
        }
        #endif
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

/// Spans or Kiloseconds dial. The widgets show the same scale, so they are
/// redrawn when it changes.
struct DialVariantChoice: View {
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue

    var body: some View {
        ChoiceButtons(choices: Scale.allCases.map { ($0.rawValue, $0.title) }, selection: $variant)
            .onChange(of: variant) { WidgetCenter.shared.reloadAllTimelines() }
    }
}

/// Low, medium or high, each button showing the decimals it gives the
/// chosen dial's scale: `0`, `0.0`, `0.00` for spans, one more for kiloseconds.
struct PrecisionChoice: View {
    @AppStorage(Settings.precisionKey) private var precision = Precision.standard.rawValue
    @AppStorage(Settings.dialVariantKey, store: AppGroup.defaults) private var variant = Scale.spans.rawValue

    var body: some View {
        let scale = Scale(rawValue: variant) ?? .spans
        ChoiceButtons(choices: Precision.allCases.map { ($0.rawValue, Self.label($0.decimals(for: scale))) },
                      selection: $precision)
    }

    private static func label(_ decimals: Int) -> String {
        decimals == 0 ? "0" : "0." + String(repeating: "0", count: decimals)
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
