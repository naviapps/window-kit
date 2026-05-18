import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowScreenMovementTests: XCTestCase {
  func testMoveCenterPreservingSizeKeepsFittingSizeCentered() {
    let windowFrame = CGRect(x: 0, y: 0, width: 120, height: 80)
    let visibleFrame = CGRect(x: 100, y: 200, width: 300, height: 200)
    let moved = WindowScreenMovement.centerPreservingSize(
      windowFrame: windowFrame,
      in: visibleFrame
    )

    XCTAssertEqual(moved, CGRect(x: 190, y: 260, width: 120, height: 80))
  }

  func testMoveCenterPreservingSizeClampsToVisibleFrame() {
    let windowFrame = CGRect(x: 0, y: 0, width: 500, height: 500)
    let visibleFrame = CGRect(x: 100, y: 100, width: 300, height: 200)
    let moved = WindowScreenMovement.centerPreservingSize(
      windowFrame: windowFrame,
      in: visibleFrame
    )
    XCTAssertEqual(moved.size, visibleFrame.size)
    XCTAssertEqual(moved.midX, visibleFrame.midX)
    XCTAssertEqual(moved.midY, visibleFrame.midY)
  }

  func testMoveCenterPreservingSizeStandardizesFrames() {
    let windowFrame = CGRect(x: 500, y: 500, width: -500, height: -500)
    let visibleFrame = CGRect(x: 400, y: 300, width: -300, height: -200)
    let moved = WindowScreenMovement.centerPreservingSize(
      windowFrame: windowFrame,
      in: visibleFrame
    )
    XCTAssertEqual(moved, CGRect(x: 100, y: 100, width: 300, height: 200))
  }

  func testMovePreservingRelativePositionKeepsRelativeOrigin() {
    let windowFrame = CGRect(x: 50, y: 100, width: 100, height: 100)
    let source = CGRect(x: 0, y: 0, width: 200, height: 200)
    let target = CGRect(x: 300, y: 400, width: 400, height: 300)
    let moved = WindowScreenMovement.preservingRelativePosition(
      windowFrame: windowFrame,
      from: source,
      to: target
    )

    XCTAssertEqual(moved, CGRect(x: 450, y: 600, width: 100, height: 100))
  }

  func testMovePreservingRelativePositionClampsToTarget() {
    let windowFrame = CGRect(x: 50, y: 50, width: 80, height: 60)
    let source = CGRect(x: 0, y: 0, width: 200, height: 200)
    let target = CGRect(x: 300, y: 0, width: 100, height: 100)
    let moved = WindowScreenMovement.preservingRelativePosition(
      windowFrame: windowFrame,
      from: source,
      to: target
    )
    XCTAssertTrue(target.contains(CGPoint(x: moved.midX, y: moved.midY)))
    XCTAssertLessThanOrEqual(moved.maxX, target.maxX)
    XCTAssertLessThanOrEqual(moved.maxY, target.maxY)
  }

  func testMovePreservingRelativePositionStandardizesFrames() {
    let windowFrame = CGRect(x: 130, y: 110, width: -80, height: -60)
    let source = CGRect(x: 200, y: 200, width: -200, height: -200)
    let target = CGRect(x: 400, y: 100, width: -100, height: -100)
    let moved = WindowScreenMovement.preservingRelativePosition(
      windowFrame: windowFrame,
      from: source,
      to: target
    )
    XCTAssertEqual(
      moved,
      CGRect(x: 308.3333333333333, y: 14.285714285714286, width: 80, height: 60)
    )
  }

  func testMovePreservingRelativePositionClampsNonFiniteProgress() {
    let moved = WindowScreenMovement.preservingRelativePosition(
      windowFrame: CGRect(x: CGFloat.infinity, y: CGFloat.nan, width: 80, height: 60),
      from: CGRect(x: 0, y: 0, width: 200, height: 200),
      to: CGRect(x: 300, y: 0, width: 100, height: 100)
    )
    XCTAssertEqual(moved, CGRect(x: 320, y: 0, width: 80, height: 60))
  }
}
