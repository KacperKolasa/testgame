import Foundation

struct ResourceState: Codable, Equatable {
    var power: Double
    var credits: Double
    var stability: Double
    var batteryCapacity: Double
    var populationServed: Int
    var cityCompletion: Double
}

extension ResourceState {
    private enum CodingKeys: String, CodingKey {
        case power
        case credits
        case stability
        case batteryCapacity
        case populationServed
        case cityCompletion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.power = try container.decodeIfPresent(Double.self, forKey: .power) ?? 0
        self.credits = try container.decodeIfPresent(Double.self, forKey: .credits) ?? 0
        self.stability = try container.decodeIfPresent(Double.self, forKey: .stability) ?? 100
        self.batteryCapacity = try container.decodeIfPresent(Double.self, forKey: .batteryCapacity) ?? 100
        self.populationServed = try container.decodeIfPresent(Int.self, forKey: .populationServed) ?? 0
        self.cityCompletion = try container.decodeIfPresent(Double.self, forKey: .cityCompletion) ?? 0
    }
}

struct ProgressStats: Codable, Equatable {
    var runCreditsEarned: Double
    var runPowerGenerated: Double
    var runTaps: Int
    var allTimeCreditsEarned: Double
    var allTimePowerGenerated: Double
    var allTimeTaps: Int
    var completedEvents: Int
    var failedEvents: Int

    static let empty = ProgressStats(
        runCreditsEarned: 0,
        runPowerGenerated: 0,
        runTaps: 0,
        allTimeCreditsEarned: 0,
        allTimePowerGenerated: 0,
        allTimeTaps: 0,
        completedEvents: 0,
        failedEvents: 0
    )
}

extension ProgressStats {
    private enum CodingKeys: String, CodingKey {
        case runCreditsEarned
        case runPowerGenerated
        case runTaps
        case allTimeCreditsEarned
        case allTimePowerGenerated
        case allTimeTaps
        case completedEvents
        case failedEvents
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.runCreditsEarned = try container.decodeIfPresent(Double.self, forKey: .runCreditsEarned) ?? 0
        self.runPowerGenerated = try container.decodeIfPresent(Double.self, forKey: .runPowerGenerated) ?? 0
        self.runTaps = try container.decodeIfPresent(Int.self, forKey: .runTaps) ?? 0
        self.allTimeCreditsEarned = try container.decodeIfPresent(Double.self, forKey: .allTimeCreditsEarned) ?? runCreditsEarned
        self.allTimePowerGenerated = try container.decodeIfPresent(Double.self, forKey: .allTimePowerGenerated) ?? runPowerGenerated
        self.allTimeTaps = try container.decodeIfPresent(Int.self, forKey: .allTimeTaps) ?? runTaps
        self.completedEvents = try container.decodeIfPresent(Int.self, forKey: .completedEvents) ?? 0
        self.failedEvents = try container.decodeIfPresent(Int.self, forKey: .failedEvents) ?? 0
    }
}

struct GameState: Codable, Equatable {
    var schemaVersion: Int
    var resources: ResourceState
    var districts: [DistrictState]
    var upgradeLevels: [String: Int]
    var prestige: PrestigeState
    var currentEvent: ActiveGameEvent?
    var eventHistory: [EventHistoryEntry]
    var settings: SettingsState
    var stats: ProgressStats
    var lastActiveAt: Date
    var eventCooldown: TimeInterval
    var blackoutTimer: TimeInterval
    var selectedContractModifier: CityModifierID

