import CoreGraphics

/// App-facing abstraction for point-based window hit-testing.
public protocol WindowHitTesting: Sendable {
  /// Returns a hit-test result for the topmost matching window at the given point.
  func hitTest(at point: CGPoint) -> WindowHitTestResult
}

extension WindowHitTesting {
  /// Returns the topmost matching window at the given point, or `nil` when there is no match.
  public func topmost(at point: CGPoint) -> WindowSnapshot? {
    guard case let .hit(snapshot) = hitTest(at: point) else { return nil }
    return snapshot
  }
}
