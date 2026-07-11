import CoreGraphics
import WindowKit
import XCTest

final class WindowSnapshotTests: XCTestCase {
  private let frame = CGRect(x: 10, y: 20, width: 300, height: 200)

  func testInitUsesDefaultMetadata() {
    let snapshot = makeSnapshot()

    XCTAssertNil(snapshot.ownerName)
    XCTAssertNil(snapshot.ownerBundleIdentifier)
    XCTAssertNil(snapshot.title)
  }

  func testInitStoresSnapshotFields() {
    let snapshot = makeSnapshot(
      ownerName: "ExampleApp",
      ownerBundleIdentifier: "com.example.app",
      title: "Main"
    )

    XCTAssertEqual(snapshot.ownerProcessIdentifier, 123)
    XCTAssertEqual(snapshot.windowIdentifier, 456)
    XCTAssertEqual(snapshot.ownerName, "ExampleApp")
    XCTAssertEqual(snapshot.ownerBundleIdentifier, "com.example.app")
    XCTAssertEqual(snapshot.title, "Main")
    XCTAssertEqual(snapshot.frame, frame)
  }

  func testInitStandardizesFrame() {
    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: 123,
      windowIdentifier: 456,
      frame: CGRect(x: 100, y: 100, width: -80, height: -60),
    )

    XCTAssertEqual(snapshot.frame.origin, CGPoint(x: 20, y: 40))
    XCTAssertEqual(snapshot.frame.size, CGSize(width: 80, height: 60))
  }

  func testInitSanitizesNonFiniteFrame() {
    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: 123,
      windowIdentifier: 456,
      frame: CGRect(
        x: CGFloat.infinity,
        y: CGFloat.nan,
        width: CGFloat.infinity,
        height: -CGFloat.infinity
      ),
    )

    XCTAssertEqual(snapshot.frame, CGRect(x: 0, y: 0, width: 0, height: 0))
  }

  func testWindowSnapshotValueConformance() throws {
    try assertValueConformance(makeSnapshot())
    try assertValueConformance(
      makeSnapshot(
        ownerName: "ExampleApp",
        ownerBundleIdentifier: "com.example.app",
        title: "Main"
      )
    )
  }

  func testWindowSnapshotIsSendable() {
    assertSendable(
      makeSnapshot(
        ownerName: "ExampleApp",
        ownerBundleIdentifier: "com.example.app",
        title: "Main"
      )
    )
  }

  private func makeSnapshot(
    ownerName: String? = nil,
    ownerBundleIdentifier: String? = nil,
    title: String? = nil
  ) -> WindowSnapshot {
    WindowSnapshot(
      ownerProcessIdentifier: 123,
      windowIdentifier: 456,
      ownerName: ownerName,
      ownerBundleIdentifier: ownerBundleIdentifier,
      title: title,
      frame: frame,
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
