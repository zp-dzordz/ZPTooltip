//
//  ContentView.swift
//  Examples
//
//  Created by Grzegorz Kiel on 27/09/2025.
//

import SwiftUI

enum ExamplesTab {
  case inList
  case nineGrid
}
extension ExamplesTab {
  var label: String {
    switch self {
    case .inList: return "In list"
    case .nineGrid: return "Nine grid"
    }
  }
}

struct ContentView: View {
  var body: some View {
    TabView {
      InList(viewModel: .init())
        .tag(ExamplesTab.inList)
        .tabItem {
          Label(ExamplesTab.inList.label, systemImage: "list.bullet")
        }
      NineGrid(viewModel: .init())
        .tag(ExamplesTab.nineGrid)
        .tabItem {
          Label(ExamplesTab.nineGrid.label, systemImage: "square.grid.3x3.square")
        }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}

