/// Live window state values that may be unavailable on some windows.
public struct WindowState: Equatable, Hashable, Sendable, Codable {
  /// Whether the window is minimized, when the value is available.
  public let isMinimized: Bool?
  /// Whether the window is full-screen, when the value is available.
  public let isFullScreen: Bool?

  /// Creates a window state value.
  public init(isMinimized: Bool?, isFullScreen: Bool?) {
    self.isMinimized = isMinimized
    self.isFullScreen = isFullScreen
  }
}

/// Reads state for a target window.
public protocol WindowStateProviding: Sendable {
  /// Returns the current state for a target window.
  @MainActor
  func state(for target: WindowTarget) throws -> WindowState
}
