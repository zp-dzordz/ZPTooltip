import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct TooltipTrigger<Label, ID> : View where Label : View, ID: Hashable {
  let label: Label
  var config: TriggerConfig<ID>
  @preconcurrency public init(
    config: TriggerConfig<ID>,
    @ViewBuilder label: () -> Label
  ) {
    self.config = config
    self.label = label()
  }
  public var body: some View {
    label
      .modifier(TooltipTriggerModifier(config: config))
    
  }
}

public struct TriggerConfig<ID:Hashable> {
  var id: ID
  var selected: ID?
  var didSelect: (ID) -> Void
  
  public init(
    id: ID,
    selected: ID? = nil,
    didSelect: @escaping (ID) -> Void
  ) {
    self.id = id
    self.didSelect = didSelect
    self.selected = selected
  }
}

struct TooltipTriggerModifier<ID: Hashable>: ViewModifier {
  private let config: TriggerConfig<ID>
  
  // Uniquely identifies trigger using @Namespace
  @Namespace private var id
  @Environment(TooltipState.self) private var state
  let selected: ID?
  
  init(config: TriggerConfig<ID>) {
    self.config = config
    self.selected = config.id
  }
  
  func body(content: Content) -> some View {
    content
      .contentShape(.rect)
      .onTapGesture {
        guard state.tooltipInfo.current == nil else {
          state.dismissIfNeeded()
          return
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()   // haptic feedback
        state.didTapTrigger(id: id)
      }
      .overlay {
        GeometryReader { proxy in
          ZStack {
            if state.tooltipInfo.current == id {
              Color.clear
                .onAppear {
                  state.set(
                    triggerFrame: proxy.frame(in: .named(tooltipCoordinateSpace)),
                    for: id
                  )
                  config.didSelect(config.id)
                }
            }
          }
        }
      }
      .onAppear {
        if(config.selected == selected) {
          state.didTapTrigger(id: id)
        }
      }
  }
}
#endif
