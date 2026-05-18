import CoreGraphics

protocol WindowHitTestProviding: Sendable {
  /// Returns a hit-test result for the topmost matching window at a given point.
  ///
  /// The `point` must be in the same global coordinate space as snapshot frames.
  func hitTest(at point: CGPoint) -> WindowHitTestResult
}

final class WindowListHitTestProvider: WindowHitTestProviding, Sendable {
  private let options: CGWindowListOption
  private let listProvider: any WindowListProviding
  private let pointTransform: @Sendable (CGPoint) -> CGPoint
  private let mapper: WindowListSnapshotMapper

  /// - Parameters:
  ///   - options: Core Graphics window-list options used for hit-testing.
  ///   - allowedLayers: Window layers accepted by the snapshot mapper.
  ///   - pointTransform: Converts the input point to the same global coordinate space as snapshot
  ///     frames before hit-testing.
  ///   - ownerBundleIdentifierProvider: Resolves owner bundle identifiers for returned snapshots.
  ///   - filter: Filters candidate windows before hit-testing.
  convenience init(
    options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements],
    allowedLayers: Set<Int> = [0],
    pointTransform: @escaping @Sendable (CGPoint) -> CGPoint = { $0 },
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NullWindowOwnerBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init()
  ) {
    self.init(
      options: options,
      allowedLayers: allowedLayers,
      listProvider: SystemWindowListProvider(),
      pointTransform: pointTransform,
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter
    )
  }

  init(
    options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements],
    allowedLayers: Set<Int> = [0],
    listProvider: any WindowListProviding,
    pointTransform: @escaping @Sendable (CGPoint) -> CGPoint = { $0 },
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NullWindowOwnerBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init()
  ) {
    self.options = options
    self.listProvider = listProvider
    self.pointTransform = pointTransform
    mapper = WindowListSnapshotMapper(
      allowedLayers: allowedLayers,
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter
    )
  }

  func hitTest(at point: CGPoint) -> WindowHitTestResult {
    let transformedPoint = pointTransform(point)
    guard
      let windowList = listProvider.windowList(
        options: options,
        windowIdentifier: kCGNullWindowID
      )
    else {
      return .miss(.listUnavailable)
    }

    guard
      let selected = windowList.lazy.compactMap({
        self.mapper.snapshot(from: $0, containing: transformedPoint)
      }).first
    else {
      return .miss(.noMatchingWindowAtPoint)
    }
    return .hit(selected)
  }
}
