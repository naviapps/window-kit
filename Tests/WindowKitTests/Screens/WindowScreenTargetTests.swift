import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowScreenTargetTests: XCTestCase {
  func testWindowScreenTargetValueConformance() throws {
    try assertValueConformance(WindowScreenTarget.main)
    try assertValueConformance(WindowScreenTarget.containingWindow)
    try assertValueConformance(WindowScreenTarget.point(CGPoint(x: 10, y: 20)))
    try assertValueConformance(WindowScreenTarget.displayIdentifier(123))
    try assertValueConformance(WindowScreenTarget.orderedIndex(2))
  }

  func testWindowScreenTargetIsSendable() {
    assertSendable(WindowScreenTarget.main)
    assertSendable(WindowScreenTarget.containingWindow)
    assertSendable(WindowScreenTarget.point(CGPoint(x: 10, y: 20)))
    assertSendable(WindowScreenTarget.displayIdentifier(123))
    assertSendable(WindowScreenTarget.orderedIndex(2))
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
