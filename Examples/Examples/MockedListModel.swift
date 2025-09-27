import SwiftUI
import ZPTooltip

#if os(iOS)
extension ListModel {
  public static var mocked: Self {
    return Self(options: [
      .init(label: "Go to Document", icon: Image(systemName: "info.square"), action: { print("Go to document...") }),
      .init(label: "Play Next", icon: Image(systemName: "list.triangle"), action: { }),
      .init(label: "Mark as Played", icon: Image(systemName: "rectangle.badge.checkmark"), action: { }),
      .init(label: "View Transcript", icon: Image(systemName: "quote.bubble"), action: {}),
      .init(label: "Share Document...", icon: Image(systemName: "square.and.arrow.up"), action: {}),
      .init(label: "Copy Link", icon: Image(systemName: "link"), action: {}),
      .init(label: "Report a Concern", icon: Image(systemName: "exclamationmark.bubble"), action: {}),
    ])
  }
}
#endif
