import Foundation

enum PurchaseResult: Equatable {
    case success(String)
    case failure(String)

    var message: String {
        switch self {
        case .success(let message), .failure(let message):
            return message
        }
    }

    var succeeded: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}

struct GameTickSummary: Equatable {
    var economy: EconomyTickSummary
    var event: EventTickSummary
}

enum GameEngine {
    static func tick<R: RandomNumberGenerator>(state: inout GameState, delta: TimeInterval, now: Date = Date(), rng: inout R) -> GameTickSummary {
        let economy = EconomyEngine.applyTick(state: &state, delta: delta)
        let event = EventEngine.tick(state: &state, delta: delta, now: now, rng: &rng)
        return GameTickSummary(economy: economy, event: event)
    }

    static func tapGenerator(state: inout GameState) -> Double {
        EconomyEngine.recalculateDerivedResources(state: &state)
        return EconomyEngine.addPowerFromTap(state: &state)
    }

    static func restoreDistrict(_ id: DistrictID, state: inout GameState) -> PurchaseResult {
        let district = state.districtState(for: id)
        guard !district.isRestored else {
            return .failure("District already restored")
        }

        let cost = EconomyEngine.restoreCost(for: id, state: state)
        guard state.resources.power >= cost else {
            return .failure("Need \(NumberFormatters.compact(cost)) power")
        }

        state.resources.power -= cost
        state.updateDistrict(id) { district in
            district.isRestored = true
            district.isPowered = true
        }

        if id == .hospital {
            state.eventCooldown = min(state.eventCooldown, 50)
        }
        if id == .factoryZone {
            state.eventCooldown = min(state.eventCooldown, 35)
        }
        if id == .dataCenter {
            state.eventCooldown = min(state.eventCooldown, 25)
        }

        EconomyEngine.recalculateDerivedResources(state: &state)
        return .success("\(DistrictCatalog.definition(for: id).name) restored")
    }

    static func toggleDistrictPower(_ id: DistrictID, state: inout GameState) -> PurchaseResult {
        let district = state.districtState(for: id)
        guard district.isRestored else {
            return .failure("Restore district first")
        }

        state.updateDistrict(id) { district in
            district.isPowered.toggle()
        }

        let name = DistrictCatalog.definition(for: id).name
        let powered = state.districtState(for: id).isPowered
        return .success(powered ? "\(name) powered" : "\(name) paused")
    }

    static func setDistrictPower(_ id: DistrictID, powered: Bool, state: inout GameState) -> PurchaseResult {
        let district = state.districtState(for: id)
        guard district.isRestored else {
            return .failure("Restore district first")
        }

        state.updateDistrict(id) { district in
            district.isPowered = powered
        }
        return .success(powered ? "Power routed" : "Power rerouted")
    }

    static func upgradeDistrict(_ id: DistrictID, state: inout GameState) -> PurchaseResult {
        let district = state.districtState(for: id)
        guard district.isRestored else {
            return .failure("Restore district first")
        }
        guard district.level < 5 else {
            return .failure("District is fully upgraded")
        }

        let cost = EconomyEngine.districtUpgradeCost(id, state: state)
        guard state.resources.credits >= cost else {
            return .failure("Need \(NumberFormatters.compact(cost)) credits")
        }

        state.resources.credits -= cost
        state.updateDistrict(id) { district in
            district.level += 1
        }
        EconomyEngine.recalculateDerivedResources(state: &state)
        return .success("\(DistrictCatalog.definition(for: id).name) upgraded")
    }

    static func buyUpgrade(_ id: UpgradeID, state: inout GameState) -> PurchaseResult {
        let definition = UpgradeCatalog.definition(for: id)
        let level = state.upgradeLevel(id)
        guard level < definition.maxLevel else {
            return .failure("Upgrade is at max level")
        }

        let cost = EconomyEngine.globalUpgradeCost(id, state: state)
        guard state.resources.credits >= cost else {
            return .failure("Need \(NumberFormatters.compact(cost)) credits")
        }

        state.resources.credits -= cost
        state.incrementUpgrade(id)
        EconomyEngine.recalculateDerivedResources(state: &state)
        return .success("\(definition.name) upgraded")
    }

    static func performEventAction(_ action: PlayerEventAction, state: inout GameState, now: Date = Date()) -> PurchaseResult {
        let result = EventEngine.perform(action: action, state: &state, now: now)
        EconomyEngine.recalculateDerivedResources(state: &state)
        return result
    }
}
