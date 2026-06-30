import CoreGraphics
import XCTest
@testable import GrowEffectKit

final class GrowEffectConfigurationTests: XCTestCase {
    func testDefaultConfigurationMatchesCurrentDressMatchBehavior() {
        let configuration = GrowEffectConfiguration()

        XCTAssertEqual(configuration.peakScale, CGFloat(1.035))
        XCTAssertEqual(configuration.duration, 1.6)
        XCTAssertEqual(configuration.glowOpacity, 0.22)
        XCTAssertEqual(configuration.cornerRadius, CGFloat(34))
        XCTAssertEqual(configuration.lineWidth, CGFloat(4))
        XCTAssertEqual(configuration.amplitude, 3.0)
        XCTAssertEqual(configuration.minimumTimelineInterval, 1.0 / 30.0)
        XCTAssertEqual(configuration.glowColors.count, 7)
    }

    func testEmptyColorInputFallsBackToDefaultGlowColors() {
        let configuration = GrowEffectConfiguration(glowColors: [])

        XCTAssertEqual(configuration.effectiveGlowColors.count, GrowEffectConfiguration.defaultGlowColors.count)
    }

    func testCustomConfigurationStoresCallerValues() {
        let configuration = GrowEffectConfiguration(
            peakScale: 1.02,
            duration: 2.1,
            glowOpacity: 0.32,
            glowColors: [.red, .blue],
            cornerRadius: 18,
            lineWidth: 6,
            amplitude: 2.5,
            minimumTimelineInterval: 1.0 / 24.0
        )

        XCTAssertEqual(configuration.peakScale, CGFloat(1.02))
        XCTAssertEqual(configuration.duration, 2.1)
        XCTAssertEqual(configuration.glowOpacity, 0.32)
        XCTAssertEqual(configuration.cornerRadius, CGFloat(18))
        XCTAssertEqual(configuration.lineWidth, CGFloat(6))
        XCTAssertEqual(configuration.amplitude, 2.5)
        XCTAssertEqual(configuration.minimumTimelineInterval, 1.0 / 24.0)
        XCTAssertEqual(configuration.effectiveGlowColors.count, 2)
    }
}
