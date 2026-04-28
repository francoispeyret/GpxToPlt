import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case french = "fr"
    case english = "en"
    case spanish = "es"
    case german = "de"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .french:  return "Français"
        case .english: return "English"
        case .spanish: return "Español"
        case .german:  return "Deutsch"
        }
    }

    static func detect() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? ""
        let code = String(preferred.prefix(2)).lowercased()
        return AppLanguage(rawValue: code) ?? .english
    }
}
