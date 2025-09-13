import SwiftUI

#if(iOS)
struct DismissalProbeWrapper: View {
  @State private var coordinatorRef: DismissalProbe.Coordinator?
  let onDismiss: () -> Void
  
  var body: some View {
    DismissalProbe(coordinatorRef: $coordinatorRef, onDismiss: onDismiss)
      .onDisappear {
        coordinatorRef?.cleanUp()
      }
  }
}

struct DismissalProbe: UIViewRepresentable {
  @Binding var coordinatorRef: Coordinator?
  let onDismiss: () -> Void
  
  func makeCoordinator() -> Coordinator {
    let c = Coordinator(onDismiss: onDismiss)
    // Avoid mutating SwiftUI state during view update.
    DispatchQueue.main.async {
      if self.coordinatorRef == nil {
        self.coordinatorRef = c
      }
    }
    return c
  }

  func makeUIView(context: Context) -> UIView {
    let v = UIView(frame: .zero)
    v.backgroundColor = .clear
    v.isUserInteractionEnabled = false // critical: do not steal touches
    return v
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    // Attach once after we're in the hierarchy
    DispatchQueue.main.async {
      guard
        context.coordinator.attachedScrollView == nil else { return }
      if let scroll = self.findNearestDescendantScrollView(from: uiView) {
        context.coordinator.attach(to: scroll)
      }
      else {
        // No scrollview found -> install tap on our own host view
        context.coordinator.attachToHost(uiView)
      }
    }
  }

  private func findNearestDescendantScrollView(from view: UIView) -> UIScrollView? {
    var ancestor: UIView? = view.superview
    while let current = ancestor {
      if let found = siblingsScrollView(in: current, excluding: view) {
        return found
      }
      ancestor = current.superview
    }
    return nil
  }
  
  private func siblingsScrollView(in root: UIView, excluding excluded: UIView) -> UIScrollView? {
    var queue = root.subviews.filter { $0 != excluded }
    while !queue.isEmpty {
      let node = queue.removeFirst()
      if let scroll = node as? UIScrollView { return scroll }
      queue.append(contentsOf: node.subviews)
    }
    return nil
  }

  final class Coordinator: NSObject, UIGestureRecognizerDelegate {
    let onDismiss: () -> Void

    private(set) weak var attachedScrollView: UIScrollView?
    private var tapRecognizer: UITapGestureRecognizer?
    private var hostTapRecognizer: UITapGestureRecognizer?
    private var panHooked = false
    
    init(onDismiss: @escaping () -> Void) {
      self.onDismiss = onDismiss
    }
    
    func attach(to scroll: UIScrollView) {
      attachedScrollView = scroll
      
      // 1) Observe scrolling without adding our own pan recognizer
      if !panHooked {
        scroll.panGestureRecognizer.addTarget(self, action: #selector(handlePanState(_:)))
        panHooked = true
      }
      
      // 2) Passive tap recognizer that never cancels touches and recognizes simultaneously
      let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
      tap.delegate = self
      scroll.addGestureRecognizer(tap)
      tapRecognizer = tap
    }
    
    func attachToHost(_ host: UIView) {
      // Allow interactions so tap recognizer works
      host.isUserInteractionEnabled = true
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
      tap.delegate = self
      host.addGestureRecognizer(tap)
      hostTapRecognizer = tap
    }
    
    // Fire dismissal when a scroll gesture begins
    @objc private func handlePanState(_ gr: UIPanGestureRecognizer) {
      if gr.state == .began { onDismiss() }
    }
    
    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
      if gr.state == .ended { onDismiss() }
    }

    func cleanUp() {
      if let scroll = attachedScrollView {
        if panHooked {
          scroll.panGestureRecognizer.removeTarget(self, action: #selector(handlePanState))
          panHooked = false
        }
        if let tapRecognizer {
          scroll.removeGestureRecognizer(tapRecognizer)
        }
      }
      if let hostTapRecognizer, let host = hostTapRecognizer.view {
        host.removeGestureRecognizer(hostTapRecognizer)
      }
      tapRecognizer = nil
      hostTapRecognizer = nil
      attachedScrollView = nil
    }
    
    // Allow gestures to recognize simultaneously with others
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }
  }
}
#endif
