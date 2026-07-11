import WindowKit
import XCTest

final class WindowScreenFallbackTests: XCTestCase {
  func testWindowScreenFallbackValueConformance() throws {
    try assertValueConformance(WindowScreenFallback.firstScreen)
    try assertValueConformance(WindowScreenFallback.none)
  }

  func testWindowScreenFallbackIsSendable() {
    assertSendable(WindowScreenFallback.firstScreen)
    assertSendable(WindowScreenFallback.none)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
