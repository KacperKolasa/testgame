import XCTest
@testable import TheGridBlackoutCity

final class EventEngineTests: XCTestCase {
    func testPowerSurgeCompletesAfterRequiredStabilizeActions() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        EventEngine.startEvent(.powerSurge, state: &state)
        let required = Int(ceil(state.currentEvent?.requiredProgress ?? 0))

        for _ in 0..<required {
            _ = GameEngine.performEventAction(.stabilizeTap, state: &state)
        }

        XCTAssertNil(state.currentEvent)
        XCTAssertEqual(state.stats.completedEvents, 1)
        XCTAssertEqual(state.eventHistory.first?.outcome, .success)
    }

    func testFactoryOverloadCanBeResolvedWithMaintenanceChoice() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        state.resources.power = 100
        state.updateDistrict(.factoryZone) { district in
            district.isRestored = true
            district.isPowered = true
        }
        EventEngine.startEvent(.factoryOverload, state: &state)

        let result = GameEngine.performEventAction(.maintenance, state: &state)

        XCTAssertTrue(result.succeeded)
        XCTAssertNil(state.currentEvent)
        XCTAssertEqual(state.eventHistory.first?.outcome, .choice)
    }

    func testEventGenerationUsesUnlockedDistricts() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        state.eventCooldown = 0
        state.updateDistrict(.residentialBlock) { district in
            district.isRestored = true
        }
        state.updateDistrict(.factoryZone) { district in
            district.isRestored = true
            district.isPowered = true
        }
        var rng = SeededRandomGenerator(seed: 42)

        _ = EventEngine.tick(state: &state, delta: 1, rng: &rng)

        XCTAssertNotNil(state.currentEvent)
    }
}
