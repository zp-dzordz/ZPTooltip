import SwiftUI

struct TooltipGeometry {
  var position: CGPoint
  var anchor: UnitPoint
}

struct TooltipGeometryCalculator {
  static func compute(
    trigger: CGRect,
    tooltipSize: CGSize,
    container: CGRect
  ) -> TooltipGeometry {
    var pos = CGPoint.zero
    var anchor = UnitPoint.center

    // --- Vertical placement ---
    if trigger.maxY + tooltipSize.height <= container.maxY {
        // place below
        pos.y = trigger.maxY + tooltipSize.height / 2
        anchor.y = trigger.maxY / container.height
    } else {
        // place above
        pos.y = trigger.minY - tooltipSize.height / 2
        anchor.y = trigger.minY / container.height
    }
    
    // --- Horizontal placement ---
    let idealX = trigger.midX
    let halfWidth = tooltipSize.width / 2
    if idealX - halfWidth < container.minX {
      pos.x = container.minX + halfWidth
    } else if idealX + halfWidth > container.maxX {
      pos.x = container.maxX - halfWidth
    } else {
      pos.x = idealX
    }
    anchor.x = trigger.midX / container.width
    
    return TooltipGeometry(position: pos, anchor: anchor)
  }
}

