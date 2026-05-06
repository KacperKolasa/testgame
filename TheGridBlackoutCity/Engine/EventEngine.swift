import Foundation

struct EventTickSummary: Equatable {
    var startedEvent: GameEventType?
    var resolvedEvent: GameEventType?
    var outcome: EventOutcome?
}

enum EventEngine {
    static func startEvent(_ type: GameEventType, state: inout GameState) {
        let definition = EventCatalog.definition(for: type)
        state.currentEvent = ActiveGameEvent(
            type: type,
            duration: definition.duration,
            requiredProgress: adjustedRequiredProgress(type: type, state: state)
        )
    }

    static func tick<R: RandomNumberGenerator>(state: inout GameState, delta: TimeInterval, now: Date = Date(), rng: inout R) -> EventTickSummary {
        let safeDelta = max(0, min(delta, 5))

        if var event = state.currentEvent {
            event.remaining = max(0, event.remaining - safeDelta)
            applyAutomaticProgress(to: &event, state: &state, delta: safeDelta)

            if event.failedCondition {
                complete(event: event, success: false, state: &state, now: now)
                return EventTickSummary(startedEvent: nil, resolvedEvent: event.type, outcome: .failure)
            }

            if event.progress >= event.requiredProgress, event.type != .factoryOverload {
                complete(event: event, success: true, state: &state, now: now)
                return EventTickSummary(startedEvent: nil, resolvedEvent: event.type, outcome: .success)
            }

            if event.remaining <= 0 {
                let success = event.progress >= event.requiredProgress
                complete(event: event, success: success, state: &state, now: now)
                return EventTickSummary(startedEvent: nil, resolvedEvent: event.type, outcome: success ? .success : .failure)
            }

            state.currentEvent = event
            return EventTickSummary(startedEvent: nil, resolvedEvent: nil, outcome: nil)
        }

        guard state.districts.filter({ $0.isRestored }).count >= 2 else {
            return EventTickSummary(startedEvent: nil, resolvedEvent: nil, outcome: nil)
        }

        state.eventCooldown -= safeDelta
        guard state.eventCooldown <= 0 else {
            return EventTickSummary(startedEvent: nil, resolvedEvent: nil, outcome: nil)
        }

        let eventType = chooseEvent(state: state, rng: &rng)
        startEvent(eventType, state: &state)
        state.eventCooldown = nextEventCooldown(state: state, rng: &rng)
        return EventTickSummary(startedEvent: eventType, resolvedEvent: nil, outcome: nil)
    }

