import XCTest

@testable import WindowKit

final class WindowHitTestResultTests: XCTestCase {
  func testHitResultExposesSnapshot() {
    let snapshot = makeSnapshot(windowIdentifier: 1)

    XCTAssertEqual(WindowHitTestResult.hit(snapshot).snapshot, snapshot)
    XCTAssertNil(WindowHitTestResult.miss(.noMatchingWindowAtPoint).snapshot)
  }

  func testMissResultExposesMissReason() {
    let snapshot = makeSnapshot(windowIdentifier: 1)

    XCTAssertNil(WindowHitTestResult.hit(snapshot).missReason)
    XCTAssertEqual(
      WindowHitTestResult.miss(.noMatchingWindowAtPoint).missReason,
      .noMatchingWindowAtPoint
    )
  }

  func testHitTestResultAndMissReasonValueConformance() throws {
    try assertValueConformance(WindowHitTestMissReason.listUnavailable)
    try assertValueConformance(WindowHitTestMissReason.noMatchingWindowAtPoint)
    try assertValueConformance(WindowHitTestResult.miss(.listUnavailable))
    try assertValueConformance(
      WindowHitTestResult.hit(makeSnapshot())
    )
  }

  func testHitTestResultAndMissReasonAreSendable() {
    assertSendable(WindowHitTestMissReason.listUnavailable)
    assertSendable(WindowHitTestResult.miss(.noMatchingWindowAtPoint))
    assertSendable(
      WindowHitTestResult.hit(makeSnapshot())
    )
  }

  private func makeSnapshot(windowIdentifier: UInt32 = 456) -> WindowSnapshot {
    WindowSnapshot(
      ownerProcessIdentifier: 123,
      windowIdentifier: windowIdentifier,
      frame: .zero,
      layer: 0
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
