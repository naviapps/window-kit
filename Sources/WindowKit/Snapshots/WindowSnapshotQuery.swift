import CoreGraphics

/// Queries the macOS window list and returns immutable app-facing window snapshots.
public struct WindowSnapshotQuery: WindowSnapshotProviding, Sendable {
  private let options: CGWindowListOption
  private let singleWindowOptions: CGWindowListOption
  private let listProvider: any WindowListProviding
  private let limitsToTopmostWindow: Bool
  private let mapper: WindowListSnapshotMapper

  /// Creates a system-backed window snapshot query.
  public init(
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NullWindowOwnerBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init(),
    limitsToTopmostWindow: Bool = false
  ) {
    self.init(
      listProvider: SystemWindowListProvider(),
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter,
      limitsToTopmostWindow: limitsToTopmostWindow
    )
  }

  init(
    options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements],
    singleWindowOptions: CGWindowListOption = [.optionIncludingWindow, .excludeDesktopElements],
    allowedLayers: Set<Int> = [0],
    listProvider: any WindowListProviding,
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NullWindowOwnerBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init(),
    limitsToTopmostWindow: Bool = false
  ) {
    self.options = options
    self.singleWindowOptions = singleWindowOptions
    self.listProvider = listProvider
    self.limitsToTopmostWindow = limitsToTopmostWindow
    mapper = WindowListSnapshotMapper(
      allowedLayers: allowedLayers,
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: filter
    )
  }

  /// Reads the current system window list and returns matching snapshots.
  public func snapshots() throws -> [WindowSnapshot] {
    guard
      let windowList = listProvider.windowList(
        options: options,
        windowIdentifier: kCGNullWindowID
      )
    else {
      throw WindowSnapshotQueryError.listUnavailable
    }

    if limitsToTopmostWindow {
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
      let windowList = listProvider.windowList(
        options: singleWindowOptions, windowIdentifier: windowIdentifier)
    else {
      throw WindowSnapshotQueryError.listUnavailable
    }

    return windowList.lazy
      .compactMap { mapper.snapshot(from: $0) }
      .first { $0.windowIdentifier == windowIdentifier }
  }
}
