/// Error thrown when a window snapshot query cannot read the system window list.
public enum WindowSnapshotQueryError: Error, Equatable, Sendable {
  /// The system window list could not be read.
  case listUnavailable
}
