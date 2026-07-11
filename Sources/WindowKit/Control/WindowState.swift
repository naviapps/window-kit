/// Live window state values that may be unavailable on some windows.
public struct WindowState: Equatable, Hashable, Sendable, Codable {
  /// Whether the window is minimized, when the value is available.
  public let isMinimized: Bool?
  /// Whether the window is full-screen, when the value is available.
  public let isFullScreen: Bool?

  /// Creates a window state value.
  public init(isMinimized: Bool? = nil, isFullScreen: Bool? = nil) {
    self.isMinimized = isMinimized
    self.isFullScreen = isFullScreen
  }
}
