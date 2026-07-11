import CoreGraphics
import WindowKit
import XCTest

final class WindowScreenTests: XCTestCase {
  func testInitSanitizesNonFiniteFrames() {
    let screen = WindowScreen(
      frame: CGRect(x: .infinity, y: .nan, width: .infinity, height: -.infinity),
      visibleFrame: CGRect(x: .nan, y: .infinity, width: -.infinity, height: .nan)
    )

    XCTAssertEqual(screen.frame, .zero)
    XCTAssertEqual(screen.visibleFrame, .zero)
  }

  private let fullFrame = CGRect(x: 0, y: 0, width: 800, height: 600)
  private let visibleFrame = CGRect(x: 0, y: 24, width: 800, height: 576)

  func testInitUsesDefaultMetadata() {
    let screen = makeScreen()

    XCTAssertNil(screen.displayIdentifier)
    XCTAssertFalse(screen.isMain)
  }

  func testInitStoresMetadata() {
    let screen = makeScreen(displayIdentifier: 123, isMain: true)

    XCTAssertEqual(screen.displayIdentifier, 123)
    XCTAssertTrue(screen.isMain)
  }

  func testFrameReturnsRequestedScreenArea() {
    let screen = makeScreen()

    XCTAssertEqual(screen.frame(for: .full), fullFrame)
    XCTAssertEqual(screen.frame(for: .visible), visibleFrame)
  }

  func testInitStandardizesFrames() {
    let screen = WindowScreen(
      frame: CGRect(x: 800, y: 600, width: -800, height: -600),
      visibleFrame: CGRect(x: 800, y: 600, width: -780, height: -560)
    )

    XCTAssertEqual(screen.frame.origin, CGPoint(x: 0, y: 0))
    XCTAssertEqual(screen.frame.size, CGSize(width: 800, height: 600))
    XCTAssertEqual(screen.visibleFrame.origin, CGPoint(x: 20, y: 40))
    XCTAssertEqual(screen.visibleFrame.size, CGSize(width: 780, height: 560))
    XCTAssertEqual(screen.frame(for: .full).origin, CGPoint(x: 0, y: 0))
    XCTAssertEqual(screen.frame(for: .visible).origin, CGPoint(x: 20, y: 40))
  }

  func testWindowScreenValueConformance() throws {
    try assertValueConformance(makeScreen())
    try assertValueConformance(makeScreen(displayIdentifier: 123, isMain: true))
  }

  func testWindowScreenIsSendable() {
    assertSendable(makeScreen(displayIdentifier: 123, isMain: true))
  }

  private func makeScreen(
    displayIdentifier: CGDirectDisplayID? = nil,
    isMain: Bool = false
  ) -> WindowScreen {
    WindowScreen(
      displayIdentifier: displayIdentifier,
      frame: fullFrame,
      visibleFrame: visibleFrame,
      isMain: isMain
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
