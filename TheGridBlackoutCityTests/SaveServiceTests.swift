import XCTest
@testable import TheGridBlackoutCity

final class SaveServiceTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var saveService: SaveService!

    override func setUp() {
        super.setUp()
        suiteName = "TheGridBlackoutCityTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        saveService = SaveService(defaults: defaults, saveKey: "test-save")
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        suiteName = nil
        defaults = nil
        saveService = nil
        super.tearDown()
    }

    func testSaveAndLoadRoundTrip() throws {
        var state = GameState.newGame(now: Date(timeIntervalSince1970: 10))
        state.resources.power = 42
        state.resources.credits = 123
        state.updateDistrict(.hospital) { district in
            district.isRestored = true
            district.isPowered = true
            district.level = 3
        }

        try saveService.save(state, at: Date(timeIntervalSince1970: 11))
        let loaded = saveService.load()

        XCTAssertEqual(loaded?.resources.power, 42)
        XCTAssertEqual(loaded?.resources.credits, 123)
        XCTAssertEqual(loaded?.districtState(for: .hospital).level, 3)
        XCTAssertEqual(loaded?.districtState(for: .hospital).isPowered, true)
    }

    func testCorruptedDataReturnsNilInsteadOfCrashing() {
        defaults.set(Data("not-json".utf8), forKey: "test-save")
        XCTAssertNil(saveService.load())
    }

    func testMissingNewFieldsDecodeWithDefaults() throws {
        let oldJSON = """
        {
          "version": 1,
          "savedAt": "2026-05-06T12:00:00Z",
          "state": {
            "resources": { "power": 12, "credits": 4 },
            "districts": [],
            "upgradeLevels": {}
          }
        }
        """.data(using: .utf8)!

        defaults.set(oldJSON, forKey: "test-save")
        let loaded = saveService.load()

        XCTAssertEqual(loaded?.resources.power, 12)
        XCTAssertEqual(loaded?.resources.stability, 100)
        XCTAssertEqual(loaded?.districts.count, DistrictID.allCases.count)
    }
}
