import Foundation

enum DistrictID: String, Codable, CaseIterable, Identifiable {
    case residentialBlock
    case hospital
    case factoryZone
    case nightMarket
    case transitHub
    case dataCenter
    case waterPlant
    case downtownCore
    case solarFarm
    case batteryYard

    var id: String { rawValue }
}

enum DistrictCategory: String, Codable, CaseIterable, Identifiable {
    case residential = "Residential"
    case healthcare = "Healthcare"
    case industrial = "Industrial"
    case commerce = "Commerce"
    case transit = "Transit"
    case technology = "Technology"
    case utility = "Utility"
    case civic = "Civic"
    case generation = "Generation"
    case storage = "Storage"

    var id: String { rawValue }
}

struct MapPoint: Codable, Hashable {
    let x: Double
    let y: Double
}

struct DistrictDefinition: Identifiable, Hashable {
    let id: DistrictID
    let name: String
    let category: DistrictCategory
    let unlockCostPower: Double
    let baseDemand: Double
    let baseIncome: Double
    let baseStabilityDelta: Double
    let population: Int
    let completionWeight: Double
    let mapPosition: MapPoint
    let description: String
    let uniqueEffect: String
}

struct DistrictState: Codable, Equatable, Identifiable {
    let id: DistrictID
    var isRestored: Bool
    var isPowered: Bool
    var level: Int

    init(id: DistrictID, isRestored: Bool = false, isPowered: Bool = false, level: Int = 1) {
        self.id = id
        self.isRestored = isRestored
        self.isPowered = isPowered
        self.level = level
    }
}

extension DistrictState {
    private enum CodingKeys: String, CodingKey {
        case id
        case isRestored
        case isPowered
        case level
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(DistrictID.self, forKey: .id)
        self.isRestored = try container.decodeIfPresent(Bool.self, forKey: .isRestored) ?? false
        self.isPowered = try container.decodeIfPresent(Bool.self, forKey: .isPowered) ?? false
        self.level = max(1, try container.decodeIfPresent(Int.self, forKey: .level) ?? 1)
    }
}

enum DistrictCatalog {
    static let all: [DistrictDefinition] = [
        DistrictDefinition(
            id: .residentialBlock,
            name: "Residential Block",
            category: .residential,
            unlockCostPower: 20,
            baseDemand: 1,
            baseIncome: 1,
            baseStabilityDelta: 0.02,
            population: 100,
            completionWeight: 8,
            mapPosition: MapPoint(x: 0.22, y: 0.34),
            description: "A dark apartment cluster waiting for heat, elevators, and streetlights.",
            uniqueEffect: "Low demand, reliable credits, and early population growth."
        ),
        DistrictDefinition(
            id: .hospital,
            name: "Hospital",
            category: .healthcare,
            unlockCostPower: 50,
            baseDemand: 2,
            baseIncome: 0.5,
            baseStabilityDelta: 0.04,
            population: 180,
            completionWeight: 9,
            mapPosition: MapPoint(x: 0.58, y: 0.24),
            description: "Emergency wards, backup elevators, and critical life-support circuits.",
            uniqueEffect: "Protects against blackout penalties and anchors hospital emergencies."
        ),
        DistrictDefinition(
            id: .factoryZone,
            name: "Factory Zone",
            category: .industrial,
            unlockCostPower: 150,
            baseDemand: 5,
            baseIncome: 6,
            baseStabilityDelta: -0.12,
            population: 80,
            completionWeight: 11,
            mapPosition: MapPoint(x: 0.25, y: 0.68),
            description: "Heavy machinery can fund the rebuild, but it hammers fragile transformers.",
            uniqueEffect: "High income with a stability cost until upgraded."
        ),
        DistrictDefinition(
            id: .nightMarket,
            name: "Night Market",
            category: .commerce,
            unlockCostPower: 220,
            baseDemand: 3,
            baseIncome: 3.2,
            baseStabilityDelta: -0.02,
            population: 150,
            completionWeight: 9,
            mapPosition: MapPoint(x: 0.46, y: 0.52),
            description: "Food stalls and neon awnings turn spare watts into fast local commerce.",
            uniqueEffect: "Income and active tapping surge during Festival Night events."
        ),
        DistrictDefinition(
            id: .transitHub,
            name: "Transit Hub",
            category: .transit,
            unlockCostPower: 320,
            baseDemand: 3,
            baseIncome: 2.4,
            baseStabilityDelta: 0.03,
            population: 220,
            completionWeight: 10,
            mapPosition: MapPoint(x: 0.71, y: 0.46),
            description: "Rail signals and tram loops reconnect workers to recovering districts.",
            uniqueEffect: "Reduces total demand and improves citywide district efficiency."
        ),
        DistrictDefinition(
            id: .dataCenter,
            name: "Data Center",
            category: .technology,
            unlockCostPower: 620,
            baseDemand: 7,
            baseIncome: 12,
            baseStabilityDelta: -0.06,
            population: 60,
            completionWeight: 11,
            mapPosition: MapPoint(x: 0.78, y: 0.70),
            description: "Server halls restore banking, logistics, and city communications.",
            uniqueEffect: "Strong late-game income with heat and demand spike events."
        ),
        DistrictDefinition(
            id: .waterPlant,
            name: "Water Plant",
            category: .utility,
            unlockCostPower: 420,
            baseDemand: 1.5,
            baseIncome: 1.1,
            baseStabilityDelta: 0.32,
            population: 260,
            completionWeight: 9,
            mapPosition: MapPoint(x: 0.18, y: 0.83),
            description: "Pumps, filters, and floodgates keep the city calm during bad weather.",
            uniqueEffect: "Improves stability and reduces storm damage."
        ),
        DistrictDefinition(
            id: .downtownCore,
            name: "Downtown Core",
            category: .civic,
            unlockCostPower: 1200,
            baseDemand: 8,
            baseIncome: 18,
            baseStabilityDelta: -0.04,
            population: 420,
            completionWeight: 14,
            mapPosition: MapPoint(x: 0.52, y: 0.78),
            description: "The skyline, municipal grid controls, and the symbolic end of blackout.",
            uniqueEffect: "Big income and required for full city restoration."
        ),
        DistrictDefinition(
            id: .solarFarm,
            name: "Solar Farm",
            category: .generation,
            unlockCostPower: 700,
            baseDemand: 0,
            baseIncome: 0.8,
            baseStabilityDelta: 0.02,
            population: 40,
            completionWeight: 9,
            mapPosition: MapPoint(x: 0.82, y: 0.18),
            description: "A hillside field of panels that feeds passive power back into the city.",
            uniqueEffect: "Generates passive power, stronger in clear weather and weaker in storms."
        ),
        DistrictDefinition(
            id: .batteryYard,
            name: "Battery Yard",
            category: .storage,
            unlockCostPower: 860,
            baseDemand: 0.8,
            baseIncome: 0.6,
            baseStabilityDelta: 0.07,
            population: 30,
            completionWeight: 10,
            mapPosition: MapPoint(x: 0.64, y: 0.86),
            description: "Container batteries, reserve relays, and emergency load buffers.",
            uniqueEffect: "Raises storage capacity and cushions outages."
        )
    ]

    static let totalCompletionWeight = all.reduce(0) { $0 + $1.completionWeight }

    static func definition(for id: DistrictID) -> DistrictDefinition {
        guard let definition = all.first(where: { $0.id == id }) else {
            preconditionFailure("Missing district definition for \(id.rawValue)")
        }
        return definition
    }

    static func initialStates() -> [DistrictState] {
        DistrictID.allCases.map { DistrictState(id: $0) }
    }
}
