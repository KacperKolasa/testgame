import Foundation

struct EconomyTickSummary: Equatable {
    var passivePowerGenerated: Double
    var demandConsumed: Double
    var creditsGenerated: Double
    var stabilityDelta: Double
    var powerCoverage: Double
    var blackoutTriggered: Bool
}

enum EconomyEngine {
    static func powerPerTap(state: GameState) -> Double {
        let base = 1.0
        let crank = Double(state.upgradeLevel(.handCrankGenerator))
        let coils = Double(state.upgradeLevel(.copperCoils)) * 2
        let legacy = Double(state.permanentLevel(.legacyTurbines))
        var value = base + crank + coils + legacy

        if state.currentEvent?.type == .festivalNight,
           state.districtState(for: .nightMarket).isPowered {
            value *= 1.4 + (Double(state.upgradeLevel(.nightCrew)) * 0.04)
        }

        return value
    }

    static func passivePowerPerSecond(state: GameState, includeEventBonuses: Bool = true) -> Double {
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        let kinetic = Double(state.upgradeLevel(.kineticFlywheel)) * 0.4
        let permanentIdle = Double(state.permanentLevel(.idleGrid)) * 0.25
        let autoTap = powerPerTap(state: state) * Double(state.upgradeLevel(.autoOperator)) * 0.3
        var solar = Double(state.upgradeLevel(.solarPanels)) * 0.5 * modifier.solarMultiplier

        let solarState = state.districtState(for: .solarFarm)
        if solarState.isRestored && solarState.isPowered {
            solar += (2.8 + Double(solarState.level - 1) * 0.7) * modifier.solarMultiplier
        }

        if state.currentEvent?.type == .stormDamage {
            solar *= state.districtState(for: .waterPlant).isPowered ? 0.55 : 0.35
        }

        if includeEventBonuses, state.currentEvent != nil {
            solar += Double(state.upgradeLevel(.emergencyGenerator)) * 1.4
        }

        return kinetic + permanentIdle + autoTap + solar
    }

    static func restoreCost(for id: DistrictID, state: GameState) -> Double {
        let definition = DistrictCatalog.definition(for: id)
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        return definition.unlockCostPower * (id == .solarFarm ? 1 : modifier.demandMultiplier.clamped(to: 1.0...1.25))
    }

    static func globalUpgradeCost(_ id: UpgradeID, state: GameState) -> Double {
        let definition = UpgradeCatalog.definition(for: id)
        let level = state.upgradeLevel(id)
        return definition.baseCost * pow(definition.costMultiplier, Double(level))
    }

    static func districtUpgradeCost(_ id: DistrictID, state: GameState) -> Double {
        let definition = DistrictCatalog.definition(for: id)
        let currentLevel = state.districtState(for: id).level
        let base = max(35, definition.unlockCostPower * 0.9 + definition.baseIncome * 20)
        return base * pow(1.72, Double(currentLevel - 1))
    }

    static func permanentUpgradeCost(_ id: PermanentUpgradeID, state: GameState) -> Int {
        let definition = UpgradeCatalog.permanentDefinition(for: id)
        let level = state.permanentLevel(id)
        return definition.baseCost + level + Int(Double(level) * 0.65)
    }

    static func totalDemandPerSecond(state: GameState) -> Double {
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        let smartRoutingMultiplier = pow(0.95, Double(state.upgradeLevel(.smartRouting)))
        let balancingMultiplier = pow(0.97, Double(state.upgradeLevel(.smartGridBalancing)))
        let transitMultiplier = state.districtState(for: .transitHub).isPowered ? 0.92 : 1.0
        let insulatedRelief = 1.0 - min(0.12, Double(state.upgradeLevel(.insulatedCells)) * 0.015)
        var demand = 0.0

        for district in state.districts where district.isRestored && district.isPowered {
            let definition = DistrictCatalog.definition(for: district.id)
            var districtDemand = definition.baseDemand

            if district.id == .dataCenter, state.currentEvent?.type == .dataSpike {
                districtDemand *= 1.55
            }

            if district.id == .factoryZone {
                districtDemand *= 1.0 - min(0.18, Double(state.upgradeLevel(.transformerUpgrade)) * 0.025)
            }

            let levelReduction = 1.0 - min(0.28, Double(district.level - 1) * 0.035)
            demand += districtDemand * levelReduction
        }

        return demand * modifier.demandMultiplier * smartRoutingMultiplier * balancingMultiplier * transitMultiplier * insulatedRelief
    }

