import SwiftUI

/// A control that triggers a tooltip.
///
/// You create a tooltip trigger by providing a trigger configuration and a label.
///
/// The label of a tooltip trigger can be any kind of view:
///
///     TooltipTrigger(configuration: configuration) {
///       Text("...")
///     }
///

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
