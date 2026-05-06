import SwiftUI
import Foundation

struct CityMapView: View {
    let state: GameState

    var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let size = proxy.size
                let time = timeline.date.timeIntervalSinceReferenceDate
                let pulse = (sin(time * 2.4) + 1) / 2

                ZStack {
                    Image(GameArt.cityBackdrop)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .opacity(1)
                        .saturation(1.05)
                        .contrast(1.02)
                        .allowsHitTesting(false)

                    LinearGradient(
                        colors: [Color.clear, Color.clear, Color.black.opacity(0.16)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)

                    VStack {
                        HStack {
                            Text("RESTORE RUSH")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .tracking(2)
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(GridTheme.electric, in: Capsule())
                            Spacer()
                            Text("\(Int(state.resources.cityCompletion * 100))% ONLINE")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .tracking(1.4)
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(GridTheme.buyGreen, in: Capsule())
                        }
                        Spacer()
                        HStack(spacing: 8) {
                            ForEach(DistrictCatalog.all.prefix(5)) { definition in
                                let district = state.districtState(for: definition.id)
                                Image(GameArt.districtImageName(for: definition.id))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 42, height: 42)
                                    .padding(4)
                                    .background(Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(district.isPowered ? GridTheme.buyGreen : Color.white, lineWidth: 2)
                                    )
                                    .opacity(district.isRestored ? 1 : 0.46)
                                    .saturation(district.isRestored ? 1 : 0)
                            }
                            Spacer()
                        }
                    }
                    .padding(12)

                    Circle()
                        .stroke(Color.white.opacity(0.38 + pulse * 0.28), lineWidth: 5)
                        .frame(width: 118, height: 118)
                        .position(x: size.width * 0.50, y: size.height * 0.88)

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
        .frame(height: 360)
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
            let roadColor = GridTheme.coinGold.opacity(0.22)
            var main = Path()
            main.move(to: CGPoint(x: canvasSize.width * 0.13, y: canvasSize.height * 0.51))
            main.addLine(to: CGPoint(x: canvasSize.width * 0.88, y: canvasSize.height * 0.51))
            context.stroke(main, with: .color(roadColor), style: StrokeStyle(lineWidth: 10, lineCap: .round))

            var vertical = Path()
            vertical.move(to: CGPoint(x: canvasSize.width * 0.52, y: canvasSize.height * 0.16))
            vertical.addLine(to: CGPoint(x: canvasSize.width * 0.52, y: canvasSize.height * 0.91))
            context.stroke(vertical, with: .color(roadColor), style: StrokeStyle(lineWidth: 9, lineCap: .round))

            var diagonal = Path()
            diagonal.move(to: CGPoint(x: canvasSize.width * 0.20, y: canvasSize.height * 0.82))
            diagonal.addLine(to: CGPoint(x: canvasSize.width * 0.82, y: canvasSize.height * 0.20))
            context.stroke(diagonal, with: .color(GridTheme.electric.opacity(0.16)), style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [8, 9]))
        }
        .allowsHitTesting(false)
    }

    private func skylineLayer(size: CGSize, pulse: Double) -> some View {
        Canvas { context, canvasSize in
            let heights: [CGFloat] = [0.18, 0.11, 0.24, 0.14, 0.31, 0.21, 0.12, 0.27, 0.17, 0.23, 0.15, 0.29]
            let width = canvasSize.width / CGFloat(heights.count)
            for index in heights.indices {
                let h = canvasSize.height * heights[index]
                let rect = CGRect(
                    x: CGFloat(index) * width,
                    y: canvasSize.height * 0.72 - h,
                    width: width * 0.82,
                    height: h
                )
                context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(Color(hex: 0x070A10).opacity(0.92)))
                if index % 3 == 0 {
                    let light = CGRect(x: rect.midX - 2, y: rect.minY + 12, width: 4, height: 5)
                    context.fill(Path(roundedRect: light, cornerRadius: 1), with: .color(GridTheme.warm.opacity(0.18 + pulse * 0.16)))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func scanlineLayer(offset: TimeInterval) -> some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, GridTheme.electric.opacity(0.10), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 46)
                .offset(y: CGFloat(Int(offset * 26) % max(1, Int(proxy.size.height + 46))) - 46)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
                    lineColor = GridTheme.coinGold.opacity(0.42 + pulse * 0.26)
                    width = 3.4
                } else {
                    lineColor = Color.white.opacity(0.30)
                    width = 1.6
                }
                context.stroke(path, with: .color(lineColor), style: StrokeStyle(lineWidth: width, lineCap: .round, dash: district.isPowered ? [] : [4, 6]))
            }
        }
        .allowsHitTesting(false)
    }
}

