import os
import WindowKit
import XCTest

@testable import WindowKitAppKit

@MainActor
final class WindowHitTesterTests: XCTestCase {
  func testHitTesterSkipsBundleLookupForWindowsOutsidePoint() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 200, y: 200, width: 100, height: 100),
        ownerProcessIdentifier: 111
      )
    ])
    let bundleProvider = CountingBundleIdentifierProvider()
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: bundleProvider
    )

    XCTAssertEqual(
      hitTester.hitTest(at: CGPoint(x: 10, y: 10)),
      .miss(.noMatchingWindowAtPoint)
    )
    XCTAssertEqual(bundleProvider.callCount, 0)
  }

  func testHitTesterReturnsWindowListUnavailableWhenProviderReturnsNil() {
    let provider = WindowListProviderSpy(entries: nil)
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.sourceUnavailable))
  }

  func testHitTesterDoesNotTransformPointWhenWindowListUnavailable() {
    let transformCount = OSAllocatedUnfairLock(initialState: 0)
    let provider = WindowListProviderSpy(entries: nil)
    let hitTester = WindowHitTester(
      listProvider: provider,
      pointTransform: { point in
        transformCount.withLock { $0 += 1 }
        return point
      },
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.sourceUnavailable))
    XCTAssertEqual(transformCount.withLock { $0 }, 0)
  }

  func testHitTesterReadsDefaultOnScreenWindowList() {
    let provider = WindowListProviderSpy(entries: [])
    let hitTester = WindowHitTester(listProvider: provider)

    _ = hitTester.hitTest(at: CGPoint(x: 10, y: 10))

    XCTAssertEqual(provider.requests, [.onScreenWindows])
  }

  func testHitTesterForwardsCustomWindowListOptions() {
    let provider = WindowListProviderSpy(entries: [])
    let hitTester = WindowHitTester(
      request: .windows(options: [.optionAll]),
      listProvider: provider
    )

    _ = hitTester.hitTest(at: CGPoint(x: 10, y: 10))

    XCTAssertEqual(provider.requests, [.windows(options: [.optionAll])])
  }

  func testHitTesterReturnsNoMatchingWindowAtPointWhenNoFrameContainsPoint() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 50, height: 50), ownerProcessIdentifier: 111)
    ])
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 100, y: 100)), .miss(.noMatchingWindowAtPoint))
  }

  func testHitTesterStandardizesFrameBeforeHitTesting() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 100, y: 100, width: -100, height: -100),
        ownerProcessIdentifier: 111
      )
    ])
    let hitTester = WindowHitTester(listProvider: provider)

    XCTAssertEqual(
      hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.ownerProcessIdentifier,
      111
    )
  }

  func testHitTesterReturnsNoWindowWhenOwnerProcessIdentifierMissing() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: nil)
    ])
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testHitTesterReturnsNoWindowWhenWindowIdentifierMissing() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0,
        frame: CGRect(x: 0, y: 0, width: 100, height: 100),
        ownerProcessIdentifier: 111,
        windowIdentifier: nil
      )
    ])
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider()
    )
    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testHitTesterFiltersByLayer() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 1, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 111),
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222),
    ])
    let hitTester = WindowHitTester(listProvider: provider)
    switch hitTester.hitTest(at: CGPoint(x: 10, y: 10)) {
    case let .hit(window):
      XCTAssertEqual(window.ownerProcessIdentifier, 222)
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testHitTesterReturnsFirstMatchingWindow() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 111),
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222),
    ])
    let hitTester = WindowHitTester(listProvider: provider)

    switch hitTester.hitTest(at: CGPoint(x: 10, y: 10)) {
    case let .hit(window):
      XCTAssertEqual(window.ownerProcessIdentifier, 111)
    case let .miss(reason):
      XCTFail("Expected hit, got miss(\(reason))")
    }
  }

  func testHitTesterAppliesPointTransform() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowHitTester(
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

  func testHitTesterIncludesOwnerNameAndTitle() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowHitTester(
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

  func testHitTesterIncludesWindowIdentifierWhenPresent() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowHitTester(
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

  func testHitTesterFiltersExcludedOwnerBundleIdentifiers() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider(
        bundleIdentifier: "com.example.blocked"),
      filter: WindowSnapshotFilter(excludedOwnerBundleIdentifiers: ["com.example.blocked"])
    )

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)), .miss(.noMatchingWindowAtPoint))
  }

  func testHitTesterFiltersIncludedOwnerBundleIdentifiers() {
    let provider = WindowListProviderSpy(entries: [
      makeWindowEntry(
        layer: 0, frame: CGRect(x: 0, y: 0, width: 100, height: 100), ownerProcessIdentifier: 222)
    ])
    let hitTester = WindowHitTester(
      listProvider: provider,
      ownerBundleIdentifierProvider: makeBundleIdentifierProvider(
        bundleIdentifier: "com.example.allowed"),
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.allowed"])
    )

    XCTAssertEqual(
      hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.ownerProcessIdentifier, 222)
  }

  func testHitTesterFiltersIncludedWindowIdentifiers() {
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
    let hitTester = WindowHitTester(
      listProvider: provider,
      filter: WindowSnapshotFilter(includedWindowIdentifiers: [222])
    )

    XCTAssertEqual(hitTester.hitTest(at: CGPoint(x: 10, y: 10)).snapshot?.windowIdentifier, 222)
  }

  func testHitTesterIsSendable() {
    let hitTester = WindowHitTester(listProvider: WindowListProviderSpy(entries: []))

    assertSendable(hitTester)
  }

  private func makeBundleIdentifierProvider(
    bundleIdentifier: String = "com.example.app"
  ) -> WindowOwnerBundleIdentifierProvidingStub {
    WindowOwnerBundleIdentifierProvidingStub(bundleIdentifier: bundleIdentifier)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}

private struct CountingBundleIdentifierProvider: WindowOwnerBundleIdentifierProviding {
  private let callCountStorage = OSAllocatedUnfairLock(initialState: 0)

  var callCount: Int {
    callCountStorage.withLock { $0 }
  }

  func bundleIdentifier(forProcessIdentifier _: pid_t) -> String? {
    callCountStorage.withLock { $0 += 1 }
    return "com.example.app"
  }
}
