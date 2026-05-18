/// Direction for selecting an adjacent screen from an ordered screen list.
public enum WindowScreenCycleDirection: Equatable, Hashable, Sendable, Codable {
  /// Select the next ordered screen.
  case next
  /// Select the previous ordered screen.
  case previous
}
