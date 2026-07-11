import WindowKit
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXWindowControllerRoleTests: XCTestCase {
  func testRoleReturnsResolvedAccessibilityRole() throws {
    let fixture = FocusedWindowAXFixture()
    let roleAttribute = AXWindowAttribute.role.accessibilityName
    let subroleAttribute = AXWindowAttribute.subrole.accessibilityName
    var readAttributes: [String] = []

    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = AXWindowRoleValue.sheet.accessibilityName as CFString
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

    let provider = fixture.roleProvider(accessibilityClient: accessibilityClient)

    XCTAssertEqual(try provider.role(for: .focused), .sheet)
    XCTAssertEqual(readAttributes, [roleAttribute, subroleAttribute])
  }

  func testRoleReturnsResolvedAccessibilitySubrole() throws {
    let fixture = FocusedWindowAXFixture()
    let roleAttribute = AXWindowAttribute.role.accessibilityName
    let subroleAttribute = AXWindowAttribute.subrole.accessibilityName

    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        value.pointee = AXWindowRoleValue.window.accessibilityName as CFString
        return .success
      case subroleAttribute:
        value.pointee = AXWindowSubroleValue.dialog.accessibilityName as CFString
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider(accessibilityClient: accessibilityClient)

    XCTAssertEqual(try provider.role(for: .focused), .dialog)
  }

  func testRoleReturnsUnclassifiedWhenRoleMetadataIsUnavailable() throws {
    let fixture = FocusedWindowAXFixture()

    let provider = fixture.roleProvider()

    XCTAssertEqual(
      try provider.role(for: .focused),
      .unclassified(accessibilityRole: nil, accessibilitySubrole: nil))
  }

  func testRolePreservesSubroleMetadataWhenRoleIsUnavailable() throws {
    let fixture = FocusedWindowAXFixture()
    let roleAttribute = AXWindowAttribute.role.accessibilityName
    let subroleAttribute = AXWindowAttribute.subrole.accessibilityName

    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        value.pointee = nil
        return .noValue
      case subroleAttribute:
        value.pointee = AXWindowSubroleValue.dialog.accessibilityName as CFString
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let provider = fixture.roleProvider(accessibilityClient: accessibilityClient)

    XCTAssertEqual(
      try provider.role(for: .focused),
      .unclassified(
        accessibilityRole: nil,
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName
      )
    )
  }

  func testRoleThrowsUnderlyingAccessibilityErrorWhenRoleReadFails() {
    let fixture = FocusedWindowAXFixture()
    let roleAttribute = AXWindowAttribute.role.accessibilityName
    var readAttributes: [String] = []

    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
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

    let provider = fixture.roleProvider(accessibilityClient: accessibilityClient)

    XCTAssertThrowsError(try provider.role(for: .focused)) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .readRole, failure: .cannotComplete)
      )
    }
    XCTAssertEqual(readAttributes, [roleAttribute])
  }

  func testRoleThrowsUnderlyingAccessibilityErrorWhenSubroleReadFails() {
    let fixture = FocusedWindowAXFixture()
    let roleAttribute = AXWindowAttribute.role.accessibilityName
    let subroleAttribute = AXWindowAttribute.subrole.accessibilityName
    var readAttributes: [String] = []

    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case roleAttribute:
        readAttributes.append(attribute as String)
        value.pointee = AXWindowRoleValue.window.accessibilityName as CFString
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

    let provider = fixture.roleProvider(accessibilityClient: accessibilityClient)

    XCTAssertThrowsError(try provider.role(for: .focused)) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .readRole, failure: .cannotComplete)
      )
    }
    XCTAssertEqual(readAttributes, [roleAttribute, subroleAttribute])
  }

  func testRoleThrowsInvalidAXValueForUnexpectedRoleType() {
    let fixture = FocusedWindowAXFixture()
    let roleAttribute = AXWindowAttribute.role.accessibilityName

    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
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

    let provider = fixture.roleProvider(accessibilityClient: accessibilityClient)

    XCTAssertThrowsError(try provider.role(for: .focused)) { error in
      XCTAssertEqual(error as? WindowAccessibilityError, .invalidAccessibilityValue(.readRole))
    }
  }
}
