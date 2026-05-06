import SwiftUI

struct CityView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var tapPulse = false

    var body: some View {
        ZStack {
            GameScreenBackdrop()

            ScrollView {
                VStack(spacing: 14) {
                    tycoonHeader
                    resourceStrip
                    CityMapView(state: viewModel.state)

                    generatorPanel

                    if viewModel.state.currentEvent != nil {
                        EventCardView()
                    }

                    productionPanel
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 96)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var tycoonHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [GridTheme.coinGold, Color(hex: 0xFF8B21)], startPoint: .top, endPoint: .bottom))
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 3))
                    .shadow(color: Color(hex: 0x9B5E10).opacity(0.28), radius: 8, y: 5)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 29, weight: .black))
                    .foregroundStyle(Color.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("THE GRID")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(GridTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Blackout City")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(GridTheme.violet, in: Capsule())
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("CITY")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(GridTheme.secondaryText)
                Text("\(Int(viewModel.state.resources.cityCompletion * 100))%")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(GridTheme.buyGreen)
            }
        }
        .padding(12)
        .background(GridTheme.panelRaised, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.85), lineWidth: 3)
        )
    }

    private var resourceStrip: some View {
        VStack(spacing: 9) {
            Grid(horizontalSpacing: 9, verticalSpacing: 9) {
                GridRow {
                    MetricPill(
                        title: "Power",
                        value: "\(NumberFormatters.compact(viewModel.state.resources.power))/\(NumberFormatters.compact(viewModel.state.resources.batteryCapacity))",
                        systemImage: "bolt.fill",
                        accent: GridTheme.coinGold
                    )
                    MetricPill(
                        title: "Credits",
                        value: NumberFormatters.compact(viewModel.state.resources.credits),
                        systemImage: "dollarsign.circle.fill",
                        accent: GridTheme.buyGreen
                    )
                }
                GridRow {
                    MetricPill(
                        title: "Income",
                        value: "\(NumberFormatters.compact(viewModel.creditsPerSecond))/s",
                        systemImage: "arrow.up.forward.circle.fill",
                        accent: GridTheme.electric
                    )
                    MetricPill(
                        title: "Fans",
                        value: "\(viewModel.state.resources.populationServed)",
                        systemImage: "person.2.fill",
                        accent: GridTheme.violet
                    )
                }
            }

            StabilityBar(stability: viewModel.state.resources.stability)
            ProgressMeter(title: "Restore Meter", fraction: viewModel.state.resources.cityCompletion, accent: GridTheme.coinGold)
                .padding(12)
                .background(GridTheme.panelRaised, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                )
        }
    }

    private var generatorPanel: some View {
        HStack(spacing: 12) {
            ZStack {
                ForEach(viewModel.floatingGains) { gain in
                    Text(gain.text)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(GridTheme.buyGreen, in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.85), lineWidth: 2))
                        .offset(y: -84)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.62)) {
                        tapPulse.toggle()
                    }
                    viewModel.tapGenerator()
                } label: {
                    Image(GameArt.reactorCore)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 138, height: 138)
                        .scaleEffect(tapPulse ? 1.04 : 1)
                        .shadow(color: GridTheme.coinGold.opacity(0.45), radius: 16, y: 8)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 150, height: 154)

            VStack(alignment: .leading, spacing: 10) {
                Text("TAP GENERATOR")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(GridTheme.text)
                Text("+\(NumberFormatters.compact(viewModel.powerPerTap)) power every tap")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(GridTheme.secondaryText)

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.62)) {
                        tapPulse.toggle()
                    }
                    viewModel.tapGenerator()
                } label: {
                    Label("MAKE POWER", systemImage: "hand.tap.fill")
                }
                .buttonStyle(GridPrimaryButtonStyle(accent: GridTheme.buyGreen))

                HStack(spacing: 8) {
                    miniStat("Tap", NumberFormatters.compact(viewModel.powerPerTap), GridTheme.coinGold)
                    miniStat("Idle", "\(NumberFormatters.compact(viewModel.passivePower))/s", GridTheme.electric)
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(colors: [Color(hex: 0xFFF7C7), Color(hex: 0xFFD96E)], startPoint: .top, endPoint: .bottom),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.85), lineWidth: 3)
        )
        .shadow(color: Color(hex: 0x9B5E10).opacity(0.25), radius: 12, y: 7)
    }

    private var productionPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("POWER BUSINESSES")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(GridTheme.text)
                Spacer()
                Text("\(viewModel.restoredDistricts.filter(\.isPowered).count) running")
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(GridTheme.electric, in: Capsule())
            }

            ForEach(DistrictCatalog.all) { definition in
                ProductionRow(definition: definition)
            }
        }
        .padding(12)
        .background(GridTheme.panel.opacity(0.98), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.78), lineWidth: 3)
        )
    }

    private func miniStat(_ title: String, _ value: String, _ accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
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
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(accent.opacity(0.28), lineWidth: 2)
        )
    }
}

