import SwiftUI

struct CityView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var tapPulse = false

    var body: some View {
        ZStack {
            GridTheme.background.ignoresSafeArea()

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
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Blackout City")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                Text("THE GRID")
                    .font(.caption.weight(.black))
                    .tracking(1.8)
                    .foregroundStyle(GridTheme.electric)
                Text(CityModifierCatalog.definition(for: viewModel.state.prestige.currentCityModifier).name)
                    .font(.title2.weight(.black))
                    .foregroundStyle(GridTheme.text)
                Text("Route power, keep stability alive, and bring every district back.")
                    .font(.subheadline)
                    .foregroundStyle(GridTheme.secondaryText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Demand")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
                Text("\(NumberFormatters.compact(viewModel.totalDemand))/s")
                    .font(.system(.headline, design: .rounded).weight(.black))
                    .foregroundStyle(viewModel.totalDemand > viewModel.passivePower + 0.1 ? GridTheme.warm : GridTheme.stable)
            }
        }
    }

    private var metricsGrid: some View {
        VStack(spacing: 10) {
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
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Generator")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(GridTheme.text)
                    Text("+\(NumberFormatters.compact(viewModel.powerPerTap)) per tap, +\(NumberFormatters.compact(viewModel.passivePower))/s passive")
                        .font(.subheadline)
                        .foregroundStyle(GridTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "bolt.horizontal.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(GridTheme.warm)
            }

            ZStack {
                ForEach(viewModel.floatingGains) { gain in
                    Text(gain.text)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(GridTheme.warm)
                        .offset(y: -48)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.62)) {
                        tapPulse.toggle()
                    }
                    viewModel.tapGenerator()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "hand.tap.fill")
                        Text("Tap Generator")
                    }
                    .font(.headline.weight(.black))
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                }
                .buttonStyle(GridPrimaryButtonStyle(accent: GridTheme.warm))
                .scaleEffect(tapPulse ? 1.015 : 1)
            }
        }
        .padding(14)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(GridTheme.warm.opacity(0.22), lineWidth: 1)
        )
    }

    private var routingPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Power Routing", systemImage: "switch.2")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(GridTheme.text)
                Spacer()
                Text("\(viewModel.restoredDistricts.filter(\.isPowered).count)/\(max(1, viewModel.restoredDistricts.count)) active")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
            }

            if viewModel.restoredDistricts.isEmpty {
                EmptyStateView(
                    title: "No live districts",
                    message: "Restore Residential Block from the Districts tab to start routing city power.",
                    systemImage: "poweroutlet.type.b"
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.restoredDistricts) { district in
                        let definition = DistrictCatalog.definition(for: district.id)
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(definition.name)
                                    .font(.subheadline.weight(.bold))
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
                        .background(GridTheme.panelRaised.opacity(0.72), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }
            }
        }
    }
}
