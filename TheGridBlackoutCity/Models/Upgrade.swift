import Foundation

enum UpgradeCategory: String, Codable, CaseIterable, Identifiable {
    case generation = "Generation"
    case storage = "Storage"
    case stability = "Stability"
    case city = "City Output"
    case automation = "Automation"

    var id: String { rawValue }
}

enum UpgradeID: String, Codable, CaseIterable, Identifiable {
    case handCrankGenerator
    case copperCoils
    case kineticFlywheel
    case solarPanels
    case emergencyGenerator
    case batteryExpansion
    case capacitorBanks
    case insulatedCells
    case reserveProtocol
    case improvedWiring
    case dynamicPricing
    case transitScheduling
    case surgeProtectors
    case transformerUpgrade
    case smartGridBalancing
    case maintenanceCrew
    case autoOperator
    case autoStabilizer
    case autoRepair
    case smartRouting
    case nightCrew
    case offlineDispatch

    var id: String { rawValue }
}

struct UpgradeDefinition: Identifiable, Hashable {
    let id: UpgradeID
    let name: String
    let category: UpgradeCategory
    let baseCost: Double
    let costMultiplier: Double
    let maxLevel: Int
    let description: String
    let effectSummary: String
    let systemImage: String
}

enum PermanentUpgradeID: String, Codable, CaseIterable, Identifiable {
    case legacyTurbines
    case idleGrid
    case civicCredit
    case reserveBanks
    case eventResponse
    case stabilizationTraining

    var id: String { rawValue }
}

struct PermanentUpgradeDefinition: Identifiable, Hashable {
    let id: PermanentUpgradeID
    let name: String
    let baseCost: Int
    let maxLevel: Int
    let description: String
    let effectSummary: String
    let systemImage: String
}

