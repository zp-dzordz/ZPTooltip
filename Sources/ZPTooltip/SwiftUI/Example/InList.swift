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

#if os(iOS)

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
        ForEach(viewModel.items) { item in
          HStack {
            Text("Item \(item.count)")
              .fixedSize()
              .foregroundColor(.black)
              .frame(maxWidth: .infinity)
              .padding(10)
            TooltipTrigger(
              config: .init(
                id: item.id,
                selected: viewModel.selectedId,
                didSelect: { [weak viewModel] itemId in
                  viewModel?.openTooltip(entryID: itemId)
                }
              ),
              label: {
                Image(systemName: "ellipsis")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(maxWidth: 16)
                  .padding(16)
              }
            )
          }
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
#endif
