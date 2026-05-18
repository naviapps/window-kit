import ApplicationServices
import WindowKit

/// Errors thrown by AX window operations.
public enum AXWindowError: Error, Equatable, Sendable {
  /// The current process is not trusted for Accessibility access.
  case accessibilityNotTrusted
  /// The target application could not be resolved.
  case applicationNotFound(WindowTarget)
  /// The target window could not be resolved.
  case windowNotFound(WindowTarget)
  /// An Accessibility value had an unexpected type or shape.
  case invalidAXValue
  /// The requested Accessibility action is not supported by the target window.
  case unsupportedAction(String)
  /// The Accessibility API returned an underlying error.
  case underlyingAccessibilityError(AXError)
}
