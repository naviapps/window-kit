import CoreGraphics

/// Calculates window frames when moving between screen visible areas.
public enum WindowScreenMovement {
  /// Centers a window in a target visible frame while preserving as much size as fits.
  ///
  /// Input rectangles are made finite and standardized before calculation. The returned frame is
  /// clamped to the target visible frame when the source window is larger than the target.
  ///
  /// - Parameters:
  ///   - windowFrame: Current window frame.
  ///   - visibleFrame: Target visible frame.
  /// - Returns: A centered frame inside the target visible frame.
  public static func centerPreservingSize(windowFrame: CGRect, in visibleFrame: CGRect)
    -> CGRect
  {
    let window = windowFrame.finiteStandardized
    let target = visibleFrame.finiteStandardized
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
  /// Input rectangles are made finite and standardized before calculation. The returned frame is
  /// clamped to the target visible frame when the source window is larger than the target.
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
    let window = windowFrame.finiteStandardized
    let source = sourceVisibleFrame.finiteStandardized
    let target = targetVisibleFrame.finiteStandardized
    let width = clamped(window.width, lowerBound: 0, upperBound: target.width)
    let height = clamped(window.height, lowerBound: 0, upperBound: target.height)

    let xProgress = relativeProgress(
      offset: window.minX - source.minX,
      availableLength: source.width - window.width
    )
    let yProgress = relativeProgress(
      offset: window.minY - source.minY,
      availableLength: source.height - window.height
    )

    let targetAvailableWidth = max(0, target.width - width)
    let targetAvailableHeight = max(0, target.height - height)

    return CGRect(
      x: target.minX + (xProgress * targetAvailableWidth),
      y: target.minY + (yProgress * targetAvailableHeight),
      width: width,
      height: height
    )
  }

  private static func relativeProgress(offset: CGFloat, availableLength: CGFloat) -> CGFloat {
    guard availableLength > 0 else { return 0.5 }
    return clamped(offset / availableLength)
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
