import ApplicationServices
import XCTest

@testable import WindowKit
@testable import WindowKitAppKit

final class AXWindowErrorTests: XCTestCase {
  func testAXWindowErrorIsSendable() {
    for error in sampleErrors {
      assertSendable(error)
    }
  }

  func testAXWindowErrorEquatableMatchesIdenticalValues() {
    for error in sampleErrors {
      XCTAssertEqual(error, error)
    }
  }

  func testAXWindowErrorEquatableDistinguishesCasesAndAssociatedValues() {
    XCTAssertNotEqual(
      AXWindowError.applicationNotFound(.focused),
      .applicationNotFound(.windowIdentifier(1))
    )
    XCTAssertNotEqual(
      AXWindowError.windowNotFound(.focused),
      .windowNotFound(.windowIdentifier(1))
    )
    XCTAssertNotEqual(
      AXWindowError.applicationNotFound(.focused),
      .windowNotFound(.focused)
    )
    XCTAssertNotEqual(
      AXWindowError.unsupportedAction(AXWindowActionName.lower),
      .unsupportedAction("AXRaise")
    )
    XCTAssertNotEqual(
      AXWindowError.underlyingAccessibilityError(.notImplemented),
      .underlyingAccessibilityError(.cannotComplete)
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}

private let sampleErrors: [AXWindowError] = [
  .accessibilityNotTrusted,
  .applicationNotFound(.focused),
  .applicationNotFound(.windowIdentifier(1)),
  .windowNotFound(.focused),
  .windowNotFound(.windowIdentifier(1)),
  .invalidAXValue,
  .unsupportedAction(AXWindowActionName.lower),
  .underlyingAccessibilityError(.notImplemented),
]
