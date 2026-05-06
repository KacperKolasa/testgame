import SwiftUI

struct UpgradesView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    private var filteredUpgrades: [UpgradeDefinition] {
        UpgradeCatalog.all.filter { $0.category == viewModel.selectedUpgradeCategory }
    }

    var body: some View {
        ZStack {
            GameScreenBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    CommandHeader(
                        kicker: "TECH TREE",
                        title: "Build a sharper grid.",
                        subtitle: "Choose between raw generation, safer reserves, smarter routing, and idle automation.",
                        accent: GridTheme.warm
                    )

                    Picker("Category", selection: $viewModel.selectedUpgradeCategory) {
                        ForEach(UpgradeCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)

                    ForEach(filteredUpgrades) { upgrade in
                        UpgradeCard(upgrade: upgrade)
                    }
                }
                .padding(16)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Tech")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct UpgradeCard: View {
    @EnvironmentObject private var viewModel: GameViewModel
    let upgrade: UpgradeDefinition

    private var level: Int {
        viewModel.state.upgradeLevel(upgrade.id)
    }

    private var cost: Double {
        EconomyEngine.globalUpgradeCost(upgrade.id, state: viewModel.state)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: upgrade.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(accent)
                    .frame(width: 42, height: 42)
                    .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(upgrade.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(GridTheme.text)
                        Spacer()
                        Text("LV \(level)/\(upgrade.maxLevel)")
                            .font(.caption.monospacedDigit().weight(.bold))
                            .foregroundStyle(level >= upgrade.maxLevel ? GridTheme.stable : GridTheme.secondaryText)
                    }

                    Text(upgrade.description)
                        .font(.subheadline)
                        .foregroundStyle(GridTheme.secondaryText)
                }
            }

            Text(upgrade.effectSummary)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Button {
                viewModel.buyUpgrade(upgrade.id)
            } label: {
                Label(level >= upgrade.maxLevel ? "Max level" : "Buy - \(NumberFormatters.compact(cost)) credits", systemImage: "arrow.up.circle")
            }
            .buttonStyle(GridPrimaryButtonStyle(accent: canAfford ? accent : GridTheme.secondaryText))
            .disabled(!canAfford || level >= upgrade.maxLevel)
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
    }

    private var canAfford: Bool {
        viewModel.state.resources.credits >= cost
    }

    private var accent: Color {
        switch upgrade.category {
        case .generation:
            return GridTheme.warm
        case .storage:
            return GridTheme.electric
        case .stability:
            return GridTheme.stable
        case .city:
            return GridTheme.electricSoft
        case .automation:
            return Color(hex: 0xB8C7D9)
        }
    }
}
