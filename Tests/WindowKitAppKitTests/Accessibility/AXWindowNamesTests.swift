import ApplicationServices
import XCTest

@testable import WindowKitAppKit

final class AXWindowNamesTests: XCTestCase {
  func testWindowAttributesExposeAccessibilityNames() {
    XCTAssertEqual(
      AXWindowAttribute.focusedApplication.accessibilityName,
      kAXFocusedApplicationAttribute as String
    )
    XCTAssertEqual(
      AXWindowAttribute.focusedWindow.accessibilityName,
      kAXFocusedWindowAttribute as String
    )
    XCTAssertEqual(AXWindowAttribute.fullScreen.accessibilityName, "AXFullScreen")
    XCTAssertEqual(AXWindowAttribute.minimized.accessibilityName, kAXMinimizedAttribute as String)
    XCTAssertEqual(AXWindowAttribute.position.accessibilityName, kAXPositionAttribute as String)
    XCTAssertEqual(AXWindowAttribute.role.accessibilityName, kAXRoleAttribute as String)
    XCTAssertEqual(AXWindowAttribute.size.accessibilityName, kAXSizeAttribute as String)
    XCTAssertEqual(AXWindowAttribute.subrole.accessibilityName, kAXSubroleAttribute as String)
    XCTAssertEqual(AXWindowAttribute.windowIdentifier.accessibilityName, "AXWindowID")
    XCTAssertEqual(AXWindowAttribute.windows.accessibilityName, kAXWindowsAttribute as String)
  }

  func testWindowActionsExposeAccessibilityNames() {
    XCTAssertEqual(AXWindowAction.raise.accessibilityName, kAXRaiseAction as String)
    XCTAssertEqual(AXWindowAction.lower.accessibilityName, "AXLower")
  }
}
