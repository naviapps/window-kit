import XCTest

@testable import WindowKit

@MainActor
final class WindowHitTesterTests: XCTestCase {
  func testHitTestReturnsProviderResult() {
    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: 10,
      windowIdentifier: 42,
      frame: CGRect(x: 0, y: 0, width: 200, height: 100),
      layer: 0
    )
    let provider = WindowHitTestProviderStub(
      result: .hit(snapshot),
      expectedPoint: CGPoint(x: 10, y: 10)
    )
    let tester = WindowHitTester(provider: provider)

    XCTAssertEqual(tester.hitTest(at: CGPoint(x: 10, y: 10)), .hit(snapshot))
  }

  func testTopmostReturnsSnapshot() {
    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: 10,
      windowIdentifier: 42,
      ownerName: "Demo",
      ownerBundleIdentifier: "com.example.demo",
      title: "Front",
      frame: CGRect(x: 0, y: 0, width: 200, height: 100),
      layer: 0
    )
    let provider = WindowHitTestProviderStub(result: .hit(snapshot))
    let tester = WindowHitTester(provider: provider)

    let result = tester.topmost(at: CGPoint(x: 10, y: 10))

    XCTAssertEqual(result?.windowIdentifier, 42)
  }

  func testHitTesterCanBeUsedThroughHitTestingProtocol() {
    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: 10,
      windowIdentifier: 42,
      frame: CGRect(x: 0, y: 0, width: 200, height: 100),
      layer: 0
    )
    let provider = WindowHitTestProviderStub(result: .hit(snapshot))
    let tester: any WindowHitTesting = WindowHitTester(provider: provider)

    XCTAssertEqual(tester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.windowIdentifier, 42)
    XCTAssertEqual(tester.topmost(at: CGPoint(x: 10, y: 10))?.windowIdentifier, 42)
  }

  func testTopmostReturnsNilForMiss() {
    let provider = WindowHitTestProviderStub(result: .miss(.noMatchingWindowAtPoint))
    let tester = WindowHitTester(provider: provider)

    let result = tester.topmost(at: CGPoint(x: 10, y: 10))

    XCTAssertNil(result)
  }

  func testWindowHitTesterIsSendable() {
    let tester = WindowHitTester(
      provider: WindowHitTestProviderStub(result: .miss(.noMatchingWindowAtPoint))
    )

    assertSendable(tester)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}

private struct WindowHitTestProviderStub: WindowHitTestProviding {
  let result: WindowHitTestResult
  var expectedPoint: CGPoint?

  init(result: WindowHitTestResult, expectedPoint: CGPoint? = nil) {
    self.result = result
    self.expectedPoint = expectedPoint
  }

  func hitTest(at point: CGPoint) -> WindowHitTestResult {
    if let expectedPoint {
      XCTAssertEqual(point, expectedPoint)
    }
    return result
  }
}
