import CoreGraphics
import os
import WindowKit
import WindowKitAppKit
import XCTest

final class WindowPlacerTests: XCTestCase {
  @MainActor
  func testPlaceUsesVisibleFrameForTarget() throws {
    let target = WindowTarget.windowIdentifier(1)
    let frameController = WindowFrameControllerFake(frames: [
      (target, CGRect(x: 10, y: 10, width: 100, height: 100))
    ])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 20, width: 800, height: 560),
        isMain: true
      )
    ])
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: screens
    )

    try controller.place(
      .grid(columns: 2, rows: 1, column: 1, row: 0, columnSpan: 1, rowSpan: 1), for: target)
    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 400, y: 20, width: 400, height: 560))
  }

  @MainActor
  func testMoveToAdjacentScreenPreservesRelativePosition() throws {
    let target = WindowTarget.windowIdentifier(2)
    let frameController = WindowFrameControllerFake(frames: [
      (target, CGRect(x: 100, y: 50, width: 200, height: 100))
    ])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 600)),
      .init(
        frame: CGRect(x: 800, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 800, y: 0, width: 800, height: 600)
      ),
    ])

    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: screens
    )

    try controller.moveToAdjacentScreen(.next, for: target, preservingRelativePosition: true)
    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 900, y: 50, width: 200, height: 100))
  }

  @MainActor
  func testPlaceUsesFullScreenBoundsWhenRequested() throws {
    let target = WindowTarget.windowIdentifier(3)
    let frameController = WindowFrameControllerFake(frames: [
      (target, CGRect(x: 10, y: 10, width: 100, height: 100))
    ])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 20, width: 800, height: 560),
        isMain: true
      )
    ])
    let controller = WindowPlacer(frameController: frameController, screenProvider: screens)

    try controller.place(
      .grid(columns: 2, rows: 1, column: 0, row: 0, columnSpan: 1, rowSpan: 1),
      for: target,
      area: .full
    )

    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 0, y: 0, width: 400, height: 600))
  }

  @MainActor
  func testPlaceThrowsBeforeReadingWindowFrameWhenNoScreensAreAvailable() throws {
    let target = WindowTarget.windowIdentifier(42)
    let frameController = WindowFrameControllerFake()
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: WindowScreenProviderStub(screens: [])
    )

    XCTAssertThrowsError(
      try controller.place(.fill, for: target)
    ) { error in
      XCTAssertEqual(error as? WindowPlacerError, .screenNotFound(.containingWindow))
    }
    XCTAssertEqual(frameController.frameReadCount, 0)
  }

  @MainActor
  func testPlaceDoesNotReadWindowFrameForExplicitScreenTargets() throws {
    let target = WindowTarget.windowIdentifier(43)
    let frameController = WindowFrameControllerFake(frames: [
      (target, CGRect(x: 0, y: 0, width: 10, height: 10))
    ])
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: WindowScreenProviderStub(screens: [
        .init(
          displayIdentifier: 1,
          frame: CGRect(x: 0, y: 0, width: 800, height: 600),
          visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 600),
          isMain: true
        )
      ])
    )

    try controller.place(.fill, for: target, screen: .displayIdentifier(1))

    XCTAssertEqual(frameController.frameReadCount, 0)
    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 0, y: 0, width: 800, height: 600))
  }

  @MainActor
  func testPlaceThrowsWhenStrictScreenTargetDoesNotMatch() throws {
    let target = WindowTarget.windowIdentifier(6)
    let original = CGRect(x: 10, y: 10, width: 100, height: 100)
    let frameController = WindowFrameControllerFake(frames: [(target, original)])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        displayIdentifier: 1,
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 600)
      )
    ])
    let controller = WindowPlacer(frameController: frameController, screenProvider: screens)

    XCTAssertThrowsError(
      try controller.place(
        .fill,
        for: target,
        screen: .displayIdentifier(99),
        screenFallback: .none
      )
    ) { error in
      XCTAssertEqual(error as? WindowPlacerError, .screenNotFound(.displayIdentifier(99)))
    }
    XCTAssertEqual(try frameController.frame(for: target), original)
  }

  @MainActor
  func testMoveToAdjacentScreenCanCenterInsteadOfPreservingRelativePosition() throws {
    let target = WindowTarget.windowIdentifier(5)
    let frameController = WindowFrameControllerFake(frames: [
      (target, CGRect(x: 100, y: 50, width: 200, height: 100))
    ])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 600)),
      .init(
        frame: CGRect(x: 800, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 800, y: 0, width: 800, height: 600)
      ),
    ])

    let controller = WindowPlacer(frameController: frameController, screenProvider: screens)

    try controller.moveToAdjacentScreen(.next, for: target, preservingRelativePosition: false)

    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 1100, y: 250, width: 200, height: 100))
  }

  @MainActor
  func testMoveToAdjacentScreenThrowsWhenStrictCurrentScreenDoesNotMatch() throws {
    let target = WindowTarget.windowIdentifier(7)
    let original = CGRect(x: 900, y: 900, width: 100, height: 100)
    let frameController = WindowFrameControllerFake(frames: [(target, original)])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 600)
      )
    ])
    let controller = WindowPlacer(frameController: frameController, screenProvider: screens)

    XCTAssertThrowsError(
      try controller.moveToAdjacentScreen(.next, for: target, screenFallback: .none)
    ) { error in
      XCTAssertEqual(error as? WindowPlacerError, .screenNotFound(.containingWindow))
    }
    XCTAssertEqual(try frameController.frame(for: target), original)
  }

  @MainActor
  func testMoveToAdjacentScreenFallsBackToFirstScreenWhenCurrentScreenDoesNotMatch() throws {
    let target = WindowTarget.windowIdentifier(10)
    let frameController = WindowFrameControllerFake(frames: [
      (target, CGRect(x: 900, y: 900, width: 100, height: 100))
    ])
    let screens = WindowScreenProviderStub(screens: [
      .init(
        frame: CGRect(x: 0, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 600)),
      .init(
        frame: CGRect(x: 800, y: 0, width: 800, height: 600),
        visibleFrame: CGRect(x: 800, y: 0, width: 800, height: 600)
      ),
    ])
    let controller = WindowPlacer(frameController: frameController, screenProvider: screens)

    try controller.moveToAdjacentScreen(.next, for: target, preservingRelativePosition: false)

    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 1150, y: 250, width: 100, height: 100))
  }

  @MainActor
  func testMoveToAdjacentScreenThrowsWhenNoScreensAreAvailable() throws {
    let target = WindowTarget.windowIdentifier(8)
    let original = CGRect(x: 10, y: 10, width: 100, height: 100)
    let frameController = WindowFrameControllerFake(frames: [(target, original)])
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: WindowScreenProviderStub(screens: [])
    )

    XCTAssertThrowsError(
      try controller.moveToAdjacentScreen(.next, for: target)
    ) { error in
      XCTAssertEqual(error as? WindowPlacerError, .screenNotFound(.containingWindow))
    }
    XCTAssertEqual(try frameController.frame(for: target), original)
  }

  @MainActor
  func testMoveToAdjacentScreenThrowsBeforeReadingWindowFrameWhenNoScreensAreAvailable()
    throws
  {
    let target = WindowTarget.windowIdentifier(81)
    let frameController = WindowFrameControllerFake()
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: WindowScreenProviderStub(screens: [])
    )

    XCTAssertThrowsError(
      try controller.moveToAdjacentScreen(.next, for: target)
    ) { error in
      XCTAssertEqual(error as? WindowPlacerError, .screenNotFound(.containingWindow))
    }
    XCTAssertEqual(frameController.frameReadCount, 0)
  }

}

