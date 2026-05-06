import Foundation

enum CityModifierID: String, Codable, CaseIterable, Identifiable {
    case standard
    case snow

    var id: String { rawValue }
}

struct CityModifierDefinition: Identifiable, Hashable {
    let id: CityModifierID
    let name: String
    let subtitle: String
    let demandMultiplier: Double
    let solarMultiplier: Double
    let stabilityRecoveryMultiplier: Double
    let batteryDrainMultiplier: Double
    let stormChanceMultiplier: Double
    let waterPlantStabilityMultiplier: Double
    let nightAndDataIncomeMultiplier: Double
    let startingBatteryBonus: Double
    let description: String
}

enum CityModifierCatalog {
    static let standard = CityModifierDefinition(
        id: .standard,
        name: "Standard City",
        subtitle: "Baseline contract",
        demandMultiplier: 1.0,
        solarMultiplier: 1.0,
        stabilityRecoveryMultiplier: 1.0,
        batteryDrainMultiplier: 1.0,
        stormChanceMultiplier: 1.0,
        waterPlantStabilityMultiplier: 1.0,
        nightAndDataIncomeMultiplier: 1.0,
        startingBatteryBonus: 0,
        description: "Balanced weather, normal demand, and steady rebuild pacing."
    )

    static let snow = CityModifierDefinition(
        id: .snow,
        name: "Snow City",
        subtitle: "Heating demand contract",
        demandMultiplier: 1.18,
        solarMultiplier: 0.82,
        stabilityRecoveryMultiplier: 0.86,
        batteryDrainMultiplier: 1.08,
        stormChanceMultiplier: 1.15,
        waterPlantStabilityMultiplier: 1.05,
        nightAndDataIncomeMultiplier: 1.0,
        startingBatteryBonus: 25,
        description: "Heating loads raise baseline demand. Stability upgrades matter earlier."
    )

    static let all: [CityModifierDefinition] = [standard, snow]

    static func definition(for id: CityModifierID) -> CityModifierDefinition {
        guard let definition = all.first(where: { $0.id == id }) else {
            preconditionFailure("Missing city modifier definition for \(id.rawValue)")
        }
        return definition
    }
}
