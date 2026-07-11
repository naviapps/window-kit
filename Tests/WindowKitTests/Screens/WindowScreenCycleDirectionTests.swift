import WindowKit
import XCTest

final class WindowScreenCycleDirectionTests: XCTestCase {
  func testWindowScreenCycleDirectionValueConformance() throws {
    try assertValueConformance(WindowScreenCycleDirection.next)
    try assertValueConformance(WindowScreenCycleDirection.previous)
  }

  func testWindowScreenCycleDirectionIsSendable() {
    assertSendable(WindowScreenCycleDirection.next)
    assertSendable(WindowScreenCycleDirection.previous)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
