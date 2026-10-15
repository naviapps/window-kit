import CoreGraphics
import WindowKit
import XCTest

@testable import WindowKitAppKit

@MainActor
final class WindowPlacerCoordinatesTests: XCTestCase {
  func testFillKeepsMenuBarAndDockOffsetsInAccessibilityCoordinates() throws {
    let frameController = AccessibilityFrameFixture(
      frame: CGRect(x: 100, y: 100, width: 200, height: 100))
    let placer = makePlacer(frameController: frameController)

    try placer.place(.fill, for: .focused, screen: .displayIdentifier(1))

    XCTAssertEqual(frameController.currentFrame, CGRect(x: 0, y: 25, width: 1440, height: 825))
  }

  func testFirstGridRowIsAtTheTopForLiveAccessibilityPlacement() throws {
    let frameController = AccessibilityFrameFixture(frame: .zero)
    let placer = makePlacer(frameController: frameController)

    try placer.place(
      .grid(columns: 1, rows: 2, column: 0, row: 0, columnSpan: 1, rowSpan: 1),
      for: .focused,
      screen: .displayIdentifier(1)
    )

    XCTAssertEqual(frameController.currentFrame, CGRect(x: 0, y: 25, width: 1440, height: 412.5))
  }

  func testContainingWindowResolvesDisplayAbovePrimaryWithNegativeAccessibilityY() throws {
    let frameController = AccessibilityFrameFixture(
      frame: CGRect(x: 100, y: -800, width: 200, height: 100))
    let placer = makePlacer(frameController: frameController)

    try placer.place(.fill, for: .focused, screenFallback: .none)

    XCTAssertEqual(frameController.currentFrame, CGRect(x: 0, y: -900, width: 1440, height: 900))
  }

  func testMoveToDisplayAbovePrimaryCentersInAccessibilityCoordinates() throws {
    let frameController = AccessibilityFrameFixture(
      frame: CGRect(x: 100, y: 100, width: 200, height: 100))
    let placer = makePlacer(frameController: frameController)

    try placer.moveToAdjacentScreen(
      .next, for: .focused, preservingRelativePosition: false, screenFallback: .none)

    XCTAssertEqual(frameController.currentFrame, CGRect(x: 620, y: -500, width: 200, height: 100))
  }

  func testPointTargetResolvesDisplayBelowPrimaryInAccessibilityCoordinates() throws {
    let frameController = AccessibilityFrameFixture(frame: .zero)
    let placer = makePlacer(frameController: frameController, secondaryY: -900)

    try placer.place(
      .fill, for: .focused, screen: .point(CGPoint(x: 100, y: 1000)), screenFallback: .none)

    XCTAssertEqual(frameController.currentFrame, CGRect(x: 0, y: 900, width: 1440, height: 900))
  }

  private func makePlacer(frameController: AccessibilityFrameFixture, secondaryY: CGFloat = 900)
    -> WindowPlacer
  {
    let appKitScreens = AppKitScreenFixture(secondaryY: secondaryY)
    let accessibilityScreens = AccessibilityScreenProvider(
      appKitScreenProvider: appKitScreens
    )
    return WindowPlacer(frameController: frameController, screenProvider: accessibilityScreens)
  }
}

@MainActor
private final class AccessibilityFrameFixture: WindowFrameControlling {
  var currentFrame: CGRect

  init(frame: CGRect) {
    currentFrame = frame
  }

  func frame(for target: WindowTarget) throws -> CGRect {
    currentFrame
  }

  func setFrame(_ frame: CGRect, for target: WindowTarget) throws {
    currentFrame = frame
  }
}

private struct AppKitScreenFixture: WindowScreenProviding {
  let secondaryY: CGFloat

  @MainActor
  func screens() -> [WindowScreen] {
    [
      WindowScreen(
        displayIdentifier: 1,
        frame: CGRect(x: 0, y: 0, width: 1440, height: 900),
        visibleFrame: CGRect(x: 0, y: 50, width: 1440, height: 825)
      ),
      WindowScreen(
        displayIdentifier: 2,
        frame: CGRect(x: 0, y: secondaryY, width: 1440, height: 900),
        visibleFrame: CGRect(x: 0, y: secondaryY, width: 1440, height: 900),
        isMain: true
      ),
    ]
  }
}
