// AppGroup.swift
// Author: David M. Anderson
// Built with AI assistance (Claude, Anthropic)

import Foundation

/// What each app leaves for its own widgets: the coordinates in use.
enum AppGroup {
    /// Config/Tagbogen.xcconfig derives the same id for the entitlements.
    static let identifier = "group.com.excelano.tagbogen"

    static var defaults: UserDefaults { UserDefaults(suiteName: identifier) ?? .standard }

    struct Place: Codable, Equatable, Sendable {
        var latitude: Double
        var longitude: Double
    }

    private static let placeKey = "place"

    static func loadPlace() -> Place? {
        guard let data = defaults.data(forKey: placeKey) else { return nil }
        return try? JSONDecoder().decode(Place.self, from: data)
    }

    static func save(_ place: Place) {
        defaults.set(try? JSONEncoder().encode(place), forKey: placeKey)
    }
}
