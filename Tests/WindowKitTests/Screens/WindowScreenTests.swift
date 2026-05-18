import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowScreenTests: XCTestCase {
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
