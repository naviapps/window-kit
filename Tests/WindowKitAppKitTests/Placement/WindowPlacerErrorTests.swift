import WindowKit
import WindowKitAppKit
import XCTest

final class WindowPlacerErrorTests: XCTestCase {
  func testWindowPlacerErrorIsSendable() {
    assertSendable(WindowPlacerError.screenNotFound(.displayIdentifier(1)))
  }

  func testWindowPlacerErrorEquatableMatchesIdenticalValues() {
    XCTAssertEqual(
      WindowPlacerError.screenNotFound(.displayIdentifier(1)),
      .screenNotFound(.displayIdentifier(1))
    )
  }

  func testWindowPlacerErrorEquatableDistinguishesAssociatedValues() {
    XCTAssertNotEqual(
      WindowPlacerError.screenNotFound(.main),
      .screenNotFound(.displayIdentifier(1))
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
