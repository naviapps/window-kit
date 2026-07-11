import ApplicationServices
import WindowKit
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXWindowControllerStateTests: XCTestCase {
  func testStateReturnsExpectedValuesForFocusedWindow() throws {
    let minimizedAttribute = AXWindowAttribute.minimized.accessibilityName
    let fullScreenAttribute = AXWindowAttribute.fullScreen.accessibilityName

    var readAttributes: [String] = []
    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case minimizedAttribute:
        readAttributes.append(attribute as String)
        value.pointee = kCFBooleanTrue
        return .success
      case fullScreenAttribute:
        readAttributes.append(attribute as String)
        value.pointee = kCFBooleanFalse
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.stateProvider(accessibilityClient: accessibilityClient)
    let state = try provider.state(for: .focused)

    XCTAssertEqual(state.isMinimized, true)
    XCTAssertEqual(state.isFullScreen, false)
    XCTAssertEqual(readAttributes, [minimizedAttribute, fullScreenAttribute])
  }

  func testStateReturnsNilForUnavailableValues() throws {
    let minimizedAttribute = AXWindowAttribute.minimized.accessibilityName
    let fullScreenAttribute = AXWindowAttribute.fullScreen.accessibilityName

    var readAttributes: [String] = []
    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case minimizedAttribute, fullScreenAttribute:
        readAttributes.append(attribute as String)
        value.pointee = nil
        return .noValue
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.stateProvider(accessibilityClient: accessibilityClient)
    let state = try provider.state(for: .focused)

    XCTAssertNil(state.isMinimized)
    XCTAssertNil(state.isFullScreen)
    XCTAssertEqual(readAttributes, [minimizedAttribute, fullScreenAttribute])
  }

  func testStateThrowsWhenAccessibilityNotTrusted() {
    let systemElement = AXUIElementCreateSystemWide()
    let provider = AXWindowController(
      accessibilityClient: .testing(isProcessTrusted: { false }),
      systemWideElement: systemElement,
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )
    XCTAssertThrowsError(try provider.state(for: .focused)) { error in
      XCTAssertEqual(error as? WindowAccessibilityError, .accessibilityNotTrusted)
    }
  }

  func testStateThrowsInvalidAXValue() {
    let minimizedAttribute = AXWindowAttribute.minimized.accessibilityName

    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case minimizedAttribute:
        value.pointee = "invalid" as CFString
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.stateProvider(accessibilityClient: accessibilityClient)
    XCTAssertThrowsError(try provider.state(for: .focused)) { error in
      XCTAssertEqual(error as? WindowAccessibilityError, .invalidAccessibilityValue(.readState))
    }
  }

  func testStateThrowsUnderlyingAccessibilityError() {
    let minimizedAttribute = AXWindowAttribute.minimized.accessibilityName

    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case minimizedAttribute:
        value.pointee = nil
        return .notImplemented
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.stateProvider(accessibilityClient: accessibilityClient)
    XCTAssertThrowsError(try provider.state(for: .focused)) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .readState, failure: .notImplemented)
      )
    }
  }
}
