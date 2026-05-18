import XCTest

@testable import WindowKit

@MainActor
final class WindowListHitTestProviderTests: XCTestCase {
  func testListHitTestProviderReturnsWindowListUnavailableWhenProviderReturnsNil() {
    let provider = WindowListProviderSpy(entries: nil)
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.listUnavailable))
  }

  func testListHitTestProviderReadsDefaultOnScreenWindowList() {
    let provider = WindowListProviderSpy(entries: [])
    let hitTester = WindowListHitTestProvider(listProvider: provider)

    _ = hitTester.hitTest(at: CGPoint(x: 10, y: 10))

    XCTAssertEqual(provider.requests.map(\.windowIdentifier), [kCGNullWindowID])
    XCTAssertEqual(
      provider.requests.map(\.options),
      [[.optionOnScreenOnly, .excludeDesktopElements]]
    )
  }

  func testListHitTestProviderForwardsCustomWindowListOptions() {
    let provider = WindowListProviderSpy(entries: [])
    let hitTester = WindowListHitTestProvider(options: [.optionAll], listProvider: provider)

    _ = hitTester.hitTest(at: CGPoint(x: 10, y: 10))

    XCTAssertEqual(provider.requests.map(\.windowIdentifier), [kCGNullWindowID])
    XCTAssertEqual(provider.requests.map(\.options), [[.optionAll]])
  }

  func testListHitTestProviderReturnsNoMatchingWindowAtPointWhenNoFrameContainsPoint() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 50, height: 50), ownerProcessIdentifier: 111)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 100, y: 100)), .miss(.noMatchingWindowAtPoint))
  }

  func testListHitTestProviderStandardizesFrameBeforeHitTesting() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 100, y: 100, width: -100, height: -100),
        ownerProcessIdentifier: 111
      )
    ])
    let hitTester = WindowListHitTestProvider(listProvider: provider)

    XCTAssertEqual(
      hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.ownerProcessIdentifier,
      111
    )
  }

  func testListHitTestProviderReturnsNoWindowWhenOwnerProcessIdentifierMissing() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: nil)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testListHitTestProviderReturnsNoWindowWhenWindowIdentifierMissing() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 0, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 111,
        windowIdentifier: nil
      )
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testListHitTestProviderFiltersByLayer() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 1, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 111),
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222),
    ])
    let hitTester = WindowListHitTestProvider(allowedLayers: [0], listProvider: provider)
    switch hitTester.hitTest(at: CGPoint(x: 10, y: 10)) {
    case let .hit(window):
      XCTAssertEqual(window.ownerProcessIdentifier, 222)
      XCTAssertEqual(window.layer, 0)
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testListHitTestProviderReturnsFirstMatchingWindow() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 111),
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222),
    ])
    let hitTester = WindowListHitTestProvider(listProvider: provider)

    switch hitTester.hitTest(at: CGPoint(x: 10, y: 10)) {
    case let .hit(window):
      XCTAssertEqual(window.ownerProcessIdentifier, 111)
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testListHitTestProviderAppliesPointTransform() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      pointTransform: { CGPoint(x: $0.x - 20, y: $0.y - 20) },
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )

    switch hitTester.hitTest(at: CGPoint(x: 110, y: 110)) {
    case let .hit(window):
      XCTAssertEqual(window.ownerProcessIdentifier, 222)
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testListHitTestProviderIncludesOwnerNameAndTitle() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    switch hitTester.hitTest(at: CGPoint(x: 10, y: 10)) {
    case let .hit(window):
      XCTAssertEqual(window.ownerName, "ExampleApp")
      XCTAssertEqual(window.ownerBundleIdentifier, "com.example.app")
      XCTAssertEqual(window.title, "Main")
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testListHitTestProviderIncludesWindowIdentifierWhenPresent() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    switch hitTester.hitTest(at: CGPoint(x: 10, y: 10)) {
    case let .hit(window):
      XCTAssertEqual(window.windowIdentifier, 12345)
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testListHitTestProviderFiltersExcludedOwnerBundleIdentifiers() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider(
        bundleIdentifier: "com.example.blocked"),
      filter: WindowSnapshotFilter(excludedOwnerBundleIdentifiers: ["com.example.blocked"])
    )

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testListHitTestProviderFiltersIncludedOwnerBundleIdentifiers() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider(
        bundleIdentifier: "com.example.allowed"),
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.allowed"])
    )

    XCTAssertEqual(
      hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.ownerProcessIdentifier, 222)
  }

  func testListHitTestProviderFiltersIncludedWindowIdentifiers() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 111,
        windowIdentifier: 111),
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 222,
        windowIdentifier: 222),
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      filter: WindowSnapshotFilter(includedWindowIdentifiers: [222])
    )

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.windowIdentifier, 222)
  }

  func testListHitTestProviderExcludesMinimizedWhenEnabled() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222,
        isMinimized: true)
    ])
    let hitTester = WindowListHitTestProvider(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider(),
      filter: WindowSnapshotFilter(excludesMinimizedWindows: true)
    )

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testListHitTestProviderIncludesMinimizedMetadata() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 0, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 222,
        isMinimized: true
      )
    ])
    let hitTester = WindowListHitTestProvider(listProvider: provider)

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.isMinimized, true)
  }

  func testListHitTestProviderIsSendable() {
    let hitTester = WindowListHitTestProvider(listProvider: WindowListProviderSpy(entries: []))

    assertSendable(hitTester)
  }

  private func makeBundleIdentifierProvider(
    bundleIdentifier: String = "com.example.app"
  ) -> WindowOwnerBundleIdentifierProviderStub {
    WindowOwnerBundleIdentifierProviderStub(bundleIdentifier: bundleIdentifier)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
