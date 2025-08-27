import SnapshotTesting
import SwiftUI
import XCTest
@testable import ZPTooltip

final class ZPTooltipTests: XCTestCase {
  
  @MainActor
  func testTooltipsSnapshots() {
    let config = ViewImageConfig.iPhone13(.portrait)
    let timeout: TimeInterval = 0.5
    
    for configuration in NineGrid_Previews.snapshots.configurations {
      
      let view = NineGrid_Previews.snapshots.configure(configuration.state)
        .frame(width: config.size!.width, height: config.size!.height)

      let vc = UIHostingController(rootView: view)

      vc.view.frame = CGRect(x: 0, y: 0, width: config.size!.width, height: config.size!.height)
      let window = UIWindow(frame: vc.view.frame)
      window.rootViewController = vc
      window.makeKeyAndVisible()

      assertSnapshot(
        of: vc,
        as: .wait(
          for: timeout,
          on: .image(
            on: .iPhone13,
            precision: 0.98
          )
        ),
        named: configuration.name
      )
    }
  }
}

