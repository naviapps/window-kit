import CoreGraphics

/// Reusable placement description for calculating a target window frame.
public enum WindowPlacement: Equatable, Hashable, Sendable, Codable {
  /// Fill the selected screen area.
  case fill
  /// Left half of the selected screen area.
  case leftHalf
  /// Right half of the selected screen area.
  case rightHalf
  /// Top half of the selected screen area.
  case topHalf
  /// Bottom half of the selected screen area.
  case bottomHalf
  /// Top-left quarter of the selected screen area.
  case topLeftQuarter
  /// Top-right quarter of the selected screen area.
  case topRightQuarter
  /// Bottom-left quarter of the selected screen area.
  case bottomLeftQuarter
  /// Bottom-right quarter of the selected screen area.
  case bottomRightQuarter
  /// Left third of the selected screen area.
  case leftThird
  /// Center third of the selected screen area.
  case centerThird
  /// Right third of the selected screen area.
  case rightThird
  /// Top third of the selected screen area.
  case topThird
  /// Middle third of the selected screen area.
  case middleThird
  /// Bottom third of the selected screen area.
  case bottomThird
  /// Left two-thirds of the selected screen area.
  case leftTwoThirds
  /// Right two-thirds of the selected screen area.
  case rightTwoThirds
  /// Top two-thirds of the selected screen area.
  case topTwoThirds
  /// Bottom two-thirds of the selected screen area.
  case bottomTwoThirds
  /// Rectangular region in a grid.
  ///
  /// Columns are zero-based from the left. Rows are zero-based from the bottom in the same
  /// coordinate space as the selected screen area. ``WindowPlacementCalculator`` clamps invalid
  /// column/row counts, indexes, and spans.
  case grid(columns: Int, rows: Int, column: Int, row: Int, columnSpan: Int, rowSpan: Int)
  /// Centered frame sized as a ratio of the selected screen area.
  ///
  /// ``WindowPlacementCalculator`` clamps ratios to the `0...1` range.
  case centered(widthRatio: CGFloat, heightRatio: CGFloat)
}
