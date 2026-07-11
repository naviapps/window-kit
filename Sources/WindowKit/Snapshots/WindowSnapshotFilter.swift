import CoreGraphics

/// Filters applied to ``WindowSnapshot`` values produced by query and hit-testing adapters.
public struct WindowSnapshotFilter: Equatable, Hashable, Sendable, Codable {
  /// Owner bundle identifiers to include in results.
  ///
  /// Empty means all bundle identifiers are included.
  public let includedOwnerBundleIdentifiers: Set<String>
  /// Owner process identifiers to include in results.
  ///
  /// Empty means all process identifiers are included.
  public let includedOwnerProcessIdentifiers: Set<pid_t>
  /// Window identifiers to include in results.
  ///
  /// Empty means all window identifiers are included.
  public let includedWindowIdentifiers: Set<CGWindowID>
  /// Owner bundle identifiers to exclude from results after include filters are applied.
  public let excludedOwnerBundleIdentifiers: Set<String>
  /// Owner process identifiers to exclude from results after include filters are applied.
  public let excludedOwnerProcessIdentifiers: Set<pid_t>
  /// Window identifiers to exclude from results after include filters are applied.
  public let excludedWindowIdentifiers: Set<CGWindowID>
  /// Creates a filter for snapshot queries and hit-testing.
  public init(
    includedOwnerBundleIdentifiers: Set<String> = [],
    includedOwnerProcessIdentifiers: Set<pid_t> = [],
    includedWindowIdentifiers: Set<CGWindowID> = [],
    excludedOwnerBundleIdentifiers: Set<String> = [],
    excludedOwnerProcessIdentifiers: Set<pid_t> = [],
    excludedWindowIdentifiers: Set<CGWindowID> = []
  ) {
    self.includedOwnerBundleIdentifiers = includedOwnerBundleIdentifiers
    self.includedOwnerProcessIdentifiers = includedOwnerProcessIdentifiers
    self.includedWindowIdentifiers = includedWindowIdentifiers
    self.excludedOwnerBundleIdentifiers = excludedOwnerBundleIdentifiers
    self.excludedOwnerProcessIdentifiers = excludedOwnerProcessIdentifiers
    self.excludedWindowIdentifiers = excludedWindowIdentifiers
  }

  /// Returns whether the snapshot satisfies this filter.
  public func includes(_ snapshot: WindowSnapshot) -> Bool {
    if !includedOwnerProcessIdentifiers.isEmpty,
      !includedOwnerProcessIdentifiers.contains(snapshot.ownerProcessIdentifier)
    {
      return false
    }
    if !includedWindowIdentifiers.isEmpty,
      !includedWindowIdentifiers.contains(snapshot.windowIdentifier)
    {
      return false
    }
    if !includedOwnerBundleIdentifiers.isEmpty {
      guard let ownerBundleIdentifier = snapshot.ownerBundleIdentifier,
        includedOwnerBundleIdentifiers.contains(ownerBundleIdentifier)
      else {
        return false
      }
    }
    if excludedOwnerProcessIdentifiers.contains(snapshot.ownerProcessIdentifier) {
      return false
    }
    if excludedWindowIdentifiers.contains(snapshot.windowIdentifier) {
      return false
    }
    if let ownerBundleIdentifier = snapshot.ownerBundleIdentifier,
      excludedOwnerBundleIdentifiers.contains(ownerBundleIdentifier)
    {
      return false
    }
    return true
  }
}
