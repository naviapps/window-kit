import WindowKit

/// App-facing abstraction for reading window role classifications.
@MainActor
public protocol WindowRoleProviding: Sendable {
  /// Returns the role classification for a target window.
  func role(for target: WindowTarget) throws -> WindowRole
}