    static func perform(action: PlayerEventAction, state: inout GameState, now: Date = Date()) -> PurchaseResult {
        guard var event = state.currentEvent else {
            return .failure("No active event")
        }

        switch (event.type, action) {
        case (.powerSurge, .stabilizeTap):
            event.progress += 1 + Double(state.upgradeLevel(.surgeProtectors)) * 0.05
            if event.progress >= event.requiredProgress {
                complete(event: event, success: true, state: &state, now: now)
                return .success("Surge stabilized")
            }
            state.currentEvent = event
            return .success("Stabilizer charged")

        case (.hospitalEmergency, .prioritizeHospital):
            state.updateDistrict(.hospital) { district in
                if district.isRestored {
                    district.isPowered = true
                }
            }
            state.updateDistrict(.factoryZone) { district in
                if district.isRestored {
                    district.isPowered = false
                }
            }
            state.updateDistrict(.dataCenter) { district in
                if district.isRestored {
                    district.isPowered = false
                }
            }
            event.progress += 4
            state.currentEvent = event
            return .success("Hospital prioritized")

        case (.stormDamage, .repairLines):
            let maintenanceLevel = state.upgradeLevel(.maintenanceCrew)
            let repairCost = max(6, 15 - Double(maintenanceLevel) * 1.4)
            guard state.resources.power >= repairCost else {
                return .failure("Need \(NumberFormatters.compact(repairCost)) power")
            }
            state.resources.power -= repairCost
            let waterBonus = state.districtState(for: .waterPlant).isPowered ? 0.35 : 0
            event.progress += 1 + waterBonus + Double(maintenanceLevel) * 0.03
            if event.progress >= event.requiredProgress {
                complete(event: event, success: true, state: &state, now: now)
                return .success("Storm lines repaired")
            }
            state.currentEvent = event
            return .success("Line segment repaired")

        case (.factoryOverload, .slowProduction):
            state.updateDistrict(.factoryZone) { district in
                if district.isRestored {
                    district.isPowered = false
                }
            }
            state.resources.stability = min(100, state.resources.stability + 9)
            addHistory(type: event.type, outcome: .choice, message: "Factory slowed. Stability recovered while output cooled.", state: &state, now: now)
            state.currentEvent = nil
            return .success("Production slowed")

        case (.factoryOverload, .pushOutput):
            let reward = eventRewardBase(120, state: state)
            state.resources.credits += reward
            state.stats.runCreditsEarned += reward
            state.stats.allTimeCreditsEarned += reward
            let penalty = max(6, 14 - Double(state.upgradeLevel(.transformerUpgrade)) * 1.2)
            state.resources.stability = max(0, state.resources.stability - penalty)
            addHistory(type: event.type, outcome: .choice, message: "Factory output pushed for \(NumberFormatters.compact(reward)) credits at a stability cost.", state: &state, now: now)
            state.currentEvent = nil
            return .success("Output pushed")

        case (.factoryOverload, .maintenance):
            let cost = 35.0
            guard state.resources.power >= cost else {
                return .failure("Need \(NumberFormatters.compact(cost)) power")
            }
            state.resources.power -= cost
            state.resources.stability = min(100, state.resources.stability + 13 + Double(state.upgradeLevel(.maintenanceCrew)))
            let reward = eventRewardBase(45, state: state)
            state.resources.credits += reward
            state.stats.runCreditsEarned += reward
            state.stats.allTimeCreditsEarned += reward
            addHistory(type: event.type, outcome: .choice, message: "Maintenance kept the factory online and earned \(NumberFormatters.compact(reward)) credits.", state: &state, now: now)
            state.currentEvent = nil
            return .success("Maintenance complete")

        case (.festivalNight, .routeMarket):
            state.updateDistrict(.nightMarket) { district in
                if district.isRestored {
                    district.isPowered = true
                }
            }
            event.progress += 6
            state.currentEvent = event
            return .success("Power routed to market")

        case (.dataSpike, .coolServers):
            let cost = 25.0
            guard state.resources.power >= cost else {
                return .failure("Need \(NumberFormatters.compact(cost)) power")
            }
            state.resources.power -= cost
            event.progress += 4
            state.resources.stability = min(100, state.resources.stability + 4)
            if event.progress >= event.requiredProgress {
                complete(event: event, success: true, state: &state, now: now)
                return .success("Data spike contained")
            }
            state.currentEvent = event
            return .success("Servers cooled")

        default:
            return .failure("Action is not valid for this event")
        }
    }

    static func upcomingHint(state: GameState) -> String {
        if state.currentEvent != nil {
            return "Respond to the active emergency."
        }

        let restored = Set(state.districts.filter(\.isRestored).map(\.id))
        if restored.contains(.factoryZone) {
            return "Industrial loads increase event risk."
        }
        if restored.contains(.hospital) {
            return "Hospital dispatch may call for protected power soon."
        }
        return "Restore one more district to bring city incidents online."
    }

