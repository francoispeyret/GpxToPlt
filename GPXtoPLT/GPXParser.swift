import Foundation

enum GPXError: LocalizedError {
    case cannotReadFile
    case parseError(String)
    case noTracks

    var errorDescription: String? {
        switch self {
        case .cannotReadFile:   return "Impossible de lire le fichier."
        case .parseError(let m): return "Fichier GPX invalide : \(m)"
        case .noTracks:         return "Aucune trace GPS trouvée dans le fichier."
        }
    }
}

final class GPXParser: NSObject, XMLParserDelegate {
    private var tracks: [TrackInfo] = []
    private var currentTrackPoints: [TrackPoint] = []
    private var currentSegmentPoints: [TrackPoint] = []
    private var currentTrackName = "Track"
    private var currentLat: Double?
    private var currentLon: Double?
    private var currentEle: Double?
    private var currentTime: Date?
    private var currentText = ""
    private var inTrkpt = false
    private var inTrk = false
    private var parseError: Error?

    private let isoFull: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    private let isoBasic: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    func parse(url: URL) throws -> TrackInfo {
        guard let parser = XMLParser(contentsOf: url) else {
            throw GPXError.cannotReadFile
        }
        parser.delegate = self
        guard parser.parse() else {
            throw GPXError.parseError(parseError?.localizedDescription ?? "Erreur inconnue")
        }
        guard !tracks.isEmpty else { throw GPXError.noTracks }

        if tracks.count == 1 { return tracks[0] }
        return TrackInfo(name: tracks[0].name, points: tracks.flatMap(\.points))
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement element: String,
                namespaceURI: String?, qualifiedName: String?,
                attributes attrs: [String: String] = [:]) {
        currentText = ""
        switch element.lowercased() {
        case "trk":
            inTrk = true
            currentTrackPoints = []
            currentTrackName = "Track"
        case "trkseg":
            currentSegmentPoints = []
        case "trkpt":
            inTrkpt = true
            currentLat = attrs["lat"].flatMap(Double.init)
            currentLon = attrs["lon"].flatMap(Double.init)
            currentEle = nil
            currentTime = nil
        default: break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement element: String,
                namespaceURI: String?, qualifiedName: String?) {
        let text = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        switch element.lowercased() {
        case "name" where inTrk && !inTrkpt:
            if !text.isEmpty { currentTrackName = text }
        case "ele" where inTrkpt:
            currentEle = Double(text)
        case "time" where inTrkpt:
            currentTime = isoFull.date(from: text) ?? isoBasic.date(from: text)
        case "trkpt":
            if let lat = currentLat, let lon = currentLon {
                currentSegmentPoints.append(TrackPoint(
                    latitude: lat, longitude: lon,
                    elevation: currentEle, timestamp: currentTime,
                    isFirstInSegment: currentSegmentPoints.isEmpty
                ))
            }
            inTrkpt = false
        case "trkseg":
            currentTrackPoints.append(contentsOf: currentSegmentPoints)
        case "trk":
            tracks.append(TrackInfo(name: currentTrackName, points: currentTrackPoints))
            inTrk = false
        default: break
        }
        currentText = ""
    }

    func parser(_ parser: XMLParser, parseErrorOccurred error: Error) {
        parseError = error
    }
}