private struct GeneratorCore: View {
    let pulse: Double
    let current: Double

    var body: some View {
        ZStack {
            Image(GameArt.reactorCore)
                .resizable()
                .scaledToFit()
                .frame(width: 116, height: 116)
                .shadow(color: GridTheme.coinGold.opacity(0.34 + pulse * 0.18), radius: 18, y: 4)
            Circle()
                .stroke(Color.white.opacity(0.72), style: StrokeStyle(lineWidth: 3, dash: [9, 7]))
                .frame(width: 90, height: 90)
                .rotationEffect(.degrees(current * 360))
            Image(systemName: "bolt.fill")
                .font(.system(size: 25, weight: .black))
                .foregroundStyle(Color.white)
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
            SlabShape()
                .fill(fill)
                .overlay(
                    SlabShape()
                        .stroke(stroke, lineWidth: isEventDistrict ? 2 : 1)
                )
                .shadow(color: shadow, radius: state.isPowered ? 13 : 0)

            Image(GameArt.districtImageName(for: definition.id))
                .resizable()
                .scaledToFit()
                .padding(2)
                .opacity(state.isRestored ? (state.isPowered ? 1 : 0.38) : 0.16)
                .saturation(state.isRestored ? 1 : 0)
                .brightness(state.isPowered ? 0.05 : -0.20)
                .contrast(state.isPowered ? 1.08 : 0.82)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack {
                Spacer()
                Text(abbreviation)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(state.isRestored ? GridTheme.background : GridTheme.secondaryText.opacity(0.55))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 2)
                    .background(state.isPowered ? GridTheme.warm.opacity(0.92) : Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .padding(.bottom, 4)
            }
        }
        .scaleEffect(state.isPowered ? 1.0 + pulse * 0.018 : 1)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: state.isRestored)
    }

    private var fill: Color {
        if !state.isRestored {
            return Color.white.opacity(0.44)
        }
        if state.isPowered {
            return isEventDistrict ? GridTheme.danger.opacity(0.40 + pulse * 0.18) : GridTheme.buyGreen.opacity(0.30 + pulse * 0.10)
        }
        return GridTheme.panelRaised.opacity(0.72)
    }

    private var stroke: Color {
        if isEventDistrict {
            return GridTheme.danger.opacity(0.82)
        }
        if state.isPowered {
            return GridTheme.buyGreen.opacity(0.82)
        }
        if state.isRestored {
            return GridTheme.coinGold.opacity(0.42)
        }
        return Color.white.opacity(0.48)
    }

    private var shadow: Color {
        isEventDistrict ? GridTheme.danger.opacity(0.25) : GridTheme.coinGold.opacity(0.28)
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
        .padding(.bottom, 14)
    }

    private var buildingSilhouette: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(state.isRestored ? Color(hex: 0x111A28) : Color(hex: 0x06080C))
                    .frame(width: index == 1 ? 11 : 9, height: CGFloat([18, 30, 23, 15][index]))
                    .overlay(
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .stroke(Color.white.opacity(state.isRestored ? 0.08 : 0.03), lineWidth: 1)
                    )
            }
        }
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

private struct SlabShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.minY + rect.height * 0.18))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.10, y: rect.minY + rect.height * 0.18))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.55))
        path.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.18, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.55))
        path.closeSubpath()
        return path
    }
}