    static func districtIncomePerSecond(_ district: DistrictState, state: GameState) -> Double {
        guard district.isRestored && district.isPowered else {
            return 0
        }

        let definition = DistrictCatalog.definition(for: district.id)
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        var income = definition.baseIncome
        income *= 1.0 + Double(district.level - 1) * 0.28
        income *= pow(1.10, Double(state.upgradeLevel(.improvedWiring)))
        income *= pow(1.06, Double(state.upgradeLevel(.dynamicPricing)))
        income *= 1.0 + Double(state.permanentLevel(.civicCredit)) * 0.05

        if state.districtState(for: .transitHub).isPowered {
            income *= 1.08 + Double(state.upgradeLevel(.transitScheduling)) * 0.04
        }

        if state.currentEvent?.type == .festivalNight, district.id == .nightMarket {
            income *= 3.0 + Double(state.upgradeLevel(.nightCrew)) * 0.12
        }

        if state.currentEvent?.type == .dataSpike, district.id == .dataCenter {
            income *= 2.6
        }

        if (district.id == .nightMarket || district.id == .dataCenter), modifier.id == .snow {
            income *= modifier.nightAndDataIncomeMultiplier
        }

        return income
    }

    static func creditsPerSecond(state: GameState) -> Double {
        guard state.blackoutTimer <= 0 else {
            return 0
        }

        let rawIncome = state.districts.reduce(0) { partialResult, district in
            partialResult + districtIncomePerSecond(district, state: state)
        }

        return rawIncome * stabilityIncomeMultiplier(stability: state.resources.stability)
    }

    static func stabilityIncomeMultiplier(stability: Double) -> Double {
        switch stability {
        case 80...100:
            return 1.0
        case 50..<80:
            return 0.85
        case 20..<50:
            return 0.60
        case 1..<20:
            return 0.35
        default:
            return 0.0
        }
    }

    static func effectiveBatteryCapacity(state: GameState) -> Double {
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        var capacity = 100.0 + modifier.startingBatteryBonus
        capacity += Double(state.upgradeLevel(.batteryExpansion)) * 50
        capacity += Double(state.upgradeLevel(.capacitorBanks)) * 125
        capacity += Double(state.upgradeLevel(.insulatedCells)) * 85
        capacity += Double(state.permanentLevel(.reserveBanks)) * 30

        let batteryYard = state.districtState(for: .batteryYard)
        if batteryYard.isRestored {
            capacity += 160 + Double(batteryYard.level - 1) * 80
        }

        return capacity
    }

    static func recalculateDerivedResources(state: inout GameState) {
        let capacity = effectiveBatteryCapacity(state: state)
        state.resources.batteryCapacity = capacity
        state.resources.power = state.resources.power.clamped(to: 0...capacity)

        var population = state.prestige.populationLegacyBonus
        var completionWeight = 0.0

        for district in state.districts where district.isRestored {
            let definition = DistrictCatalog.definition(for: district.id)
            let districtPopulation = Int(Double(definition.population) * (1.0 + Double(district.level - 1) * 0.08))
            population += districtPopulation
            completionWeight += definition.completionWeight
        }

        state.resources.populationServed = population
        state.resources.cityCompletion = (completionWeight / DistrictCatalog.totalCompletionWeight).clamped(to: 0...1)
    }

    static func applyTick(state: inout GameState, delta: TimeInterval) -> EconomyTickSummary {
        let safeDelta = max(0, min(delta, 5))
        recalculateDerivedResources(state: &state)

        if state.blackoutTimer > 0 {
            state.blackoutTimer = max(0, state.blackoutTimer - safeDelta)
        }

        let passivePowerPerSecond = passivePowerPerSecond(state: state)
        let passivePower = passivePowerPerSecond * safeDelta
        let demandPerSecond = totalDemandPerSecond(state: state)
        let demand = demandPerSecond * safeDelta
        let powerBeforeDemand = min(state.resources.batteryCapacity, state.resources.power + passivePower)
        let coverage = demand > 0 ? min(1, max(0, powerBeforeDemand / demand)) : 1
        state.resources.power = (powerBeforeDemand - demand).clamped(to: 0...state.resources.batteryCapacity)

        let credits = creditsPerSecond(state: state) * safeDelta * coverage
        state.resources.credits += credits
        state.stats.runCreditsEarned += credits
        state.stats.allTimeCreditsEarned += credits
        state.stats.runPowerGenerated += passivePower
        state.stats.allTimePowerGenerated += passivePower

        var stabilityDelta = stabilityPerSecond(state: state, demandPerSecond: demandPerSecond, passivePowerPerSecond: passivePowerPerSecond, coverage: coverage) * safeDelta
        if state.blackoutTimer > 0 {
            stabilityDelta += 0.04 * safeDelta
        }

        let oldStability = state.resources.stability
        state.resources.stability = (state.resources.stability + stabilityDelta).clamped(to: 0...100)
        var blackoutTriggered = false

        if oldStability > 0, state.resources.stability <= 0, state.blackoutTimer <= 0 {
            blackoutTriggered = true
            applyBlackoutPenalty(state: &state)
        }

        recalculateDerivedResources(state: &state)
        return EconomyTickSummary(
            passivePowerGenerated: passivePower,
            demandConsumed: demand * coverage,
            creditsGenerated: credits,
            stabilityDelta: stabilityDelta,
            powerCoverage: coverage,
            blackoutTriggered: blackoutTriggered
        )
    }

