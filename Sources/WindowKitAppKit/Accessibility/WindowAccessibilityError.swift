import WindowKit

/// Errors surfaced by public Accessibility-backed window adapters.
public enum WindowAccessibilityError: Error, Equatable, Hashable, Sendable {
  /// The current process is not trusted for Accessibility access.
  case accessibilityNotTrusted
  /// The target application could not be resolved.
  case applicationUnavailable(WindowTarget)
  /// The target window could not be resolved.
  case windowUnavailable(WindowTarget)
  /// Accessibility returned an invalid value during an operation.
  case invalidAccessibilityValue(WindowAccessibilityOperation)
  /// The target window does not support an operation.
  case unsupportedAccessibilityOperation(WindowAccessibilityOperation)
  /// The underlying Accessibility operation failed.
  case accessibilityOperationFailed(
    operation: WindowAccessibilityOperation,
    failure: WindowAccessibilityOperationFailure
  )
}

/// Public classification of Accessibility-backed window operations.
public enum WindowAccessibilityOperation: String, Equatable, Hashable, Sendable, Codable {
  /// Read a window frame.
  case readFrame
  /// Set a window frame.
  case setFrame
  /// Read window state.
  case readState
  /// Set minimized state.
  case setMinimized
  /// Set full-screen state.
  case setFullScreen
  /// Raise a window.
  case raise
  /// Lower a window.
  case lower
  /// Read a window role.
  case readRole
}

/// Public, stable classification of Accessibility operation failures.
public enum WindowAccessibilityOperationFailure: String, Equatable, Hashable, Sendable, Codable {
  /// Accessibility returned success where a failure was expected.
  case unexpectedSuccess
  /// Accessibility returned a generic failure.
  case failure
  /// Accessibility rejected an argument.
  case illegalArgument
  /// Accessibility reported an invalid UI element.
  case invalidUIElement
  /// Accessibility reported an invalid UI element observer.
  case invalidUIElementObserver
  /// Accessibility could not complete the requested operation.
  case cannotComplete
  /// Accessibility does not support the requested attribute.
  case attributeUnsupported
  /// Accessibility does not support the requested action.
  case actionUnsupported
  /// Accessibility does not support the requested notification.
  case notificationUnsupported
  /// Accessibility has not implemented the requested operation.
  case notImplemented
  /// The notification was already registered.
  case notificationAlreadyRegistered
  /// The notification was not registered.
  case notificationNotRegistered
  /// The Accessibility API is disabled.
  case apiDisabled
  /// Accessibility reported no value.
  case noValue
  /// Accessibility does not support the requested parameterized attribute.
  case parameterizedAttributeUnsupported
  /// Accessibility could not provide enough precision.
  case notEnoughPrecision
  /// Accessibility returned an AXError case this package does not recognize yet.
  case unrecognizedAXError
}
