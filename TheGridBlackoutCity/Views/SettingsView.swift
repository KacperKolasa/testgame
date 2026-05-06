import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            GameScreenBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CommandHeader(
                        kicker: "OPS TERMINAL",
                        title: "Crew preferences.",
                        subtitle: "Tune feedback, review the build, or wipe the city for a fresh contract.",
                        accent: GridTheme.electric
                    )

                    opsPanel(title: "Feedback") {
                        Toggle("Haptics", isOn: Binding(
                            get: { viewModel.state.settings.hapticsEnabled },
                            set: { viewModel.setHapticsEnabled($0) }
                        ))
                        .tint(GridTheme.warm)
                        Toggle("Sound", isOn: Binding(
                            get: { viewModel.state.settings.soundEnabled },
                            set: { viewModel.setSoundEnabled($0) }
                        ))
                        .tint(GridTheme.electric)
                    }

                    opsPanel(title: "Save Core") {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            Label("Reset Save", systemImage: "trash.fill")
                        }
                        .buttonStyle(GridSecondaryButtonStyle(accent: GridTheme.danger))
                    }

                    opsPanel(title: "Build") {
                        buildRow("Version", "1.0.0")
                        buildRow("Mode", "Offline single-player")
                        buildRow("Minimum iOS", "17.0")
                    }
                }
                .padding(16)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Ops")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Reset all progress?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset Save", role: .destructive) {
                viewModel.resetSave()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This clears districts, upgrades, events, prestige tokens, and settings.")
        }
    }

    private func opsPanel<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .black, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(GridTheme.secondaryText)
            content()
                .font(.subheadline.weight(.bold))
                .foregroundStyle(GridTheme.text)
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
    }

    private func buildRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(GridTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(GridTheme.text)
        }
        .padding(.vertical, 4)
    }
}
