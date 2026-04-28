import SwiftUI

private let kLanguageKey = "appLanguage"

class LanguageManager: ObservableObject {
    @Published private(set) var language: AppLanguage

    init() {
        if let saved = UserDefaults.standard.string(forKey: kLanguageKey),
           let lang = AppLanguage(rawValue: saved) {
            language = lang
        } else {
            language = AppLanguage.detect()
        }
    }

    func set(_ lang: AppLanguage) {
        language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: kLanguageKey)
    }

    var strings: AppStrings { language.strings }
}