    static func newGame(now: Date = Date(), prestige: PrestigeState = .initial, settings: SettingsState = .default, stats: ProgressStats = .empty) -> GameState {
        let modifier = CityModifierCatalog.definition(for: prestige.currentCityModifier)
        let permanentBattery = Double(prestige.permanentLevel(.reserveBanks)) * 30
        var state = GameState(
            schemaVersion: 1,
            resources: ResourceState(
                power: 0,
                credits: 0,
                stability: 100,
                batteryCapacity: 100 + modifier.startingBatteryBonus + permanentBattery,
                populationServed: 0,
                cityCompletion: 0
            ),
            districts: DistrictCatalog.initialStates(),
            upgradeLevels: [:],
            prestige: prestige,
            currentEvent: nil,
            eventHistory: [],
            settings: settings,
            stats: stats,
            lastActiveAt: now,
            eventCooldown: 85,
            blackoutTimer: 0,
            selectedContractModifier: prestige.currentCityModifier
        )
        EconomyEngine.recalculateDerivedResources(state: &state)
        return state
    }

    func districtState(for id: DistrictID) -> DistrictState {
        districts.first(where: { $0.id == id }) ?? DistrictState(id: id)
    }

    mutating func updateDistrict(_ id: DistrictID, update: (inout DistrictState) -> Void) {
        guard let index = districts.firstIndex(where: { $0.id == id }) else {
            return
        }
        update(&districts[index])
    }

    func upgradeLevel(_ id: UpgradeID) -> Int {
        upgradeLevels[id.rawValue, default: 0]
    }

    mutating func setUpgradeLevel(_ id: UpgradeID, level: Int) {
        upgradeLevels[id.rawValue] = level
    }

    mutating func incrementUpgrade(_ id: UpgradeID) {
        upgradeLevels[id.rawValue, default: 0] += 1
    }

    func permanentLevel(_ id: PermanentUpgradeID) -> Int {
        prestige.permanentUpgradeLevels[id.rawValue, default: 0]
    }

    mutating func incrementPermanentUpgrade(_ id: PermanentUpgradeID) {
        prestige.permanentUpgradeLevels[id.rawValue, default: 0] += 1
    }
}

extension GameState {
    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case resources
        case districts
        case upgradeLevels
        case prestige
        case currentEvent
        case eventHistory
        case settings
        case stats
        case lastActiveAt
        case eventCooldown
        case blackoutTimer
        case selectedContractModifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fallback = GameState.newGame(now: Date())

        self.schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        self.resources = try container.decodeIfPresent(ResourceState.self, forKey: .resources) ?? fallback.resources

        let decodedDistricts = try container.decodeIfPresent([DistrictState].self, forKey: .districts) ?? []
        var mergedDistricts = DistrictCatalog.initialStates()
        for decoded in decodedDistricts {
            if let index = mergedDistricts.firstIndex(where: { $0.id == decoded.id }) {
                mergedDistricts[index] = decoded
            }
        }
        self.districts = mergedDistricts

        self.upgradeLevels = try container.decodeIfPresent([String: Int].self, forKey: .upgradeLevels) ?? [:]
        self.prestige = try container.decodeIfPresent(PrestigeState.self, forKey: .prestige) ?? .initial
        if !self.prestige.unlockedCityModifiers.contains(.standard) {
            self.prestige.unlockedCityModifiers.insert(.standard, at: 0)
        }
        self.currentEvent = try container.decodeIfPresent(ActiveGameEvent.self, forKey: .currentEvent)
        self.eventHistory = try container.decodeIfPresent([EventHistoryEntry].self, forKey: .eventHistory) ?? []
        self.settings = try container.decodeIfPresent(SettingsState.self, forKey: .settings) ?? .default
        self.stats = try container.decodeIfPresent(ProgressStats.self, forKey: .stats) ?? .empty
        self.lastActiveAt = try container.decodeIfPresent(Date.self, forKey: .lastActiveAt) ?? Date()
        self.eventCooldown = try container.decodeIfPresent(TimeInterval.self, forKey: .eventCooldown) ?? fallback.eventCooldown
        self.blackoutTimer = try container.decodeIfPresent(TimeInterval.self, forKey: .blackoutTimer) ?? 0
        self.selectedContractModifier = try container.decodeIfPresent(CityModifierID.self, forKey: .selectedContractModifier) ?? self.prestige.currentCityModifier

        EconomyEngine.recalculateDerivedResources(state: &self)
    }
}
