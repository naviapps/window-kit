import CoreGraphics

/// Calculates window frames when moving between screen visible areas.
public enum WindowScreenMovement {
  /// Centers a window in a target visible frame while preserving as much size as fits.
  ///
  /// Input rectangles are standardized before calculation. The returned frame is clamped to the
  /// target visible frame when the source window is larger than the target.
  ///
  /// - Parameters:
  ///   - windowFrame: Current window frame.
  ///   - visibleFrame: Target visible frame.
  /// - Returns: A centered frame inside the target visible frame.
  public static func centerPreservingSize(windowFrame: CGRect, in visibleFrame: CGRect)
    -> CGRect
  {
    let window = normalized(windowFrame)
    let target = normalized(visibleFrame)
    let width = clamped(window.width, lowerBound: 0, upperBound: target.width)
    let height = clamped(window.height, lowerBound: 0, upperBound: target.height)
    return CGRect(
      x: target.midX - width / 2,
      y: target.midY - height / 2,
      width: width,
      height: height
    )
  }

  /// Moves a window between visible frames while preserving relative position.
  ///
  /// Input rectangles are standardized before calculation. The returned frame is clamped to the
  /// target visible frame when the source window is larger than the target.
  ///
  /// - Parameters:
  ///   - windowFrame: Current window frame.
  ///   - sourceVisibleFrame: Visible frame that currently contains the window.
  ///   - targetVisibleFrame: Visible frame to move the window into.
  /// - Returns: A frame inside the target visible frame.
  public static func preservingRelativePosition(
    windowFrame: CGRect,
    from sourceVisibleFrame: CGRect,
    to targetVisibleFrame: CGRect
  ) -> CGRect {
    let window = normalized(windowFrame)
    let source = normalized(sourceVisibleFrame)
    let target = normalized(targetVisibleFrame)
    let width = clamped(window.width, lowerBound: 0, upperBound: target.width)
    let height = clamped(window.height, lowerBound: 0, upperBound: target.height)

    let sourceAvailableWidth = max(1, source.width - window.width)
    let sourceAvailableHeight = max(1, source.height - window.height)

    let xProgress = clamped((window.minX - source.minX) / sourceAvailableWidth)
    let yProgress = clamped((window.minY - source.minY) / sourceAvailableHeight)

    let targetAvailableWidth = max(0, target.width - width)
    let targetAvailableHeight = max(0, target.height - height)

    return CGRect(
      x: target.minX + (xProgress * targetAvailableWidth),
      y: target.minY + (yProgress * targetAvailableHeight),
      width: width,
      height: height
    )
  }

  private static func normalized(_ rect: CGRect) -> CGRect {
    if rect.origin.x.isFinite, rect.origin.y.isFinite, rect.width.isFinite, rect.height.isFinite {
      return rect.standardized
    }

    let width = finiteMagnitude(rect.width)
    let height = finiteMagnitude(rect.height)
    return CGRect(
      x: rect.width < 0 ? rect.origin.x + rect.width : rect.origin.x,
      y: rect.height < 0 ? rect.origin.y + rect.height : rect.origin.y,
      width: width,
      height: height
    )
  }

  private static func finiteMagnitude(_ value: CGFloat) -> CGFloat {
    guard value.isFinite else {
      return value > 0 ? .greatestFiniteMagnitude : 0
    }
    return abs(value)
  }

  private static func clamped(
    _ value: CGFloat,
    lowerBound: CGFloat = 0,
    upperBound: CGFloat = 1
  ) -> CGFloat {
    guard value.isFinite else {
      return value > upperBound ? upperBound : lowerBound
    }
    return Swift.min(Swift.max(value, lowerBound), upperBound)
  }
}
