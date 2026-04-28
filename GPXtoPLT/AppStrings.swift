import Foundation

struct AppStrings {
    let appSubtitle: String
    let dropZoneTitle: String
    let dropZoneSubtitle: String
    let clickToChange: String
    let points: String          // use String(format:) with %d
    let elevationBadge: String
    let convertButton: String
    let convertingLabel: String
    let resetButton: String
    let savePanelTitle: String
    let successPrefix: String   // "Converted: " – bold filename appended in UI
    let errorBadFile: String
    let errorWrite: String      // use String(format:) with %@
    let preferencesTitle: String
    let languageLabel: String
    let generalTab: String
}

extension AppLanguage {
    var strings: AppStrings {
        switch self {
        case .french:
            return AppStrings(
                appSubtitle: "Convertisseur de traces GPS",
                dropZoneTitle: "Déposez un fichier GPX ici",
                dropZoneSubtitle: "ou cliquez pour sélectionner",
                clickToChange: "Cliquer pour changer de fichier",
                points: "%d points",
                elevationBadge: "Alt.",
                convertButton: "Convertir en PLT",
                convertingLabel: "Conversion en cours…",
                resetButton: "Réinitialiser",
                savePanelTitle: "Enregistrer le fichier PLT",
                successPrefix: "Converti : ",
                errorBadFile: "Sélectionnez un fichier au format .gpx",
                errorWrite: "Écriture impossible : %@",
                preferencesTitle: "Préférences",
                languageLabel: "Langue",
                generalTab: "Général"
            )
        case .english:
            return AppStrings(
                appSubtitle: "GPS Track Converter",
                dropZoneTitle: "Drop a GPX file here",
                dropZoneSubtitle: "or click to select",
                clickToChange: "Click to change file",
                points: "%d points",
                elevationBadge: "Elev.",
                convertButton: "Convert to PLT",
                convertingLabel: "Converting…",
                resetButton: "Reset",
                savePanelTitle: "Save PLT File",
                successPrefix: "Converted: ",
                errorBadFile: "Please select a .gpx file",
                errorWrite: "Write failed: %@",
                preferencesTitle: "Preferences",
                languageLabel: "Language",
                generalTab: "General"
            )
        case .spanish:
            return AppStrings(
                appSubtitle: "Convertidor de trazas GPS",
                dropZoneTitle: "Suelta un archivo GPX aquí",
                dropZoneSubtitle: "o haz clic para seleccionar",
                clickToChange: "Clic para cambiar el archivo",
                points: "%d puntos",
                elevationBadge: "Alt.",
                convertButton: "Convertir a PLT",
                convertingLabel: "Convirtiendo…",
                resetButton: "Restablecer",
                savePanelTitle: "Guardar archivo PLT",
                successPrefix: "Convertido: ",
                errorBadFile: "Selecciona un archivo con formato .gpx",
                errorWrite: "Error al escribir: %@",
                preferencesTitle: "Preferencias",
                languageLabel: "Idioma",
                generalTab: "General"
            )
        case .german:
            return AppStrings(
                appSubtitle: "GPS-Strecken-Konverter",
                dropZoneTitle: "GPX-Datei hier ablegen",
                dropZoneSubtitle: "oder klicken zum Auswählen",
                clickToChange: "Klicken um Datei zu wechseln",
                points: "%d Punkte",
                elevationBadge: "Höhe",
                convertButton: "In PLT konvertieren",
                convertingLabel: "Konvertierung läuft…",
                resetButton: "Zurücksetzen",
                savePanelTitle: "PLT-Datei speichern",
                successPrefix: "Konvertiert: ",
                errorBadFile: "Bitte eine .gpx-Datei auswählen",
                errorWrite: "Schreiben fehlgeschlagen: %@",
                preferencesTitle: "Einstellungen",
                languageLabel: "Sprache",
                generalTab: "Allgemein"
            )
        }
    }
}