@MainActor
private final class WindowFrameControllerFake: WindowFrameControlling {
  private let framesStorage: OSAllocatedUnfairLock<[(WindowTarget, CGRect)]>
  private let frameReadCountStorage = OSAllocatedUnfairLock(initialState: 0)

  var frameReadCount: Int {
    frameReadCountStorage.withLock { $0 }
  }

  init(frames: [(WindowTarget, CGRect)] = []) {
    framesStorage = OSAllocatedUnfairLock(initialState: frames)
  }

  @MainActor
  func frame(for target: WindowTarget) throws -> CGRect {
    frameReadCountStorage.withLock { $0 += 1 }
    let frame = framesStorage.withLock { frames in
      frames.first(where: { $0.0 == target })?.1
    }
    guard let frame else {
      throw WindowFrameControllerFakeError.missingFrame(target)
    }
    return frame
  }

  @MainActor
  func setFrame(_ frame: CGRect, for target: WindowTarget) throws {
    let didUpdate = framesStorage.withLock { frames in
      guard let index = frames.firstIndex(where: { $0.0 == target }) else {
        return false
      }
      frames[index].1 = frame
      return true
    }
    guard didUpdate else {
      throw WindowFrameControllerFakeError.missingFrame(target)
    }
  }
}

private enum WindowFrameControllerFakeError: Error {
  case missingFrame(WindowTarget)
}

private struct WindowScreenProviderStub: WindowScreenProviding {
  private let storedScreens: [WindowScreen]

  init(screens: [WindowScreen]) {
    storedScreens = screens
  }

  @MainActor
  func screens() -> [WindowScreen] {
    storedScreens
  }
}
