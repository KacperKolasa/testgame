import XCTest
@testable import TheGridBlackoutCity

final class EconomyEngineTests: XCTestCase {
    func testPowerPerTapScalesWithUpgradesAndPermanentTokens() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        XCTAssertEqual(EconomyEngine.powerPerTap(state: state), 1, accuracy: 0.001)

        state.setUpgradeLevel(.handCrankGenerator, level: 2)
        state.setUpgradeLevel(.copperCoils, level: 1)
        state.prestige.permanentUpgradeLevels[PermanentUpgradeID.legacyTurbines.rawValue] = 3

        XCTAssertEqual(EconomyEngine.powerPerTap(state: state), 8, accuracy: 0.001)
    }

    func testStabilityIncomeMultiplierMatchesDesignBands() {
        XCTAssertEqual(EconomyEngine.stabilityIncomeMultiplier(stability: 92), 1.0)
        XCTAssertEqual(EconomyEngine.stabilityIncomeMultiplier(stability: 65), 0.85)
        XCTAssertEqual(EconomyEngine.stabilityIncomeMultiplier(stability: 31), 0.60)
        XCTAssertEqual(EconomyEngine.stabilityIncomeMultiplier(stability: 12), 0.35)
        XCTAssertEqual(EconomyEngine.stabilityIncomeMultiplier(stability: 0), 0.0)
    }

    func testCreditsPerSecondUsesDistrictIncomeAndUpgrades() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        state.updateDistrict(.residentialBlock) { district in
            district.isRestored = true
            district.isPowered = true
            district.level = 2
        }

        let base = EconomyEngine.creditsPerSecond(state: state)
        state.setUpgradeLevel(.improvedWiring, level: 1)
        let improved = EconomyEngine.creditsPerSecond(state: state)

        XCTAssertGreaterThan(base, 1.0)
        XCTAssertGreaterThan(improved, base)
    }

    func testUpgradeCostsScaleByFormula() {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 0))
        let firstCost = EconomyEngine.globalUpgradeCost(.batteryExpansion, state: state)
        state.setUpgradeLevel(.batteryExpansion, level: 2)
        let laterCost = EconomyEngine.globalUpgradeCost(.batteryExpansion, state: state)

        XCTAssertGreaterThan(laterCost, firstCost)
        XCTAssertEqual(firstCost, UpgradeCatalog.definition(for: .batteryExpansion).baseCost, accuracy: 0.001)
    }
}
