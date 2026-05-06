import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

enum GridTheme {
    static let background = Color(hex: 0x05070D)
    static let void = Color(hex: 0x080B12)
    static let panel = Color(hex: 0x111827)
    static let panelRaised = Color(hex: 0x1A2435)
    static let panelHot = Color(hex: 0x231B12)
    static let line = Color.white.opacity(0.12)
    static let text = Color(hex: 0xF3F7FB)
    static let secondaryText = Color(hex: 0x8DA0B7)
    static let electric = Color(hex: 0x3BC6FF)
    static let electricSoft = Color(hex: 0x9BE7FF)
    static let warm = Color(hex: 0xFFC342)
    static let danger = Color(hex: 0xFF4F3D)
    static let stable = Color(hex: 0x40E08A)
    static let violet = Color(hex: 0x7A89FF)
}

enum GameArt {
    static let cityBackdrop = "blackout_city_backdrop"
    static let reactorCore = "reactor_core"
    static let eventPowerSurge = "event_power_surge"
    static let prestigeContract = "prestige_contract"

    static func districtImageName(for id: DistrictID) -> String {
        switch id {
        case .residentialBlock:
            return "district_residential_block"
        case .hospital:
            return "district_hospital"
        case .factoryZone:
            return "district_factory_zone"
        case .nightMarket:
            return "district_night_market"
        case .transitHub:
            return "district_transit_hub"
        case .dataCenter:
            return "district_data_center"
        case .waterPlant:
            return "district_water_plant"
        case .downtownCore:
            return "district_downtown_core"
        case .solarFarm:
            return "district_solar_farm"
        case .batteryYard:
            return "district_battery_yard"
        }
    }
}

struct MetricPill: View {
    let title: String
    let value: String
    let systemImage: String
    var accent: Color = GridTheme.electric

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(GridTheme.background)
                .frame(width: 30, height: 30)
                .background(
                    LinearGradient(colors: [accent, accent.opacity(0.72)], startPoint: .top, endPoint: .bottom),
                    in: RoundedRectangle(cornerRadius: 7, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .stroke(Color.white.opacity(0.24), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(GridTheme.secondaryText)
                    .lineLimit(1)
                Text(value)
                    .font(.system(.subheadline, design: .rounded).weight(.black))
                    .foregroundStyle(GridTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            LinearGradient(
                colors: [GridTheme.panelRaised.opacity(0.98), GridTheme.panel.opacity(0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 14, y: 8)
    }
}

struct StabilityBar: View {
    let stability: Double

    private var barColor: Color {
        switch stability {
        case 80...100:
            return GridTheme.stable
        case 50..<80:
            return GridTheme.warm
        case 20..<50:
            return Color.orange
        default:
            return GridTheme.danger
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Label("Grid Stability", systemImage: "waveform.path.ecg")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(GridTheme.secondaryText)
                Spacer()
                Text("\(Int(stability.rounded()))%")
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(barColor)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [barColor.opacity(0.72), barColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(4, proxy.size.width * CGFloat(stability.clamped(to: 0...100) / 100)))
                        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: stability)
                }
            }
            .frame(height: 10)
        }
        .padding(12)
        .background(GridTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
    }
}

struct ProgressMeter: View {
    let title: String
    let fraction: Double
    var accent: Color = GridTheme.electric

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundStyle(GridTheme.secondaryText)
                Spacer()
                Text(NumberFormatters.percent(fraction))
                    .font(.caption.monospacedDigit().weight(.black))
                    .foregroundStyle(GridTheme.text)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(accent)
                        .frame(width: max(4, proxy.size.width * CGFloat(fraction.clamped(to: 0...1))))
                }
            }
            .frame(height: 8)
        }
    }
}

struct GridPrimaryButtonStyle: ButtonStyle {
    var accent: Color = GridTheme.electric

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded).weight(.black))
            .foregroundStyle(GridTheme.background)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        accent.opacity(configuration.isPressed ? 0.74 : 1),
                        accent.opacity(configuration.isPressed ? 0.58 : 0.78)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(configuration.isPressed ? 0.12 : 0.32), lineWidth: 1)
                    .frame(height: 14)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.black.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: accent.opacity(configuration.isPressed ? 0.12 : 0.28), radius: configuration.isPressed ? 6 : 16, y: configuration.isPressed ? 3 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct GridSecondaryButtonStyle: ButtonStyle {
    var accent: Color = GridTheme.electric

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.subheadline, design: .rounded).weight(.black))
            .foregroundStyle(accent)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [accent.opacity(configuration.isPressed ? 0.18 : 0.12), GridTheme.panelRaised.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(accent.opacity(0.38), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(GridTheme.electric)
                .frame(width: 48, height: 48)
                .background(GridTheme.electric.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(title)
                .font(.headline)
                .foregroundStyle(GridTheme.text)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(GridTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(GridTheme.panel.opacity(0.86), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
    }
}

struct BannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.badge.clock")
            Text(message)
                .font(.caption.weight(.semibold))
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .foregroundStyle(GridTheme.text)
        .padding(10)
        .background(GridTheme.panelRaised.opacity(0.96), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(GridTheme.electric.opacity(0.25), lineWidth: 1)
        )
    }
}

struct GameScreenBackdrop: View {
    var body: some View {
        ZStack {
            GridTheme.background.ignoresSafeArea()
            LinearGradient(
                colors: [Color(hex: 0x10131F).opacity(0.92), GridTheme.background, Color(hex: 0x130C08).opacity(0.72)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            Canvas { context, size in
                let spacing: CGFloat = 28
                var path = Path()
                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += spacing
                }
                context.stroke(path, with: .color(GridTheme.electric.opacity(0.035)), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }
}

struct CommandHeader: View {
    let kicker: String
    let title: String
    let subtitle: String
    var accent: Color = GridTheme.electric

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(kicker)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .tracking(2)
                .foregroundStyle(accent)
            Text(title)
                .font(.system(size: 30, weight: .black, design: .rounded))
                .foregroundStyle(GridTheme.text)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
            Text(subtitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(GridTheme.secondaryText)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
