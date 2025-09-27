import Observation
import SwiftUI

struct TooltipHelper<Item: Equatable, TooltipContent: View>: ViewModifier {
  @State var model: TooltipState = .init()
  @State private var transitionAnchor: UnitPoint = .center
  @State private var cachedTooltip: TooltipContent? = nil
  @State private var tooltipPos: CGPoint = .zero
  @State private var tooltipFrame: CGRect?
  @Binding private var item: Item?
  
  private let tooltipBody: (Item) -> TooltipContent
  
  init(
    item: Binding<Item?>,
    @ViewBuilder tooltipBody: @escaping (Item) -> TooltipContent
  ) {
    self._item = item
    self.tooltipBody = tooltipBody
  }
  
  func body(content: Content) -> some View {
    content
      .coordinateSpace(.named(tooltipCoordinateSpace))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(
        GeometryReader { proxy in
          ZStack(alignment: .topLeading) {
            if let triggerFrame = tooltipFrame
            {
              cachedTooltip
                .background {
                  GeometryReader { tooltipProxy in
                    Color.clear
                      .preference(key: TooltipSizeKey.self, value: tooltipProxy.size)
                  }
                  .onPreferenceChange(TooltipSizeKey.self) { tooltipSize in
                    updateTooltipPosition(
                      triggerFrame: triggerFrame,
                      tooltipSize: tooltipSize,
                      containerSize: proxy.size
                    )
                  }
                }
                .opacity(tooltipPos != .zero ? 0 : 1)
              if tooltipPos != .zero {
                cachedTooltip
                  .position(tooltipPos)
                  .transition(
                    .scale(0.1, anchor: transitionAnchor)
                    .combined(with: .opacity)
                    .animation(
                      .interpolatingSpring(
                        stiffness: 220,
                        damping: 22
                      )
                    )
                  )
#if os(iOS)
                  .background(
                    DismissalProbeWrapper(onDismiss: dismissTooltip)
                  )
#endif
              }
            }
          }
        }
      )
      .onChange(of: item, { _, newValue in
        handleItemChange(newValue)
      })
      .onChange(of: model.tooltipInfo.triggerGlobalFrame) { _, newFrame in
        handleTriggerChanged(frame: newFrame)
      }
      .environment(model)
  }
  
  // MARK: - Private Helper Methods
  private func updateTooltipPosition(
    triggerFrame: CGRect,
    tooltipSize: CGSize,
    containerSize: CGSize
  ) {
    let containerRect = CGRect(origin: .zero, size: containerSize)
    let geometry = TooltipGeometryCalculator.compute(
      trigger: triggerFrame,
      tooltipSize: tooltipSize,
      container: containerRect
    )
    tooltipPos = geometry.position
    transitionAnchor = geometry.anchor
  }
  
  private func dismissTooltip() {
    model.dismiss()
  }
  
  private func handleItemChange(_ newValue: Item?) {
    guard let item = newValue else {
      model.dismiss()
      cachedTooltip = nil
      return
    }
    model.set(dismissCallback: { self.item = nil })
    cachedTooltip = tooltipBody(item)
  }
  
  private func reset() {
    transitionAnchor = .center
    tooltipPos = .zero
    cachedTooltip = nil
    tooltipFrame = .zero
  }
  
  private func handleTriggerChanged(frame: CGRect?) {
    guard let frame = frame else {
      reset()
      return
    }
    tooltipFrame = frame
  }
}
