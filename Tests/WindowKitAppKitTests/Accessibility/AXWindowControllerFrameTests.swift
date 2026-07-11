import ApplicationServices
import CoreGraphics
import XCTest

import WindowKit
@testable import WindowKitAppKit

@MainActor
final class AXWindowControllerFrameTests: XCTestCase {
  func testFrameReadsPositionAndSizeAttributes() throws {
    var position = CGPoint(x: 30, y: 40)
    var size = CGSize(width: 500, height: 300)
    guard let positionValue = AXValueCreate(.cgPoint, &position),
      let sizeValue = AXValueCreate(.cgSize, &size)
    else {
      XCTFail("Failed to create AXValue")
      return
    }

    let positionAttribute = AXWindowAttribute.position.accessibilityName
    let sizeAttribute = AXWindowAttribute.size.accessibilityName

    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
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

    let frame = try fixture.frameController(accessibilityClient: accessibilityClient)
      .frame(for: .focused)

    XCTAssertEqual(frame.origin, CGPoint(x: 30, y: 40))
    XCTAssertEqual(frame.size, CGSize(width: 500, height: 300))
  }

  func testFrameStandardizesReadAttributes() throws {
    var position = CGPoint(x: 100, y: 100)
    var size = CGSize(width: -80, height: -60)
    guard let positionValue = AXValueCreate(.cgPoint, &position),
      let sizeValue = AXValueCreate(.cgSize, &size)
    else {
      XCTFail("Failed to create AXValue")
      return
    }

    let fixture = FocusedWindowAXFixture()
    let accessibilityClient = fixture.accessibilityClient { _, attribute, value in
      switch attribute as String {
      case AXWindowAttribute.position.accessibilityName:
        value.pointee = positionValue
        return .success
      case AXWindowAttribute.size.accessibilityName:
        value.pointee = sizeValue
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let frame = try fixture.frameController(accessibilityClient: accessibilityClient)
      .frame(for: .focused)

    XCTAssertEqual(frame, CGRect(x: 20, y: 40, width: 80, height: 60))
  }

  func testFrameThrowsUnderlyingAccessibilityErrorWhenPositionReadFails() {
    let fixture = FocusedWindowAXFixture()
    var readAttributes: [String] = []
    let accessibilityClient = fixture.accessibilityClient { element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      readAttributes.append(attribute as String)
      value.pointee = nil
      return .cannotComplete
    }

    XCTAssertThrowsError(
      try fixture.frameController(accessibilityClient: accessibilityClient).frame(for: .focused)
    ) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .readFrame, failure: .cannotComplete)
      )
    }
    XCTAssertEqual(readAttributes, [AXWindowAttribute.position.accessibilityName])
  }

  func testSetFrameWritesPositionAndSizeAttributes() throws {
    let fixture = FocusedWindowAXFixture()

    var writes: [FrameAttributeWrite] = []
    let positionAttribute = AXWindowAttribute.position.accessibilityName
    let sizeAttribute = AXWindowAttribute.size.accessibilityName
    let accessibilityClient = fixture.accessibilityClient(setAttributeValue: {
      element, attribute, value in
      XCTAssertEqual(CFEqual(element, fixture.windowElement), true)
      guard CFGetTypeID(value) == AXValueGetTypeID() else {
        XCTFail("Expected AXValue")
        return .success
      }
      let axValue = typedReference(value, as: AXValue.self)
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
    })

    try fixture.frameController(accessibilityClient: accessibilityClient)
      .setFrame(CGRect(x: 1, y: 2, width: 3, height: 4), for: .focused)

    XCTAssertEqual(
      writes,
      [
        .position(CGPoint(x: 1, y: 2)),
        .size(CGSize(width: 3, height: 4)),
      ])
  }

  func testSetFrameStandardizesFrameBeforeWritingAttributes() throws {
    let fixture = FocusedWindowAXFixture()

    var writes: [FrameAttributeWrite] = []
    let accessibilityClient = fixture.accessibilityClient(setAttributeValue: {
      _, attribute, value in
      let axValue = typedReference(value, as: AXValue.self)
      switch attribute as String {
      case AXWindowAttribute.position.accessibilityName:
        var point = CGPoint.zero
        XCTAssertTrue(AXValueGetValue(axValue, .cgPoint, &point))
        writes.append(.position(point))
      case AXWindowAttribute.size.accessibilityName:
        var size = CGSize.zero
        XCTAssertTrue(AXValueGetValue(axValue, .cgSize, &size))
        writes.append(.size(size))
      default:
        XCTFail("Unexpected attribute \(attribute)")
      }
      return .success
    })

    try fixture.frameController(accessibilityClient: accessibilityClient)
      .setFrame(CGRect(x: 100, y: 100, width: -80, height: -60), for: .focused)

    XCTAssertEqual(
      writes,
      [
        .position(CGPoint(x: 20, y: 40)),
        .size(CGSize(width: 80, height: 60)),
      ])
  }

  func testSetFrameThrowsUnderlyingAccessibilityErrorWhenPositionWriteFails() {
    let fixture = FocusedWindowAXFixture()

    var writtenAttributes: [String] = []
    let accessibilityClient = fixture.accessibilityClient(setAttributeValue: { _, attribute, _ in
      writtenAttributes.append(attribute as String)
      return .cannotComplete
    })

    XCTAssertThrowsError(
      try fixture.frameController(accessibilityClient: accessibilityClient)
        .setFrame(CGRect(x: 1, y: 2, width: 3, height: 4), for: .focused)
    ) { error in
      XCTAssertEqual(
        error as? WindowAccessibilityError,
        .accessibilityOperationFailed(operation: .setFrame, failure: .cannotComplete)
      )
    }
    XCTAssertEqual(writtenAttributes, [AXWindowAttribute.position.accessibilityName])
  }

  func testSetFrameDoesNotPartiallyWriteWhenSizeValueCreationFails() {
    let fixture = FocusedWindowAXFixture()

    var writtenAttributes: [String] = []
    let accessibilityClient = fixture.accessibilityClient(
      setAttributeValue: { _, attribute, _ in
        writtenAttributes.append(attribute as String)
        return .success
      },
      valueCreate: { type, pointer in
        guard type != .cgSize else { return nil }
        return AXValueCreate(type, pointer)
      }
    )

    XCTAssertThrowsError(
      try fixture.frameController(accessibilityClient: accessibilityClient)
        .setFrame(CGRect(x: 1, y: 2, width: 3, height: 4), for: .focused)
    ) { error in
      XCTAssertEqual(error as? WindowAccessibilityError, .invalidAccessibilityValue(.setFrame))
    }
    XCTAssertEqual(writtenAttributes, [])
  }
}

private enum FrameAttributeWrite: Equatable {
  case position(CGPoint)
  case size(CGSize)
}

private func typedReference<Value: AnyObject>(
  _ value: CFTypeRef,
  as _: Value.Type
) -> Value {
  Unmanaged<Value>
    .fromOpaque(Unmanaged.passUnretained(value).toOpaque())
    .takeUnretainedValue()
}
