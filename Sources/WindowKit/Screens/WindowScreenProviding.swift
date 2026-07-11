/// Provides app-facing screen values.
public protocol WindowScreenProviding: Sendable {
  /// Returns the current screens.
  @MainActor
  func screens() -> [WindowScreen]
}
