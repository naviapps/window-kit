import CoreGraphics
import WindowKit

/// Queries the macOS window list and returns immutable app-facing window snapshots.
public struct WindowSnapshotQuery: WindowSnapshotProviding, WindowSnapshotResolving, Sendable {
  private let request: WindowListRequest
  private let makeSingleWindowRequest: @Sendable (CGWindowID) -> WindowListRequest
  private let listProvider: any WindowListProviding
  private let limit: WindowSnapshotQueryLimit
  private let mapper: WindowListSnapshotMapper

  /// Creates a system-backed window snapshot query.
  public init(
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NSRunningApplicationBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init(),
    limit: WindowSnapshotQueryLimit = .allMatchingWindows
  ) {
    self.init(
      listProvider: SystemWindowListProvider(),
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter,
      limit: limit
    )
  }

  init(
    request: WindowListRequest = .onScreenWindows,
    makeSingleWindowRequest: @escaping @Sendable (CGWindowID) -> WindowListRequest = {
      .window($0)
    },
    listProvider: any WindowListProviding,
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NSRunningApplicationBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init(),
    limit: WindowSnapshotQueryLimit = .allMatchingWindows
  ) {
    self.request = request
    self.makeSingleWindowRequest = makeSingleWindowRequest
    self.listProvider = listProvider
    self.limit = limit
    mapper = WindowListSnapshotMapper(
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter
    )
  }

  /// Reads the current system window list and returns matching snapshots.
  public func snapshots() throws -> [WindowSnapshot] {
    guard let windowList = listProvider.windowList(for: request) else {
      throw WindowSnapshotQueryError.windowListUnavailable
    }

    if limit == .topmostMatchingWindow {
      for entry in windowList {
        if let snapshot = mapper.snapshot(from: entry) {
          return [snapshot]
        }
      }
      return []
    }
    return windowList.compactMap { mapper.snapshot(from: $0) }
  }

  /// Reads a snapshot for a known Core Graphics window identifier.
  public func snapshot(for windowIdentifier: CGWindowID) throws -> WindowSnapshot? {
    guard
      let windowList = listProvider.windowList(for: makeSingleWindowRequest(windowIdentifier))
    else {
      throw WindowSnapshotQueryError.windowListUnavailable
    }

    return windowList.lazy
      .compactMap { mapper.snapshot(from: $0) }
      .first { $0.windowIdentifier == windowIdentifier }
  }
}
