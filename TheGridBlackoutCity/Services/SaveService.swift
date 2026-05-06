import Foundation

struct SaveEnvelope: Codable {
    let version: Int
    let savedAt: Date
    let state: GameState
}

enum SaveServiceError: Error {
    case encodeFailed
}

final class SaveService {
    private let defaults: UserDefaults
    private let saveKey: String

    init(defaults: UserDefaults = .standard, saveKey: String = "the-grid-blackout-city-save") {
        self.defaults = defaults
        self.saveKey = saveKey
    }

    func load() -> GameState? {
        guard let data = defaults.data(forKey: saveKey) else {
            return nil
        }

        do {
            let envelope = try JSONDecoder.gameDecoder.decode(SaveEnvelope.self, from: data)
            var state = envelope.state
            EconomyEngine.recalculateDerivedResources(state: &state)
            return state
        } catch {
            return nil
        }
    }

    func save(_ state: GameState, at date: Date = Date()) throws {
        let envelope = SaveEnvelope(version: 1, savedAt: date, state: state)
        let data = try JSONEncoder.gameEncoder.encode(envelope)
        defaults.set(data, forKey: saveKey)
    }

    func reset() {
        defaults.removeObject(forKey: saveKey)
    }
}

extension JSONEncoder {
    static var gameEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

extension JSONDecoder {
    static var gameDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
