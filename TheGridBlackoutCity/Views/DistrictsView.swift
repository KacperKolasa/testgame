import SwiftUI

struct DistrictsView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        ZStack {
            GameScreenBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    CommandHeader(
                        kicker: "ZONE CONTROL",
                        title: "Light the city block by block.",
                        subtitle: "Restore districts, level them up, and decide which zones deserve live power.",
                        accent: GridTheme.electric
                    )

                    ForEach(DistrictCatalog.all) { definition in
                        DistrictCard(definition: definition)
                    }
                }
                .padding(16)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Zones")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct DistrictCard: View {
    @EnvironmentObject private var viewModel: GameViewModel
    let definition: DistrictDefinition

    private var district: DistrictState {
        viewModel.state.districtState(for: definition.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                Image(GameArt.districtImageName(for: definition.id))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 132)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .opacity(district.isRestored ? 1 : 0.36)
                    .saturation(district.isRestored ? 1 : 0)
                    .brightness(district.isPowered ? 0.04 : -0.16)

                LinearGradient(
                    colors: [Color.clear, GridTheme.background.opacity(0.78)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(district.isRestored ? (district.isPowered ? "POWERED" : "RESTORED") : "BLACKOUT")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(district.isPowered ? GridTheme.background : GridTheme.text)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 8)
                    .background(district.isPowered ? GridTheme.warm : Color.black.opacity(0.52), in: Capsule())
                    .padding(10)
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(district.isPowered ? GridTheme.warm : GridTheme.electric)
                    .frame(width: 42, height: 42)
                    .background((district.isPowered ? GridTheme.warm : GridTheme.electric).opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(definition.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(GridTheme.text)
                        Spacer()
                        Text(definition.category.rawValue.uppercased())
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(GridTheme.secondaryText)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 7)
                            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }

                    Text(definition.description)
                        .font(.subheadline)
                        .foregroundStyle(GridTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(definition.uniqueEffect)
                .font(.caption.weight(.semibold))
                .foregroundStyle(GridTheme.electricSoft)
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GridTheme.electric.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            statGrid

            if district.isRestored {
                restoredControls
            } else {
                restoreButton
            }
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(district.isPowered ? GridTheme.electric.opacity(0.32) : GridTheme.line, lineWidth: 1)
        )
    }

    private var statGrid: some View {
        let preview = singleDistrictState(powered: true)
        return Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                stat("Demand", NumberFormatters.compact(EconomyEngine.totalDemandPerSecond(state: preview)), "bolt.horizontal")
                stat("Income", "\(NumberFormatters.compact(EconomyEngine.districtIncomePerSecond(preview.districtState(for: definition.id), state: preview)))/s", "creditcard")
            }
            GridRow {
                stat("Level", "\(district.level)/5", "arrow.up.circle")
                stat("Population", "\(definition.population)", "person.2")
            }
        }
    }

    private var restoreButton: some View {
        let cost = EconomyEngine.restoreCost(for: definition.id, state: viewModel.state)
        return Button {
            viewModel.restoreDistrict(definition.id)
        } label: {
            Label("Restore - \(NumberFormatters.compact(cost)) power", systemImage: "bolt.badge.checkmark")
        }
        .buttonStyle(GridPrimaryButtonStyle(accent: viewModel.state.resources.power >= cost ? GridTheme.electric : GridTheme.secondaryText))
        .disabled(viewModel.state.resources.power < cost)
    }

    private var restoredControls: some View {
        VStack(spacing: 9) {
            HStack {
                Toggle(isOn: Binding(
                    get: { viewModel.state.districtState(for: definition.id).isPowered },
                    set: { _ in viewModel.toggleDistrictPower(definition.id) }
                )) {
                    Text(district.isPowered ? "Powered" : "Paused")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(district.isPowered ? GridTheme.stable : GridTheme.secondaryText)
                }
                .tint(GridTheme.electric)
            }

            let cost = EconomyEngine.districtUpgradeCost(definition.id, state: viewModel.state)
            Button {
                viewModel.upgradeDistrict(definition.id)
            } label: {
                Label(district.level >= 5 ? "Fully upgraded" : "Upgrade - \(NumberFormatters.compact(cost)) credits", systemImage: "arrow.up.circle")
            }
            .buttonStyle(GridSecondaryButtonStyle(accent: district.level >= 5 ? GridTheme.secondaryText : GridTheme.warm))
            .disabled(district.level >= 5 || viewModel.state.resources.credits < cost)
        }
    }

    private func singleDistrictState(powered: Bool) -> GameState {
        var copy = viewModel.state
        for id in DistrictID.allCases {
            copy.updateDistrict(id) { district in
                district.isPowered = false
            }
        }
        copy.updateDistrict(definition.id) { district in
            district.isRestored = true
            district.isPowered = powered
        }
        return copy
    }

    private func stat(_ title: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .foregroundStyle(GridTheme.electric)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(GridTheme.secondaryText)
                Text(value)
                    .font(.caption.monospacedDigit().weight(.bold))
                    .foregroundStyle(GridTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(GridTheme.panelRaised.opacity(0.62), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var icon: String {
        switch definition.category {
        case .residential:
            return "house"
        case .healthcare:
            return "cross.case"
        case .industrial:
            return "building.2"
        case .commerce:
            return "storefront"
        case .transit:
            return "tram"
        case .technology:
            return "server.rack"
        case .utility:
            return "drop"
        case .civic:
            return "building.columns"
        case .generation:
            return "sun.max"
        case .storage:
            return "battery.100"
        }
    }
}
