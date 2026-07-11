import CoreGraphics

/// Reads and writes window frames.
public protocol WindowFrameControlling: WindowFrameProviding {
  /// Sets the frame for a target window.
  @MainActor
  func setFrame(_ frame: CGRect, for target: WindowTarget) throws
}
