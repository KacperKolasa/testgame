import XCTest
@testable import TheGridBlackoutCity

final class DistrictPowerBehaviorTests: XCTestCase {
    func testPoweredDistrictConsumesPowerAndGeneratesCredits() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        state.resources.power = 50
        state.updateDistrict(.residentialBlock) { district in
            district.isRestored = true
            district.isPowered = true
        }

        let summary = EconomyEngine.applyTick(state: &state, delta: 1)

        XCTAssertGreaterThan(summary.creditsGenerated, 0)
        XCTAssertGreaterThan(summary.demandConsumed, 0)
        XCTAssertLessThan(state.resources.power, 50)
    }

    func testUnpoweredDistrictDoesNotConsumeDemandOrEarnCredits() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        state.resources.power = 50
        state.updateDistrict(.residentialBlock) { district in
            district.isRestored = true
            district.isPowered = false
        }

        let summary = EconomyEngine.applyTick(state: &state, delta: 1)

        XCTAssertEqual(summary.creditsGenerated, 0, accuracy: 0.001)
        XCTAssertEqual(summary.demandConsumed, 0, accuracy: 0.001)
        XCTAssertEqual(state.resources.power, 50, accuracy: 0.001)
    }

    func testWaterPlantImprovesStabilityWhilePowered() {
        var withoutWater = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        withoutWater.resources.power = 100
        withoutWater.resources.stability = 60
        withoutWater.updateDistrict(.factoryZone) { district in
            district.isRestored = true
            district.isPowered = true
        }

        var withWater = withoutWater
        withWater.updateDistrict(.waterPlant) { district in
            district.isRestored = true
            district.isPowered = true
        }

        _ = EconomyEngine.applyTick(state: &withoutWater, delta: 1)
        _ = EconomyEngine.applyTick(state: &withWater, delta: 1)

        XCTAssertGreaterThan(withWater.resources.stability, withoutWater.resources.stability)
    }
}