    private static func applyAutomaticProgress(to event: inout ActiveGameEvent, state: inout GameState, delta: TimeInterval) {
        switch event.type {
        case .powerSurge:
            event.progress += Double(state.upgradeLevel(.autoStabilizer)) * 0.18 * delta

        case .hospitalEmergency:
            let hospitalPowered = state.districtState(for: .hospital).isPowered
            if hospitalPowered {
                event.progress += delta
            } else {
                event.progress = max(0, event.progress - delta * 0.35)
            }

        case .stormDamage:
            event.progress += Double(state.upgradeLevel(.autoRepair)) * 0.07 * delta

        case .factoryOverload:
            break

        case .festivalNight:
            if state.districtState(for: .nightMarket).isPowered {
                event.progress += delta
            }

        case .dataSpike:
            if state.resources.stability < 28 {
                event.failedCondition = true
            } else if state.districtState(for: .dataCenter).isPowered, state.resources.stability >= 45 {
                event.progress += delta
            }
        }
    }

    private static func complete(event: ActiveGameEvent, success: Bool, state: inout GameState, now: Date) {
        if success {
            applyReward(for: event.type, state: &state)
            state.stats.completedEvents += 1
            addHistory(type: event.type, outcome: .success, message: successMessage(for: event.type), state: &state, now: now)
        } else {
            applyPenalty(for: event.type, state: &state)
            state.stats.failedEvents += 1
            addHistory(type: event.type, outcome: .failure, message: failureMessage(for: event.type), state: &state, now: now)
        }
        state.currentEvent = nil
    }

    private static func applyReward(for type: GameEventType, state: inout GameState) {
        switch type {
        case .powerSurge:
            let reward = eventRewardBase(34 + Double(state.upgradeLevel(.surgeProtectors)) * 5, state: state)
            state.resources.credits += reward
            state.resources.stability = min(100, state.resources.stability + 12)
            state.stats.runCreditsEarned += reward
            state.stats.allTimeCreditsEarned += reward

        case .hospitalEmergency:
            state.prestige.populationLegacyBonus += 40
            state.resources.stability = min(100, state.resources.stability + 8)

        case .stormDamage:
            let reward = eventRewardBase(55, state: state)
            state.resources.credits += reward
            state.resources.stability = min(100, state.resources.stability + 10)
            state.stats.runCreditsEarned += reward
            state.stats.allTimeCreditsEarned += reward

        case .factoryOverload:
            break

        case .festivalNight:
            let nightIncome = EconomyEngine.districtIncomePerSecond(state.districtState(for: .nightMarket), state: state)
            let reward = eventRewardBase(120 + nightIncome * 14, state: state)
            state.resources.credits += reward
            state.stats.runCreditsEarned += reward
            state.stats.allTimeCreditsEarned += reward

        case .dataSpike:
            let dataIncome = EconomyEngine.districtIncomePerSecond(state.districtState(for: .dataCenter), state: state)
            let reward = eventRewardBase(240 + dataIncome * 18, state: state)
            state.resources.credits += reward
            state.resources.stability = min(100, state.resources.stability + 6)
            state.stats.runCreditsEarned += reward
            state.stats.allTimeCreditsEarned += reward
        }

        EconomyEngine.recalculateDerivedResources(state: &state)
    }

    private static func applyPenalty(for type: GameEventType, state: inout GameState) {
        let mitigation = Double(state.upgradeLevel(.maintenanceCrew)) * 0.8
        switch type {
        case .powerSurge:
            state.resources.stability = max(0, state.resources.stability - max(5, 14 - mitigation))
        case .hospitalEmergency:
            state.resources.stability = max(0, state.resources.stability - max(8, 18 - mitigation))
        case .stormDamage:
            let waterReduction = state.districtState(for: .waterPlant).isPowered ? 0.55 : 1.0
            state.resources.stability = max(0, state.resources.stability - max(5, 14 - mitigation) * waterReduction)
            state.resources.power = max(0, state.resources.power - state.resources.batteryCapacity * 0.08 * waterReduction)
        case .factoryOverload:
            state.resources.stability = max(0, state.resources.stability - max(5, 10 - mitigation))
        case .festivalNight:
            state.resources.stability = max(0, state.resources.stability - 3)
        case .dataSpike:
            state.resources.stability = max(0, state.resources.stability - max(8, 18 - mitigation))
            state.resources.power = max(0, state.resources.power - state.resources.batteryCapacity * 0.1)
        }
    }

