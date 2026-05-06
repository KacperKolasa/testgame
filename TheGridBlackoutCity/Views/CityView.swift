import SwiftUI

struct CityView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var tapPulse = false

    var body: some View {
        ZStack {
            GameScreenBackdrop()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    metricsGrid
                    CityMapView(state: viewModel.state)

                    if viewModel.state.currentEvent != nil {
                        EventCardView()
                    }

                    generatorPanel
                    routingPanel
                }
                .padding(16)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Command Deck")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            CommandHeader(
                kicker: "THE GRID: BLACKOUT CITY",
                title: "Restore the dead city.",
                subtitle: "Tap the reactor, route live load, and keep the blackout from swallowing recovered districts.",
                accent: GridTheme.warm
            )

            HStack(spacing: 10) {
                missionChip(title: "Contract", value: CityModifierCatalog.definition(for: viewModel.state.prestige.currentCityModifier).subtitle, icon: "map.fill", accent: GridTheme.electric)
                missionChip(title: "Live Load", value: "\(NumberFormatters.compact(viewModel.totalDemand))/s", icon: "bolt.horizontal.fill", accent: viewModel.totalDemand > viewModel.passivePower + 0.1 ? GridTheme.danger : GridTheme.stable)
            }
        }
    }

    private func missionChip(title: String, value: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(GridTheme.secondaryText)
                Text(value)
                    .font(.caption.weight(.black))
                    .foregroundStyle(GridTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(GridTheme.panelRaised.opacity(0.86), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(accent.opacity(0.24), lineWidth: 1)
        )
    }

    private var metricsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("RESTORATION HUD")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(GridTheme.secondaryText)
                Spacer()
                Text("\(NumberFormatters.compact(viewModel.passivePower))/s passive")
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(GridTheme.electric)
            }

            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    MetricPill(
                        title: "Power",
                        value: "\(NumberFormatters.compact(viewModel.state.resources.power))/\(NumberFormatters.compact(viewModel.state.resources.batteryCapacity))",
                        systemImage: "bolt.fill",
                        accent: GridTheme.warm
                    )
                    MetricPill(
                        title: "Credits",
                        value: NumberFormatters.compact(viewModel.state.resources.credits),
                        systemImage: "creditcard.fill",
                        accent: GridTheme.electric
                    )
                }
                GridRow {
                    MetricPill(
                        title: "Population",
                        value: "\(viewModel.state.resources.populationServed)",
                        systemImage: "person.2.fill",
                        accent: GridTheme.stable
                    )
                    MetricPill(
                        title: "Income",
                        value: "\(NumberFormatters.compact(viewModel.creditsPerSecond))/s",
                        systemImage: "chart.line.uptrend.xyaxis",
                        accent: GridTheme.electricSoft
                    )
                }
            }

            StabilityBar(stability: viewModel.state.resources.stability)
            ProgressMeter(title: "City Completion", fraction: viewModel.state.resources.cityCompletion, accent: GridTheme.warm)
                .padding(12)
                .background(GridTheme.panel.opacity(0.92), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(GridTheme.line, lineWidth: 1)
                )
        }
    }

    private var generatorPanel: some View {
        HStack(spacing: 16) {
            ZStack {
                ForEach(viewModel.floatingGains) { gain in
                    Text(gain.text)
                        .font(.caption.weight(.black))
                        .foregroundStyle(GridTheme.warm)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(GridTheme.background.opacity(0.78), in: Capsule())
                        .offset(y: -86)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.62)) {
                        tapPulse.toggle()
                    }
                    viewModel.tapGenerator()
                } label: {
                    ZStack {
                        Image(GameArt.reactorCore)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 132, height: 132)
                            .shadow(color: GridTheme.warm.opacity(0.32), radius: 22, y: 10)

                        Circle()
                            .stroke(GridTheme.background.opacity(0.42), style: StrokeStyle(lineWidth: 8, dash: [10, 8]))
                            .frame(width: 102, height: 102)
                            .rotationEffect(.degrees(tapPulse ? 18 : 0))

                        VStack(spacing: 5) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 28, weight: .black))
                            Text("IGNITE")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                            Text("+\(NumberFormatters.compact(viewModel.powerPerTap))")
                                .font(.caption.monospacedDigit().weight(.black))
                        }
                        .foregroundStyle(GridTheme.background)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(tapPulse ? 1.02 : 1)
            }
            .frame(width: 148, height: 156)

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("REACTOR CORE")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .tracking(1.5)
                        .foregroundStyle(GridTheme.warm)
                    Text("Manual ignition still matters. Automation turns each tap into a citywide current pulse.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(GridTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 8) {
                    miniStat("Tap", NumberFormatters.compact(viewModel.powerPerTap), GridTheme.warm)
                    miniStat("Idle", "\(NumberFormatters.compact(viewModel.passivePower))/s", GridTheme.electric)
                }
            }
        }
        .padding(14)
        .background(
            LinearGradient(colors: [GridTheme.panelHot.opacity(0.95), GridTheme.panel.opacity(0.96)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(GridTheme.warm.opacity(0.30), lineWidth: 1)
        )
    }

    private func miniStat(_ title: String, _ value: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .tracking(1)
                .foregroundStyle(GridTheme.secondaryText)
            Text(value)
                .font(.caption.monospacedDigit().weight(.black))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.22), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(accent.opacity(0.22), lineWidth: 1)
        )
    }

    private var routingPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Loadout Routing", systemImage: "switch.2")
                    .font(.system(.headline, design: .rounded).weight(.black))
                    .foregroundStyle(GridTheme.text)
                Spacer()
                Text("\(viewModel.restoredDistricts.filter(\.isPowered).count)/\(max(1, viewModel.restoredDistricts.count)) active")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
            }

            if viewModel.restoredDistricts.isEmpty {
                EmptyStateView(
                    title: "No live zones",
                    message: "Restore Residential Block from Zones to bring the first block online.",
                    systemImage: "poweroutlet.type.b"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.restoredDistricts) { district in
                        let definition = DistrictCatalog.definition(for: district.id)
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(definition.name)
                                    .font(.system(.subheadline, design: .rounded).weight(.black))
                                    .foregroundStyle(GridTheme.text)
                                Text("\(NumberFormatters.compact(EconomyEngine.districtIncomePerSecond(district, state: viewModel.state)))/s credits - \(NumberFormatters.compact(definition.baseDemand)) demand")
                                    .font(.caption)
                                    .foregroundStyle(GridTheme.secondaryText)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.state.districtState(for: district.id).isPowered },
                                set: { _ in viewModel.toggleDistrictPower(district.id) }
                            ))
                            .labelsHidden()
                            .tint(GridTheme.electric)
                        }
                        .padding(10)
                        .background(GridTheme.panelRaised.opacity(0.72), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
    }
}
