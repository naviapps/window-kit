/// Reason a window hit-test did not produce a matching window.
public enum WindowHitTestMissReason: Equatable, Hashable, Sendable, Codable {
  /// The system window list could not be read.
  case listUnavailable
  /// No matching window contained the tested point.
  case noMatchingWindowAtPoint
}

/// Result of a point-based window hit-test.
public enum WindowHitTestResult: Equatable, Hashable, Sendable, Codable {
  /// A matching window snapshot was found.
  case hit(WindowSnapshot)
  /// No matching window was found.
  case miss(WindowHitTestMissReason)

  /// The matching snapshot when the result is ``hit(_:)``.
  public var snapshot: WindowSnapshot? {
    switch self {
    case let .hit(snapshot):
      snapshot
    case .miss:
      nil
    }
  }

  /// The miss reason when the result is ``miss(_:)``.
  public var missReason: WindowHitTestMissReason? {
    switch self {
    case .hit:
      nil
    case let .miss(reason):
      reason
    }
  }
}
