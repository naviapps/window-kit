import CoreGraphics

/// Reusable placement description for calculating a target window frame.
public enum WindowPlacement: Equatable, Hashable, Sendable, Codable {
  /// Fill the selected screen area.
  case fill
  /// Rectangular region in a grid.
  ///
  /// Columns and rows advance from the area's minimum x and y coordinates. Row zero is at the
  /// bottom for AppKit coordinates and at the top for Accessibility coordinates.
  /// ``WindowPlacementCalculator`` clamps invalid
  /// column/row counts, indexes, and spans.
  case grid(columns: Int, rows: Int, column: Int, row: Int, columnSpan: Int, rowSpan: Int)
  /// Centered frame sized as a ratio of the selected screen area.
  ///
  /// ``WindowPlacementCalculator`` clamps ratios to the `0...1` range.
  case centered(widthRatio: CGFloat, heightRatio: CGFloat)
}
