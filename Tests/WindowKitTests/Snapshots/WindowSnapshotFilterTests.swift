import WindowKit
import XCTest

final class WindowSnapshotFilterTests: XCTestCase {
  func testInitUsesDefaultFilterOptions() {
    let filter = WindowSnapshotFilter()

    XCTAssertTrue(filter.includedOwnerBundleIdentifiers.isEmpty)
    XCTAssertTrue(filter.includedOwnerProcessIdentifiers.isEmpty)
    XCTAssertTrue(filter.includedWindowIdentifiers.isEmpty)
    XCTAssertTrue(filter.excludedOwnerBundleIdentifiers.isEmpty)
    XCTAssertTrue(filter.excludedOwnerProcessIdentifiers.isEmpty)
    XCTAssertTrue(filter.excludedWindowIdentifiers.isEmpty)
  }

  func testInitStoresFilterOptions() {
    let filter = makeFilter()

    XCTAssertEqual(filter.includedOwnerBundleIdentifiers, ["com.example.allowed"])
    XCTAssertEqual(filter.includedOwnerProcessIdentifiers, [111])
    XCTAssertEqual(filter.includedWindowIdentifiers, [222])
    XCTAssertEqual(filter.excludedOwnerBundleIdentifiers, ["com.example.blocked"])
    XCTAssertEqual(filter.excludedOwnerProcessIdentifiers, [333])
    XCTAssertEqual(filter.excludedWindowIdentifiers, [444])
  }

  func testWindowSnapshotFilterValueConformance() throws {
    try assertValueConformance(WindowSnapshotFilter())
    try assertValueConformance(makeFilter())
  }

  func testWindowSnapshotFilterIsSendable() {
    assertSendable(makeFilter())
  }

  func testIncludesAcceptsSnapshotsMatchingAllFilterOptions() {
    let filter = makeFilter()
    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: 111,
      windowIdentifier: 222,
      ownerName: "Allowed",
      ownerBundleIdentifier: "com.example.allowed",
      title: "Main",
      frame: .zero,
    )

    XCTAssertTrue(filter.includes(snapshot))
  }

  func testIncludesRejectsSnapshotsOutsideFilterOptions() {
    let filter = makeFilter()

    XCTAssertFalse(filter.includes(makeSnapshot(ownerBundleIdentifier: "com.example.other")))
    XCTAssertFalse(filter.includes(makeSnapshot(ownerProcessIdentifier: 333)))
    XCTAssertFalse(filter.includes(makeSnapshot(windowIdentifier: 444)))
  }

  func testIncludesRejectsMissingBundleIdentifierWhenBundleAllowListIsSet() {
    let filter = WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.allowed"])

    XCTAssertFalse(filter.includes(makeSnapshot(ownerBundleIdentifier: nil)))
  }

  func testIncludesAppliesExcludeFiltersAfterIncludeFilters() {
    let snapshot = makeSnapshot()

    XCTAssertFalse(
      WindowSnapshotFilter(
        includedOwnerBundleIdentifiers: ["com.example.allowed"],
        excludedOwnerBundleIdentifiers: ["com.example.allowed"]
      ).includes(snapshot)
    )
    XCTAssertFalse(
      WindowSnapshotFilter(
        includedOwnerProcessIdentifiers: [111],
        excludedOwnerProcessIdentifiers: [111]
      ).includes(snapshot)
    )
    XCTAssertFalse(
      WindowSnapshotFilter(
        includedWindowIdentifiers: [222],
        excludedWindowIdentifiers: [222]
      ).includes(snapshot)
    )
  }

  private func makeFilter() -> WindowSnapshotFilter {
    WindowSnapshotFilter(
      includedOwnerBundleIdentifiers: ["com.example.allowed"],
      includedOwnerProcessIdentifiers: [111],
      includedWindowIdentifiers: [222],
      excludedOwnerBundleIdentifiers: ["com.example.blocked"],
      excludedOwnerProcessIdentifiers: [333],
      excludedWindowIdentifiers: [444]
    )
  }

  private func makeSnapshot(
    ownerProcessIdentifier: pid_t = 111,
    windowIdentifier: CGWindowID = 222,
    ownerBundleIdentifier: String? = "com.example.allowed"
  ) -> WindowSnapshot {
    WindowSnapshot(
      ownerProcessIdentifier: ownerProcessIdentifier,
      windowIdentifier: windowIdentifier,
      ownerName: "Allowed",
      ownerBundleIdentifier: ownerBundleIdentifier,
      title: "Main",
      frame: .zero,
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
