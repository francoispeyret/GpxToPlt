import Foundation

struct TrackPoint {
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let timestamp: Date?
    var isFirstInSegment: Bool
}

struct TrackInfo {
    let name: String
    let points: [TrackPoint]

    var pointCount: Int { points.count }
    var startDate: Date? { points.compactMap(\.timestamp).first }
    var endDate: Date? { points.compactMap(\.timestamp).last }
    var hasElevation: Bool { points.contains { $0.elevation != nil } }
    var hasTimestamps: Bool { points.contains { $0.timestamp != nil } }
}

struct ConversionFile: Identifiable {
    let id = UUID()
    let url: URL
    var status: FileStatus = .pending
    var info: TrackInfo?

    enum FileStatus {
        case pending
        case loading
        case ready
        case converting
        case done(String)   // nom du fichier de sortie
        case failed(String) // message d'erreur
    }

    var displayName: String { url.lastPathComponent }
    var isReady: Bool {
        if case .ready = status { return true }
        return false
    }
}
