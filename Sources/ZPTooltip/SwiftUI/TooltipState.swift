import SwiftUI

struct CurrentTooltipInfo {
  var current: Namespace.ID?
  var triggerGlobalFrame: CGRect?
}

@MainActor
@Observable
public final class TooltipState {
  private enum _State: Hashable {
    case idle
    case triggered(Namespace.ID)
    case triggerFrameReady(Namespace.ID, CGRect)
    case dismiss(Namespace.ID)
  }
  var tooltipInfo = CurrentTooltipInfo()
  var dismissCallback: (() -> Void)?
  
  private var state: _State = .idle
  
  public init(dismissCallback: (() -> Void)? = nil) {
    self.dismissCallback = dismissCallback
  }
  
  private func update(with newState: _State) {
    guard state != newState else { return }
    
    switch (state, newState)  {
    case (.idle, let .triggered(ns1)):
      guard tooltipInfo.triggerGlobalFrame == nil else {
        return
      }
      
      guard tooltipInfo.current == nil else {
        tooltipInfo = .init()
        return
      }
      tooltipInfo.current = ns1
    case (let .triggered(ns1), let .triggerFrameReady(_, frame)):
      tooltipInfo = .init(current: ns1, triggerGlobalFrame: frame)
    case (.triggerFrameReady, .triggered):
      return
    case (.triggerFrameReady, .idle):
      tooltipInfo.current = nil
    case (.triggerFrameReady, .dismiss):
      update(with: .idle)
      return
    case (.idle, .dismiss):
      tooltipInfo = .init()
      dismissCallback?()
      return
    
    default:
      fatalError("Non-supported transition \(state) -> \(newState)")
    }
    state = newState
  }
  
  func didTapTrigger(id: Namespace.ID) {
    update(with: .triggered(id))
  }
  func set(triggerFrame: CGRect, for id: Namespace.ID) {
    update(with: .triggerFrameReady(id, triggerFrame))
  }
  func dismiss(id: Namespace.ID) {
    update(with: .dismiss(id))
  }
  func dismiss() {
    dismissCallback = nil
    update(with: .idle)
  }
  func set(dismissCallback: (() -> Void)? = nil) {
    self.dismissCallback = dismissCallback
  }
  
}

