import CoreGraphics

/// Immutable app-facing representation of a macOS window.
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
  /// Standardized window frame in global screen coordinates.
  ///
  /// Non-finite components are replaced with finite zero-origin bounds.
  public let frame: CGRect
  /// Creates an immutable window snapshot.
  public init(
    ownerProcessIdentifier: pid_t,
    windowIdentifier: CGWindowID,
    ownerName: String? = nil,
    ownerBundleIdentifier: String? = nil,
    title: String? = nil,
    frame: CGRect
  ) {
    self.ownerProcessIdentifier = ownerProcessIdentifier
    self.windowIdentifier = windowIdentifier
    self.ownerName = ownerName
    self.ownerBundleIdentifier = ownerBundleIdentifier
    self.title = title
    self.frame = frame.finiteStandardized
  }
}
