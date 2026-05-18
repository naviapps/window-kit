import CoreGraphics

/// Immutable app-facing representation of a macOS window list entry.
public struct WindowSnapshot: Equatable, Hashable, Sendable, Codable {
  /// Process identifier of the owning application.
  public let ownerProcessIdentifier: pid_t
  /// Core Graphics window identifier.
  public let windowIdentifier: CGWindowID
  /// Display name of the owning application, when available.
  public let ownerName: String?
  /// Bundle identifier of the owning application, when available.
  public let ownerBundleIdentifier: String?
  /// Window title, when available.
  public let title: String?
  /// Window frame in global screen coordinates.
  public let frame: CGRect
  /// Core Graphics window layer.
  public let layer: Int
  /// Whether the window is minimized, when the system window list includes that value.
  public let isMinimized: Bool?

  /// Creates an immutable window snapshot.
  public init(
    ownerProcessIdentifier: pid_t,
    windowIdentifier: CGWindowID,
    ownerName: String? = nil,
    ownerBundleIdentifier: String? = nil,
    title: String? = nil,
    frame: CGRect,
    layer: Int,
    isMinimized: Bool? = nil
  ) {
    self.ownerProcessIdentifier = ownerProcessIdentifier
    self.windowIdentifier = windowIdentifier
    self.ownerName = ownerName
    self.ownerBundleIdentifier = ownerBundleIdentifier
    self.title = title
    self.frame = frame
    self.layer = layer
    self.isMinimized = isMinimized
  }
}
