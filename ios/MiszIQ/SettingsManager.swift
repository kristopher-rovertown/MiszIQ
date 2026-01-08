import SwiftUI

enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @AppStorage("musicEnabled") var musicEnabled: Bool = true
    @AppStorage("soundEffectsEnabled") var soundEffectsEnabled: Bool = true
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
    @AppStorage("themeMode") private var themeModeRaw: String = ThemeMode.system.rawValue

    var themeMode: ThemeMode {
        get { ThemeMode(rawValue: themeModeRaw) ?? .system }
        set {
            themeModeRaw = newValue.rawValue
            objectWillChange.send()
        }
    }

    private init() {}
}
