import XCTest

@testable import WindowKit

final class WindowScreenAreaTests: XCTestCase {
  func testWindowScreenAreaValueConformance() throws {
    try assertValueConformance(WindowScreenArea.full)
    try assertValueConformance(WindowScreenArea.visible)
  }

  func testWindowScreenAreaIsSendable() {
    assertSendable(WindowScreenArea.full)
    assertSendable(WindowScreenArea.visible)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
