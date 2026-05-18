import CoreGraphics

/// App-facing abstraction for reading immutable window snapshots.
public protocol WindowSnapshotProviding: Sendable {
  /// Reads the current system window list and returns matching snapshots.
  func snapshots() throws -> [WindowSnapshot]

  /// Reads a snapshot for a known Core Graphics window identifier.
  func snapshot(for windowIdentifier: CGWindowID) throws -> WindowSnapshot?
}
