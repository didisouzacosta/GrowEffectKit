import SwiftUI

public struct GrowEffectModifier: ViewModifier {
    public let isActive: Bool
    public let configuration: GrowEffectConfiguration

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPulsing = false

    public init(
        isActive: Bool,
        configuration: GrowEffectConfiguration = GrowEffectConfiguration()
    ) {
        self.isActive = isActive
        self.configuration = configuration
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                growGlow
            }
            .scaleEffect(isPulsing ? configuration.peakScale : 1)
            .animation(animation, value: isPulsing)
            .onAppear {
                updatePulse()
            }
            .onChange(of: isActive) { _, _ in
                updatePulse()
            }
            .onChange(of: reduceMotion) { _, _ in
                updatePulse()
            }
    }

    private var shouldPulse: Bool {
        isActive && !reduceMotion
    }

    private var growGlow: some View {
        Group {
            if isActive {
                if reduceMotion {
                    glowingBorder(
                        originUnitPoint: CGPoint(x: 0.5, y: 0.5),
                        progress: 1
                    )
                } else {
                    TimelineView(.animation(minimumInterval: configuration.minimumTimelineInterval)) { timeline in
                        let phase = GrowEffectPhase.phase(
                            at: timeline.date,
                            duration: configuration.duration
                        )

                        glowingBorder(
                            originUnitPoint: phase.originUnitPoint,
                            progress: phase.progress
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var gradientStops: [Gradient.Stop] {
        let colors = configuration.effectiveGlowColors

        guard colors.count > 1 else {
            return [.init(color: colors.first ?? .accentColor, location: 0)]
        }

        return colors.enumerated().map { offset, color in
            .init(color: color, location: Double(offset) / Double(colors.count - 1))
        }
    }

    private var animation: Animation {
        shouldPulse
            ? .easeInOut(duration: configuration.duration).repeatForever(autoreverses: true)
            : .smooth(duration: 0.18)
    }

    private var glowGradient: AngularGradient {
        AngularGradient(
            stops: gradientStops,
            center: .center,
            startAngle: .radians(.zero),
            endAngle: .radians(.pi * 2)
        )
    }

    private func glowingBorder(originUnitPoint: CGPoint, progress: Double) -> some View {
        RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous)
            .growGlow(fill: glowGradient, lineWidth: configuration.lineWidth)
            .modifier(
                ProgressiveGrowGlow(
                    originUnitPoint: originUnitPoint,
                    progress: progress,
                    amplitude: configuration.amplitude
                )
            )
            .opacity(max(configuration.glowOpacity, 0.72))
            .compositingGroup()
    }

    private func updatePulse() {
        isPulsing = shouldPulse
    }
}

private struct ProgressiveGrowGlow: ViewModifier {
    let originUnitPoint: CGPoint
    let progress: Double
    let amplitude: Double

    func body(content: Content) -> some View {
        content.visualEffect { view, proxy in
            view.colorEffect(
                ShaderLibrary.bundle(.module).growGlow(
                    .float2(
                        CGPoint(
                            x: originUnitPoint.x * proxy.size.width,
                            y: originUnitPoint.y * proxy.size.height
                        )
                    ),
                    .float2(proxy.size),
                    .float(amplitude),
                    .float(progress)
                )
            )
        }
    }
}

private extension Shape {
    func growGlow(
        fill: some ShapeStyle,
        lineWidth: CGFloat,
        blurRadius: CGFloat = 8
    ) -> some View {
        stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: .round))
            .fill(fill)
            .overlay {
                stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(fill)
                    .blur(radius: blurRadius)
            }
            .overlay {
                stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(fill)
                    .blur(radius: blurRadius / 2)
            }
    }
}

public extension View {
    func growEffect(
        isActive: Bool,
        peakScale: CGFloat = 1.035,
        duration: TimeInterval = 1.6,
        glowOpacity: Double = 0.22,
        glowColors: [Color] = GrowEffectConfiguration.defaultGlowColors,
        cornerRadius: CGFloat = 34,
        lineWidth: CGFloat = 4
    ) -> some View {
        modifier(
            GrowEffectModifier(
                isActive: isActive,
                configuration: GrowEffectConfiguration(
                    peakScale: peakScale,
                    duration: duration,
                    glowOpacity: glowOpacity,
                    glowColors: glowColors,
                    cornerRadius: cornerRadius,
                    lineWidth: lineWidth
                )
            )
        )
    }

    func growEffect(
        isActive: Bool,
        configuration: GrowEffectConfiguration
    ) -> some View {
        modifier(
            GrowEffectModifier(
                isActive: isActive,
                configuration: configuration
            )
        )
    }
}