    private static func addHistory(type: GameEventType, outcome: EventOutcome, message: String, state: inout GameState, now: Date) {
        let title = EventCatalog.definition(for: type).title
        state.eventHistory.insert(
            EventHistoryEntry(type: type, title: title, outcome: outcome, message: message, date: now),
            at: 0
        )
        if state.eventHistory.count > 30 {
            state.eventHistory.removeLast(state.eventHistory.count - 30)
        }
    }

    private static func successMessage(for type: GameEventType) -> String {
        switch type {
        case .powerSurge:
            return "Surge stabilized. The grid recovered and emergency credits were released."
        case .hospitalEmergency:
            return "Hospital circuits held. Emergency population coverage became a permanent civic bonus."
        case .stormDamage:
            return "Storm lines repaired before the outage spread."
        case .factoryOverload:
            return "Factory overload resolved."
        case .festivalNight:
            return "Festival power stayed online and the market paid out."
        case .dataSpike:
            return "Data demand was contained while the servers produced a major payout."
        }
    }

    private static func failureMessage(for type: GameEventType) -> String {
        switch type {
        case .powerSurge:
            return "The surge rolled through weak relays and damaged stability."
        case .hospitalEmergency:
            return "Hospital power dropped during transfer and the grid lost confidence."
        case .stormDamage:
            return "Storm damage spread through exposed feeder lines."
        case .factoryOverload:
            return "Factory relays tripped after no dispatch choice was made."
        case .festivalNight:
            return "The market missed its power window."
        case .dataSpike:
            return "Server demand spiked past the cooling plan."
        }
    }

    private static func eventRewardBase(_ value: Double, state: GameState) -> Double {
        value * (1.0 + Double(state.permanentLevel(.eventResponse)) * 0.12)
    }

    private static func adjustedRequiredProgress(type: GameEventType, state: GameState) -> Double {
        let definition = EventCatalog.definition(for: type)
        if type == .stormDamage, state.districtState(for: .waterPlant).isPowered {
            return max(2, definition.requiredProgress - 0.5)
        }
        if type == .powerSurge {
            return max(4, definition.requiredProgress - Double(state.upgradeLevel(.autoStabilizer)) * 0.25)
        }
        return definition.requiredProgress
    }

    private static func nextEventCooldown<R: RandomNumberGenerator>(state: GameState, rng: inout R) -> TimeInterval {
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        let base = Double.random(in: 118...185, using: &rng)
        return base / modifier.stormChanceMultiplier
    }

    private static func chooseEvent<R: RandomNumberGenerator>(state: GameState, rng: inout R) -> GameEventType {
        var weighted: [(GameEventType, Double)] = [(.powerSurge, 2.0), (.stormDamage, 1.2)]
        let modifier = CityModifierCatalog.definition(for: state.prestige.currentCityModifier)
        weighted = weighted.map { event, weight in
            event == .stormDamage ? (event, weight * modifier.stormChanceMultiplier) : (event, weight)
        }

        if state.districtState(for: .hospital).isRestored {
            weighted.append((.hospitalEmergency, 1.4))
        }
        if state.districtState(for: .factoryZone).isRestored {
            weighted.append((.factoryOverload, state.districtState(for: .factoryZone).isPowered ? 1.8 : 0.8))
        }
        if state.districtState(for: .nightMarket).isRestored {
            weighted.append((.festivalNight, 1.1))
        }
        if state.districtState(for: .dataCenter).isRestored {
            weighted.append((.dataSpike, state.districtState(for: .dataCenter).isPowered ? 1.5 : 0.6))
        }

        let total = weighted.reduce(0) { $0 + $1.1 }
        var roll = Double.random(in: 0..<total, using: &rng)
        for (event, weight) in weighted {
            if roll <= weight {
                return event
            }
            roll -= weight
        }
        return .powerSurge
    }
}
