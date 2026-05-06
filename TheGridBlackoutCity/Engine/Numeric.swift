import Foundation

enum NumberFormatters {
    static func compact(_ value: Double, digits: Int = 1) -> String {
        let absValue = abs(value)
        if absValue >= 1_000_000_000 {
            return String(format: "%.\(digits)fB", value / 1_000_000_000)
        }
        if absValue >= 1_000_000 {
            return String(format: "%.\(digits)fM", value / 1_000_000)
        }
        if absValue >= 1_000 {
            return String(format: "%.\(digits)fK", value / 1_000)
        }
        if absValue >= 100 {
            return String(format: "%.0f", value)
        }
        if absValue >= 10 {
            return String(format: "%.1f", value)
        }
        return String(format: "%.1f", value)
    }

    static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(range.upperBound, max(range.lowerBound, self))
    }
}

struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
