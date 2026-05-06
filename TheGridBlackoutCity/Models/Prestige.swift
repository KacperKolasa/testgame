import Foundation

struct PrestigeState: Codable, Equatable {
    var prestigeCount: Int
    var gridTokens: Int
    var totalGridTokensEarned: Int
    var permanentUpgradeLevels: [String: Int]
    var currentCityModifier: CityModifierID
    var unlockedCityModifiers: [CityModifierID]
    var populationLegacyBonus: Int

    static let initial = PrestigeState(
        prestigeCount: 0,
        gridTokens: 0,
        totalGridTokensEarned: 0,
        permanentUpgradeLevels: [:],
        currentCityModifier: .standard,
        unlockedCityModifiers: [.standard],
        populationLegacyBonus: 0
    )

    func permanentLevel(_ id: PermanentUpgradeID) -> Int {
        permanentUpgradeLevels[id.rawValue, default: 0]
    }
}

extension PrestigeState {
    private enum CodingKeys: String, CodingKey {
        case prestigeCount
        case gridTokens
        case totalGridTokensEarned
        case permanentUpgradeLevels
        case currentCityModifier
        case unlockedCityModifiers
        case populationLegacyBonus
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prestigeCount = try container.decodeIfPresent(Int.self, forKey: .prestigeCount) ?? 0
        self.gridTokens = try container.decodeIfPresent(Int.self, forKey: .gridTokens) ?? 0
        self.totalGridTokensEarned = try container.decodeIfPresent(Int.self, forKey: .totalGridTokensEarned) ?? gridTokens
        self.permanentUpgradeLevels = try container.decodeIfPresent([String: Int].self, forKey: .permanentUpgradeLevels) ?? [:]
        self.currentCityModifier = try container.decodeIfPresent(CityModifierID.self, forKey: .currentCityModifier) ?? .standard
        self.unlockedCityModifiers = try container.decodeIfPresent([CityModifierID].self, forKey: .unlockedCityModifiers) ?? [.standard]
        if !self.unlockedCityModifiers.contains(.standard) {
            self.unlockedCityModifiers.insert(.standard, at: 0)
        }
        self.populationLegacyBonus = try container.decodeIfPresent(Int.self, forKey: .populationLegacyBonus) ?? 0
    }
}
