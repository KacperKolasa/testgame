import SwiftUI

enum CommandScreen: String, CaseIterable, Identifiable {
    case city
    case districts
    case upgrades
    case events
    case prestige
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .city:
            return "Grid"
        case .districts:
            return "Zones"
        case .upgrades:
            return "Tech"
        case .events:
            return "Alerts"
        case .prestige:
            return "Rebuild"
        case .settings:
            return "Ops"
        }
    }

    var icon: String {
        switch self {
        case .city:
            return "bolt.fill"
        case .districts:
            return "square.grid.3x3.fill"
        case .upgrades:
            return "arrow.up.circle.fill"
        case .events:
            return "exclamationmark.triangle.fill"
        case .prestige:
            return "sparkles.rectangle.stack.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
}

struct RootTabView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @State private var selectedScreen: CommandScreen = .city

    var body: some View {
        NavigationStack {
            content
        }
        .tint(GridTheme.electric)
        .background(GridTheme.background)
        .safeAreaInset(edge: .bottom) {
            CommandDock(selectedScreen: $selectedScreen)
        }
        .overlay(alignment: .top) {
            if let message = viewModel.bannerMessage {
                BannerView(message: message)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: message) {
                        try? await Task.sleep(for: .seconds(2.2))
                        if viewModel.bannerMessage == message {
                            viewModel.bannerMessage = nil
                        }
                    }
            }
        }
        .sheet(item: $viewModel.offlineResult) { result in
            OfflineEarningsSheet(result: result) {
                viewModel.dismissOfflineResult()
            }
            .presentationDetents([.height(310)])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedScreen {
        case .city:
            CityView()
        case .districts:
            DistrictsView()
        case .upgrades:
            UpgradesView()
        case .events:
            EventsView()
        case .prestige:
            PrestigeView()
        case .settings:
            SettingsView()
        }
    }
}

private struct CommandDock: View {
    @Binding var selectedScreen: CommandScreen

    var body: some View {
        HStack(spacing: 6) {
            ForEach(CommandScreen.allCases) { screen in
                Button {
                    selectedScreen = screen
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: screen.icon)
                            .font(.system(size: 16, weight: .black))
                        Text(screen.title)
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selectedScreen == screen ? Color.white : GridTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(tabFill(isSelected: selectedScreen == screen))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(selectedScreen == screen ? Color.white.opacity(0.72) : GridTheme.line, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            LinearGradient(colors: [GridTheme.background.opacity(0), Color(hex: 0x59BD55).opacity(0.94)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private func tabFill(isSelected: Bool) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(LinearGradient(colors: [GridTheme.coinGold, GridTheme.buyGreen], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(LinearGradient(colors: [GridTheme.panelRaised.opacity(1), GridTheme.panel.opacity(1)], startPoint: .top, endPoint: .bottom))
    }
}

private struct OfflineEarningsSheet: View {
    let result: OfflineProgressResult
    let dismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Offline Dispatch")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(GridTheme.text)
                    Text("Crews kept the grid moving for \(timeString(result.cappedElapsed)).")
                        .font(.subheadline)
                        .foregroundStyle(GridTheme.secondaryText)
                }
                Spacer()
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(GridTheme.electric)
            }

            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    MetricPill(title: "Credits", value: NumberFormatters.compact(result.creditsGained), systemImage: "creditcard", accent: GridTheme.warm)
                    MetricPill(title: "Power", value: NumberFormatters.compact(result.powerGained), systemImage: "bolt", accent: GridTheme.electric)
                }
                GridRow {
                    MetricPill(title: "Stability", value: "\(result.stabilityChange >= 0 ? "+" : "")\(NumberFormatters.compact(result.stabilityChange))", systemImage: "waveform.path.ecg", accent: result.stabilityChange >= 0 ? GridTheme.stable : GridTheme.danger)
                    MetricPill(title: "Capped", value: timeString(result.cappedElapsed), systemImage: "hourglass", accent: GridTheme.secondaryText)
                }
            }

            Button("Return to the grid", action: dismiss)
                .buttonStyle(GridPrimaryButtonStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GridTheme.background)
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
