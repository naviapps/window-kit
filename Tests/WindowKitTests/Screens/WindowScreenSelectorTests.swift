import CoreGraphics
import WindowKit
import XCTest

final class WindowScreenSelectorTests: XCTestCase {
  func testOrderedScreensPreservesInputOrderWhenSortKeysAreEqual() {
    let first = WindowScreen(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100),
      visibleFrame: CGRect(x: 0, y: 10, width: 100, height: 90),
      isMain: true
    )
    let second = WindowScreen(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100),
      visibleFrame: CGRect(x: 0, y: 20, width: 100, height: 80)
    )

    XCTAssertEqual(WindowScreenSelector.orderedScreens(from: [second, first]), [second, first])
  }

  func testOrderedScreensPreservesInputOrderForDuplicateDisplayIdentifiers() {
    let first = WindowScreen(
      displayIdentifier: 7,
      frame: CGRect(x: 0, y: 0, width: 100, height: 100),
      visibleFrame: CGRect(x: 0, y: 10, width: 100, height: 90),
      isMain: true
    )
    let second = WindowScreen(
      displayIdentifier: 7,
      frame: CGRect(x: 0, y: 0, width: 100, height: 100),
      visibleFrame: CGRect(x: 0, y: 20, width: 100, height: 80)
    )

    XCTAssertEqual(WindowScreenSelector.orderedScreens(from: [second, first]), [second, first])
  }

  func testOrderedScreensSortsByMinXThenMinY() {
    let screens = [
      makeScreen(CGRect(x: 100, y: 10, width: 100, height: 100)),
      makeScreen(CGRect(x: 0, y: 20, width: 100, height: 100)),
      makeScreen(CGRect(x: 0, y: 0, width: 100, height: 100)),
    ]

    XCTAssertEqual(
      WindowScreenSelector.orderedScreens(from: screens).map(\.frame.origin),
      [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 0, y: 20),
        CGPoint(x: 100, y: 10),
      ]
    )
  }

  func testScreenResolvesTargets() {
    let primary = makeScreen(
      CGRect(x: 0, y: 0, width: 200, height: 200),
      displayIdentifier: 1,
      isMain: true
    )
    let secondary = makeScreen(
      CGRect(x: 200, y: 0, width: 200, height: 200),
      displayIdentifier: 2
    )
    let screens = [primary, secondary]

    XCTAssertEqual(
      WindowScreenSelector.screen(for: .main, windowFrame: primary.frame, in: screens),
      primary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .containingWindow,
        windowFrame: secondary.frame,
        in: screens
      ),
      secondary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .displayIdentifier(2),
        windowFrame: primary.frame,
        in: screens
      ),
      secondary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .point(CGPoint(x: 210, y: 10)),
        windowFrame: primary.frame,
        in: screens
      ),
      secondary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(for: .orderedIndex(1), windowFrame: primary.frame, in: screens),
      secondary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(for: .orderedIndex(9), windowFrame: primary.frame, in: screens),
      primary
    )
  }

  func testScreenCanDisableFirstScreenFallback() {
    let primary = makeScreen(
      CGRect(x: 0, y: 0, width: 200, height: 200),
      displayIdentifier: 1
    )
    let screens = [primary]

    XCTAssertNil(
      WindowScreenSelector.screen(
        for: .main,
        windowFrame: primary.frame,
        in: screens,
        fallback: .none
      )
    )
    XCTAssertNil(
      WindowScreenSelector.screen(
        for: .containingWindow,
        windowFrame: CGRect(x: 500, y: 500, width: 100, height: 100),
        in: screens,
        fallback: .none
      )
    )
    XCTAssertNil(
      WindowScreenSelector.screen(
        for: .point(CGPoint(x: 500, y: 500)),
        windowFrame: primary.frame,
        in: screens,
        fallback: .none
      )
    )
    XCTAssertNil(
      WindowScreenSelector.screen(
        for: .displayIdentifier(9),
        windowFrame: primary.frame,
        in: screens,
        fallback: .none
      )
    )
    XCTAssertNil(
      WindowScreenSelector.screen(
        for: .orderedIndex(9),
        windowFrame: primary.frame,
        in: screens,
        fallback: .none
      )
    )
  }

  func testScreenFallsBackToFirstScreenByDefault() {
    let primary = makeScreen(
      CGRect(x: 0, y: 0, width: 200, height: 200),
      displayIdentifier: 1
    )
    let screens = [primary]

    XCTAssertEqual(
      WindowScreenSelector.screen(for: .main, windowFrame: primary.frame, in: screens),
      primary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .containingWindow,
        windowFrame: CGRect(x: 500, y: 500, width: 100, height: 100),
        in: screens
      ),
      primary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .point(CGPoint(x: 500, y: 500)),
        windowFrame: primary.frame,
        in: screens
      ),
      primary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .displayIdentifier(9),
        windowFrame: primary.frame,
        in: screens
      ),
      primary
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .orderedIndex(9),
        windowFrame: primary.frame,
        in: screens
      ),
      primary
    )
  }

  func testScreenSelectionOrdersUnorderedInputBeforeIndexAndFallbackSelection() {
    let right = makeScreen(CGRect(x: 300, y: 0, width: 200, height: 200))
    let left = makeScreen(CGRect(x: 0, y: 0, width: 200, height: 200))

    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .orderedIndex(0),
        windowFrame: right.frame,
        in: [right, left],
        fallback: .none
      ),
      left
    )
    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .displayIdentifier(99),
        windowFrame: right.frame,
        in: [right, left]
      ),
      left
    )
  }

  func testScreenReturnsNilForEmptyScreens() {
    XCTAssertNil(
      WindowScreenSelector.screen(
        for: .main,
        windowFrame: .zero,
        in: []
      )
    )
  }

  func testIndexContainingPoint() {
    let screens = [
      makeScreen(CGRect(x: 0, y: 0, width: 200, height: 200)),
      makeScreen(CGRect(x: 200, y: 0, width: 200, height: 200)),
    ]

    XCTAssertEqual(WindowScreenSelector.index(containing: CGPoint(x: 210, y: 10), in: screens), 1)
    XCTAssertNil(WindowScreenSelector.index(containing: CGPoint(x: 500, y: 500), in: screens))
  }

  func testIndexContainingPointReturnsOrderedScreenIndex() {
    let right = makeScreen(CGRect(x: 300, y: 0, width: 200, height: 200))
    let left = makeScreen(CGRect(x: 0, y: 0, width: 200, height: 200))

    XCTAssertEqual(
      WindowScreenSelector.index(containing: CGPoint(x: 350, y: 10), in: [right, left]),
      1
    )
  }

  func testOrderedScreensUsesStandardizedScreenFrames() {
    let screens = [
      makeScreen(
        CGRect(x: 200, y: 0, width: -100, height: 100),
        visibleFrame: CGRect(x: 100, y: 0, width: 100, height: 100)
      ),
      makeScreen(CGRect(x: 0, y: 0, width: 100, height: 100)),
    ]

    XCTAssertEqual(
      WindowScreenSelector.orderedScreens(from: screens).map(\.frame.origin),
      [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 100, y: 0),
      ]
    )
  }

  func testOrderedScreensUsesFrameSizeAndDisplayIdentifierAsTieBreakers() {
    let screens = [
      makeScreen(CGRect(x: 0, y: 0, width: 200, height: 100), displayIdentifier: 3),
      makeScreen(CGRect(x: 0, y: 0, width: 100, height: 200), displayIdentifier: 2),
      makeScreen(CGRect(x: 0, y: 0, width: 100, height: 100), displayIdentifier: 1),
    ]

    XCTAssertEqual(
      WindowScreenSelector.orderedScreens(from: screens).compactMap(\.displayIdentifier),
      [1, 2, 3]
    )
  }

  func testOrderedScreensSortsDisplayIdentifiersBeforeMissingIdentifiers() {
    let screens = [
      makeScreen(CGRect(x: 0, y: 0, width: 100, height: 100)),
      makeScreen(CGRect(x: 0, y: 0, width: 100, height: 100), displayIdentifier: 1),
    ]

    XCTAssertEqual(WindowScreenSelector.orderedScreens(from: screens).first?.displayIdentifier, 1)
  }

  func testScreenStandardizesFramesBeforeContainmentChecks() {
    let screen = makeScreen(
      CGRect(x: 200, y: 0, width: -200, height: 200),
      visibleFrame: CGRect(x: 0, y: 0, width: 200, height: 200)
    )

    XCTAssertEqual(
      WindowScreenSelector.screen(
        for: .containingWindow,
        windowFrame: CGRect(x: 40, y: 40, width: 20, height: 20),
        in: [screen],
        fallback: .none
      ),
      screen
    )
    XCTAssertEqual(
      WindowScreenSelector.index(containing: CGPoint(x: 50, y: 50), in: [screen]),
      0
    )
  }

  func testAdjacentIndexCyclesForwardAndBackward() {
    XCTAssertEqual(WindowScreenSelector.adjacentIndex(from: 0, direction: .next, screenCount: 3), 1)
    XCTAssertEqual(WindowScreenSelector.adjacentIndex(from: 2, direction: .next, screenCount: 3), 0)
    XCTAssertEqual(
      WindowScreenSelector.adjacentIndex(from: 0, direction: .previous, screenCount: 3),
      2
    )
  }

  func testAdjacentIndexNormalizesOutOfRangeIndexes() {
    XCTAssertEqual(WindowScreenSelector.adjacentIndex(from: 5, direction: .next, screenCount: 3), 0)
    XCTAssertEqual(
      WindowScreenSelector.adjacentIndex(from: -5, direction: .previous, screenCount: 3),
      0
    )
    XCTAssertNil(WindowScreenSelector.adjacentIndex(from: 0, direction: .next, screenCount: 0))
    XCTAssertNil(WindowScreenSelector.adjacentIndex(from: 0, direction: .next, screenCount: -1))
  }

  func testAdjacentIndexAvoidsOverflowAtIntegerLimits() {
    XCTAssertEqual(
      WindowScreenSelector.adjacentIndex(
        from: Int.max - 1,
        direction: .next,
        screenCount: Int.max
      ),
      0
    )
    XCTAssertEqual(
      WindowScreenSelector.adjacentIndex(
        from: Int.min,
        direction: .previous,
        screenCount: Int.max
      ),
      Int.max - 2
    )
  }

  private func makeScreen(
    _ frame: CGRect,
    displayIdentifier: CGDirectDisplayID? = nil,
    visibleFrame: CGRect? = nil,
    isMain: Bool = false
  ) -> WindowScreen {
    WindowScreen(
      displayIdentifier: displayIdentifier,
      frame: frame,
      visibleFrame: visibleFrame ?? frame,
      isMain: isMain
    )
  }
}
