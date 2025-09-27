import SwiftUI

struct CurrentTooltipInfo {
  var current: Namespace.ID?
  var triggerGlobalFrame: CGRect?
}

@MainActor
@Observable
public final class TooltipState {
  enum State: Hashable {
    case idle
    case triggered(Namespace.ID)
    case triggerFrameReady(Namespace.ID, CGRect)
    case dismiss
  }
  var tooltipInfo = CurrentTooltipInfo()
  var dismissCallback: (() -> Void)?
  var state: State {
    _state
  }
  
  private var _state: State = .idle
  
  public init(dismissCallback: (() -> Void)? = nil) {
    self.dismissCallback = dismissCallback
  }
  
  private func update(with newState: State) {
    guard _state != newState else { return }
    
    switch (_state, newState)  {
    case (.idle, let .triggered(ns1)):
      guard tooltipInfo.triggerGlobalFrame == nil else {
        tooltipInfo.triggerGlobalFrame = nil
        return
      }
      guard tooltipInfo.current == nil else {
        tooltipInfo = .init()
        return
      }
      tooltipInfo.current = ns1
    case (let .triggered(ns1), let .triggerFrameReady(_, frame)):
      tooltipInfo = .init(current: ns1, triggerGlobalFrame: frame)
    case (.triggerFrameReady, .dismiss):
      update(with: .idle) // .triggerFrameReady -> .idle
      return
    case (.triggerFrameReady, .idle):
      tooltipInfo = .init()
    case (.triggerFrameReady, .triggered):
      return
    case (.idle, .dismiss):
      tooltipInfo = .init()
      dismissCallback?()
      return
      
    default:
      fatalError("Non-supported transition \(_state) -> \(newState)")
    }
    _state = newState
  }
  
  func didTapTrigger(id: Namespace.ID) {
    update(with: .triggered(id))
  }
  func dismissIfNeeded() {
    update(with: .dismiss)
  }
  func set(triggerFrame: CGRect, for id: Namespace.ID) {
    update(with: .triggerFrameReady(id, triggerFrame))
  }
  func dismiss() {
    if let callback = dismissCallback {
      callback()
    }
    dismissCallback = nil
    Task { @MainActor [weak self] in
      self?.update(with: .idle)
    }
  }
  func set(dismissCallback: (() -> Void)? = nil) {
    self.dismissCallback = dismissCallback
  }
  
}

