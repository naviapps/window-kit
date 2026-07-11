import WindowKit
import WindowKitAppKit
import XCTest

final class WindowAccessibilityErrorTests: XCTestCase {
  func testWindowAccessibilityErrorIsHashable() {
    for error in sampleErrors {
      assertHashable(error)
    }
  }

  func testWindowAccessibilityErrorEquatableDistinguishesCasesAndAssociatedValues() {
    XCTAssertNotEqual(
      WindowAccessibilityError.accessibilityNotTrusted,
      .applicationUnavailable(.focused)
    )
    XCTAssertNotEqual(
      WindowAccessibilityError.applicationUnavailable(.focused),
      .applicationUnavailable(.windowIdentifier(1))
    )
    XCTAssertNotEqual(
      WindowAccessibilityError.applicationUnavailable(.focused),
      .windowUnavailable(.focused)
    )
    XCTAssertNotEqual(
      WindowAccessibilityError.unsupportedAccessibilityOperation(.lower),
      .unsupportedAccessibilityOperation(.raise)
    )
    XCTAssertNotEqual(
      WindowAccessibilityError.accessibilityOperationFailed(
        operation: .readFrame,
        failure: .notImplemented
      ),
      .accessibilityOperationFailed(operation: .readFrame, failure: .cannotComplete)
    )
  }

  private func assertHashable<Value: Hashable>(_: Value) {}
}

private let sampleErrors: [WindowAccessibilityError] = [
  .accessibilityNotTrusted,
  .applicationUnavailable(.focused),
  .windowUnavailable(.windowIdentifier(1)),
  .invalidAccessibilityValue(.readState),
  .unsupportedAccessibilityOperation(.lower),
  .accessibilityOperationFailed(operation: .readRole, failure: .notImplemented),
]
