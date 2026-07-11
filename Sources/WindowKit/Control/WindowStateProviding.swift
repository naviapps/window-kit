/// Reads state for a target window.
public protocol WindowStateProviding: Sendable {
  /// Returns the current state for a target window.
  @MainActor
  func state(for target: WindowTarget) throws -> WindowState
}
