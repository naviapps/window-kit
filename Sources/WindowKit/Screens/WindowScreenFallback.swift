/// Screen-selection behavior when a requested screen cannot be resolved.
public enum WindowScreenFallback: Equatable, Hashable, Sendable, Codable {
  /// Use the first deterministically ordered screen when one exists.
  case firstScreen
  /// Do not fall back; return nil or throw from higher-level operations.
  case none
}
