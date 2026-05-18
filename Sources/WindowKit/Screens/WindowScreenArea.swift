/// Selects whether screen-aware operations use the full frame or visible frame.
public enum WindowScreenArea: Equatable, Hashable, Sendable, Codable {
  /// Use the full screen frame, including system-reserved areas.
  case full
  /// Use the visible screen frame, excluding system-reserved areas.
  case visible
}
