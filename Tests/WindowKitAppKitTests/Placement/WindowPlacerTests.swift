import CoreGraphics
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

    try controller.place(.rightHalf, for: target)
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

    try controller.place(.leftHalf, for: target, area: .full)

    XCTAssertEqual(
      try frameController.frame(for: target), CGRect(x: 0, y: 0, width: 400, height: 600))
  }

  @MainActor
  func testPlaceReturnsWithoutMutationWhenNoScreensAreAvailable() throws {
    let target = WindowTarget.windowIdentifier(4)
    let original = CGRect(x: 900, y: 900, width: 100, height: 100)
    let frameController = WindowFrameControllerFake(frames: [(target, original)])
    let screens = WindowScreenProviderStub(screens: [])
    let controller = WindowPlacer(frameController: frameController, screenProvider: screens)

    try controller.place(.fill, for: target)

    XCTAssertEqual(try frameController.frame(for: target), original)
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
        allowsScreenFallback: false
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
      try controller.moveToAdjacentScreen(.next, for: target, allowsScreenFallback: false)
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
  func testMoveToAdjacentScreenThrowsWhenNoScreensAreAvailableInStrictMode() throws {
    let target = WindowTarget.windowIdentifier(8)
    let original = CGRect(x: 10, y: 10, width: 100, height: 100)
    let frameController = WindowFrameControllerFake(frames: [(target, original)])
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: WindowScreenProviderStub(screens: [])
    )

    XCTAssertThrowsError(
      try controller.moveToAdjacentScreen(.next, for: target, allowsScreenFallback: false)
    ) { error in
      XCTAssertEqual(error as? WindowPlacerError, .screenNotFound(.containingWindow))
    }
    XCTAssertEqual(try frameController.frame(for: target), original)
  }

  @MainActor
  func testMoveToAdjacentScreenReturnsWithoutMutationWhenNoScreensAreAvailable() throws {
    let target = WindowTarget.windowIdentifier(9)
    let original = CGRect(x: 10, y: 10, width: 100, height: 100)
    let frameController = WindowFrameControllerFake(frames: [(target, original)])
    let controller = WindowPlacer(
      frameController: frameController,
      screenProvider: WindowScreenProviderStub(screens: [])
    )

    try controller.moveToAdjacentScreen(.next, for: target)

    XCTAssertEqual(try frameController.frame(for: target), original)
  }
}

@MainActor
private final class WindowFrameControllerFake: WindowFrameControlling, @unchecked Sendable {
  private var frames: [(WindowTarget, CGRect)]

  init(frames: [(WindowTarget, CGRect)] = []) {
    self.frames = frames
  }

  @MainActor
  func frame(for target: WindowTarget) throws -> CGRect {
    guard let frame = frames.first(where: { $0.0 == target })?.1 else {
      throw WindowFrameControllerFakeError.missingFrame(target)
    }
    return frame
  }

  @MainActor
  func setFrame(_ frame: CGRect, for target: WindowTarget) throws {
    guard let index = frames.firstIndex(where: { $0.0 == target }) else {
      throw WindowFrameControllerFakeError.missingFrame(target)
    }
    frames[index].1 = frame
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
