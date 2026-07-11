import CoreGraphics

/// App-facing abstraction for resolving one immutable window snapshot by identifier.
public protocol WindowSnapshotResolving: Sendable {
  /// Reads a snapshot for a known window identifier.
  func snapshot(for windowIdentifier: CGWindowID) throws -> WindowSnapshot?
}
