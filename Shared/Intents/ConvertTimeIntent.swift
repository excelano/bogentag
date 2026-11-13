// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import AppIntents
import Bogenzeit
import Foundation

struct ConvertTimeIntent: AppIntent {
    static let title: LocalizedStringResource = "Convert Time to Bogenzeit"
    static let description = IntentDescription("Reads a time today in Bogenzeit for where you are.")

    @Parameter(title: "Time", requestValueDialog: "What time?")
    var time: Date

    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$time) to Bogenzeit")
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let place = AppGroup.loadPlace() else { throw ConvertTimeError.noPlace }
        let reading = Reading(at: try Self.today(at: time), latitude: place.latitude, longitude: place.longitude)
        let precision = (UserDefaults.standard.object(forKey: Settings.precisionKey) as? Int).flatMap(Precision.init) ?? .standard
        let shown = DisplayedPosition(reading, scale: Settings.dialVariant, precision: precision)
        return .result(value: shown.text, dialog: IntentDialog(stringLiteral: Self.spoken(shown, reading)))
    }

    private static func today(at time: Date) throws -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: .now)
        let clock = calendar.dateComponents([.hour, .minute, .second], from: time)
        components.hour = clock.hour
        components.minute = clock.minute
        components.second = clock.second
        guard let date = calendar.date(from: components) else { throw ConvertTimeError.noTime }
        return date
    }

    private static func spoken(_ shown: DisplayedPosition, _ reading: Reading) -> String {
        guard let number = shown.number else {
            return shown.glyph.name.prefix(1).uppercased() + shown.glyph.name.dropFirst()
        }
        let value = shown.unit == nil ? number : "\(number) kiloseconds"
        if let eighth = reading.eighth { return "\(value) \(eighth.name)" }
        return "\(value) \(shown.side == .before ? "before" : "after") \(reading.anchor.name)"
    }
}

enum ConvertTimeError: Error, CustomLocalizedStringResourceConvertible {
    case noPlace
    case noTime

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noPlace: "Open Bogentag once so it knows where you are."
        case .noTime: "That time could not be read."
        }
    }
}

struct BogentagShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ConvertTimeIntent(),
            phrases: [
                "Convert a time with \(.applicationName)",
                "Convert a time to \(.applicationName)",
                "\(.applicationName) convert a time",
                "What is a time in \(.applicationName)",
            ],
            shortTitle: "Convert Time",
            systemImageName: "sun.horizon"
        )
    }
}
