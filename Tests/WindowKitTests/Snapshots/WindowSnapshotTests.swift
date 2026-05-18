import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowSnapshotTests: XCTestCase {
  private let frame = CGRect(x: 10, y: 20, width: 300, height: 200)

  func testInitUsesDefaultMetadata() {
    let snapshot = makeSnapshot()

    XCTAssertNil(snapshot.ownerName)
    XCTAssertNil(snapshot.ownerBundleIdentifier)
    XCTAssertNil(snapshot.title)
    XCTAssertNil(snapshot.isMinimized)
  }

  func testInitStoresSnapshotFields() {
    let snapshot = makeSnapshot(
      ownerName: "ExampleApp",
      ownerBundleIdentifier: "com.example.app",
      title: "Main",
      isMinimized: true
    )

    XCTAssertEqual(snapshot.ownerProcessIdentifier, 123)
    XCTAssertEqual(snapshot.windowIdentifier, 456)
    XCTAssertEqual(snapshot.ownerName, "ExampleApp")
    XCTAssertEqual(snapshot.ownerBundleIdentifier, "com.example.app")
    XCTAssertEqual(snapshot.title, "Main")
    XCTAssertEqual(snapshot.frame, frame)
    XCTAssertEqual(snapshot.layer, 0)
    XCTAssertEqual(snapshot.isMinimized, true)
  }

  func testWindowSnapshotValueConformance() throws {
    try assertValueConformance(makeSnapshot())
    try assertValueConformance(
      makeSnapshot(
        ownerName: "ExampleApp",
        ownerBundleIdentifier: "com.example.app",
        title: "Main",
        isMinimized: false
      )
    )
    try assertValueConformance(makeSnapshot(isMinimized: true))
  }

  func testWindowSnapshotIsSendable() {
    assertSendable(
      makeSnapshot(
        ownerName: "ExampleApp",
        ownerBundleIdentifier: "com.example.app",
        title: "Main",
        isMinimized: true
      )
    )
  }

  private func makeSnapshot(
    ownerName: String? = nil,
    ownerBundleIdentifier: String? = nil,
    title: String? = nil,
    isMinimized: Bool? = nil
  ) -> WindowSnapshot {
    WindowSnapshot(
      ownerProcessIdentifier: 123,
      windowIdentifier: 456,
      ownerName: ownerName,
      ownerBundleIdentifier: ownerBundleIdentifier,
      title: title,
      frame: frame,
      layer: 0,
      isMinimized: isMinimized
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
