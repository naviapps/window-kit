import CoreGraphics

/// Immutable app-facing representation of a macOS screen.
public struct WindowScreen: Equatable, Hashable, Sendable, Codable {
  /// Core Graphics display identifier, when available.
  public let displayIdentifier: CGDirectDisplayID?
  /// Full screen frame.
  public let frame: CGRect
  /// Visible frame excluding system-reserved areas such as the menu bar and Dock.
  public let visibleFrame: CGRect
  /// Whether this screen is the main screen.
  public let isMain: Bool

  /// Creates a screen value.
  public init(
    displayIdentifier: CGDirectDisplayID? = nil,
    frame: CGRect,
    visibleFrame: CGRect,
    isMain: Bool = false
  ) {
    self.displayIdentifier = displayIdentifier
    self.frame = frame
    self.visibleFrame = visibleFrame
    self.isMain = isMain
  }

  /// Returns the frame for a requested screen area.
  public func frame(for area: WindowScreenArea) -> CGRect {
    switch area {
    case .full:
      return frame
    case .visible:
      return visibleFrame
    }
  }
}

/// Provides app-facing screen values.
public protocol WindowScreenProviding: Sendable {
  /// Returns the current screens.
  @MainActor
  func screens() -> [WindowScreen]
}
