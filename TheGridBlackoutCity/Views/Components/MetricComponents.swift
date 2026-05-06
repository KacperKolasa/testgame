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
    static let background = Color(hex: 0x07111D)
    static let panel = Color(hex: 0x101C2A)
    static let panelRaised = Color(hex: 0x162538)
    static let line = Color.white.opacity(0.09)
    static let text = Color(hex: 0xE8F0F7)
    static let secondaryText = Color(hex: 0x94A9BE)
    static let electric = Color(hex: 0x52B7E8)
    static let electricSoft = Color(hex: 0x8FD3FF)
    static let warm = Color(hex: 0xFFD66B)
    static let danger = Color(hex: 0xF46D5E)
    static let stable = Color(hex: 0x63D7A0)
}

struct MetricPill: View {
    let title: String
    let value: String
    let systemImage: String
    var accent: Color = GridTheme.electric

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                .background(accent.opacity(0.13), in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(GridTheme.secondaryText)
                    .lineLimit(1)
                Text(value)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(GridTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(GridTheme.panel.opacity(0.92), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(GridTheme.line, lineWidth: 1)
        )
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
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
                Spacer()
                Text("\(Int(stability.rounded()))%")
                    .font(.caption.monospacedDigit().weight(.bold))
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
        .background(GridTheme.panel.opacity(0.92), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
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
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(GridTheme.secondaryText)
                Spacer()
                Text(NumberFormatters.percent(fraction))
                    .font(.caption.monospacedDigit().weight(.bold))
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
            .font(.subheadline.weight(.bold))
            .foregroundStyle(GridTheme.background)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(accent.opacity(configuration.isPressed ? 0.72 : 1), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct GridSecondaryButtonStyle: ButtonStyle {
    var accent: Color = GridTheme.electric

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(accent)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(accent.opacity(configuration.isPressed ? 0.16 : 0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(accent.opacity(0.25), lineWidth: 1)
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
        .background(GridTheme.panel.opacity(0.86), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
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
        .background(GridTheme.panelRaised.opacity(0.96), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(GridTheme.electric.opacity(0.25), lineWidth: 1)
        )
    }
}
