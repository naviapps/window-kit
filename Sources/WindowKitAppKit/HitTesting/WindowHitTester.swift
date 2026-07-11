import CoreGraphics
import WindowKit

/// System-backed hit tester for selecting the topmost matching window at a point.
public struct WindowHitTester: WindowHitTesting, Sendable {
  private let request: WindowListRequest
  private let listProvider: any WindowListProviding
  private let pointTransform: @Sendable (CGPoint) -> CGPoint
  private let mapper: WindowListSnapshotMapper

  /// Creates a hit tester configured with AppKit-backed window list and owner bundle lookup.
  public init(
    pointTransform: @escaping @Sendable (CGPoint) -> CGPoint = { $0 },
    filter: WindowSnapshotFilter = .init()
  ) {
    self.init(
      listProvider: SystemWindowListProvider(),
      pointTransform: pointTransform,
      filter: filter
    )
  }

  init(
    request: WindowListRequest = .onScreenWindows,
    listProvider: any WindowListProviding,
    pointTransform: @escaping @Sendable (CGPoint) -> CGPoint = { $0 },
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NSRunningApplicationBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init()
  ) {
    self.request = request
    self.listProvider = listProvider
    self.pointTransform = pointTransform
    mapper = WindowListSnapshotMapper(
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter
    )
  }

  /// Returns the topmost matching window at the given point.
  public func hitTest(at point: CGPoint) -> WindowHitTestResult {
    guard let windowList = listProvider.windowList(for: request) else {
      return .miss(.sourceUnavailable)
    }

    let transformedPoint = pointTransform(point)
    guard
      let selected = windowList.lazy
        .compactMap({ mapper.snapshot(from: $0, containing: transformedPoint) })
        .first
    else {
      return .miss(.noMatchingWindowAtPoint)
    }
    return .hit(selected)
  }
}
