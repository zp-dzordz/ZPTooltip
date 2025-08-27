import PreviewSnapshots
import SwiftUI

struct NineGridLayout: Layout {
  private let padding: CGFloat = 32
  
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    // Default to some size if nothing is proposed
    CGSize(width: proposal.width ?? 300, height: proposal.height ?? 300)
  }
  
  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    guard !subviews.isEmpty else { return }
    
    let buttonSize = 96.0
    
    for (index, subview) in subviews.enumerated() {
      let row = index / 3 // 0, 1, 2
      let col = index % 3 // 0, 1, 2
      
      let x: CGFloat
      switch col {
      case 0: x = bounds.minX + padding + buttonSize / 2
      case 1: x = bounds.midX
      case 2: x = bounds.maxX - padding - buttonSize / 2
      default: x = bounds.midX
      }
      
      let y: CGFloat
      switch row {
      case 0: y = bounds.minY + padding + buttonSize / 2
      case 1: y = bounds.midY
      case 2: y = bounds.maxY - padding - buttonSize / 2
      default: y = bounds.midY
      }
      
      let point = CGPoint(x: x, y: y)
      subview.place(
        at: point,
        anchor: .center,
        proposal: ProposedViewSize(width: buttonSize, height: 48)
      )
    }
  }
}

@Observable
@MainActor
class NineGridViewModel {
  enum Destination: Equatable {
    case tooltip(ListModel)
  }
  
  var items: [Item] = (1...9).map { Item(count: $0) }
  var destination: Destination?
  var selectedId: Int?
  
  init(destination: Destination? = nil, selectedTooltipId: Int? = nil) {
    self.items = items
    self.destination = destination
    self.selectedId = selectedTooltipId
  }
  
  func gotoDocument(id: Int) {
    print("gotoDocument with ID: \(id)")
  }
}

extension NineGridViewModel {
  func openTooltip(entryID: Int) {
    self.destination = .tooltip(
      .mocked
    )
  }
}

struct NineGrid: View {
  @Bindable var viewModel: NineGridViewModel
  
  var body: some View {
    NineGridLayout {
      ForEach(viewModel.items) {
        Rectangle()
          .fill(Color.blue)
          .overlay(Text("\($0.id)").foregroundColor(.white))
          .tooltipTrigger(
            config: .init(
              id: $0.id,
              selected: viewModel.selectedId) { [weak viewModel] id in
                viewModel?.openTooltip(entryID: id)
              }
          )
      }
    }
    .tooltip(item: $viewModel.destination) { destination in
      switch destination {
      case let .tooltip(listModel):
        ListTooltip(model: listModel)
      }
    }
  }
}

struct NineGrid_Previews: PreviewProvider {
  
  static var previews: some View {
    snapshots.previews.previewLayout(.device)
  }
  
  @MainActor
  enum TooltipTestLocation: Int, CaseIterable {
    case topLeading = 1
    case topCenter
    case topTrailing
    case centerLeading
    case center
    case centerTrailing
    case bottomLeading
    case bottomCenter
    case bottomTrailing
    
    var label: String {
      switch self {
      case .topLeading: return "topLeading"
      case .topCenter: return "topCenter"
      case .topTrailing: return "topTrailing"
      case .centerLeading: return "centerLeading"
      case .center: return "center"
      case .centerTrailing: return "centerTrailing"
      case .bottomLeading: return "bottomLeading"
      case .bottomCenter: return "bottomCenter"
      case .bottomTrailing: return "bottomTrailing"
      }
    }
  }
 
  static var snapshots: PreviewSnapshots<NineGridViewModel> {
    let configurations = TooltipTestLocation.allCases.map {
      PreviewSnapshots<NineGridViewModel>.Configuration.init(
        name: $0.label, state: .init(selectedTooltipId: $0.rawValue))
    }
    return PreviewSnapshots(configurations: configurations) { state in
      NineGrid(viewModel: state)
    }
  }
}

