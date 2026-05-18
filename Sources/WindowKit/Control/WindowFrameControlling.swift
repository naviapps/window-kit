import CoreGraphics

/// Reads window frames.
public protocol WindowFrameProviding: Sendable {
  /// Returns the current frame for a target window.
  @MainActor
  func frame(for target: WindowTarget) throws -> CGRect
}

/// Reads and writes window frames.
public protocol WindowFrameControlling: WindowFrameProviding {
  /// Sets the frame for a target window.
  @MainActor
  func setFrame(_ frame: CGRect, for target: WindowTarget) throws
}
