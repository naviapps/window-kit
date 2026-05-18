/// Changes window state and ordering without direct frame writes.
public protocol WindowCommandControlling: Sendable {
  /// Sets minimized state for a target window.
  @MainActor
  func setMinimized(_ target: WindowTarget, isMinimized: Bool) throws

  /// Sets full-screen state for a target window.
  @MainActor
  func setFullScreen(_ target: WindowTarget, isFullScreen: Bool) throws

  /// Raises a target window.
  @MainActor
  func raise(_ target: WindowTarget) throws

  /// Lowers a target window.
  @MainActor
  func lower(_ target: WindowTarget) throws
}
