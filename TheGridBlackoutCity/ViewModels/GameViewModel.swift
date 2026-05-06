import Combine
import Foundation

struct FloatingGain: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let createdAt: Date
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    @Published var offlineResult: OfflineProgressResult?
    @Published var floatingGains: [FloatingGain] = []
    @Published var bannerMessage: String?
    @Published var selectedUpgradeCategory: UpgradeCategory = .generation

    private let saveService: SaveService
    private let haptics: HapticsService
    private let sound: SoundService
    private var timerCancellable: AnyCancellable?
    private var saveTickCounter = 0
    private var rng = SystemRandomNumberGenerator()

    init(
        saveService: SaveService = SaveService(),
        haptics: HapticsService = HapticsService(),
        sound: SoundService = SoundService(),
        now: Date = Date()
    ) {
        self.saveService = saveService
        self.haptics = haptics
        self.sound = sound

        if var loaded = saveService.load() {
            let result = OfflineProgressEngine.applyOfflineProgress(state: &loaded, now: now)
            self.state = loaded
            self.offlineResult = result.isMeaningful ? result : nil
        } else {
            self.state = GameState.newGame(now: now)
            self.offlineResult = nil
        }

        startLoop()
    }

    var restoredDistricts: [DistrictState] {
        state.districts.filter(\.isRestored)
    }

    var totalDemand: Double {
        EconomyEngine.totalDemandPerSecond(state: state)
    }

    var passivePower: Double {
        EconomyEngine.passivePowerPerSecond(state: state)
    }

    var creditsPerSecond: Double {
        EconomyEngine.creditsPerSecond(state: state)
    }

    var powerPerTap: Double {
        EconomyEngine.powerPerTap(state: state)
    }

    func dismissOfflineResult() {
        offlineResult = nil
    }

    func tapGenerator() {
        let gain = GameEngine.tapGenerator(state: &state)
        addFloatingGain("+\(NumberFormatters.compact(gain)) power")
        haptics.tap(enabled: state.settings.hapticsEnabled)
        sound.tap(enabled: state.settings.soundEnabled)

        if state.currentEvent?.type == .powerSurge {
            _ = performEventAction(.stabilizeTap, saveAfterAction: false)
        }

        saveImportantChange()
    }

    func restoreDistrict(_ id: DistrictID) {
        handle(GameEngine.restoreDistrict(id, state: &state), successHaptic: true)
    }

    func toggleDistrictPower(_ id: DistrictID) {
        handle(GameEngine.toggleDistrictPower(id, state: &state), successHaptic: false)
    }

    func upgradeDistrict(_ id: DistrictID) {
        handle(GameEngine.upgradeDistrict(id, state: &state), successHaptic: true)
    }

    func buyUpgrade(_ id: UpgradeID) {
        handle(GameEngine.buyUpgrade(id, state: &state), successHaptic: true)
    }

    @discardableResult
    func performEventAction(_ action: PlayerEventAction, saveAfterAction: Bool = true) -> PurchaseResult {
        let result = GameEngine.performEventAction(action, state: &state)
        handle(result, successHaptic: true, save: saveAfterAction)
        return result
    }

    func buyPermanentUpgrade(_ id: PermanentUpgradeID) {
        handle(PrestigeEngine.buyPermanentUpgrade(id, state: &state), successHaptic: true)
    }

    func selectContractModifier(_ id: CityModifierID) {
        guard PrestigeEngine.availableCityModifiers(state: state).contains(id) else {
            bannerMessage = "City modifier locked"
            haptics.warning(enabled: state.settings.hapticsEnabled)
            return
        }
        state.selectedContractModifier = id
        saveImportantChange()
    }

    func acceptRebuildContract() {
        let result = PrestigeEngine.performPrestige(state: &state, nextModifier: state.selectedContractModifier)
        handle(result, successHaptic: true)
    }

    func setHapticsEnabled(_ enabled: Bool) {
        state.settings.hapticsEnabled = enabled
        saveImportantChange()
    }

    func setSoundEnabled(_ enabled: Bool) {
        state.settings.soundEnabled = enabled
        saveImportantChange()
    }

    func resetSave() {
        saveService.reset()
        state = GameState.newGame()
        offlineResult = nil
        floatingGains = []
        bannerMessage = "Save reset"
        saveImportantChange()
    }

    func saveForScenePhaseChange() {
        state.lastActiveAt = Date()
        try? saveService.save(state)
    }

    private func startLoop() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                Task { @MainActor in
                    self?.tick(now: now)
                }
            }
    }

    private func tick(now: Date) {
        let summary = GameEngine.tick(state: &state, delta: 1, now: now, rng: &rng)

        if summary.economy.creditsGenerated >= 0.5 {
            addFloatingGain("+\(NumberFormatters.compact(summary.economy.creditsGenerated)) credits", limit: 3)
        }

        if summary.economy.blackoutTriggered {
            bannerMessage = "Blackout relays tripped"
            haptics.failure(enabled: state.settings.hapticsEnabled)
            sound.warning(enabled: state.settings.soundEnabled)
        } else if let started = summary.event.startedEvent {
            bannerMessage = EventCatalog.definition(for: started).title
            haptics.warning(enabled: state.settings.hapticsEnabled)
            sound.warning(enabled: state.settings.soundEnabled)
        } else if let outcome = summary.event.outcome {
            switch outcome {
            case .success, .choice:
                haptics.success(enabled: state.settings.hapticsEnabled)
                sound.success(enabled: state.settings.soundEnabled)
            case .failure, .blackout:
                haptics.failure(enabled: state.settings.hapticsEnabled)
                sound.warning(enabled: state.settings.soundEnabled)
            }
        }

        floatingGains.removeAll { now.timeIntervalSince($0.createdAt) > 1.8 }
        saveTickCounter += 1
        if saveTickCounter >= 10 {
            saveTickCounter = 0
            state.lastActiveAt = now
            try? saveService.save(state, at: now)
        }
    }

    private func handle(_ result: PurchaseResult, successHaptic: Bool, save: Bool = true) {
        bannerMessage = result.message
        if result.succeeded {
            if successHaptic {
                haptics.success(enabled: state.settings.hapticsEnabled)
                sound.success(enabled: state.settings.soundEnabled)
            }
        } else {
            haptics.warning(enabled: state.settings.hapticsEnabled)
            sound.warning(enabled: state.settings.soundEnabled)
        }

        if save {
            saveImportantChange()
        }
    }

    private func saveImportantChange() {
        state.lastActiveAt = Date()
        try? saveService.save(state)
    }

    private func addFloatingGain(_ text: String, limit: Int = 5) {
        floatingGains.append(FloatingGain(text: text, createdAt: Date()))
        if floatingGains.count > limit {
            floatingGains.removeFirst(floatingGains.count - limit)
        }
    }
}
