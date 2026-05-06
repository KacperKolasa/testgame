import SwiftUI

struct EventCardView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        if let event = viewModel.state.currentEvent {
            let definition = EventCatalog.definition(for: event.type)
            VStack(alignment: .leading, spacing: 12) {
                Image(GameArt.eventPowerSurge)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.42)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    )

                HStack {
                    Text("MISSION ALERT")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(GridTheme.danger)
                    Spacer()
                    Text("T-\(Int(event.remaining.rounded(.up)))")
                        .font(.caption.monospacedDigit().weight(.black))
                        .foregroundStyle(GridTheme.warm)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.black.opacity(0.30), in: Capsule())
                }

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: definition.systemImage)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(GridTheme.background)
                        .frame(width: 46, height: 46)
                        .background(
                            LinearGradient(colors: [GridTheme.danger, GridTheme.warm], startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.26), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(definition.title)
                            .font(.system(.title3, design: .rounded).weight(.black))
                            .foregroundStyle(GridTheme.text)
                        Text(definition.description)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(GridTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Timer")
                        Spacer()
                        Text("\(Int(event.remaining.rounded(.up)))s")
                    }
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
                    ProgressMeter(title: "Objective", fraction: event.progressFraction, accent: GridTheme.danger)
                }

                if event.type == .factoryOverload {
                    VStack(spacing: 8) {
                        eventButton(.slowProduction)
                        eventButton(.pushOutput)
                        eventButton(.maintenance)
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(definition.actions) { action in
                            eventButton(action)
                        }
                    }
                }

                HStack(spacing: 10) {
                    Label(definition.reward, systemImage: "checkmark.circle")
                        .foregroundStyle(GridTheme.stable)
                    Spacer(minLength: 0)
                    Label(definition.penalty, systemImage: "xmark.octagon")
                        .foregroundStyle(GridTheme.danger)
                }
                .font(.caption2.weight(.medium))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color(hex: 0x2A1110).opacity(0.98), GridTheme.panelRaised.opacity(0.98), Color(hex: 0x111827).opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(GridTheme.danger.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: GridTheme.danger.opacity(0.20), radius: 18, y: 10)
        }
    }

    @ViewBuilder
    private func eventButton(_ action: PlayerEventAction) -> some View {
        if action == .pushOutput {
            Button {
                viewModel.performEventAction(action)
            } label: {
                Label(title(for: action), systemImage: icon(for: action))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .buttonStyle(GridSecondaryButtonStyle(accent: GridTheme.warm))
        } else {
            Button {
                viewModel.performEventAction(action)
            } label: {
                Label(title(for: action), systemImage: icon(for: action))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .buttonStyle(GridPrimaryButtonStyle(accent: accent(for: action)))
        }
    }

    private func title(for action: PlayerEventAction) -> String {
        switch action {
        case .stabilizeTap:
            return "Stabilize"
        case .prioritizeHospital:
            return "Protect Hospital"
        case .repairLines:
            return "Repair Lines"
        case .slowProduction:
            return "Slow Production"
        case .pushOutput:
            return "Push Output"
        case .maintenance:
            return "Maintenance"
        case .routeMarket:
            return "Route Power"
        case .coolServers:
            return "Cool Servers"
        }
    }

    private func icon(for action: PlayerEventAction) -> String {
        switch action {
        case .stabilizeTap:
            return "hand.tap"
        case .prioritizeHospital:
            return "cross.case"
        case .repairLines:
            return "wrench.adjustable"
        case .slowProduction:
            return "tortoise"
        case .pushOutput:
            return "bolt.fill"
        case .maintenance:
            return "gearshape"
        case .routeMarket:
            return "arrow.triangle.turn.up.right.diamond"
        case .coolServers:
            return "fan"
        }
    }

    private func accent(for action: PlayerEventAction) -> Color {
        switch action {
        case .pushOutput:
            return GridTheme.warm
        case .repairLines, .maintenance, .coolServers:
            return GridTheme.stable
        case .prioritizeHospital:
            return GridTheme.danger
        default:
            return GridTheme.electric
        }
    }
}
