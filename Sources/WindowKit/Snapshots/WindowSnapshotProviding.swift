/// App-facing abstraction for reading immutable window snapshots.
public protocol WindowSnapshotProviding: Sendable {
  /// Reads the current window snapshots.
  func snapshots() throws -> [WindowSnapshot]
}
