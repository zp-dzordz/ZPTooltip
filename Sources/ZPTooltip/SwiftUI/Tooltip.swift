import SwiftUI

extension View {
  public func tooltip<Item, Content>(
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View where Item: Equatable, Content: View {
    self.modifier(
      TooltipHelper<Item, Content>(
        item: item,
        tooltipBody: { item in
          content(item)
        })
    )
  }
}
