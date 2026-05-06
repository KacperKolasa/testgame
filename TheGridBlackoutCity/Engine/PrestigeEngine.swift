import Foundation

enum PrestigeEngine {
    static func canPrestige(state: GameState) -> Bool {
        state.resources.cityCompletion >= 1.0
    }

    static func availableCityModifiers(state: GameState) -> [CityModifierID] {
        var modifiers = Set(state.prestige.unlockedCityModifiers)
        if canPrestige(state: state) || state.prestige.prestigeCount > 0 {
            modifiers.insert(.snow)
        }
        return CityModifierID.allCases.filter { modifiers.contains($0) }
    }

    static func gridTokensAwarded(state: GameState) -> Int {
        let restoredCount = state.districts.filter(\.isRestored).count
        let populationTokens = state.resources.populationServed / 450
        let districtTokens = restoredCount / 2
        let creditTokens = Int(state.stats.runCreditsEarned / 18_000)
        let eventTokens = state.stats.completedEvents / 5
        return max(3, populationTokens + districtTokens + creditTokens + eventTokens)
    }

    static func performPrestige(state: inout GameState, nextModifier: CityModifierID, now: Date = Date()) -> PurchaseResult {
        guard canPrestige(state: state) else {
            return .failure("Restore the full city first")
        }

        var prestige = state.prestige
        let award = gridTokensAwarded(state: state)
        prestige.gridTokens += award
        prestige.totalGridTokensEarned += award
        prestige.prestigeCount += 1
        if !prestige.unlockedCityModifiers.contains(.snow) {
            prestige.unlockedCityModifiers.append(.snow)
        }

        let chosenModifier = availableCityModifiers(state: state).contains(nextModifier) ? nextModifier : .standard
        prestige.currentCityModifier = chosenModifier

        var preservedStats = state.stats
        preservedStats.runCreditsEarned = 0
        preservedStats.runPowerGenerated = 0
        preservedStats.runTaps = 0

        let settings = state.settings
        state = GameState.newGame(now: now, prestige: prestige, settings: settings, stats: preservedStats)
        state.selectedContractModifier = chosenModifier
        return .success("Rebuild contract accepted: +\(award) Grid Tokens")
    }

    static func buyPermanentUpgrade(_ id: PermanentUpgradeID, state: inout GameState) -> PurchaseResult {
        let definition = UpgradeCatalog.permanentDefinition(for: id)
        let level = state.permanentLevel(id)
        guard level < definition.maxLevel else {
            return .failure("Permanent upgrade is at max level")
        }

        let cost = EconomyEngine.permanentUpgradeCost(id, state: state)
        guard state.prestige.gridTokens >= cost else {
            return .failure("Need \(cost) Grid Tokens")
        }

        state.prestige.gridTokens -= cost
        state.incrementPermanentUpgrade(id)
        EconomyEngine.recalculateDerivedResources(state: &state)
        return .success("\(definition.name) improved")
    }
}
