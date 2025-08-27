import SwiftUI

public enum TooltipTriggerStyle {
  case threeDots
}

public struct TriggerConfig<ID:Hashable>: DynamicProperty {
  let style: TooltipTriggerStyle
  var id: ID
  var selected: ID?
  var didSelect: (ID) -> Void

  public init(
    style: TooltipTriggerStyle = .threeDots,
    id: ID,
    selected: ID? = nil,
    didSelect: @escaping (ID) -> Void
  ) {
    self.style = style
    self.id = id
    self.didSelect = didSelect
    self.selected = selected
  }
}

extension View {
  @ViewBuilder public func tooltipTrigger<ID: Hashable>(
    config: TriggerConfig<ID>
  ) -> some View {
    switch config.style {
    case .threeDots:
      HStack(spacing: .zero) {
        self
        Image(systemName: "ellipsis")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(maxWidth: 16)
          .padding(16)
          .modifier(TooltipTriggerModifier(config: config))
      }
    }
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
                    triggerFrame: proxy.frame(in: .named("root")),
                    for: id
                  )
                  config.didSelect(config.id)
                }
                .onDisappear {
                  state.dismiss(id: id)
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
