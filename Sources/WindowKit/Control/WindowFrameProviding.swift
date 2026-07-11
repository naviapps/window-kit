import CoreGraphics

/// Reads window frames.
public protocol WindowFrameProviding: Sendable {
  /// Returns the current frame for a target window.
  @MainActor
  func frame(for target: WindowTarget) throws -> CGRect
}
