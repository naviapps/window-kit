import ApplicationServices
import WindowKit
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXWindowRoleProviderTests: XCTestCase {
  func testRoleReturnsResolvedAccessibilityRole() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    let roleAttribute = kAXRoleAttribute as String
    let subroleAttribute = kAXSubroleAttribute as String
    var readAttributes: [String] = []

    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = "AXSheet" as CFString
        return .success
      case subroleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = nil
        return .noValue
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider()

    XCTAssertEqual(try provider.role(for: .focused), .sheet)
    XCTAssertEqual(readAttributes, [roleAttribute, subroleAttribute])
  }

  func testRoleReturnsResolvedAccessibilitySubrole() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    let roleAttribute = kAXRoleAttribute as String
    let subroleAttribute = kAXSubroleAttribute as String

    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        value.pointee = kAXWindowRole as CFString
        return .success
      case subroleAttribute:
        value.pointee = kAXDialogSubrole as CFString
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider()

    XCTAssertEqual(try provider.role(for: .focused), .dialog)
  }

  func testRoleReturnsUnknownWhenRoleMetadataIsUnavailable() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue()

    let provider = fixture.roleProvider()

    XCTAssertEqual(try provider.role(for: .focused), .unknown(role: nil, subrole: nil))
  }

  func testRoleThrowsUnderlyingAccessibilityErrorWhenRoleReadFails() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    let roleAttribute = kAXRoleAttribute as String
    var readAttributes: [String] = []

    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = nil
        return .cannotComplete
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider()

    XCTAssertThrowsError(try provider.role(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
    XCTAssertEqual(readAttributes, [roleAttribute])
  }

  func testRoleThrowsUnderlyingAccessibilityErrorWhenSubroleReadFails() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    let roleAttribute = kAXRoleAttribute as String
    let subroleAttribute = kAXSubroleAttribute as String
    var readAttributes: [String] = []

    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = kAXWindowRole as CFString
        return .success
      case subroleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = nil
        return .cannotComplete
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider()

    XCTAssertThrowsError(try provider.role(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
    XCTAssertEqual(readAttributes, [roleAttribute, subroleAttribute])
  }

  func testRoleThrowsInvalidAXValueForUnexpectedRoleType() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    let roleAttribute = kAXRoleAttribute as String

    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        value.pointee = NSNumber(value: 1)
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider()

    XCTAssertThrowsError(try provider.role(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }
}
