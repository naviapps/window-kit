import CoreGraphics

/// Filters applied when converting system window list entries into ``WindowSnapshot`` values.
public struct WindowSnapshotFilter: Equatable, Hashable, Sendable, Codable {
  /// Owner bundle identifiers to include in results.
  ///
  /// Empty means all bundle identifiers are included.
  public let includedOwnerBundleIdentifiers: Set<String>
  /// Owner process identifiers to include in results.
  ///
  /// Empty means all process identifiers are included.
  public let includedOwnerProcessIdentifiers: Set<pid_t>
  /// Window identifiers to include in results. Empty means all window identifiers are included.
  public let includedWindowIdentifiers: Set<CGWindowID>
  /// Owner bundle identifiers to exclude from results.
  public let excludedOwnerBundleIdentifiers: Set<String>
  /// Owner process identifiers to exclude from results.
  public let excludedOwnerProcessIdentifiers: Set<pid_t>
  /// Window identifiers to exclude from results.
  public let excludedWindowIdentifiers: Set<CGWindowID>
  /// Whether minimized windows should be excluded.
  public let excludesMinimizedWindows: Bool

  /// Creates a filter for window list queries and hit-testing.
  public init(
    includedOwnerBundleIdentifiers: Set<String> = [],
    includedOwnerProcessIdentifiers: Set<pid_t> = [],
    includedWindowIdentifiers: Set<CGWindowID> = [],
    excludedOwnerBundleIdentifiers: Set<String> = [],
    excludedOwnerProcessIdentifiers: Set<pid_t> = [],
    excludedWindowIdentifiers: Set<CGWindowID> = [],
    excludesMinimizedWindows: Bool = false
  ) {
    self.includedOwnerBundleIdentifiers = includedOwnerBundleIdentifiers
    self.includedOwnerProcessIdentifiers = includedOwnerProcessIdentifiers
    self.includedWindowIdentifiers = includedWindowIdentifiers
    self.excludedOwnerBundleIdentifiers = excludedOwnerBundleIdentifiers
    self.excludedOwnerProcessIdentifiers = excludedOwnerProcessIdentifiers
    self.excludedWindowIdentifiers = excludedWindowIdentifiers
    self.excludesMinimizedWindows = excludesMinimizedWindows
  }
}
