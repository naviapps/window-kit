import ApplicationServices
import CoreGraphics
import XCTest

@testable import WindowKit
@testable import WindowKitAppKit

@MainActor
final class AXWindowFrameControllerTests: XCTestCase {
  func testFrameReadsPositionAndSizeAttributes() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    var position = CGPoint(x: 30, y: 40)
    var size = CGSize(width: 500, height: 300)
    guard let positionValue = AXValueCreate(.cgPoint, &position),
      let sizeValue = AXValueCreate(.cgSize, &size)
    else {
      XCTFail("Failed to create AXValue")
      return
    }

    let positionAttribute = kAXPositionAttribute as String
    let sizeAttribute = kAXSizeAttribute as String

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      switch attribute as String {
      case positionAttribute:
        value.pointee = positionValue
        return .success
      case sizeAttribute:
        value.pointee = sizeValue
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let frame = try fixture.frameController().frame(for: .focused)

    XCTAssertEqual(frame.origin, CGPoint(x: 30, y: 40))
    XCTAssertEqual(frame.size, CGSize(width: 500, height: 300))
  }

  func testFrameThrowsUnderlyingAccessibilityErrorWhenPositionReadFails() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    var readAttributes: [String] = []
    fixture.installCopyAttributeValue { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      readAttributes.append(attribute as String)
      value.pointee = nil
      return .cannotComplete
    }

    XCTAssertThrowsError(try fixture.frameController().frame(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
    XCTAssertEqual(readAttributes, [kAXPositionAttribute as String])
  }

  func testSetFrameWritesPositionAndSizeAttributes() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue()

    var writes: [FrameAttributeWrite] = []
    let positionAttribute = kAXPositionAttribute as String
    let sizeAttribute = kAXSizeAttribute as String
    AXAPI.setAttributeValue = { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      guard CFGetTypeID(value) == AXValueGetTypeID() else {
        XCTFail("Expected AXValue")
        return .success
      }
      let axValue = unsafeDowncast(value, to: AXValue.self)
      switch attribute as String {
      case positionAttribute:
        var point = CGPoint.zero
        XCTAssertTrue(AXValueGetValue(axValue, .cgPoint, &point))
        writes.append(.position(point))
      case sizeAttribute:
        var size = CGSize.zero
        XCTAssertTrue(AXValueGetValue(axValue, .cgSize, &size))
        writes.append(.size(size))
      default:
        XCTFail("Unexpected attribute \(attribute)")
      }
      return .success
    }

    try fixture.frameController().setFrame(CGRect(x: 1, y: 2, width: 3, height: 4), for: .focused)

    XCTAssertEqual(
      writes,
      [
        .position(CGPoint(x: 1, y: 2)),
        .size(CGSize(width: 3, height: 4)),
      ])
  }

  func testSetFrameThrowsUnderlyingAccessibilityErrorWhenPositionWriteFails() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let fixture = FocusedWindowAXFixture()
    fixture.installCopyAttributeValue()

    var writtenAttributes: [String] = []
    AXAPI.setAttributeValue = { _, attribute, _ in
      writtenAttributes.append(attribute as String)
      return .cannotComplete
    }

    XCTAssertThrowsError(
      try fixture.frameController().setFrame(CGRect(x: 1, y: 2, width: 3, height: 4), for: .focused)
    ) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
    XCTAssertEqual(writtenAttributes, [kAXPositionAttribute as String])
  }
}

private enum FrameAttributeWrite: Equatable {
  case position(CGPoint)
  case size(CGSize)
}
