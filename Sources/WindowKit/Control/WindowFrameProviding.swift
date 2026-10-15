import CoreGraphics

/// Reads window frames.
public protocol WindowFrameProviding: Sendable {
  /// Returns the current frame for a target window.
  /// Consumers must use screen geometry and points in the same coordinate space.
  @MainActor
  func frame(for target: WindowTarget) throws -> CGRect
}
