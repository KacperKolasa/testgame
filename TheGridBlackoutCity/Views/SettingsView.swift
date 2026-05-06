import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            GridTheme.background.ignoresSafeArea()
            List {
                Section("Audio and Haptics") {
                    Toggle("Haptics", isOn: Binding(
                        get: { viewModel.state.settings.hapticsEnabled },
                        set: { viewModel.setHapticsEnabled($0) }
                    ))
                    Toggle("Sound", isOn: Binding(
                        get: { viewModel.state.settings.soundEnabled },
                        set: { viewModel.setSoundEnabled($0) }
                    ))
                }

                Section("Save") {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset Save", systemImage: "trash")
                    }
                }

                Section("Build") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Mode", value: "Offline single-player")
                    LabeledContent("Minimum iOS", value: "17.0")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Reset all progress?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset Save", role: .destructive) {
                viewModel.resetSave()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This clears districts, upgrades, events, prestige tokens, and settings.")
        }
    }
}
