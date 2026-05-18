import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowPlacementCalculatorTests: XCTestCase {
  private let calculator = WindowPlacementCalculator()

  func testFillReturnsInsetScreenArea() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)
    XCTAssertEqual(
      calculator.frame(for: .fill, in: screenArea, inset: 10),
      CGRect(x: 20, y: 30, width: 280, height: 180)
    )
  }

  func testLeftHalfSplitsWidth() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)
    XCTAssertEqual(
      calculator.frame(for: .leftHalf, in: screenArea),
      CGRect(x: 0, y: 0, width: 100, height: 100)
    )
  }

  func testRightHalfSplitsWidth() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)
    XCTAssertEqual(
      calculator.frame(for: .rightHalf, in: screenArea),
      CGRect(x: 100, y: 0, width: 100, height: 100)
    )
  }

  func testTopHalfSplitsHeight() {
    let screenArea = CGRect(x: 0, y: 10, width: 200, height: 100)
    XCTAssertEqual(
      calculator.frame(for: .topHalf, in: screenArea),
      CGRect(x: 0, y: 60, width: 200, height: 50)
    )
  }

  func testBottomHalfSplitsHeight() {
    let screenArea = CGRect(x: 0, y: 10, width: 200, height: 100)
    XCTAssertEqual(
      calculator.frame(for: .bottomHalf, in: screenArea),
      CGRect(x: 0, y: 10, width: 200, height: 50)
    )
  }

  func testTopLeftQuarter() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)
    XCTAssertEqual(
      calculator.frame(for: .topLeftQuarter, in: screenArea),
      CGRect(x: 0, y: 50, width: 100, height: 50)
    )
  }

  func testRemainingQuarterPlacements() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)

    XCTAssertEqual(
      calculator.frame(for: .topRightQuarter, in: screenArea),
      CGRect(x: 100, y: 50, width: 100, height: 50)
    )
    XCTAssertEqual(
      calculator.frame(for: .bottomLeftQuarter, in: screenArea),
      CGRect(x: 0, y: 0, width: 100, height: 50)
    )
    XCTAssertEqual(
      calculator.frame(for: .bottomRightQuarter, in: screenArea),
      CGRect(x: 100, y: 0, width: 100, height: 50)
    )
  }

  func testLeftThirdSplitsWidthIntoThirds() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 90)
    XCTAssertEqual(
      calculator.frame(for: .leftThird, in: screenArea),
      CGRect(x: 0, y: 0, width: 100, height: 90)
    )
  }

  func testTopThirdSplitsHeightIntoThirds() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 90)
    XCTAssertEqual(
      calculator.frame(for: .topThird, in: screenArea),
      CGRect(x: 0, y: 60, width: 300, height: 30)
    )
  }

  func testRemainingThirdPlacements() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 90)

    XCTAssertEqual(
      calculator.frame(for: .centerThird, in: screenArea),
      CGRect(x: 100, y: 0, width: 100, height: 90)
    )
    XCTAssertEqual(
      calculator.frame(for: .rightThird, in: screenArea),
      CGRect(x: 200, y: 0, width: 100, height: 90)
    )
    XCTAssertEqual(
      calculator.frame(for: .middleThird, in: screenArea),
      CGRect(x: 0, y: 30, width: 300, height: 30)
    )
    XCTAssertEqual(
      calculator.frame(for: .bottomThird, in: screenArea),
      CGRect(x: 0, y: 0, width: 300, height: 30)
    )
  }

  func testLeftTwoThirdsSplitsWidth() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 90)
    XCTAssertEqual(
      calculator.frame(for: .leftTwoThirds, in: screenArea),
      CGRect(x: 0, y: 0, width: 200, height: 90)
    )
  }

  func testRemainingTwoThirdPlacements() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 90)

    XCTAssertEqual(
      calculator.frame(for: .rightTwoThirds, in: screenArea),
      CGRect(x: 100, y: 0, width: 200, height: 90)
    )
    XCTAssertEqual(
      calculator.frame(for: .topTwoThirds, in: screenArea),
      CGRect(x: 0, y: 30, width: 300, height: 60)
    )
    XCTAssertEqual(
      calculator.frame(for: .bottomTwoThirds, in: screenArea),
      CGRect(x: 0, y: 0, width: 300, height: 60)
    )
  }

  func testGridPlacementCalculatesBottomRowCell() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 200)
    XCTAssertEqual(
      calculator.frame(
        for: .grid(columns: 3, rows: 2, column: 1, row: 0, columnSpan: 2, rowSpan: 1),
        in: screenArea
      ),
      CGRect(x: 100, y: 0, width: 200, height: 100)
    )
  }

  func testGridPlacementCalculatesTopRowCell() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 200)
    XCTAssertEqual(
      calculator.frame(
        for: .grid(columns: 3, rows: 2, column: 1, row: 1, columnSpan: 1, rowSpan: 1),
        in: screenArea
      ),
      CGRect(x: 100, y: 100, width: 100, height: 100)
    )
  }

  func testGridPlacementClampsInvalidInputs() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 200)

    XCTAssertEqual(
      calculator.frame(
        for: .grid(columns: 0, rows: -1, column: -10, row: 99, columnSpan: 99, rowSpan: 99),
        in: screenArea
      ),
      CGRect(x: 0, y: 0, width: 300, height: 200)
    )
  }

  func testNegativeInsetClampsToZero() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)

    XCTAssertEqual(
      calculator.frame(for: .fill, in: screenArea, inset: -50),
      screenArea
    )
  }

  func testOversizedInsetClampsToAvailableArea() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)

    XCTAssertEqual(
      calculator.frame(for: .fill, in: screenArea, inset: 500),
      CGRect(x: 110, y: 120, width: 100, height: 0)
    )
  }

  func testNonFiniteInsetClampsToAvailableArea() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)

    XCTAssertEqual(
      calculator.frame(for: .fill, in: screenArea, inset: .infinity),
      CGRect(x: 110, y: 120, width: 100, height: 0)
    )

    XCTAssertEqual(
      calculator.frame(for: .fill, in: screenArea, inset: .nan),
      screenArea
    )
  }

  func testFrameStandardizesScreenAreaBeforePlacement() {
    let screenArea = CGRect(x: 310, y: 220, width: -300, height: -200)

    XCTAssertEqual(
      calculator.frame(for: .fill, in: screenArea, inset: 10),
      CGRect(x: 20, y: 30, width: 280, height: 180)
    )
  }

  func testCenteredClampsRatiosToZeroToOne() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)
    XCTAssertEqual(
      calculator.frame(for: .centered(widthRatio: 2, heightRatio: -1), in: screenArea),
      CGRect(x: 0, y: 50, width: 200, height: 0)
    )
  }

  func testCenteredClampsNonFiniteRatios() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)

    XCTAssertEqual(
      calculator.frame(for: .centered(widthRatio: .infinity, heightRatio: .nan), in: screenArea),
      CGRect(x: 0, y: 50, width: 200, height: 0)
    )
  }

  func testCenteredUsesRatiosWithinBounds() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)

    XCTAssertEqual(
      calculator.frame(for: .centered(widthRatio: 0.5, heightRatio: 0.4), in: screenArea),
      CGRect(x: 50, y: 30, width: 100, height: 40)
    )
  }

  func testWindowPlacementCalculatorIsSendable() {
    assertSendable(WindowPlacementCalculator())
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
