import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowSnapshotQueryTests: XCTestCase {
  func testSnapshotQueryReadsDefaultOnScreenWindowList() throws {
    let provider = WindowListProviderSpy(entries: [])
    let query = WindowSnapshotQuery(listProvider: provider)

    _ = try query.snapshots()

    XCTAssertEqual(provider.requests.map(\.windowIdentifier), [kCGNullWindowID])
    XCTAssertEqual(
      provider.requests.map(\.options),
      [[.optionOnScreenOnly, .excludeDesktopElements]]
    )
  }

  func testSnapshotQueryForwardsCustomWindowListOptions() throws {
    let provider = WindowListProviderSpy(entries: [])
    let query = WindowSnapshotQuery(options: [.optionAll], listProvider: provider)

    _ = try query.snapshots()

    XCTAssertEqual(provider.requests.map(\.windowIdentifier), [kCGNullWindowID])
    XCTAssertEqual(provider.requests.map(\.options), [[.optionAll]])
  }

  func testSnapshotQueryIsSendable() {
    assertSendable(WindowSnapshotQuery(listProvider: WindowListProviderSpy(entries: [])))
  }

  func testSnapshotQueryFiltersByLayer() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 1, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 111),
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 10, y: 10, width: 100, height: 100), ownerProcessIdentifier: 222
      ),
    ])

    let query = WindowSnapshotQuery(
      allowedLayers: [0],
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviderStub(
        bundleIdentifier: "com.example.app")
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.count, 1)
    XCTAssertEqual(snapshots.first?.ownerProcessIdentifier, 222)
  }

  func testSnapshotQueryIncludesOwnerBundleIdentifier() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviderStub(
        bundleIdentifier: "com.example.app")
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.first?.ownerBundleIdentifier, "com.example.app")
  }

  func testSnapshotQueryIncludesWindowMetadata() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 0, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 123,
        windowIdentifier: 456
      )
    ])

    let snapshot = try WindowSnapshotQuery(listProvider: provider).snapshots().first

    XCTAssertEqual(snapshot?.ownerName, "ExampleApp")
    XCTAssertEqual(snapshot?.title, "Main")
    XCTAssertEqual(snapshot?.windowIdentifier, 456)
    XCTAssertEqual(snapshot?.layer, 0)
  }

  func testSnapshotQueryStandardizesFrame() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 100, y: 100, width: -80, height: -60),
        ownerProcessIdentifier: 123
      )
    ])

    let query = WindowSnapshotQuery(listProvider: provider)

    XCTAssertEqual(
      try query.snapshots().first?.frame,
      CGRect(x: 20, y: 40, width: 80, height: 60)
    )
  }

  func testSnapshotQueryCanBeUsedThroughSnapshotProvidingProtocol() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 456)
    ])
    let query: any WindowSnapshotProviding = WindowSnapshotQuery(listProvider: provider)

    XCTAssertEqual(try query.snapshots().map(\.windowIdentifier), [456])
    XCTAssertEqual(try query.snapshot(for: 456)?.windowIdentifier, 456)
  }

  func testSnapshotQuerySkipsEntriesWithoutWindowIdentifier() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: nil)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviderStub(
        bundleIdentifier: "com.example.app")
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQueryFiltersExcludedOwnerBundleIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviderStub(
        bundleIdentifier: "com.example.blocked"),
      filter: WindowSnapshotFilter(excludedOwnerBundleIdentifiers: ["com.example.blocked"])
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQueryFiltersExcludedOwnerProcessIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 456),
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProviderSpy(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      filter: WindowSnapshotFilter(excludedOwnerProcessIdentifiers: [123])
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.map(\.ownerProcessIdentifier), [456])
    XCTAssertEqual(bundleIdentifierProvider.processIdentifiers, [456])
  }

  func testSnapshotQueryFiltersExcludedWindowIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 111),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 456, windowIdentifier: 222),
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProviderSpy(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      filter: WindowSnapshotFilter(excludedWindowIdentifiers: [111])
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.map(\.windowIdentifier), [222])
    XCTAssertEqual(bundleIdentifierProvider.processIdentifiers, [456])
  }

  func testSnapshotQueryFiltersIncludedOwnerBundleIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviderStub(
        bundleIdentifier: "com.example.allowed"),
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.allowed"])
    )

    XCTAssertEqual(try query.snapshots().map(\.ownerProcessIdentifier), [123])
  }

  func testSnapshotQueryRejectsIncludedOwnerBundleIdentifierWhenIdentifierIsUnavailable() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviderStub(bundleIdentifier: nil),
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.allowed"])
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQueryFiltersIncludedOwnerProcessIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 456),
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      filter: WindowSnapshotFilter(includedOwnerProcessIdentifiers: [456])
    )

    XCTAssertEqual(try query.snapshots().map(\.ownerProcessIdentifier), [456])
  }

  func testSnapshotQueryFiltersIncludedWindowIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 111),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 456, windowIdentifier: 222),
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      filter: WindowSnapshotFilter(includedWindowIdentifiers: [222])
    )

    XCTAssertEqual(try query.snapshots().map(\.windowIdentifier), [222])
  }

  func testSnapshotForWindowIdentifierReadsSingleWindowList() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 222)
    ])

    let query = WindowSnapshotQuery(listProvider: provider)
    let snapshot = try query.snapshot(for: 222)

    XCTAssertEqual(snapshot?.windowIdentifier, 222)
    XCTAssertEqual(provider.requests.map(\.windowIdentifier), [222])
    XCTAssertEqual(
      provider.requests.map(\.options), [[.optionIncludingWindow, .excludeDesktopElements]])
  }

  func testSnapshotForWindowIdentifierForwardsCustomSingleWindowListOptions() throws {
    let provider = WindowListProviderSpy(entries: [])
    let query = WindowSnapshotQuery(
      singleWindowOptions: [.optionAll],
      listProvider: provider
    )

    _ = try query.snapshot(for: 222)

    XCTAssertEqual(provider.requests.map(\.windowIdentifier), [222])
    XCTAssertEqual(provider.requests.map(\.options), [[.optionAll]])
  }

  func testSnapshotForWindowIdentifierReturnsNilWhenFilteredOut() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 222)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      filter: WindowSnapshotFilter(excludedWindowIdentifiers: [222])
    )

    XCTAssertNil(try query.snapshot(for: 222))
  }

  func testSnapshotForWindowIdentifierThrowsWhenWindowListUnavailable() {
    let query = WindowSnapshotQuery(listProvider: WindowListProviderSpy(entries: nil))

    XCTAssertThrowsError(try query.snapshot(for: 222)) { error in
      XCTAssertEqual(error as? WindowSnapshotQueryError, .listUnavailable)
    }
  }

  func testSnapshotForWindowIdentifierReturnsNilWhenReturnedEntryDoesNotMatchIdentifier() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 111)
    ])

    let query = WindowSnapshotQuery(listProvider: provider)

    XCTAssertNil(try query.snapshot(for: 222))
  }

  func testSnapshotQueryExcludesMinimizedWhenEnabled() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, isMinimized: true)
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProviderSpy(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      filter: WindowSnapshotFilter(excludesMinimizedWindows: true)
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
    XCTAssertTrue(bundleIdentifierProvider.processIdentifiers.isEmpty)
  }

  func testSnapshotQueryIncludesMinimizedMetadata() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, isMinimized: true)
    ])

    let query = WindowSnapshotQuery(listProvider: provider)

    XCTAssertEqual(try query.snapshots().first?.isMinimized, true)
  }

  func testSnapshotQueryLimitsToTopmostWindowWhenEnabled() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 1),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 2),
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProviderSpy(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      limitsToTopmostWindow: true
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.map(\.ownerProcessIdentifier), [1])
    XCTAssertEqual(bundleIdentifierProvider.processIdentifiers, [1])
  }

  func testSnapshotQueryLimitsToFirstMatchingTopmostWindowWhenEnabled() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 1, frame: .zero, ownerProcessIdentifier: 1),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 2),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 3),
    ])

    let query = WindowSnapshotQuery(
      allowedLayers: [0],
      listProvider: provider,
      limitsToTopmostWindow: true
    )

    XCTAssertEqual(try query.snapshots().map(\.ownerProcessIdentifier), [2])
  }

  func testSnapshotQueryThrowsWhenWindowListUnavailable() {
    let query = WindowSnapshotQuery(listProvider: WindowListProviderSpy(entries: nil))

    XCTAssertThrowsError(try query.snapshots()) { error in
      XCTAssertEqual(error as? WindowSnapshotQueryError, .listUnavailable)
    }
  }

  func testSnapshotQueryErrorIsEquatableAndSendable() {
    XCTAssertEqual(WindowSnapshotQueryError.listUnavailable, .listUnavailable)
    assertSendable(WindowSnapshotQueryError.listUnavailable)
  }
}

private func assertSendable<Value: Sendable>(_: Value) {}
