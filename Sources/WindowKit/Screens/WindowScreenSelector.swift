import CoreGraphics

/// Selects and orders screen values for placement and screen movement.
public enum WindowScreenSelector {
  /// Returns screens in deterministic left-to-right, then bottom-to-top order.
  public static func orderedScreens(from screens: [WindowScreen]) -> [WindowScreen] {
    screens.sorted { lhs, rhs in
      let lhsFrame = lhs.frame.standardized
      let rhsFrame = rhs.frame.standardized
      if lhsFrame.minX != rhsFrame.minX { return lhsFrame.minX < rhsFrame.minX }
      if lhsFrame.minY != rhsFrame.minY { return lhsFrame.minY < rhsFrame.minY }
      if lhsFrame.width != rhsFrame.width { return lhsFrame.width < rhsFrame.width }
      if lhsFrame.height != rhsFrame.height { return lhsFrame.height < rhsFrame.height }
      switch (lhs.displayIdentifier, rhs.displayIdentifier) {
      case let (lhsDisplayIdentifier?, rhsDisplayIdentifier?):
        return lhsDisplayIdentifier < rhsDisplayIdentifier
      case (.some, .none):
        return true
      case (.none, .some), (.none, .none):
        return false
      }
    }
  }

  /// Selects a screen target from an ordered screen list.
  public static func screen(
    for target: WindowScreenTarget,
    windowFrame: CGRect,
    in orderedScreens: [WindowScreen],
    fallsBackToFirstScreen: Bool = true
  ) -> WindowScreen? {
    guard !orderedScreens.isEmpty else { return nil }

    switch target {
    case .main:
      return orderedScreens.first { $0.isMain }
        ?? fallbackScreen(from: orderedScreens, fallsBackToFirstScreen: fallsBackToFirstScreen)
    case .containingWindow:
      return orderedScreens.first {
        $0.frame.standardized.contains(windowFrame.standardized.center)
      }
        ?? fallbackScreen(from: orderedScreens, fallsBackToFirstScreen: fallsBackToFirstScreen)
    case let .point(point):
      return orderedScreens.first { $0.frame.standardized.contains(point) }
        ?? fallbackScreen(from: orderedScreens, fallsBackToFirstScreen: fallsBackToFirstScreen)
    case let .displayIdentifier(displayIdentifier):
      return orderedScreens.first { $0.displayIdentifier == displayIdentifier }
        ?? fallbackScreen(from: orderedScreens, fallsBackToFirstScreen: fallsBackToFirstScreen)
    case let .orderedIndex(index):
      guard orderedScreens.indices.contains(index) else {
        return fallbackScreen(from: orderedScreens, fallsBackToFirstScreen: fallsBackToFirstScreen)
      }
      return orderedScreens[index]
    }
  }

  /// Returns the index of the screen containing a point.
  public static func index(containing point: CGPoint, in screens: [WindowScreen]) -> Int? {
    screens.firstIndex { $0.frame.standardized.contains(point) }
  }

  /// Returns the adjacent ordered screen index for a cycling direction.
  ///
  /// The starting index is normalized into the available range. Empty screen lists return `nil`.
  public static func adjacentIndex(
    from index: Int,
    direction: WindowScreenCycleDirection,
    screenCount: Int
  ) -> Int? {
    guard screenCount > 0 else { return nil }
    let normalizedIndex = ((index % screenCount) + screenCount) % screenCount
    switch direction {
    case .next:
      return (normalizedIndex + 1) % screenCount
    case .previous:
      return (normalizedIndex - 1 + screenCount) % screenCount
    }
  }

  private static func fallbackScreen(
    from orderedScreens: [WindowScreen],
    fallsBackToFirstScreen: Bool
  ) -> WindowScreen? {
    fallsBackToFirstScreen ? orderedScreens.first : nil
  }
}

private extension CGRect {
  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}
