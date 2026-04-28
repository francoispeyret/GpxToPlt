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
