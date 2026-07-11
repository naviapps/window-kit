import ApplicationServices
import CoreGraphics
import XCTest

@testable import WindowKitAppKit

@MainActor
final class AXValueConversionTests: XCTestCase {
  func testCGPointConvertsToAXValue() throws {
    let value = try CGPoint(x: 12, y: 34).axValue(using: .testing())

    var point = CGPoint.zero
    XCTAssertTrue(AXValueGetValue(value, .cgPoint, &point))
    XCTAssertEqual(point, CGPoint(x: 12, y: 34))
  }

  func testCGSizeConvertsToAXValue() throws {
    let value = try CGSize(width: 56, height: 78).axValue(using: .testing())

    var size = CGSize.zero
    XCTAssertTrue(AXValueGetValue(value, .cgSize, &size))
    XCTAssertEqual(size, CGSize(width: 56, height: 78))
  }

  func testCGPointConversionPassesCGPointTypeAndValue() throws {
    var capturedType: AXValueType?
    var capturedPoint = CGPoint.zero
    let accessibilityClient = AXClient.testing(valueCreate: { type, pointer in
      capturedType = type
      capturedPoint = pointer.load(as: CGPoint.self)
      return AXValueCreate(type, pointer)
    })

    _ = try CGPoint(x: 12, y: 34).axValue(using: accessibilityClient)

    XCTAssertEqual(capturedType, .cgPoint)
    XCTAssertEqual(capturedPoint, CGPoint(x: 12, y: 34))
  }

  func testCGPointConversionRejectsNonFiniteCoordinates() {
    let points = [
      CGPoint(x: CGFloat.nan, y: 0),
      CGPoint(x: 0, y: CGFloat.infinity),
      CGPoint(x: -CGFloat.infinity, y: 0),
    ]

    for point in points {
      XCTAssertThrowsError(try point.axValue(using: AXClient.testing())) { error in
        XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
      }
    }
  }

  func testCGSizeConversionRejectsNonFiniteDimensions() {
    let sizes = [
      CGSize(width: CGFloat.nan, height: 1),
      CGSize(width: 1, height: CGFloat.infinity),
      CGSize(width: -CGFloat.infinity, height: 1),
    ]

    for size in sizes {
      XCTAssertThrowsError(try size.axValue(using: AXClient.testing())) { error in
        XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
      }
    }
  }

  func testCGSizeConversionPassesCGSizeTypeAndValue() throws {
    var capturedType: AXValueType?
    var capturedSize = CGSize.zero
    let accessibilityClient = AXClient.testing(valueCreate: { type, pointer in
      capturedType = type
      capturedSize = pointer.load(as: CGSize.self)
      return AXValueCreate(type, pointer)
    })

    _ = try CGSize(width: 56, height: 78).axValue(using: accessibilityClient)

    XCTAssertEqual(capturedType, .cgSize)
    XCTAssertEqual(capturedSize, CGSize(width: 56, height: 78))
  }

  func testCGPointConversionThrowsWhenAXValueCreationFails() {
    let accessibilityClient = AXClient.testing(valueCreate: { _, _ in nil })

    XCTAssertThrowsError(try CGPoint(x: 12, y: 34).axValue(using: accessibilityClient)) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testCGSizeConversionThrowsWhenAXValueCreationFails() {
    let accessibilityClient = AXClient.testing(valueCreate: { _, _ in nil })

    XCTAssertThrowsError(try CGSize(width: 56, height: 78).axValue(using: accessibilityClient)) {
      error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }
}
