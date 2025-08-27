import Testing
import SwiftUI
@testable import ZPTooltip

struct TooltipGeometryCalculatorTests {

    // User iPhone 16 Pro Max as reference
    let container = CGRect(x: 0, y: 0, width: 430, height: 932)
    let tooltipSize = CGSize(width: 200, height: 80)
    let padding: CGFloat = 16

    // Helper: create trigger rect at a specific point
    private func triggerRect(at point: CGPoint, size: CGSize = CGSize(width: 8, height: 8)) -> CGRect {
        CGRect(
            x: point.x - size.width / 2,
            y: point.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
    // MARK: - Tests

    @Test
    func topLeading() {
        let trigger = triggerRect(at: CGPoint(x: padding, y: padding))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.y > trigger.minY) // tooltip below
        #expect(geom.position.x >= tooltipSize.width/2) // clamped to left edge
    }

    @Test
    func topCenter() {
        let trigger = triggerRect(at: CGPoint(x: container.midX, y: padding))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.y > trigger.minY) // tooltip below
        #expect(abs(geom.position.x - container.midX) < 1) // centered horizontally
    }

    @Test
    func topTrailing() {
        let trigger = triggerRect(at: CGPoint(x: container.maxX - padding, y: padding))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.y > trigger.minY) // below
        #expect(geom.position.x <= container.maxX - tooltipSize.width/2) // clamped right
    }

    @Test
    func centerLeading() {
        let trigger = triggerRect(at: CGPoint(x: padding, y: container.midY))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(abs(geom.position.y - (trigger.maxY + tooltipSize.height/2)) < 1) // below trigger
        #expect(geom.position.x >= tooltipSize.width/2) // clamped left
    }

    @Test
    func center() {
        let trigger = triggerRect(at: CGPoint(x: container.midX, y: container.midY))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(abs(geom.position.x - container.midX) < 1)
        #expect(geom.position.y > trigger.maxY) // placed below
    }

    @Test
    func centerTrailing() {
        let trigger = triggerRect(at: CGPoint(x: container.maxX - padding, y: container.midY))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.x <= container.maxX - tooltipSize.width/2) // clamped right
        #expect(geom.position.y > trigger.maxY) // below
    }

    @Test
    func bottomLeading() {
        let trigger = triggerRect(at: CGPoint(x: padding, y: container.maxY - padding))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.y < trigger.minY) // must be above (no space below)
        #expect(geom.position.x >= tooltipSize.width/2) // clamped left
    }

    @Test
    func bottomCenter() {
        let trigger = triggerRect(at: CGPoint(x: container.midX, y: container.maxY - padding))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.y < trigger.minY) // above
        #expect(abs(geom.position.x - container.midX) < 1) // centered
    }

    @Test
    func bottomTrailing() {
        let trigger = triggerRect(at: CGPoint(x: container.maxX - padding, y: container.maxY - padding))
        let geom = TooltipGeometryCalculator.compute(trigger: trigger, tooltipSize: tooltipSize, container: container)

        #expect(geom.position.y < trigger.minY) // above
        #expect(geom.position.x <= container.maxX - tooltipSize.width/2) // clamped right
    }
}
