import SwiftUI

struct EventsView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        ZStack {
            GameScreenBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    CommandHeader(
                        kicker: "CITY INCIDENTS",
                        title: "Emergencies are missions.",
                        subtitle: "Fast reactions earn credits, population, and stability. Ignored alerts push the city back toward blackout.",
                        accent: GridTheme.danger
                    )

                    if viewModel.state.currentEvent != nil {
                        EventCardView()
                    } else {
                        EmptyStateView(
                            title: "No active emergency",
                            message: EventEngine.upcomingHint(state: viewModel.state),
                            systemImage: "antenna.radiowaves.left.and.right"
                        )
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("Event History", systemImage: "clock.arrow.circlepath")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(GridTheme.text)
                            Spacer()
                            Text("\(viewModel.state.stats.completedEvents) won / \(viewModel.state.stats.failedEvents) failed")
                                .font(.caption.monospacedDigit().weight(.semibold))
                                .foregroundStyle(GridTheme.secondaryText)
                        }

                        if viewModel.state.eventHistory.isEmpty {
                            EmptyStateView(
                                title: "The grid is quiet",
                                message: "Incidents begin after the first few districts come online.",
                                systemImage: "checkmark.shield"
                            )
                        } else {
                            VStack(spacing: 8) {
                                ForEach(viewModel.state.eventHistory) { entry in
                                    EventHistoryRow(entry: entry)
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 96)
            }
        }
        .navigationTitle("Alerts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct EventHistoryRow: View {
    let entry: EventHistoryEntry

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(GridTheme.text)
                Text(entry.message)
                    .font(.caption)
                    .foregroundStyle(GridTheme.secondaryText)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(10)
        .background(GridTheme.panel.opacity(0.92), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
    }

    private var icon: String {
        switch entry.outcome {
        case .success:
            return "checkmark.circle"
        case .failure:
            return "xmark.octagon"
        case .choice:
            return "arrow.triangle.branch"
        case .blackout:
            return "bolt.slash"
        }
    }

    private var color: Color {
        switch entry.outcome {
        case .success:
            return GridTheme.stable
        case .failure, .blackout:
            return GridTheme.danger
        case .choice:
            return GridTheme.warm
        }
    }
}
