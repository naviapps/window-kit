/// Reason a window hit-test did not produce a matching window.
public enum WindowHitTestMissReason: Equatable, Hashable, Sendable, Codable {
  /// The hit-testing provider could not read its window source.
  case sourceUnavailable
  /// No matching window contained the tested point.
  case noMatchingWindowAtPoint
}
