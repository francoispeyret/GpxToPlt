import SwiftUI

@main
struct GPXtoPLTApp: App {
    @StateObject private var langManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(langManager)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            PreferencesView()
                .environmentObject(langManager)
        }
    }
}
