import Foundation

public struct TrackMapPoint: Sendable {
    public let x: Double
    public let y: Double
    public init(x: Double, y: Double) { self.x = x; self.y = y }
}

public struct CircuitPath: Sendable {
    public let outline: [TrackMapPoint]
    public init(outline: [TrackMapPoint]) { self.outline = outline }

    public func positionOnOutline(at fraction: Double) -> TrackMapPoint? {
        guard outline.count >= 2, fraction.isFinite else { return nil }
        let closed = outline + [outline[0]]
        var distances = [0.0]
        for index in 1..<closed.count {
            distances.append(distances[index - 1] + hypot(closed[index].x - closed[index - 1].x,
                                                         closed[index].y - closed[index - 1].y))
        }
        guard let length = distances.last, length > 0 else { return nil }
        let target = fraction.truncatingRemainder(dividingBy: 1) * length
        var low = 0, high = distances.count - 1
        while low < high {
            let middle = (low + high) / 2
            if distances[middle] < target { low = middle + 1 } else { high = middle }
        }
        guard low > 0 else { return closed[0] }
        let ratio = (target - distances[low - 1]) / max(distances[low] - distances[low - 1], 0.001)
        return TrackMapPoint(x: closed[low - 1].x + (closed[low].x - closed[low - 1].x) * ratio,
                             y: closed[low - 1].y + (closed[low].y - closed[low - 1].y) * ratio)
    }
}
