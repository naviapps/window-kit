import CoreGraphics

/// Deterministically calculates frames for ``WindowPlacement`` values.
public enum WindowPlacementCalculator {
  /// Calculates a frame for a placement inside the given screen area.
  ///
  /// The screen area is standardized before placement. Non-finite screen area components are
  /// replaced with finite zero-origin bounds, and the inset is clamped so it cannot invert the
  /// returned frame.
  ///
  /// - Parameters:
  ///   - placement: Placement value to resolve.
  ///   - screenArea: Screen area used as the placement bounds.
  ///   - inset: Uniform inset applied before resolving the placement.
  /// - Returns: A deterministic frame for the requested placement.
  public static func frame(
    for placement: WindowPlacement,
    in screenArea: CGRect,
    inset: CGFloat = 0
  ) -> CGRect {
    let area = insetArea(screenArea, by: inset)
    return resolveFrame(placement, in: area)
  }

  private static func insetArea(_ area: CGRect, by inset: CGFloat) -> CGRect {
    let standardizedArea = area.finiteStandardized
    let maximumInset = max(0, min(standardizedArea.width, standardizedArea.height) / 2)
    let clampedInset = clamped(inset, lowerBound: 0, upperBound: maximumInset)
    return standardizedArea.insetBy(dx: clampedInset, dy: clampedInset)
  }

  private static func resolveFrame(_ placement: WindowPlacement, in area: CGRect) -> CGRect {
    switch placement {
    case .fill:
      return area
    case let .grid(columns, rows, column, row, columnSpan, rowSpan):
      return grid(
        area,
        columns: columns,
        rows: rows,
        column: column,
        row: row,
        columnSpan: columnSpan,
        rowSpan: rowSpan
      )
    case let .centered(widthRatio, heightRatio):
      return centered(area, widthRatio: widthRatio, heightRatio: heightRatio)
    }
  }

  private static func grid(
    _ area: CGRect,
    columns: Int,
    rows: Int,
    column: Int,
    row: Int,
    columnSpan: Int,
    rowSpan: Int
  ) -> CGRect {
    let safeColumns = max(1, columns)
    let safeRows = max(1, rows)
    let clampedColumn = min(max(0, column), safeColumns - 1)
    let clampedRow = min(max(0, row), safeRows - 1)
    let spanColumns = min(max(1, columnSpan), safeColumns - clampedColumn)
    let spanRows = min(max(1, rowSpan), safeRows - clampedRow)
    let cellWidth = area.width / CGFloat(safeColumns)
    let cellHeight = area.height / CGFloat(safeRows)
    return CGRect(
      x: area.minX + (CGFloat(clampedColumn) * cellWidth),
      y: area.minY + (CGFloat(clampedRow) * cellHeight),
      width: cellWidth * CGFloat(spanColumns),
      height: cellHeight * CGFloat(spanRows)
    )
  }

  private static func centered(_ area: CGRect, widthRatio: CGFloat, heightRatio: CGFloat) -> CGRect
  {
    let normalizedWidthRatio = clamped(widthRatio, lowerBound: 0, upperBound: 1)
    let normalizedHeightRatio = clamped(heightRatio, lowerBound: 0, upperBound: 1)
    let width = area.width * normalizedWidthRatio
    let height = area.height * normalizedHeightRatio
    return CGRect(
      x: area.midX - (width / 2),
      y: area.midY - (height / 2),
      width: width,
      height: height
    )
  }

  private static func clamped(_ value: CGFloat, lowerBound: CGFloat, upperBound: CGFloat) -> CGFloat
  {
    guard value.isFinite else {
      return value > upperBound ? upperBound : lowerBound
    }
    return min(max(value, lowerBound), upperBound)
  }
}
