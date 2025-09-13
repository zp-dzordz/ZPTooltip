import Observation
import SwiftUI

struct TooltipHelper<Item: Equatable, TooltipContent: View>: ViewModifier {
  @State var model: TooltipState = .init()
  @State private var transitionAnchor: UnitPoint = .center
  @State private var tooltipPos: CGPoint = .zero
  @State private var tooltipVisible: Bool = false
  @State private var cachedTooltip: TooltipContent? = nil
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
      .coordinateSpace(.named("root"))
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(
        GeometryReader { proxy in
          ZStack(alignment: .topLeading) {
            if let cachedTooltip,
               let triggerFrame = model.tooltipInfo.triggerGlobalFrame
            {
              cachedTooltip
                .background {
                  GeometryReader { tooltipProxy in
                    Color.clear
                      .preference(key: TooltipSizeKey.self, value: tooltipProxy.size)
                  }
                  .onPreferenceChange(TooltipSizeKey.self) { tooltipSize in
                    
                        let containerRect = CGRect(origin: .zero, size: proxy.size)
                        let geom = TooltipGeometryCalculator.compute(
                          trigger: triggerFrame ,
                          tooltipSize: tooltipSize,
                          container: containerRect
                        )
                        tooltipPos = geom.position
                        transitionAnchor = geom.anchor
                  }
                }
                .position(tooltipPos)
                .scaleEffect(tooltipVisible ? 1 : 0.1, anchor: transitionAnchor)
                .opacity(tooltipVisible ? 1 : 0)
                .animation(
                  .interpolatingSpring(stiffness: 220, damping: 22),
                  value: tooltipVisible
                )
              #if(iOS)
                .background(
                  DismissalProbeWrapper(onDismiss: {
                    withAnimation { [weak model] in
                      model?.dismiss()
                      tooltipVisible = false
                    }
                  })
                )
              #endif
            }
          }
        }
      )
      .onChange(of: item, { _, newValue in
        withAnimation {
          guard let item = newValue else {
            model.dismiss()
            tooltipVisible = false
            cachedTooltip = nil
            return
          }          
          model.set(dismissCallback: { self.item = nil })
          cachedTooltip = tooltipBody(item)
          tooltipVisible = true
        }
      })
      .environment(model)
  }
}

extension GeometryProxy: @unchecked @retroactive Sendable {}