    static func addPowerFromTap(state: inout GameState) -> Double {
        let gain = powerPerTap(state: state)
        state.resources.power = min(state.resources.batteryCapacity, state.resources.power + gain)
        state.stats.runPowerGenerated += gain
        state.stats.allTimePowerGenerated += gain
        state.stats.runTaps += 1
        state.stats.allTimeTaps += 1
        return gain
    }

    private static func stabilityPerSecond(state: GameState, demandPerSecond: Double, passivePowerPerSecond: Double, coverage: Double) -> Double {
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        var delta = 0.0

        for district in state.districts where district.isRestored && district.isPowered {
            let definition = DistrictCatalog.definition(for: district.id)
            var districtDelta = definition.baseStabilityDelta

            if district.id == .factoryZone {
                let transformerRelief = min(0.08, Double(state.upgradeLevel(.transformerUpgrade)) * 0.012)
                districtDelta += transformerRelief
            }

            if district.id == .waterPlant {
                districtDelta *= modifier.waterPlantStabilityMultiplier
            }

            delta += districtDelta
        }

        if demandPerSecond > passivePowerPerSecond {
            let stress = min(1.4, (demandPerSecond - passivePowerPerSecond) / 8.0)
            delta -= stress
        } else if demandPerSecond > 0 {
            delta += 0.04
        }

        if coverage < 1 {
            delta -= (1 - coverage) * 3.2
        }

        let reserveRatio = state.resources.batteryCapacity > 0 ? state.resources.power / state.resources.batteryCapacity : 0
        if reserveRatio > 0.55 {
            delta += 0.05
        } else if reserveRatio < 0.08, demandPerSecond > 0 {
            delta -= 0.18
        }

        delta += Double(state.upgradeLevel(.surgeProtectors)) * 0.05
        delta += Double(state.upgradeLevel(.smartGridBalancing)) * 0.08
        delta += Double(state.permanentLevel(.stabilizationTraining)) * 0.04

        if state.currentEvent?.type == .stormDamage {
            delta -= state.districtState(for: .waterPlant).isPowered ? 0.06 : 0.14
        }

        if state.currentEvent?.type == .dataSpike, state.resources.stability < 45 {
            delta -= 0.18
        }

        if demandPerSecond == 0, state.resources.stability < 100 {
            delta += 0.08
        }

        return delta * modifier.stabilityRecoveryMultiplier
    }

    private static func applyBlackoutPenalty(state: inout GameState) {
        let hospital = state.districtState(for: .hospital)
        let batteryYard = state.districtState(for: .batteryYard)
        let reserveLevel = state.upgradeLevel(.reserveProtocol)
        var drainFraction = 0.35 - Double(reserveLevel) * 0.04

        if hospital.isRestored && hospital.isPowered {
            drainFraction -= 0.08 + Double(hospital.level - 1) * 0.015
        }

        if batteryYard.isRestored {
            drainFraction -= 0.04 + Double(batteryYard.level - 1) * 0.01
        }

        drainFraction = drainFraction.clamped(to: 0.12...0.35)
        state.resources.power *= (1.0 - drainFraction)
        state.resources.stability = hospital.isPowered ? 14 : 8
        state.blackoutTimer = hospital.isPowered ? 14 : 22

        let entry = EventHistoryEntry(
            type: .powerSurge,
            title: "City Blackout",
            outcome: .blackout,
            message: "Emergency relays tripped. Battery reserves absorbed \(Int(drainFraction * 100))% of stored power.",
            date: Date()
        )
        state.eventHistory.insert(entry, at: 0)
    }
}
