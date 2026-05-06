import SwiftUI
import Foundation

struct CityMapView: View {
    let state: GameState

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let size = proxy.size
                let pulse = (sin(timeline.date.timeIntervalSinceReferenceDate * 2.4) + 1) / 2

                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x081420), Color(hex: 0x0C1A29), Color(hex: 0x07111D)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    roadLayer(size: size)
                    powerLineLayer(size: size, pulse: pulse)

                    GeneratorCore(pulse: pulse)
                        .position(x: size.width * 0.50, y: size.height * 0.93)

                    ForEach(DistrictCatalog.all) { definition in
                        DistrictMapNode(
                            definition: definition,
                            state: state.districtState(for: definition.id),
                            eventType: state.currentEvent?.type,
                            pulse: pulse
                        )
                        .frame(width: nodeWidth(size: size, for: definition), height: nodeHeight(size: size, for: definition))
                        .position(x: size.width * CGFloat(definition.mapPosition.x), y: size.height * CGFloat(definition.mapPosition.y))
                    }

                    if state.blackoutTimer > 0 {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(GridTheme.danger.opacity(0.35 + pulse * 0.35), lineWidth: 2)
                            .padding(2)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(GridTheme.electric.opacity(0.18), lineWidth: 1)
                )
            }
        }
        .frame(height: 330)
    }

    private func nodeWidth(size: CGSize, for definition: DistrictDefinition) -> CGFloat {
        switch definition.id {
        case .downtownCore:
            return min(82, max(62, size.width * 0.19))
        case .hospital, .dataCenter, .factoryZone:
            return min(76, max(58, size.width * 0.17))
        default:
            return min(68, max(50, size.width * 0.155))
        }
    }

    private func nodeHeight(size: CGSize, for definition: DistrictDefinition) -> CGFloat {
        switch definition.id {
        case .downtownCore:
            return 66
        case .factoryZone, .dataCenter:
            return 58
        default:
            return 50
        }
    }

    private func roadLayer(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let roadColor = Color.white.opacity(0.08)
            var main = Path()
            main.move(to: CGPoint(x: canvasSize.width * 0.13, y: canvasSize.height * 0.51))
            main.addLine(to: CGPoint(x: canvasSize.width * 0.88, y: canvasSize.height * 0.51))
            context.stroke(main, with: .color(roadColor), style: StrokeStyle(lineWidth: 8, lineCap: .round))

            var vertical = Path()
            vertical.move(to: CGPoint(x: canvasSize.width * 0.52, y: canvasSize.height * 0.16))
            vertical.addLine(to: CGPoint(x: canvasSize.width * 0.52, y: canvasSize.height * 0.91))
            context.stroke(vertical, with: .color(roadColor), style: StrokeStyle(lineWidth: 7, lineCap: .round))

            var diagonal = Path()
            diagonal.move(to: CGPoint(x: canvasSize.width * 0.20, y: canvasSize.height * 0.82))
            diagonal.addLine(to: CGPoint(x: canvasSize.width * 0.82, y: canvasSize.height * 0.20))
            context.stroke(diagonal, with: .color(Color.white.opacity(0.045)), style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [8, 9]))
        }
        .allowsHitTesting(false)
    }

    private func powerLineLayer(size: CGSize, pulse: Double) -> some View {
        Canvas { context, canvasSize in
            let generator = CGPoint(x: canvasSize.width * 0.50, y: canvasSize.height * 0.93)
            for definition in DistrictCatalog.all {
                let district = state.districtState(for: definition.id)
                guard district.isRestored else { continue }
                let point = CGPoint(x: canvasSize.width * CGFloat(definition.mapPosition.x), y: canvasSize.height * CGFloat(definition.mapPosition.y))
                var path = Path()
                path.move(to: generator)
                path.addLine(to: point)

                let lineColor: Color
                let width: CGFloat
                if district.isPowered {
                    lineColor = GridTheme.electric.opacity(0.22 + pulse * 0.18)
                    width = 2.2
                } else {
                    lineColor = GridTheme.secondaryText.opacity(0.16)
                    width = 1.2
                }
                context.stroke(path, with: .color(lineColor), style: StrokeStyle(lineWidth: width, lineCap: .round, dash: district.isPowered ? [] : [4, 6]))
            }
        }
        .allowsHitTesting(false)
    }
}

private struct GeneratorCore: View {
    let pulse: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(GridTheme.electric.opacity(0.08 + pulse * 0.08))
                .frame(width: 84, height: 84)
            Circle()
                .stroke(GridTheme.electric.opacity(0.35), lineWidth: 2)
                .frame(width: 62, height: 62)
            Image(systemName: "bolt.fill")
                .font(.system(size: 28, weight: .black))
                .foregroundStyle(GridTheme.warm)
                .shadow(color: GridTheme.warm.opacity(0.45), radius: 8, y: 2)
        }
    }
}

private struct DistrictMapNode: View {
    let definition: DistrictDefinition
    let state: DistrictState
    let eventType: GameEventType?
    let pulse: Double

    private var isEventDistrict: Bool {
        switch eventType {
        case .hospitalEmergency:
            return definition.id == .hospital
        case .factoryOverload:
            return definition.id == .factoryZone
        case .festivalNight:
            return definition.id == .nightMarket
        case .dataSpike:
            return definition.id == .dataCenter
        case .stormDamage:
            return definition.id == .waterPlant || definition.id == .solarFarm
        default:
            return false
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(fill)
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(stroke, lineWidth: isEventDistrict ? 2 : 1)
                )
                .shadow(color: shadow, radius: state.isPowered ? 9 : 0)

            buildingWindows

            VStack {
                Spacer()
                Text(abbreviation)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(state.isRestored ? GridTheme.text.opacity(0.86) : GridTheme.secondaryText.opacity(0.45))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 3)
                    .padding(.bottom, 4)
            }
        }
        .scaleEffect(state.isPowered ? 1.0 + pulse * 0.018 : 1)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: state.isRestored)
    }

    private var fill: Color {
        if !state.isRestored {
            return Color(hex: 0x0C1420)
        }
        if state.isPowered {
            return isEventDistrict ? GridTheme.danger.opacity(0.26 + pulse * 0.16) : GridTheme.electric.opacity(0.18 + pulse * 0.08)
        }
        return GridTheme.panelRaised.opacity(0.58)
    }

    private var stroke: Color {
        if isEventDistrict {
            return GridTheme.danger.opacity(0.82)
        }
        if state.isPowered {
            return GridTheme.electric.opacity(0.58)
        }
        if state.isRestored {
            return GridTheme.secondaryText.opacity(0.24)
        }
        return Color.white.opacity(0.06)
    }

    private var shadow: Color {
        isEventDistrict ? GridTheme.danger.opacity(0.25) : GridTheme.electric.opacity(0.22)
    }

    private var abbreviation: String {
        definition.name
            .split(separator: " ")
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }

    private var buildingWindows: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<4, id: \.self) { column in
                        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                            .fill(windowColor(row: row, column: column))
                            .frame(width: 5, height: state.isRestored ? 6 : 4)
                    }
                }
            }
        }
        .padding(.bottom, 9)
    }

    private func windowColor(row: Int, column: Int) -> Color {
        guard state.isRestored else {
            return Color.white.opacity(0.035)
        }
        guard state.isPowered else {
            return GridTheme.electric.opacity(0.12)
        }

        let alternating = (row + column + definition.id.rawValue.count) % 3 == 0
        return alternating ? GridTheme.warm.opacity(0.82 + pulse * 0.15) : GridTheme.electricSoft.opacity(0.55 + pulse * 0.12)
    }
}
