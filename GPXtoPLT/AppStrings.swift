import Foundation

struct AppStrings {
    let appSubtitle: String
    let dropZoneTitle: String
    let dropZoneSubtitle: String
    let filesLoaded: String       // use String(format:) with %d
    let dropMoreFiles: String
    let points: String            // use String(format:) with %d
    let elevationBadge: String
    let convertButton: String
    let convertAllButton: String  // use String(format:) with %d
    let convertingLabel: String
    let resetButton: String
    let outputFolderLabel: String
    let sameAsSource: String
    let chooseFolderButton: String
    let chooseFolderTitle: String
    let successMultiple: String   // use String(format:) with %d
    let partialSuccess: String    // use String(format:) with %d, %d (ok, total)
    let errorBadFile: String
    let errorWrite: String        // use String(format:) with %@
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
                dropZoneTitle: "Déposez des fichiers GPX ici",
                dropZoneSubtitle: "ou cliquez pour sélectionner",
                filesLoaded: "%d fichier(s) chargé(s)",
                dropMoreFiles: "Déposer d'autres fichiers ou cliquer pour ajouter",
                points: "%d points",
                elevationBadge: "Alt.",
                convertButton: "Convertir en PLT",
                convertAllButton: "Convertir %d fichier(s)",
                convertingLabel: "Conversion en cours…",
                resetButton: "Réinitialiser",
                outputFolderLabel: "Dossier de sortie",
                sameAsSource: "Même dossier que la source",
                chooseFolderButton: "Choisir…",
                chooseFolderTitle: "Choisir le dossier de sortie",
                successMultiple: "%d fichier(s) converti(s) avec succès",
                partialSuccess: "%d/%d fichier(s) converti(s)",
                errorBadFile: "Sélectionnez un fichier au format .gpx",
                errorWrite: "Écriture impossible : %@",
                preferencesTitle: "Préférences",
                languageLabel: "Langue",
                generalTab: "Général"
            )
        case .english:
            return AppStrings(
                appSubtitle: "GPS Track Converter",
                dropZoneTitle: "Drop GPX files here",
                dropZoneSubtitle: "or click to select",
                filesLoaded: "%d file(s) loaded",
                dropMoreFiles: "Drop more files or click to add",
                points: "%d points",
                elevationBadge: "Elev.",
                convertButton: "Convert to PLT",
                convertAllButton: "Convert %d file(s)",
                convertingLabel: "Converting…",
                resetButton: "Reset",
                outputFolderLabel: "Output folder",
                sameAsSource: "Same folder as source",
                chooseFolderButton: "Choose…",
                chooseFolderTitle: "Choose output folder",
                successMultiple: "%d file(s) converted successfully",
                partialSuccess: "%d/%d file(s) converted",
                errorBadFile: "Please select a .gpx file",
                errorWrite: "Write failed: %@",
                preferencesTitle: "Preferences",
                languageLabel: "Language",
                generalTab: "General"
            )
        case .spanish:
            return AppStrings(
                appSubtitle: "Convertidor de trazas GPS",
                dropZoneTitle: "Suelta archivos GPX aquí",
                dropZoneSubtitle: "o haz clic para seleccionar",
                filesLoaded: "%d archivo(s) cargado(s)",
                dropMoreFiles: "Suelta más archivos o haz clic para añadir",
                points: "%d puntos",
                elevationBadge: "Alt.",
                convertButton: "Convertir a PLT",
                convertAllButton: "Convertir %d archivo(s)",
                convertingLabel: "Convirtiendo…",
                resetButton: "Restablecer",
                outputFolderLabel: "Carpeta de salida",
                sameAsSource: "Misma carpeta que la fuente",
                chooseFolderButton: "Elegir…",
                chooseFolderTitle: "Elegir carpeta de salida",
                successMultiple: "%d archivo(s) convertido(s) correctamente",
                partialSuccess: "%d/%d archivo(s) convertido(s)",
                errorBadFile: "Selecciona un archivo con formato .gpx",
                errorWrite: "Error al escribir: %@",
                preferencesTitle: "Preferencias",
                languageLabel: "Idioma",
                generalTab: "General"
            )
        case .german:
            return AppStrings(
                appSubtitle: "GPS-Strecken-Konverter",
                dropZoneTitle: "GPX-Dateien hier ablegen",
                dropZoneSubtitle: "oder klicken zum Auswählen",
                filesLoaded: "%d Datei(en) geladen",
                dropMoreFiles: "Weitere Dateien ablegen oder klicken zum Hinzufügen",
                points: "%d Punkte",
                elevationBadge: "Höhe",
                convertButton: "In PLT konvertieren",
                convertAllButton: "%d Datei(en) konvertieren",
                convertingLabel: "Konvertierung läuft…",
                resetButton: "Zurücksetzen",
                outputFolderLabel: "Ausgabeordner",
                sameAsSource: "Gleicher Ordner wie Quelle",
                chooseFolderButton: "Wählen…",
                chooseFolderTitle: "Ausgabeordner wählen",
                successMultiple: "%d Datei(en) erfolgreich konvertiert",
                partialSuccess: "%d/%d Datei(en) konvertiert",
                errorBadFile: "Bitte eine .gpx-Datei auswählen",
                errorWrite: "Schreiben fehlgeschlagen: %@",
                preferencesTitle: "Einstellungen",
                languageLabel: "Sprache",
                generalTab: "Allgemein"
            )
        }
    }
}
