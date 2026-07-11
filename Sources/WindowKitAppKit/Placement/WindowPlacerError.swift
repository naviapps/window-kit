import WindowKit

/// Errors thrown by live window placement operations.
public enum WindowPlacerError: Error, Equatable, Hashable, Sendable {
  /// The requested screen target could not be resolved.
  case screenNotFound(WindowScreenTarget)
}
