import ApplicationServices
import XCTest

@testable import WindowKit
@testable import WindowKitAppKit

@MainActor
final class AXWindowStateProviderTests: XCTestCase {
  func testStateReturnsExpectedValuesForFocusedWindow() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let minimizedAttribute = kAXMinimizedAttribute as String
    let fullScreenAttribute = AXWindowAttributeName.fullScreen

    var readAttributes: [String] = []
    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue { element, attribute, value in
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

    let provider = fixture.stateProvider()
    let state = try provider.state(for: .focused)

    XCTAssertEqual(state.isMinimized, true)
    XCTAssertEqual(state.isFullScreen, false)
    XCTAssertEqual(readAttributes, [minimizedAttribute, fullScreenAttribute])
  }

  func testStateReturnsNilForUnavailableValues() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let minimizedAttribute = kAXMinimizedAttribute as String
    let fullScreenAttribute = AXWindowAttributeName.fullScreen

    var readAttributes: [String] = []
    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue { element, attribute, value in
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

    let provider = fixture.stateProvider()
    let state = try provider.state(for: .focused)

    XCTAssertNil(state.isMinimized)
    XCTAssertNil(state.isFullScreen)
    XCTAssertEqual(readAttributes, [minimizedAttribute, fullScreenAttribute])
  }

  func testStateThrowsWhenAccessibilityNotTrusted() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { false }

    let provider = AXWindowStateProvider()
    XCTAssertThrowsError(try provider.state(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .accessibilityNotTrusted)
    }
  }

  func testStateThrowsInvalidAXValue() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let minimizedAttribute = kAXMinimizedAttribute as String

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue { element, attribute, value in
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

    let provider = fixture.stateProvider()
    XCTAssertThrowsError(try provider.state(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testStateThrowsUnderlyingAccessibilityError() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let minimizedAttribute = kAXMinimizedAttribute as String

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue { element, attribute, value in
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

    let provider = fixture.stateProvider()
    XCTAssertThrowsError(try provider.state(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.notImplemented))
    }
  }
}
