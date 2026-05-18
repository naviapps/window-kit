import XCTest

@testable import WindowKit

final class WindowSnapshotFilterTests: XCTestCase {
  func testInitUsesDefaultFilterOptions() {
    let filter = WindowSnapshotFilter()

    XCTAssertTrue(filter.includedOwnerBundleIdentifiers.isEmpty)
    XCTAssertTrue(filter.includedOwnerProcessIdentifiers.isEmpty)
    XCTAssertTrue(filter.includedWindowIdentifiers.isEmpty)
    XCTAssertTrue(filter.excludedOwnerBundleIdentifiers.isEmpty)
    XCTAssertTrue(filter.excludedOwnerProcessIdentifiers.isEmpty)
    XCTAssertTrue(filter.excludedWindowIdentifiers.isEmpty)
    XCTAssertFalse(filter.excludesMinimizedWindows)
  }

  func testInitStoresFilterOptions() {
    let filter = makeFilter()

    XCTAssertEqual(filter.includedOwnerBundleIdentifiers, ["com.example.allowed"])
    XCTAssertEqual(filter.includedOwnerProcessIdentifiers, [111])
    XCTAssertEqual(filter.includedWindowIdentifiers, [222])
    XCTAssertEqual(filter.excludedOwnerBundleIdentifiers, ["com.example.blocked"])
    XCTAssertEqual(filter.excludedOwnerProcessIdentifiers, [333])
    XCTAssertEqual(filter.excludedWindowIdentifiers, [444])
    XCTAssertTrue(filter.excludesMinimizedWindows)
  }

  func testWindowSnapshotFilterValueConformance() throws {
    try assertValueConformance(WindowSnapshotFilter())
    try assertValueConformance(makeFilter())
  }

  func testWindowSnapshotFilterIsSendable() {
    assertSendable(makeFilter())
  }

  private func makeFilter() -> WindowSnapshotFilter {
    WindowSnapshotFilter(
      includedOwnerBundleIdentifiers: ["com.example.allowed"],
      includedOwnerProcessIdentifiers: [111],
      includedWindowIdentifiers: [222],
      excludedOwnerBundleIdentifiers: ["com.example.blocked"],
      excludedOwnerProcessIdentifiers: [333],
      excludedWindowIdentifiers: [444],
      excludesMinimizedWindows: true
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
