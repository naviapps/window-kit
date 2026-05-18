import ApplicationServices
import XCTest

@testable import WindowKit
@testable import WindowKitAppKit

@MainActor
final class AXWindowCommandControllerTests: XCTestCase {
  func testSetMinimizedWritesMinimizedAttribute() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue()

    var writes: [BooleanAttributeWrite] = []
    AXAPI.setAttributeValue = { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      guard let boolValue = (value as? NSNumber)?.boolValue else {
        XCTFail("Expected Boolean attribute value")
        return .success
      }
      writes.append(BooleanAttributeWrite(attribute: attribute as String, value: boolValue))
      return .success
    }

    let controller = fixture.commandController()

    try controller.setMinimized(.focused, isMinimized: true)
    try controller.setMinimized(.focused, isMinimized: false)

    XCTAssertEqual(
      writes,
      [
        BooleanAttributeWrite(attribute: kAXMinimizedAttribute as String, value: true),
        BooleanAttributeWrite(attribute: kAXMinimizedAttribute as String, value: false),
      ])
  }

  func testSetFullScreenWritesFullScreenAttribute() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fullScreenAttribute = AXWindowAttributeName.fullScreen

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue()

    var writes: [BooleanAttributeWrite] = []
    AXAPI.setAttributeValue = { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      guard let boolValue = (value as? NSNumber)?.boolValue else {
        XCTFail("Expected Boolean attribute value")
        return .success
      }
      writes.append(BooleanAttributeWrite(attribute: attribute as String, value: boolValue))
      return .success
    }

    let controller = fixture.commandController()

    try controller.setFullScreen(.focused, isFullScreen: true)
    try controller.setFullScreen(.focused, isFullScreen: false)

    XCTAssertEqual(
      writes,
      [
        BooleanAttributeWrite(attribute: fullScreenAttribute, value: true),
        BooleanAttributeWrite(attribute: fullScreenAttribute, value: false),
      ])
  }

  func testSetMinimizedThrowsUnderlyingAccessibilityErrorWhenWriteFails() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue()
    AXAPI.setAttributeValue = { element, attribute, _ in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      XCTAssertEqual(attribute as String, kAXMinimizedAttribute as String)
      return .cannotComplete
    }

    let controller = fixture.commandController()

    XCTAssertThrowsError(try controller.setMinimized(.focused, isMinimized: true)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
  }

  func testRaisePerformsRaiseAction() throws {
    defer { AXAPI.reset() }
    let fixture = FocusedWindowAXFixture()
    let controller = fixture.commandController()

    var performedActions: [String] = []
    AXAPI.isProcessTrusted = { true }
    fixture.installCopyAttributeValue()
    AXAPI.performAction = { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      performedActions.append(action as String)
      return .success
    }

    try controller.raise(.focused)
    XCTAssertEqual(performedActions, [kAXRaiseAction as String])
  }

  func testRaiseThrowsUnderlyingAccessibilityErrorWhenActionFails() {
    defer { AXAPI.reset() }
    let fixture = FocusedWindowAXFixture()
    let controller = fixture.commandController()

    AXAPI.isProcessTrusted = { true }
    fixture.installCopyAttributeValue()
    AXAPI.performAction = { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      XCTAssertEqual(action as String, kAXRaiseAction as String)
      return .cannotComplete
    }

    XCTAssertThrowsError(try controller.raise(.focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
  }

  func testLowerPerformsLowerAction() throws {
    defer { AXAPI.reset() }
    let fixture = FocusedWindowAXFixture()
    let controller = fixture.commandController()

    var performedActions: [String] = []
    AXAPI.isProcessTrusted = { true }
    fixture.installCopyAttributeValue()
    AXAPI.performAction = { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      performedActions.append(action as String)
      return .success
    }

    try controller.lower(.focused)
    XCTAssertEqual(performedActions, [AXWindowActionName.lower])
  }

  func testLowerThrowsUnsupportedActionWhenLowerActionIsUnsupported() {
    defer { AXAPI.reset() }
    let fixture = FocusedWindowAXFixture()
    let controller = fixture.commandController()

    AXAPI.isProcessTrusted = { true }
    fixture.installCopyAttributeValue()
    AXAPI.performAction = { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      XCTAssertEqual(action as String, AXWindowActionName.lower)
      return .actionUnsupported
    }

    XCTAssertThrowsError(try controller.lower(.focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .unsupportedAction(AXWindowActionName.lower))
    }
  }
}

private struct BooleanAttributeWrite: Equatable {
  let attribute: String
  let value: Bool
}
