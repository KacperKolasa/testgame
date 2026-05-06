import Foundation

enum GameEventType: String, Codable, CaseIterable, Identifiable {
    case powerSurge
    case hospitalEmergency
    case stormDamage
    case factoryOverload
    case festivalNight
    case dataSpike

    var id: String { rawValue }
}

enum EventOutcome: String, Codable {
    case success
    case failure
    case choice
    case blackout
}

enum PlayerEventAction: String, Codable, CaseIterable, Identifiable {
    case stabilizeTap
    case prioritizeHospital
    case repairLines
    case slowProduction
    case pushOutput
    case maintenance
    case routeMarket
    case coolServers

    var id: String { rawValue }
}

struct EventDefinition: Identifiable, Hashable {
    let id: GameEventType
    let title: String
    let description: String
    let duration: TimeInterval
    let requiredProgress: Double
    let reward: String
    let penalty: String
    let actions: [PlayerEventAction]
    let systemImage: String
}

struct ActiveGameEvent: Codable, Equatable, Identifiable {
    let id: UUID
    let type: GameEventType
    var remaining: TimeInterval
    var duration: TimeInterval
    var progress: Double
    var requiredProgress: Double
    var failedCondition: Bool

    init(type: GameEventType, duration: TimeInterval, requiredProgress: Double) {
        self.id = UUID()
        self.type = type
        self.remaining = duration
        self.duration = duration
        self.progress = 0
        self.requiredProgress = requiredProgress
        self.failedCondition = false
    }

    var progressFraction: Double {
        guard requiredProgress > 0 else { return 0 }
        return min(1, max(0, progress / requiredProgress))
    }

    var timeFraction: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, remaining / duration))
    }
}

struct EventHistoryEntry: Codable, Equatable, Identifiable {
    let id: UUID
    let type: GameEventType
    let title: String
    let outcome: EventOutcome
    let message: String
    let date: Date

    init(type: GameEventType, title: String, outcome: EventOutcome, message: String, date: Date) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.outcome = outcome
        self.message = message
        self.date = date
    }
}

enum EventCatalog {
    static let all: [EventDefinition] = [
        EventDefinition(
            id: .powerSurge,
            title: "Power Surge",
            description: "A transformer is oscillating. Tap stabilize before the surge rolls across the grid.",
            duration: 22,
            requiredProgress: 8,
            reward: "+stability and emergency credits",
            penalty: "-stability",
            actions: [.stabilizeTap],
            systemImage: "bolt.trianglebadge.exclamationmark"
        ),
        EventDefinition(
            id: .hospitalEmergency,
            title: "Hospital Emergency",
            description: "Critical care is transferring patients. Keep the hospital powered until the ward stabilizes.",
            duration: 36,
            requiredProgress: 26,
            reward: "population legacy bonus or credits",
            penalty: "-stability",
            actions: [.prioritizeHospital],
            systemImage: "cross.case"
        ),
        EventDefinition(
            id: .stormDamage,
            title: "Storm Damage",
            description: "Wind has damaged feeder lines. Solar output is reduced until crews repair enough segments.",
            duration: 46,
            requiredProgress: 3,
            reward: "+stability and reduced storm losses",
            penalty: "-stability and battery drain",
            actions: [.repairLines],
            systemImage: "cloud.bolt.rain"
        ),
        EventDefinition(
            id: .factoryOverload,
            title: "Factory Overload",
            description: "The factory is over schedule. Choose safety, output, or maintenance before relays trip.",
            duration: 30,
            requiredProgress: 1,
            reward: "credits, stability, or balanced repair",
            penalty: "-stability if ignored",
            actions: [.slowProduction, .pushOutput, .maintenance],
            systemImage: "exclamationmark.octagon"
        ),
        EventDefinition(
            id: .festivalNight,
            title: "Festival Night",
            description: "The night market can turn surplus power into a citywide morale and credit burst.",
            duration: 50,
            requiredProgress: 30,
            reward: "large Night Market credit payout",
            penalty: "small missed-opportunity stability dip",
            actions: [.routeMarket],
            systemImage: "sparkles"
        ),
        EventDefinition(
            id: .dataSpike,
            title: "Data Spike",
            description: "Demand jumps as restored servers sync city systems. Keep stability above the danger band.",
            duration: 38,
            requiredProgress: 24,
            reward: "large Data Center credit payout",
            penalty: "-stability and battery drain",
            actions: [.coolServers],
            systemImage: "server.rack"
        )
    ]

    static func definition(for type: GameEventType) -> EventDefinition {
        guard let definition = all.first(where: { $0.id == type }) else {
            preconditionFailure("Missing event definition for \(type.rawValue)")
        }
        return definition
    }
}
