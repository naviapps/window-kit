import XCTest

@testable import WindowKit

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
