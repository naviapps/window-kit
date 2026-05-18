import ApplicationServices
import CoreGraphics
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXValueConversionTests: XCTestCase {
  func testCGPointConvertsToAXValue() throws {
    let value = try CGPoint(x: 12, y: 34).axValue()

    var point = CGPoint.zero
    XCTAssertTrue(AXValueGetValue(value, .cgPoint, &point))
    XCTAssertEqual(point, CGPoint(x: 12, y: 34))
  }

  func testCGSizeConvertsToAXValue() throws {
    let value = try CGSize(width: 56, height: 78).axValue()

    var size = CGSize.zero
    XCTAssertTrue(AXValueGetValue(value, .cgSize, &size))
    XCTAssertEqual(size, CGSize(width: 56, height: 78))
  }

  func testCGPointConversionPassesCGPointTypeAndValue() throws {
    defer { AXAPI.reset() }
    var capturedType: AXValueType?
    var capturedPoint = CGPoint.zero
    AXAPI.valueCreate = { type, pointer in
      capturedType = type
      capturedPoint = pointer.load(as: CGPoint.self)
      return AXValueCreate(type, pointer)
    }

    _ = try CGPoint(x: 12, y: 34).axValue()

    XCTAssertEqual(capturedType, .cgPoint)
    XCTAssertEqual(capturedPoint, CGPoint(x: 12, y: 34))
  }

  func testCGSizeConversionPassesCGSizeTypeAndValue() throws {
    defer { AXAPI.reset() }
    var capturedType: AXValueType?
    var capturedSize = CGSize.zero
    AXAPI.valueCreate = { type, pointer in
      capturedType = type
      capturedSize = pointer.load(as: CGSize.self)
      return AXValueCreate(type, pointer)
    }

    _ = try CGSize(width: 56, height: 78).axValue()

    XCTAssertEqual(capturedType, .cgSize)
    XCTAssertEqual(capturedSize, CGSize(width: 56, height: 78))
  }

  func testCGPointConversionThrowsWhenAXValueCreationFails() {
    defer { AXAPI.reset() }
    AXAPI.valueCreate = { _, _ in nil }

    XCTAssertThrowsError(try CGPoint(x: 12, y: 34).axValue()) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testCGSizeConversionThrowsWhenAXValueCreationFails() {
    defer { AXAPI.reset() }
    AXAPI.valueCreate = { _, _ in nil }

    XCTAssertThrowsError(try CGSize(width: 56, height: 78).axValue()) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }
}