private struct ProductionRow: View {
    @EnvironmentObject private var viewModel: GameViewModel
    let definition: DistrictDefinition

    private var district: DistrictState {
        viewModel.state.districtState(for: definition.id)
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(GameArt.districtImageName(for: definition.id))
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .opacity(district.isRestored ? 1 : 0.45)
                .saturation(district.isRestored ? 1 : 0)
                .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.95), lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(definition.name)
                        .font(.system(size: 15, weight: .black, design: .rounded))
                        .foregroundStyle(GridTheme.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    Spacer()
                    Text("LV \(district.level)")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 3)
                        .padding(.horizontal, 7)
                        .background(GridTheme.violet, in: Capsule())
                }

                ProgressMeter(title: district.isRestored ? "Profit timer" : "Locked route", fraction: progressFraction, accent: progressColor)

                HStack(spacing: 6) {
                    Text("\(NumberFormatters.compact(EconomyEngine.districtIncomePerSecond(district, state: viewModel.state)))/s")
                        .font(.caption.monospacedDigit().weight(.black))
                        .foregroundStyle(GridTheme.buyGreen)
                    Text("Load \(NumberFormatters.compact(definition.baseDemand))")
                        .font(.caption.monospacedDigit().weight(.bold))
                        .foregroundStyle(GridTheme.secondaryText)
                    Spacer()
                }
            }

            VStack(spacing: 6) {
                actionButton

                if district.isRestored {
                    Toggle("", isOn: Binding(
                        get: { viewModel.state.districtState(for: definition.id).isPowered },
                        set: { _ in viewModel.toggleDistrictPower(definition.id) }
                    ))
                    .labelsHidden()
                    .tint(GridTheme.buyGreen)
                }
            }
            .frame(width: 92)
        }
        .padding(9)
        .background(district.isRestored ? Color.white.opacity(0.92) : Color(hex: 0xD9E4EA).opacity(0.86), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(district.isPowered ? GridTheme.buyGreen.opacity(0.70) : Color.white.opacity(0.82), lineWidth: 3)
        )
        .shadow(color: Color(hex: 0x7B643A).opacity(0.14), radius: 8, y: 4)
    }

    @ViewBuilder
    private var actionButton: some View {
        if district.isRestored {
            let cost = EconomyEngine.districtUpgradeCost(definition.id, state: viewModel.state)
            Button {
                viewModel.upgradeDistrict(definition.id)
            } label: {
                VStack(spacing: 1) {
                    Text(district.level >= 5 ? "MAX" : "UP")
                    Text(district.level >= 5 ? "" : NumberFormatters.compact(cost))
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
            }
            .buttonStyle(GridPrimaryButtonStyle(accent: district.level >= 5 ? GridTheme.secondaryText : GridTheme.coinGold))
            .disabled(district.level >= 5 || viewModel.state.resources.credits < cost)
        } else {
            let cost = EconomyEngine.restoreCost(for: definition.id, state: viewModel.state)
            Button {
                viewModel.restoreDistrict(definition.id)
            } label: {
                VStack(spacing: 1) {
                    Text("BUY")
                    Text(NumberFormatters.compact(cost))
                        .font(.system(size: 10, weight: .black, design: .rounded))
                }
            }
            .buttonStyle(GridPrimaryButtonStyle(accent: viewModel.state.resources.power >= cost ? GridTheme.buyGreen : GridTheme.secondaryText))
            .disabled(viewModel.state.resources.power < cost)
        }
    }

    private var progressFraction: Double {
        guard district.isRestored else { return 0.08 }
        let base = (Double(definition.id.rawValue.count % 7) + Double(district.level)) / 9
        return district.isPowered ? base.clamped(to: 0.18...0.98) : 0.12
    }

    private var progressColor: Color {
        if !district.isRestored {
            return GridTheme.secondaryText
        }
        return district.isPowered ? GridTheme.buyGreen : GridTheme.warm
    }
}
