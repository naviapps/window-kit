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
  /// Accessibility role metadata that does not match a known app-facing classification.
  case unclassified(accessibilityRole: String?, accessibilitySubrole: String?)
}
