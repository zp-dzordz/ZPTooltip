import SwiftUI

#if(iOS)

fileprivate enum Config {
  static let tooltipHorizontalPadding: CGFloat = 16
  static let tooltipVerticalPadding: CGFloat = 8
  static let labelIconPadding: CGFloat = 8
  static let iconSize = CGSize(width: 16, height: 16)
  static let scaledTooltipSize: CGFloat = 0.8
  static let cornerRadius: CGFloat = 16
  static let listOpacity: CGFloat = 0.2
  static let highlightedOpacity: CGFloat = 0.3
  static let listShadowRadius: CGFloat = 2
}

/// Preference key for row frames
struct RowFrameKey: PreferenceKey {
  static let defaultValue: [UUID: CGRect] = [:]
  static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}

/// Preference key for list frame
struct ListFrameKey: PreferenceKey {
  static let defaultValue: CGRect = .zero
  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

/// Preference key for tooltip label width - used to measure widest option string
struct TooltipLabelWidthKey: PreferenceKey {
  static let defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = max(value, nextValue())
  }
}

public enum ListOptionRole {
  case plain
  case prominent
  case destructive
}

public struct ListOption: Identifiable {
  public let id = UUID()
  var label: String
  var icon: Image
  let style: ListOptionRole
  var action: () -> Void
  
  public init(label: String, icon: Image, style: ListOptionRole = .plain, action: @escaping () -> Void) {
    self.label = label
    self.icon = icon
    self.action = action
    self.style = style
  }
}

public final class ListModel: Equatable, Identifiable {
  let options: [ListOption]
  public init(options: [ListOption] = []) {
    self.options = options
  }
  
  public static func ==(lhs: ListModel, rhs: ListModel) -> Bool {
    return lhs === rhs
  }
}

public struct ListTooltip: View {
  let model: ListModel
  
  @State private var maxLabelWidth: CGFloat = .zero
  @State private var highlightedId: UUID?
  @State private var rowFrames: [UUID: CGRect] = [:]
  @State private var listFrame: CGRect = .zero
  @State private var isOutside: Bool = false
  
  // Haptic feedback for changing selecte
  private let selectionFeedback = UISelectionFeedbackGenerator()
  
  public init(model: ListModel) {
    self.model = model
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: .zero) {
      ForEach(model.options, id: \.id) { option in
        if model.options.first?.id != option.id {
          Divider()
        }
        HStack {
          Text(option.label)
            .font(.callout)
            .fixedSize()
            .background(
              GeometryReader { proxy in
                Color.clear
                  .preference(key: TooltipLabelWidthKey.self, value: proxy.size.width)
              }
            )
            .frame(width: maxLabelWidth + Config.labelIconPadding, alignment: .leading)
          option.icon
            .resizable()
            .frame(width: Config.iconSize.width, height: Config.iconSize.height)
        }
        .padding(.horizontal, Config.tooltipHorizontalPadding)
        .padding(.vertical, Config.tooltipVerticalPadding)
        .background(
          highlightForRow(optionId: option.id, rowId: highlightedId)
        )
        .background(
          GeometryReader { proxy in
            Color.clear.preference(
              key: RowFrameKey.self,
              value: [option.id: proxy.frame(in: .global)]
            )
          }
        )
      }
    }
    .onPreferenceChange(TooltipLabelWidthKey.self) { value in
      maxLabelWidth = value
    }
    .onPreferenceChange(RowFrameKey.self) { frames in
      rowFrames = frames
    }
    .onPreferenceChange(ListFrameKey.self) { frame in
      listFrame = frame
    }
    .frame(width: maxLabelWidth + Config.labelIconPadding + Config.iconSize.width + 2 * Config.tooltipHorizontalPadding)
    .clipped()
    .background(
      GeometryReader { proxy in
        Color.clear.preference(
          key: ListFrameKey.self,
          value: proxy.frame(in: .global)
        )
      }
    )
    .background(
      .regularMaterial
        .shadow(
          .drop(color: Color.primary.opacity(Config.listOpacity),radius: 2)
        ),
      in: .rect(cornerRadius: Config.cornerRadius)
    )
    .scaleEffect(isOutside ? Config.scaledTooltipSize : 1.0)
    .animation(.spring(), value: isOutside)
    .gesture(dragGesture)
  }
  
  private var dragGesture: some Gesture {
    LongPressGesture(minimumDuration: 0.1)
      .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
      .onChanged { value in
        switch value {
        case .second(true, let drag):
          guard let location = drag?.location else { return }
          updateHighlight(at: location)
        default:
          break
        }
      }
      .onEnded { value in
        if case .second(true, let drag?) = value {
          let location = drag.location   // <-- no `if let`, just assign
          if let id = rowFrames.first(where: { $0.value.contains(location) })?.key,
             let option = model.options.first(where: { $0.id == id }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              option.action()
            }
          }
        }
        highlightedId = nil
        isOutside = false
      }
  }
  
  private func updateHighlight(at location: CGPoint) {
    if let newId = rowFrames.first(where: { $0.value.contains(location) })?.key {
      if highlightedId != newId {
        highlightedId = newId
        selectionFeedback.selectionChanged()
      }
      isOutside = false
    } else {
      highlightedId = nil
      isOutside = !listFrame.contains(location)
    }
  }
  
  @ViewBuilder func highlightForRow(optionId: UUID, rowId: UUID?) -> some View {
    
    Group {
      if highlightedId == optionId {
        if optionId == model.options.first?.id {
          Rectangle()
            .fill(Color.orange.opacity(Config.highlightedOpacity))
            .clipShape(RectCornerShape(corners: [.topLeft, .topRight], radius: Config.cornerRadius))
          
        }
        else if optionId == model.options.last?.id {
          Rectangle()
            .fill(Color.orange.opacity(Config.highlightedOpacity))
            .clipShape(RectCornerShape(corners: [.bottomLeft, .bottomRight], radius: Config.cornerRadius))
        }
        else {
          Rectangle().fill(Color.orange.opacity(Config.highlightedOpacity))
        }
      }
    }
  }
}

struct RectCornerShape: Shape {
  var corners: UIRectCorner
  var radius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

#Preview {
  ListTooltip(model: .mocked)
}

extension Color {
  static var random: Color {
    return .init(hue: CGFloat.random(in: 0...1), saturation: CGFloat.random(in: 0...1), brightness: CGFloat.random(in: 0...1))
  }
}

#endif

