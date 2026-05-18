import AppKit
import WindowKit
import WindowKitAppKit
import XCTest

@MainActor
final class NSScreenProviderTests: XCTestCase {
  func testScreensMapCurrentNSScreens() {
    let provider = NSScreenProvider()
    let screens = provider.screens()
    let nsScreens = NSScreen.screens
    let mainScreen = NSScreen.main

    XCTAssertFalse(screens.isEmpty)
    XCTAssertEqual(screens.count, nsScreens.count)

    for (screen, nsScreen) in zip(screens, nsScreens) {
      XCTAssertEqual(screen.displayIdentifier, nsScreen.displayIdentifier)
      XCTAssertEqual(screen.frame, nsScreen.frame)
      XCTAssertEqual(screen.visibleFrame, nsScreen.visibleFrame)
      XCTAssertEqual(screen.isMain, nsScreen == mainScreen)
    }
  }

  func testProviderCanBeUsedThroughScreenProvidingProtocol() {
    let provider: any WindowScreenProviding = NSScreenProvider()
    let nsScreens = NSScreen.screens

    XCTAssertEqual(provider.screens().count, nsScreens.count)
  }

  func testProviderIsSendable() {
    assertSendable(NSScreenProvider())
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}

private extension NSScreen {
  var displayIdentifier: CGDirectDisplayID? {
    let screenNumber = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
    return screenNumber.map { CGDirectDisplayID($0.uint32Value) }
  }
}
