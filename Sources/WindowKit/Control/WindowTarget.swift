import CoreGraphics

/// Identifies the window a controller should operate on.
public enum WindowTarget: Equatable, Hashable, Sendable, Codable {
  /// The currently focused window.
  case focused
  /// A window with a known Core Graphics window identifier.
  case windowIdentifier(CGWindowID)
}
