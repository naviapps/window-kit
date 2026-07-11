/// Controls how many matching snapshots a ``WindowSnapshotQuery`` returns.
public enum WindowSnapshotQueryLimit: Equatable, Hashable, Sendable, Codable {
  /// Return every matching window from the system window list.
  case allMatchingWindows
  /// Return only the first matching window from the system window list.
  case topmostMatchingWindow
}
