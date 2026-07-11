import ApplicationServices
import CoreGraphics
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXClientUIElementTests: XCTestCase {
  func testOptionalAttributeElementReturnsNilWhenAttributeHasNoValue() throws {
    for error in [AXError.attributeUnsupported, .noValue] {
      let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
        XCTAssertEqual(attribute as String, AXWindowAttribute.focusedWindow.accessibilityName)
        value.pointee = nil
        return error
      })

      let element = try accessibilityClient.attributeElement(
        .focusedWindow,
        of: AXUIElementCreateSystemWide()
      )

      XCTAssertNil(element)
    }
  }

  func testOptionalAttributeElementRejectsUnexpectedValueType() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = "invalid" as CFString
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeElement(.focusedWindow, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testAttributeElementsRejectsNonArrayValues() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = "invalid" as CFString
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeElements(.windows, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testAttributeBoolRequiresCFBooleanValues() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = NSNumber(value: Int32(1))
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeBool(.minimized, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testAttributeUInt32ReturnsExactUnsignedIntegerValue() throws {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = NSNumber(value: UInt32.max)
      return .success
    })

    let windowIdentifier = try accessibilityClient.attributeUInt32(
      .windowIdentifier,
      of: AXUIElementCreateSystemWide()
    )

    XCTAssertEqual(windowIdentifier, UInt32.max)
  }

  func testAttributeUInt32RejectsNonExactUnsignedIntegerValues() {
    let invalidValues: [NSNumber] = [
      kCFBooleanTrue,
      NSNumber(value: -1),
      NSNumber(value: 1.5),
      NSNumber(value: UInt64(UInt32.max) + 1),
    ]

    for invalidValue in invalidValues {
      let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
        value.pointee = invalidValue
        return .success
      })

      XCTAssertThrowsError(
        try accessibilityClient.attributeUInt32(
          .windowIdentifier, of: AXUIElementCreateSystemWide())
      ) { error in
        XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
      }
    }
  }

  func testRequiredCGPointAttributeRejectsMissingSuccessfulValue() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = nil
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeCGPoint(.position, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testRequiredCGSizeAttributeRejectsWrongAXValueType() throws {
    var point = CGPoint(x: 12, y: 34)
    let pointValue = try XCTUnwrap(AXValueCreate(.cgPoint, &point))
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = pointValue
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeCGSize(.size, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testRequiredCGPointAttributeRejectsNonFiniteValue() throws {
    var point = CGPoint(x: CGFloat.nan, y: 34)
    let pointValue = try XCTUnwrap(AXValueCreate(.cgPoint, &point))
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = pointValue
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeCGPoint(.position, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testRequiredCGSizeAttributeRejectsNonFiniteValue() throws {
    var size = CGSize(width: 56, height: CGFloat.infinity)
    let sizeValue = try XCTUnwrap(AXValueCreate(.cgSize, &size))
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = sizeValue
      return .success
    })

    XCTAssertThrowsError(
      try accessibilityClient.attributeCGSize(.size, of: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testSetAttributeBoolWritesTypedBooleanAttribute() throws {
    var capturedAttribute: String?
    var capturedTypeID: CFTypeID?
    var capturedValue: Bool?
    let accessibilityClient = AXClient.testing(setAttributeValue: { _, attribute, value in
      capturedAttribute = attribute as String
      capturedTypeID = CFGetTypeID(value)
      capturedValue = value as? Bool
      return .success
    })

    try accessibilityClient.setAttributeBool(
      .minimized,
      value: true,
      on: AXUIElementCreateSystemWide()
    )

    XCTAssertEqual(capturedAttribute, AXWindowAttribute.minimized.accessibilityName)
    XCTAssertEqual(capturedTypeID, CFBooleanGetTypeID())
    XCTAssertEqual(capturedValue, true)
  }

  func testPerformActionMapsUnsupportedActionToTypedError() {
    let accessibilityClient = AXClient.testing(performAction: { _, action in
      XCTAssertEqual(action as String, AXWindowAction.lower.accessibilityName)
      return .actionUnsupported
    })

    XCTAssertThrowsError(
      try accessibilityClient.performAction(.lower, on: AXUIElementCreateSystemWide())
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .unsupportedOperation)
    }
  }
}
