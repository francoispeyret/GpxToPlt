import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var langManager: LanguageManager

    var body: some View {
        let s = langManager.strings
        Form {
            Picker(s.languageLabel, selection: Binding(
                get: { langManager.language },
                set: { langManager.set($0) }
            )) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.menu)
        }
        .formStyle(.grouped)
        .navigationTitle(s.preferencesTitle)
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    PreferencesView()
        .environmentObject(LanguageManager())
}
