import SwiftUI
import Observation

struct Item: Identifiable {
  var count: Int
  let id: Int
  
  init(count: Int) {
    self.count = count
    self.id = count
  }
}

@Observable
@MainActor
class InListViewModel {
  enum Destination: Equatable {
    case tooltip(ListModel)
  }
  
  var items: [Item] = (1...100).map { Item(count: $0) }
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

extension InListViewModel {
  func openTooltip(entryID: Int) {
    self.destination = .tooltip(
      .mocked
    )
  }
}

struct InList: View {
  @Bindable var viewModel: InListViewModel
  
  var body: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        ForEach(viewModel.items) {
          Text("Item \($0.count)")
            .fixedSize()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(10)
            .tooltipTrigger(
              config: .init(
                id: $0.id,
                selected: viewModel.selectedId) { [weak viewModel] id in
                  viewModel?.openTooltip(entryID: id)
                }
            )
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .tooltip(item: $viewModel.destination) { destination in
      switch destination {
      case let .tooltip(listModel):
        ListTooltip(model: listModel)
      }
    }
  }
}

struct InlistPreviews: PreviewProvider {
  static var previews: some View {
    InList(viewModel: .init())
  }
}

