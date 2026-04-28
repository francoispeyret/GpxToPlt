import Foundation

enum PLTError: LocalizedError {
    case noPoints
    var errorDescription: String? { "La trace ne contient aucun point GPS." }
}

struct PLTConverter {

    static func convert(_ track: TrackInfo) throws -> String {
        guard !track.points.isEmpty else { throw PLTError.noPoints }

        var lines = [String]()
        lines.append("OziExplorer Track Point File V2.1")
        lines.append("WGS 84")
        lines.append("Altitude is in Feet")
        lines.append("Reserved 3")
        lines.append("0,2,255,0,0,0,0,0")
        lines.append(String(track.points.count))

        for point in track.points {
            lines.append(formatPoint(point))
        }

        return lines.joined(separator: "\r\n") + "\r\n"
    }

    // MARK: - Private

    private static func formatPoint(_ pt: TrackPoint) -> String {
        let code = pt.isFirstInSegment ? 1 : 0

        let alt: String
        if let ele = pt.elevation {
            alt = String(format: "%.6f", ele * 3.28084)
        } else {
            alt = "-777"
        }

        let delphi: String
        let dateStr: String
        let timeStr: String

        if let ts = pt.timestamp {
            delphi = String(format: "%.7f", delphiDateTime(ts))
            (dateStr, timeStr) = humanDateTime(ts)
        } else {
            delphi = "0"
            dateStr = "00-Jan-00"
            timeStr = "0:00:00"
        }

        return "\(pt.latitude),\(pt.longitude),\(code),\(alt),\(delphi),\(dateStr),\(timeStr)"
    }

    // Days (+ fractional day) since 30 December 1899 00:00:00 UTC
    private static func delphiDateTime(_ date: Date) -> Double {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        var c = DateComponents()
        c.year = 1899; c.month = 12; c.day = 30
        c.hour = 0; c.minute = 0; c.second = 0
        let ref = cal.date(from: c)!
        return date.timeIntervalSince(ref) / 86400.0
    }

    private static let months = ["Jan","Feb","Mar","Apr","May","Jun",
                                  "Jul","Aug","Sep","Oct","Nov","Dec"]

    // Returns ("14-Oct-07", "10:09:57")
    private static func humanDateTime(_ date: Date) -> (String, String) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let c = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        let d = String(format: "%02d", c.day ?? 0)
        let m = months[(c.month ?? 1) - 1]
        let y = String(format: "%02d", (c.year ?? 2000) % 100)
        let h = c.hour ?? 0
        let mi = String(format: "%02d", c.minute ?? 0)
        let s  = String(format: "%02d", c.second ?? 0)
        return ("\(d)-\(m)-\(y)", "\(h):\(mi):\(s)")
    }
}
