import SwiftUI

struct PrestigeView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var showPrestigeConfirmation = false

    var body: some View {
        ZStack {
            GridTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    contractPanel
                    modifierPanel
                    permanentUpgradePanel
                }
                .padding(16)
            }
        }
        .navigationTitle("Rebuild Contract")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Accept Rebuild Contract?", isPresented: $showPrestigeConfirmation, titleVisibility: .visible) {
            Button("Accept Contract", role: .destructive) {
                viewModel.acceptRebuildContract()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Normal city progress resets. Grid Tokens and permanent upgrades remain.")
        }
    }

    private var contractPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("City Completion")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(GridTheme.text)
                    Text("Prestige count \(viewModel.state.prestige.prestigeCount)")
                        .font(.subheadline)
                        .foregroundStyle(GridTheme.secondaryText)
                }
                Spacer()
                Text("\(viewModel.state.prestige.gridTokens)")
                    .font(.system(.title2, design: .rounded).weight(.black))
                    .foregroundStyle(GridTheme.warm)
                Text("Tokens")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
            }

            ProgressMeter(title: "Restored", fraction: viewModel.state.resources.cityCompletion, accent: GridTheme.warm)

            let award = PrestigeEngine.gridTokensAwarded(state: viewModel.state)
            Text("Next contract awards \(award) Grid Tokens based on population, districts, run credits, and event wins.")
                .font(.caption)
                .foregroundStyle(GridTheme.secondaryText)

            Button {
                showPrestigeConfirmation = true
            } label: {
                Label(PrestigeEngine.canPrestige(state: viewModel.state) ? "Accept Rebuild Contract" : "Restore all districts first", systemImage: "sparkles.rectangle.stack")
            }
            .buttonStyle(GridPrimaryButtonStyle(accent: PrestigeEngine.canPrestige(state: viewModel.state) ? GridTheme.warm : GridTheme.secondaryText))
            .disabled(!PrestigeEngine.canPrestige(state: viewModel.state))
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
    }

    private var modifierPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Next City Modifier", systemImage: "map")
                .font(.headline.weight(.bold))
                .foregroundStyle(GridTheme.text)

            ForEach(CityModifierCatalog.all) { modifier in
                let available = PrestigeEngine.availableCityModifiers(state: viewModel.state).contains(modifier.id)
                Button {
                    viewModel.selectContractModifier(modifier.id)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: modifier.id == .snow ? "snowflake" : "building.2")
                            .foregroundStyle(available ? GridTheme.electric : GridTheme.secondaryText)
                            .frame(width: 34, height: 34)
                            .background((available ? GridTheme.electric : GridTheme.secondaryText).opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(modifier.name)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(GridTheme.text)
                                if viewModel.state.selectedContractModifier == modifier.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(GridTheme.stable)
                                }
                            }
                            Text(available ? modifier.description : "Unlocks after accepting your first rebuild contract.")
                                .font(.caption)
                                .foregroundStyle(GridTheme.secondaryText)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(GridTheme.panelRaised.opacity(viewModel.state.selectedContractModifier == modifier.id ? 0.86 : 0.55), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(viewModel.state.selectedContractModifier == modifier.id ? GridTheme.electric.opacity(0.34) : GridTheme.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!available)
            }
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var permanentUpgradePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Permanent Grid", systemImage: "hexagon")
                .font(.headline.weight(.bold))
                .foregroundStyle(GridTheme.text)

            ForEach(UpgradeCatalog.permanent) { upgrade in
                PermanentUpgradeRow(upgrade: upgrade)
            }
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct PermanentUpgradeRow: View {
    @EnvironmentObject private var viewModel: GameViewModel
    let upgrade: PermanentUpgradeDefinition

    private var level: Int {
        viewModel.state.permanentLevel(upgrade.id)
    }

    private var cost: Int {
        EconomyEngine.permanentUpgradeCost(upgrade.id, state: viewModel.state)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: upgrade.systemImage)
                    .foregroundStyle(GridTheme.warm)
                    .frame(width: 34, height: 34)
                    .background(GridTheme.warm.opacity(0.1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(upgrade.name)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(GridTheme.text)
                        Spacer()
                        Text("Lv \(level)/\(upgrade.maxLevel)")
                            .font(.caption.monospacedDigit().weight(.bold))
                            .foregroundStyle(GridTheme.secondaryText)
                    }
                    Text(upgrade.effectSummary)
                        .font(.caption)
                        .foregroundStyle(GridTheme.secondaryText)
                }
            }

            Button {
                viewModel.buyPermanentUpgrade(upgrade.id)
            } label: {
                Label(level >= upgrade.maxLevel ? "Max level" : "Spend \(cost) Grid Tokens", systemImage: "plus.circle")
            }
            .buttonStyle(GridSecondaryButtonStyle(accent: canAfford ? GridTheme.warm : GridTheme.secondaryText))
            .disabled(!canAfford || level >= upgrade.maxLevel)
        }
        .padding(10)
        .background(GridTheme.panelRaised.opacity(0.58), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var canAfford: Bool {
        viewModel.state.prestige.gridTokens >= cost
    }
}
