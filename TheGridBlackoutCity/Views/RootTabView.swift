import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        TabView {
            NavigationStack {
                CityView()
            }
            .tabItem {
                Label("City", systemImage: "building.2")
            }

            NavigationStack {
                DistrictsView()
            }
            .tabItem {
                Label("Districts", systemImage: "square.grid.3x3")
            }

            NavigationStack {
                UpgradesView()
            }
            .tabItem {
                Label("Upgrades", systemImage: "arrow.up.circle")
            }

            NavigationStack {
                EventsView()
            }
            .tabItem {
                Label("Events", systemImage: "exclamationmark.triangle")
            }

            NavigationStack {
                PrestigeView()
            }
            .tabItem {
                Label("Prestige", systemImage: "sparkles.rectangle.stack")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(GridTheme.electric)
        .background(GridTheme.background)
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
