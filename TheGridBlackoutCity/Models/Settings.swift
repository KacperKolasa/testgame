import Foundation

struct SettingsState: Codable, Equatable {
    var hapticsEnabled: Bool
    var soundEnabled: Bool

    static let `default` = SettingsState(hapticsEnabled: true, soundEnabled: true)
}

extension SettingsState {
    private enum CodingKeys: String, CodingKey {
        case hapticsEnabled
        case soundEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.hapticsEnabled = try container.decodeIfPresent(Bool.self, forKey: .hapticsEnabled) ?? true
        self.soundEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundEnabled) ?? true
    }
}
