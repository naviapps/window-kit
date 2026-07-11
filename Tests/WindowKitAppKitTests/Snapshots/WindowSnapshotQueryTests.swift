import CoreGraphics
import WindowKit
import XCTest

@testable import WindowKitAppKit

final class WindowSnapshotQueryTests: XCTestCase {
  func testSnapshotQuerySkipsEntriesWithNonFiniteFrames() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: CGFloat.infinity, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 123
      )
    ])

    XCTAssertTrue(try WindowSnapshotQuery(listProvider: provider).snapshots().isEmpty)
  }

  func testSnapshotQueryReadsDefaultOnScreenWindowList() throws {
    let provider = WindowListProviderSpy(entries: [])
    let query = WindowSnapshotQuery(listProvider: provider)

    _ = try query.snapshots()

    XCTAssertEqual(provider.requests, [.onScreenWindows])
  }

  func testSnapshotQueryForwardsCustomWindowListOptions() throws {
    let provider = WindowListProviderSpy(entries: [])
    let query = WindowSnapshotQuery(
      request: .windows(options: [.optionAll]),
      listProvider: provider
    )

    _ = try query.snapshots()

    XCTAssertEqual(provider.requests, [.windows(options: [.optionAll])])
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
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
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
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
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
    let query: any WindowSnapshotProviding & WindowSnapshotResolving =
      WindowSnapshotQuery(listProvider: provider)

    XCTAssertEqual(try query.snapshots().map(\.windowIdentifier), [456])
    XCTAssertEqual(try query.snapshot(for: 456)?.windowIdentifier, 456)
  }

  func testSnapshotQuerySkipsEntriesWithoutWindowIdentifier() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: nil)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
        bundleIdentifier: "com.example.app")
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQuerySkipsCGWindowEntriesWithInvalidIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      WindowListEntry(
        cgWindowInfo: makeCGWindowInfo(
          ownerProcessIdentifier: NSNumber(value: 123),
          windowIdentifier: NSNumber(value: -1))),
      WindowListEntry(
        cgWindowInfo: makeCGWindowInfo(
          ownerProcessIdentifier: NSNumber(value: -1),
          windowIdentifier: NSNumber(value: 456))),
      WindowListEntry(
        cgWindowInfo: makeCGWindowInfo(
          ownerProcessIdentifier: NSNumber(value: 123),
          windowIdentifier: NSNumber(value: 1.5))),
      WindowListEntry(
        cgWindowInfo: makeCGWindowInfo(
          ownerProcessIdentifier: NSNumber(value: true),
          windowIdentifier: NSNumber(value: 456))),
    ])
    let query = WindowSnapshotQuery(listProvider: provider)

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQuerySkipsCGWindowEntriesWithInvalidLayers() throws {
    let provider = WindowListProviderSpy(entries: [
      WindowListEntry(
        cgWindowInfo: makeCGWindowInfo(
          layer: NSNumber(value: true),
          ownerProcessIdentifier: NSNumber(value: 123),
          windowIdentifier: NSNumber(value: 456))),
      WindowListEntry(
        cgWindowInfo: makeCGWindowInfo(
          layer: NSNumber(value: 0.5),
          ownerProcessIdentifier: NSNumber(value: 123),
          windowIdentifier: NSNumber(value: 456))),
    ])
    let query = WindowSnapshotQuery(listProvider: provider)

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQueryFiltersExcludedOwnerBundleIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
        bundleIdentifier: "com.example.blocked"),
      filter: WindowSnapshotFilter(excludedOwnerBundleIdentifiers: ["com.example.blocked"])
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQueryAppliesExcludedOwnerBundleIdentifiersAfterIncludedOnes() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
        bundleIdentifier: "com.example.app"),
      filter: WindowSnapshotFilter(
        includedOwnerBundleIdentifiers: ["com.example.app"],
        excludedOwnerBundleIdentifiers: ["com.example.app"]
      )
    )

    XCTAssertTrue(try query.snapshots().isEmpty)
  }

  func testSnapshotQueryFiltersExcludedOwnerProcessIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 456),
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProvidingStub(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      filter: WindowSnapshotFilter(excludedOwnerProcessIdentifiers: [123])
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.map(\.ownerProcessIdentifier), [456])
  }

  func testSnapshotQueryFiltersExcludedWindowIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 111),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 456, windowIdentifier: 222),
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProvidingStub(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      filter: WindowSnapshotFilter(excludedWindowIdentifiers: [111])
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.map(\.windowIdentifier), [222])
  }

  func testSnapshotQueryFiltersIncludedOwnerBundleIdentifiers() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123)
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
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
      ownerBundleIdentifierProvider: WindowOwnerBundleIdentifierProvidingStub(
        bundleIdentifier: nil),
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
    XCTAssertEqual(provider.requests, [.window(222)])
  }

  func testSnapshotForWindowIdentifierForwardsCustomSingleWindowListOptions() throws {
    let provider = WindowListProviderSpy(entries: [])
    let query = WindowSnapshotQuery(
      makeSingleWindowRequest: { .window($0, options: [.optionAll]) },
      listProvider: provider
    )

    _ = try query.snapshot(for: 222)

    XCTAssertEqual(provider.requests, [.window(222, options: [.optionAll])])
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
      XCTAssertEqual(error as? WindowSnapshotQueryError, .windowListUnavailable)
    }
  }

  func testSnapshotForWindowIdentifierReturnsNilWhenReturnedEntryDoesNotMatchIdentifier() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 123, windowIdentifier: 111)
    ])

    let query = WindowSnapshotQuery(listProvider: provider)

    XCTAssertNil(try query.snapshot(for: 222))
  }

  func testSnapshotQueryReturnsTopmostMatchingWindowWhenLimited() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 1),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 2),
    ])
    let bundleIdentifierProvider = WindowOwnerBundleIdentifierProvidingStub(
      bundleIdentifier: "com.example.app")

    let query = WindowSnapshotQuery(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleIdentifierProvider,
      limit: .topmostMatchingWindow
    )

    let snapshots = try query.snapshots()
    XCTAssertEqual(snapshots.map(\.ownerProcessIdentifier), [1])
  }

  func testSnapshotQueryReturnsFirstMatchingTopmostWindowWhenLimited() throws {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(layer: 1, frame: .zero, ownerProcessIdentifier: 1),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 2),
      makeWindowEntry(layer: 0, frame: .zero, ownerProcessIdentifier: 3),
    ])

    let query = WindowSnapshotQuery(
      listProvider: provider,
      limit: .topmostMatchingWindow
    )

    XCTAssertEqual(try query.snapshots().map(\.ownerProcessIdentifier), [2])
  }

  func testSnapshotQueryThrowsWhenWindowListUnavailable() {
    let query = WindowSnapshotQuery(listProvider: WindowListProviderSpy(entries: nil))

    XCTAssertThrowsError(try query.snapshots()) { error in
      XCTAssertEqual(error as? WindowSnapshotQueryError, .windowListUnavailable)
    }
  }

  func testSnapshotQueryErrorIsEquatableAndSendable() {
    XCTAssertEqual(WindowSnapshotQueryError.windowListUnavailable, .windowListUnavailable)
    assertSendable(WindowSnapshotQueryError.windowListUnavailable)
  }
}

private func makeCGWindowInfo(
  layer: NSNumber = NSNumber(value: 0),
  ownerProcessIdentifier: NSNumber,
  windowIdentifier: NSNumber
) -> NSDictionary {
  [
    kCGWindowBounds as String: CGRect(x: 0, y: 0, width: 100, height: 100)
      .dictionaryRepresentation,
    kCGWindowLayer as String: layer,
    kCGWindowOwnerPID as String: ownerProcessIdentifier,
    kCGWindowNumber as String: windowIdentifier,
  ]
}

private func assertSendable<Value: Sendable>(_: Value) {}
