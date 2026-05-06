import XCTest
@testable import TheGridBlackoutCity

final class OfflineProgressTests: XCTestCase {
    func testOfflineProgressAwardsCreditsAndCapsElapsedTime() {
        let start = Date(timeIntervalSince1970: 0)
        var state = GameState.newGame(now: start)
        state.resources.power = 100
        state.updateDistrict(.residentialBlock) { district in
            district.isRestored = true
            district.isPowered = true
        }
        state.setUpgradeLevel(.solarPanels, level: 3)
        state.lastActiveAt = start

        let result = OfflineProgressEngine.applyOfflineProgress(state: &state, now: start.addingTimeInterval(12 * 60 * 60))

        XCTAssertEqual(result.cappedElapsed, OfflineProgressEngine.maxOfflineSeconds)
        XCTAssertGreaterThan(result.creditsGained, 0)
        XCTAssertGreaterThan(state.resources.credits, 0)
    }

    func testOfflineProgressDoesNotExceedBatteryCapacity() {
        let start = Date(timeIntervalSince1970: 0)
        var state = GameState.newGame(now: start)
        state.setUpgradeLevel(.solarPanels, level: 10)
        state.lastActiveAt = start

        _ = OfflineProgressEngine.applyOfflineProgress(state: &state, now: start.addingTimeInterval(2 * 60 * 60))

        XCTAssertLessThanOrEqual(state.resources.power, state.resources.batteryCapacity)
    }
}
