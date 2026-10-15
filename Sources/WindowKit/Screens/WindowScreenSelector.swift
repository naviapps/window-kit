import CoreGraphics

/// Selects and orders screen values for placement and screen movement.
public enum WindowScreenSelector {
  /// Returns screens in deterministic increasing-x, then increasing-y order.
  public static func orderedScreens(from screens: [WindowScreen]) -> [WindowScreen] {
    screens.enumerated().sorted { lhsEntry, rhsEntry in
      let lhs = lhsEntry.element
      let rhs = rhsEntry.element
      let lhsFrame = lhs.frame
      let rhsFrame = rhs.frame
      if lhsFrame.minX != rhsFrame.minX { return lhsFrame.minX < rhsFrame.minX }
      if lhsFrame.minY != rhsFrame.minY { return lhsFrame.minY < rhsFrame.minY }
      if lhsFrame.width != rhsFrame.width { return lhsFrame.width < rhsFrame.width }
      if lhsFrame.height != rhsFrame.height { return lhsFrame.height < rhsFrame.height }
      switch (lhs.displayIdentifier, rhs.displayIdentifier) {
      case let (lhsDisplayIdentifier?, rhsDisplayIdentifier?):
        if lhsDisplayIdentifier != rhsDisplayIdentifier {
          return lhsDisplayIdentifier < rhsDisplayIdentifier
        }
        return lhsEntry.offset < rhsEntry.offset
      case (.some, .none):
        return true
      case (.none, .some):
        return false
      case (.none, .none):
        return lhsEntry.offset < rhsEntry.offset
      }
    }.map(\.element)
  }

  /// Selects a screen target from a screen list.
  ///
  /// Screens are ordered deterministically before selection. Unmatched targets fall back to the
  /// first ordered screen by default. Pass ``WindowScreenFallback/none``
  /// when a missing screen should return `nil`.
  public static func screen(
    for target: WindowScreenTarget,
    windowFrame: CGRect,
    in screens: [WindowScreen],
    fallback: WindowScreenFallback = .firstScreen
  ) -> WindowScreen? {
    let orderedScreens = orderedScreens(from: screens)
    guard !orderedScreens.isEmpty else { return nil }

    switch target {
    case .main:
      return orderedScreens.first { $0.isMain }
        ?? fallbackScreen(from: orderedScreens, fallback: fallback)
    case .containingWindow:
      return orderedScreens.first {
        $0.frame.contains(windowFrame.standardized.center)
      }
        ?? fallbackScreen(from: orderedScreens, fallback: fallback)
    case let .point(point):
      return orderedScreens.first { $0.frame.contains(point) }
        ?? fallbackScreen(from: orderedScreens, fallback: fallback)
    case let .displayIdentifier(displayIdentifier):
      return orderedScreens.first { $0.displayIdentifier == displayIdentifier }
        ?? fallbackScreen(from: orderedScreens, fallback: fallback)
    case let .orderedIndex(index):
      guard orderedScreens.indices.contains(index) else {
        return fallbackScreen(from: orderedScreens, fallback: fallback)
      }
      return orderedScreens[index]
    }
  }

  /// Returns the deterministic ordered index of the screen containing a point.
  public static func index(containing point: CGPoint, in screens: [WindowScreen]) -> Int? {
    orderedScreens(from: screens).firstIndex { $0.frame.contains(point) }
  }

  /// Returns the adjacent ordered screen index for a cycling direction.
  ///
  /// The starting index is normalized into the available range. Empty and negative screen counts
  /// return `nil`.
  public static func adjacentIndex(
    from index: Int,
    direction: WindowScreenCycleDirection,
    screenCount: Int
  ) -> Int? {
    guard screenCount > 0 else { return nil }
    let remainder = index % screenCount
    let normalizedIndex = remainder >= 0 ? remainder : remainder + screenCount
    switch direction {
    case .next:
      return normalizedIndex == screenCount - 1 ? 0 : normalizedIndex + 1
    case .previous:
      return normalizedIndex == 0 ? screenCount - 1 : normalizedIndex - 1
    }
  }

  private static func fallbackScreen(
    from orderedScreens: [WindowScreen],
    fallback: WindowScreenFallback
  ) -> WindowScreen? {
    switch fallback {
    case .firstScreen:
      orderedScreens.first
    case .none:
      nil
    }
  }
}

private extension CGRect {
  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}
