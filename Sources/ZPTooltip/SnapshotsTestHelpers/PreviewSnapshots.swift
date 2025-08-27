// This file is almost entirely based on PreviewSnapshots.swift file of
// swiftui-preview-snapshots package
// of
// PreviewSnapshots
// Copyright 2022 DoorDash, Inc.

import SwiftUI

public struct PreviewSnapshots<State> {
  /// Array of configurations to apply to the view for preview and snapshot testing.
  public let configurations: [Configuration]
  
  /// Function to configure the `View` being tested given a configuration state.
  public let configure: (State) -> AnyView
  
  /// Create a `PreviewSnapshots` collection.
  ///
  /// - Parameters:
  ///   - configurations: The list of configurations to construct for previews and snapshot testing.
  ///   - configure: A closure that constructs the `View` to be previewed/tested given a configuration state.
  public init<V: View>(
      configurations: [Configuration],
      configure: @escaping (State) -> V
  ) {
    self.configurations = configurations
    self.configure = { AnyView(configure($0)) }
  }
  
  /// The previews to be displayed by the `PreviewProvider`.
  public var previews: some View {
      ForEach(configurations, id: \.name) { configuration in
          configure(configuration.state)
              .previewDisplayName("\(configuration.name)")
      }
  }
}

// MARK: - PreviewSnapshots.Configuration
public extension PreviewSnapshots {
  /// A single configuration used for preview snapshotting.
  struct Configuration {
    /// The name of the configuration. Should be unique across an instance of `PreviewSnapshots`.
    public let name: String
    /// The state to render.
    public let state: State
    
    /// Create a `PreviewSnapshots.Configuration`.
    ///
    /// - Parameters:
    ///   - name: The name of the configuration.
    ///   - state: The state the configuration should render.
    public init(name: String, state: State) {
        self.name = name
        self.state = state
    }
  }
}
