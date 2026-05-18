import CoreGraphics

/// Selects a screen from an ordered screen list.
public enum WindowScreenTarget: Equatable, Hashable, Sendable, Codable {
  /// The main screen.
  case main
  /// The screen containing the target window center.
  case containingWindow
  /// The screen containing a point.
  case point(CGPoint)
  /// The screen matching a Core Graphics display identifier.
  case displayIdentifier(CGDirectDisplayID)
  /// A screen by deterministic ordered index.
  case orderedIndex(Int)
}
