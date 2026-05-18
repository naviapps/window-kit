import CoreGraphics

/// Hit-testing facade for selecting the topmost matching window at a point.
public struct WindowHitTester: WindowHitTesting, Sendable {
  private let provider: any WindowHitTestProviding

  /// Creates a hit tester backed by the system window list.
  ///
  /// - Parameters:
  ///   - pointTransform: Converts the input point to the same global coordinate space as snapshot
  ///     frames before hit-testing.
  ///   - ownerBundleIdentifierProvider: Resolves owner bundle identifiers for returned snapshots.
  ///   - filter: Filters candidate windows before hit-testing.
  public init(
    pointTransform: @escaping @Sendable (CGPoint) -> CGPoint = { $0 },
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NullWindowOwnerBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init()
  ) {
    provider = WindowListHitTestProvider(
      pointTransform: pointTransform,
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter
    )
  }

  init(provider: any WindowHitTestProviding) {
    self.provider = provider
  }

  /// Returns a hit-test result for the topmost matching window at the given point.
  public func hitTest(at point: CGPoint) -> WindowHitTestResult {
    provider.hitTest(at: point)
  }
}
