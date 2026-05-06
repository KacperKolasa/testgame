import Foundation

#if canImport(AudioToolbox)
import AudioToolbox
#endif

final class SoundService {
    func tap(enabled: Bool) {
        playSystemSound(1104, enabled: enabled)
    }

    func success(enabled: Bool) {
        playSystemSound(1025, enabled: enabled)
    }

    func warning(enabled: Bool) {
        playSystemSound(1053, enabled: enabled)
    }

    private func playSystemSound(_ id: UInt32, enabled: Bool) {
        guard enabled else { return }
        #if canImport(AudioToolbox)
        AudioServicesPlaySystemSound(SystemSoundID(id))
        #endif
    }
}