enum UpgradeCatalog {
    static let all: [UpgradeDefinition] = [
        UpgradeDefinition(
            id: .handCrankGenerator,
            name: "Hand Crank Generator",
            category: .generation,
            baseCost: 8,
            costMultiplier: 1.55,
            maxLevel: 12,
            description: "Retune the starter coil for stronger manual generation.",
            effectSummary: "+1 power per tap per level",
            systemImage: "hand.tap"
        ),
        UpgradeDefinition(
            id: .copperCoils,
            name: "Copper Coils",
            category: .generation,
            baseCost: 90,
            costMultiplier: 1.72,
            maxLevel: 8,
            description: "Replace corroded generator windings with clean copper.",
            effectSummary: "+2 power per tap per level",
            systemImage: "bolt.circle"
        ),
        UpgradeDefinition(
            id: .kineticFlywheel,
            name: "Kinetic Flywheel",
            category: .generation,
            baseCost: 260,
            costMultiplier: 1.8,
            maxLevel: 6,
            description: "Store mechanical momentum between taps and pulses.",
            effectSummary: "+0.4 passive power/sec per level",
            systemImage: "circle.hexagongrid"
        ),
        UpgradeDefinition(
            id: .solarPanels,
            name: "Solar Panels",
            category: .generation,
            baseCost: 140,
            costMultiplier: 1.65,
            maxLevel: 10,
            description: "Install rooftop panels on restored blocks.",
            effectSummary: "+0.5 passive power/sec per level",
            systemImage: "sun.max"
        ),
        UpgradeDefinition(
            id: .emergencyGenerator,
            name: "Emergency Generator",
            category: .generation,
            baseCost: 520,
            costMultiplier: 1.9,
            maxLevel: 5,
            description: "A diesel-free backup turbine that wakes during city incidents.",
            effectSummary: "+1.4 passive power/sec during events per level",
            systemImage: "exclamationmark.triangle"
        ),
        UpgradeDefinition(
            id: .batteryExpansion,
            name: "Battery Expansion",
            category: .storage,
            baseCost: 45,
            costMultiplier: 1.55,
            maxLevel: 12,
            description: "Add modular cells to the emergency battery.",
            effectSummary: "+50 battery capacity per level",
            systemImage: "battery.100"
        ),
        UpgradeDefinition(
            id: .capacitorBanks,
            name: "Capacitor Banks",
            category: .storage,
            baseCost: 250,
            costMultiplier: 1.72,
            maxLevel: 8,
            description: "Buffer sudden spikes before they reach the main grid.",
            effectSummary: "+125 battery capacity per level",
            systemImage: "cpu"
        ),
        UpgradeDefinition(
            id: .insulatedCells,
            name: "Insulated Cells",
            category: .storage,
            baseCost: 680,
            costMultiplier: 1.85,
            maxLevel: 6,
            description: "Reduce battery leakage during harsh weather.",
            effectSummary: "+85 capacity and lower city modifier drain",
            systemImage: "shield.lefthalf.filled"
        ),
        UpgradeDefinition(
            id: .reserveProtocol,
            name: "Reserve Protocol",
            category: .storage,
            baseCost: 900,
            costMultiplier: 2.0,
            maxLevel: 5,
            description: "Keep protected reserve charge for blackout recovery.",
            effectSummary: "Blackouts drain 4% less battery per level",
            systemImage: "lock.shield"
        ),
        UpgradeDefinition(
            id: .improvedWiring,
            name: "Improved Wiring",
            category: .city,
            baseCost: 60,
            costMultiplier: 1.6,
            maxLevel: 12,
            description: "Clean line loss out of restored districts.",
            effectSummary: "+10% district income per level",
            systemImage: "point.3.connected.trianglepath.dotted"
        ),
        UpgradeDefinition(
            id: .dynamicPricing,
            name: "Dynamic Pricing",
            category: .city,
            baseCost: 220,
            costMultiplier: 1.7,
            maxLevel: 8,
            description: "Route credits toward high-priority city services.",
            effectSummary: "+6% district income per level",
            systemImage: "chart.line.uptrend.xyaxis"
        ),
        UpgradeDefinition(
            id: .transitScheduling,
            name: "Transit Scheduling",
            category: .city,
            baseCost: 440,
            costMultiplier: 1.8,
            maxLevel: 6,
            description: "Time tram loops around factory shifts and hospital staffing.",
            effectSummary: "+4% income when Transit Hub is powered",
            systemImage: "tram"
        ),
        UpgradeDefinition(
            id: .surgeProtectors,
            name: "Surge Protectors",
            category: .stability,
            baseCost: 120,
            costMultiplier: 1.62,
            maxLevel: 10,
            description: "Clamp dangerous surges before they cascade into outages.",
            effectSummary: "+0.05 stability/sec and stronger surge rewards",
            systemImage: "waveform.path.ecg"
        ),
        UpgradeDefinition(
            id: .transformerUpgrade,
            name: "Transformer Upgrade",
            category: .stability,
            baseCost: 320,
            costMultiplier: 1.78,
            maxLevel: 8,
            description: "Modern transformers tolerate industrial loads with less heat.",
            effectSummary: "Reduces overload and factory penalties",
            systemImage: "bolt.horizontal.circle"
        ),
        UpgradeDefinition(
            id: .smartGridBalancing,
            name: "Smart Grid Balancing",
            category: .stability,
            baseCost: 760,
            costMultiplier: 1.85,
            maxLevel: 7,
            description: "Predictive relays rebalance the live city every second.",
            effectSummary: "+0.08 stability/sec and lower active demand",
            systemImage: "network"
        ),
        UpgradeDefinition(
            id: .maintenanceCrew,
            name: "Maintenance Crew",
            category: .stability,
            baseCost: 560,
            costMultiplier: 1.75,
            maxLevel: 6,
            description: "Line crews repair small faults before they become emergencies.",
            effectSummary: "Storm repairs cost less and failures hurt less",
            systemImage: "wrench.adjustable"
        ),
        UpgradeDefinition(
            id: .autoOperator,
            name: "Auto Operator",
            category: .automation,
            baseCost: 180,
            costMultiplier: 1.85,
            maxLevel: 8,
            description: "A relay arm taps the generator while you manage the city.",
            effectSummary: "Auto-taps once per second per level at 30% tap value",
            systemImage: "gearshape.2"
        ),
        UpgradeDefinition(
            id: .autoStabilizer,
            name: "Auto Stabilizer",
            category: .automation,
            baseCost: 700,
            costMultiplier: 1.9,
            maxLevel: 6,
            description: "A control loop assists during surge events.",
            effectSummary: "Adds free surge progress over time",
            systemImage: "dot.radiowaves.left.and.right"
        ),
        UpgradeDefinition(
            id: .autoRepair,
            name: "Auto Repair",
            category: .automation,
            baseCost: 980,
            costMultiplier: 1.95,
            maxLevel: 5,
            description: "Dispatch drones to patch line faults during storms.",
            effectSummary: "Adds storm repair progress over time",
            systemImage: "antenna.radiowaves.left.and.right"
        ),
        UpgradeDefinition(
            id: .smartRouting,
            name: "Smart Routing",
            category: .automation,
            baseCost: 420,
            costMultiplier: 1.78,
            maxLevel: 8,
            description: "Suggests safer load paths and trims avoidable demand.",
            effectSummary: "-5% district demand per level",
            systemImage: "arrow.triangle.turn.up.right.diamond"
        ),
        UpgradeDefinition(
            id: .nightCrew,
            name: "Night Crew",
            category: .automation,
            baseCost: 360,
            costMultiplier: 1.72,
            maxLevel: 8,
            description: "Operators keep markets, depots, and substations earning offline.",
            effectSummary: "+8% offline credits per level",
            systemImage: "moon.stars"
        ),
        UpgradeDefinition(
            id: .offlineDispatch,
            name: "Offline Dispatch",
            category: .automation,
            baseCost: 1100,
            costMultiplier: 2.0,
            maxLevel: 5,
            description: "A schedule board allocates idle crews while the app is closed.",
            effectSummary: "+10% offline credits and power retention per level",
            systemImage: "clock.badge.checkmark"
        )
    ]

