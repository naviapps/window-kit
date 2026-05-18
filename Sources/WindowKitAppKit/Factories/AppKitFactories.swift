import CoreGraphics
import WindowKit

extension WindowSnapshotQuery {
  /// Creates a query configured with AppKit-backed owner bundle identifier lookup.
  public static func appKit(
    filter: WindowSnapshotFilter = .init(),
    limitsToTopmostWindow: Bool = false
  ) -> Self {
    Self(
      ownerBundleIdentifierProvider: NSRunningApplicationBundleIdentifierProvider(),
      filter: filter,
      limitsToTopmostWindow: limitsToTopmostWindow
    )
  }
}

extension WindowHitTester {
  /// Creates a hit tester configured with AppKit-backed owner bundle identifier lookup.
  public static func appKit(
    pointTransform: @escaping @Sendable (CGPoint) -> CGPoint = { $0 },
    filter: WindowSnapshotFilter = .init()
  ) -> Self {
    Self(
      pointTransform: pointTransform,
      ownerBundleIdentifierProvider: NSRunningApplicationBundleIdentifierProvider(),
      filter: filter
    )
  }
}
