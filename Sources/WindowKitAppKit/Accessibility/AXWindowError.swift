import ApplicationServices
import WindowKit

/// Errors thrown by AX window operations.
enum AXWindowError: Error, Equatable, Sendable {
  /// The current process is not trusted for Accessibility access.
  case accessibilityNotTrusted
  /// The target application could not be resolved.
  case applicationNotFound(WindowTarget)
  /// The target window could not be resolved.
  case windowNotFound(WindowTarget)
  /// An Accessibility value had an unexpected type or shape.
  case invalidAXValue
  /// The requested Accessibility action is not supported by the target window.
  case unsupportedOperation
  /// The Accessibility API returned an underlying error.
  case underlyingAccessibilityError(AXError)
}

extension AXWindowError {
  func windowAccessibilityError(
    for operation: WindowAccessibilityOperation
  ) -> WindowAccessibilityError {
    switch self {
    case .accessibilityNotTrusted:
      .accessibilityNotTrusted
    case .applicationNotFound(let target):
      .applicationUnavailable(target)
    case .windowNotFound(let target):
      .windowUnavailable(target)
    case .invalidAXValue:
      .invalidAccessibilityValue(operation)
    case .unsupportedOperation:
      .unsupportedAccessibilityOperation(operation)
    case .underlyingAccessibilityError(let error):
      .accessibilityOperationFailed(
        operation: operation,
        failure: error.windowKitOperationFailure
      )
    }
  }
}

@MainActor
func translateAXWindowErrors<Value>(
  for operation: WindowAccessibilityOperation,
  _ body: () throws -> Value
) throws -> Value {
  do {
    return try body()
  } catch let error as AXWindowError {
    throw error.windowAccessibilityError(for: operation)
  }
}

private extension AXError {
  var windowKitOperationFailure: WindowAccessibilityOperationFailure {
    switch self {
    case .success:
      .unexpectedSuccess
    case .failure:
      .failure
    case .illegalArgument:
      .illegalArgument
    case .invalidUIElement:
      .invalidUIElement
    case .invalidUIElementObserver:
      .invalidUIElementObserver
    case .cannotComplete:
      .cannotComplete
    case .attributeUnsupported:
      .attributeUnsupported
    case .actionUnsupported:
      .actionUnsupported
    case .notificationUnsupported:
      .notificationUnsupported
    case .notImplemented:
      .notImplemented
    case .notificationAlreadyRegistered:
      .notificationAlreadyRegistered
    case .notificationNotRegistered:
      .notificationNotRegistered
    case .apiDisabled:
      .apiDisabled
    case .noValue:
      .noValue
    case .parameterizedAttributeUnsupported:
      .parameterizedAttributeUnsupported
    case .notEnoughPrecision:
      .notEnoughPrecision
    @unknown default:
      .unrecognizedAXError
    }
  }
}
