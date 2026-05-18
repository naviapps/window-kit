import WindowKit

/// App-facing classification of an Accessibility window role and subrole.
public enum WindowRole: Equatable, Hashable, Sendable, Codable {
  /// Standard document or application window.
  case standard
  /// Dialog window.
  case dialog
  /// Sheet attached to another window.
  case sheet
  /// Panel window.
  case panel
  /// Popover window.
  case popover
  /// System dialog window.
  case systemDialog
  /// Role or subrole that does not match a known classification.
  case unknown(role: String?, subrole: String?)
}

/// App-facing abstraction for reading window role classifications.
@MainActor
public protocol WindowRoleProviding: Sendable {
  /// Returns the role classification for a target window.
  func role(for target: WindowTarget) throws -> WindowRole
}
