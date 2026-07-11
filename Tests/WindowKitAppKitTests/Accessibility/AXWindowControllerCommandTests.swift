import ApplicationServices
import WindowKit
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXWindowControllerCommandTests: XCTestCase {
  func testSetMinimizedWritesMinimizedAttribute() throws {
    let fixture = FocusedWindowAXFixture()

    var writes: [BooleanAttributeWrite] = []
    let accessibilityClient = fixture.accessibilityClient(setAttributeValue: {
      element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      guard CFGetTypeID(value) == CFBooleanGetTypeID(),
        let boolValue = value as? Bool
      else {
        XCTFail("Expected Boolean attribute value")
        return .success
      }
      writes.append(BooleanAttributeWrite(attribute: attribute as String, value: boolValue))
      return .success
    })

    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

    try controller.setMinimized(.focused, isMinimized: true)
    try controller.setMinimized(.focused, isMinimized: false)

    XCTAssertEqual(
      writes,
      [
        BooleanAttributeWrite(
          attribute: AXWindowAttribute.minimized.accessibilityName,
          value: true),
        BooleanAttributeWrite(
          attribute: AXWindowAttribute.minimized.accessibilityName,
          value: false),
      ])
  }

  func testSetFullScreenWritesFullScreenAttribute() throws {
    let fullScreenAttribute = AXWindowAttribute.fullScreen.accessibilityName

    let fixture = FocusedWindowAXFixture()

    var writes: [BooleanAttributeWrite] = []
    let accessibilityClient = fixture.accessibilityClient(setAttributeValue: {
      element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      guard CFGetTypeID(value) == CFBooleanGetTypeID(),
        let boolValue = value as? Bool
      else {
        XCTFail("Expected Boolean attribute value")
        return .success
      }
      writes.append(BooleanAttributeWrite(attribute: attribute as String, value: boolValue))
      return .success
    })

    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

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
    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient(setAttributeValue: {
      element, attribute, _ in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      XCTAssertEqual(attribute as String, AXWindowAttribute.minimized.accessibilityName)
      return .cannotComplete
    })

    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

    XCTAssertThrowsError(try controller.setMinimized(.focused, isMinimized: true)) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .setMinimized, failure: .cannotComplete)
      )
    }
  }

  func testRaisePerformsRaiseAction() throws {
    let fixture = FocusedWindowAXFixture()

    var performedActions: [String] = []
    let accessibilityClient = fixture.accessibilityClient(performAction: { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      performedActions.append(action as String)
      return .success
    })
    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

    try controller.raise(.focused)
    XCTAssertEqual(performedActions, [AXWindowAction.raise.accessibilityName])
  }

  func testRaiseThrowsUnderlyingAccessibilityErrorWhenActionFails() {
    let fixture = FocusedWindowAXFixture()

    let accessibilityClient = fixture.accessibilityClient(performAction: { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      XCTAssertEqual(action as String, AXWindowAction.raise.accessibilityName)
      return .cannotComplete
    })
    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

    XCTAssertThrowsError(try controller.raise(.focused)) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .raise, failure: .cannotComplete)
      )
    }
  }

  func testLowerPerformsLowerAction() throws {
    let fixture = FocusedWindowAXFixture()

    var performedActions: [String] = []
    let accessibilityClient = fixture.accessibilityClient(performAction: { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      performedActions.append(action as String)
      return .success
    })
    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

    try controller.lower(.focused)
    XCTAssertEqual(performedActions, [AXWindowAction.lower.accessibilityName])
  }

  func testLowerThrowsUnsupportedActionWhenLowerActionIsUnsupported() {
    let fixture = FocusedWindowAXFixture()

    let accessibilityClient = fixture.accessibilityClient(performAction: { element, action in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      XCTAssertEqual(action as String, AXWindowAction.lower.accessibilityName)
      return .actionUnsupported
    })
    let controller = fixture.commandController(accessibilityClient: accessibilityClient)

    XCTAssertThrowsError(try controller.lower(.focused)) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .unsupportedAccessibilityOperation(.lower)
      )
    }
  }
}

private struct BooleanAttributeWrite: Equatable {
  let attribute: String
  let value: Bool
}