    static let permanent: [PermanentUpgradeDefinition] = [
        PermanentUpgradeDefinition(
            id: .legacyTurbines,
            name: "Legacy Turbines",
            baseCost: 1,
            maxLevel: 10,
            description: "Keep the best rebuilt generator assemblies between contracts.",
            effectSummary: "+1 tap power per level",
            systemImage: "bolt"
        ),
        PermanentUpgradeDefinition(
            id: .idleGrid,
            name: "Idle Grid",
            baseCost: 2,
            maxLevel: 8,
            description: "Permanent automation protocols start each city stronger.",
            effectSummary: "+0.25 passive power/sec per level",
            systemImage: "timer"
        ),
        PermanentUpgradeDefinition(
            id: .civicCredit,
            name: "Civic Credit",
            baseCost: 2,
            maxLevel: 8,
            description: "A reputation bonus improves contract payouts.",
            effectSummary: "+5% credit income per level",
            systemImage: "building.columns"
        ),
        PermanentUpgradeDefinition(
            id: .reserveBanks,
            name: "Reserve Banks",
            baseCost: 2,
            maxLevel: 8,
            description: "Begin each rebuild with stronger emergency storage.",
            effectSummary: "+30 starting battery capacity per level",
            systemImage: "battery.100"
        ),
        PermanentUpgradeDefinition(
            id: .eventResponse,
            name: "Event Response",
            baseCost: 3,
            maxLevel: 6,
            description: "Train city crews to extract more value from emergency wins.",
            effectSummary: "+12% event rewards per level",
            systemImage: "person.3.sequence"
        ),
        PermanentUpgradeDefinition(
            id: .stabilizationTraining,
            name: "Stabilization Training",
            baseCost: 3,
            maxLevel: 6,
            description: "Carry lessons from prior blackouts into every new contract.",
            effectSummary: "+0.04 stability recovery/sec per level",
            systemImage: "heart.text.square"
        )
    ]

    static func definition(for id: UpgradeID) -> UpgradeDefinition {
        guard let definition = all.first(where: { $0.id == id }) else {
            preconditionFailure("Missing upgrade definition for \(id.rawValue)")
        }
        return definition
    }

    static func permanentDefinition(for id: PermanentUpgradeID) -> PermanentUpgradeDefinition {
        guard let definition = permanent.first(where: { $0.id == id }) else {
            preconditionFailure("Missing permanent upgrade definition for \(id.rawValue)")
        }
        return definition
    }
}
