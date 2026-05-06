import Foundation

struct OfflineProgressResult: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    let elapsed: TimeInterval
    let cappedElapsed: TimeInterval
    let powerGained: Double
    let creditsGained: Double
    let stabilityChange: Double

    var isMeaningful: Bool {
        cappedElapsed >= 60 && (powerGained > 0.1 || creditsGained > 0.1 || abs(stabilityChange) > 0.1)
    }
}

enum OfflineProgressEngine {
    static let maxOfflineSeconds: TimeInterval = 8 * 60 * 60

    static func applyOfflineProgress(state: inout GameState, now: Date = Date()) -> OfflineProgressResult {
        let elapsed = max(0, now.timeIntervalSince(state.lastActiveAt))
        let capped = min(elapsed, maxOfflineSeconds)

        guard capped > 0 else {
            state.lastActiveAt = now
            return OfflineProgressResult(elapsed: elapsed, cappedElapsed: capped, powerGained: 0, creditsGained: 0, stabilityChange: 0)
        }

        EconomyEngine.recalculateDerivedResources(state: &state)

        let passivePerSecond = EconomyEngine.passivePowerPerSecond(state: state, includeEventBonuses: false)
        let demandPerSecond = EconomyEngine.totalDemandPerSecond(state: state)
        let offlineDispatch = Double(state.upgradeLevel(.offlineDispatch))
        let creditMultiplier = (0.42 + Double(state.upgradeLevel(.nightCrew)) * 0.08 + offlineDispatch * 0.10).clamped(to: 0.2...1.25)
        let retentionMultiplier = (1.0 + offlineDispatch * 0.05).clamped(to: 1.0...1.3)

        let startingPower = state.resources.power
        let passivePower = passivePerSecond * capped * retentionMultiplier
        let demand = demandPerSecond * capped
        let available = min(state.resources.batteryCapacity, startingPower + passivePower)
        let coverage = demand > 0 ? min(1, max(0.15, available / demand)) : 1
        state.resources.power = (available - demand).clamped(to: 0...state.resources.batteryCapacity)

        let credits = EconomyEngine.creditsPerSecond(state: state) * capped * coverage * creditMultiplier
        state.resources.credits += credits
        state.stats.runCreditsEarned += credits
        state.stats.allTimeCreditsEarned += credits
        state.stats.runPowerGenerated += passivePower
        state.stats.allTimePowerGenerated += passivePower

        let oldStability = state.resources.stability
        if demand > passivePower + startingPower {
            let deficitRatio = ((demand - passivePower - startingPower) / max(1, state.resources.batteryCapacity)).clamped(to: 0...4)
            state.resources.stability = max(15, state.resources.stability - deficitRatio * 5)
        } else if passivePerSecond >= demandPerSecond {
            state.resources.stability = min(100, state.resources.stability + min(7, capped / 3600))
        }

        state.lastActiveAt = now
        EconomyEngine.recalculateDerivedResources(state: &state)

        return OfflineProgressResult(
            elapsed: elapsed,
            cappedElapsed: capped,
            powerGained: max(0, state.resources.power - startingPower),
            creditsGained: credits,
            stabilityChange: state.resources.stability - oldStability
        )
    }
}
