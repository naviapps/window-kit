import CoreGraphics
import WindowKit
import XCTest

final class WindowPlacementCalculatorTests: XCTestCase {
  func testFillReturnsInsetScreenArea() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)
    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea, inset: 10),
      CGRect(x: 20, y: 30, width: 280, height: 180)
    )
  }

  func testGridPlacementCalculatesBottomRowCell() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 200)
    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .grid(columns: 3, rows: 2, column: 1, row: 0, columnSpan: 2, rowSpan: 1),
        in: screenArea
      ),
      CGRect(x: 100, y: 0, width: 200, height: 100)
    )
  }

  func testGridPlacementCalculatesTopRowCell() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 200)
    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .grid(columns: 3, rows: 2, column: 1, row: 1, columnSpan: 1, rowSpan: 1),
        in: screenArea
      ),
      CGRect(x: 100, y: 100, width: 100, height: 100)
    )
  }

  func testGridPlacementClampsInvalidInputs() {
    let screenArea = CGRect(x: 0, y: 0, width: 300, height: 200)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .grid(columns: 0, rows: -1, column: -10, row: 99, columnSpan: 99, rowSpan: 99),
        in: screenArea
      ),
      CGRect(x: 0, y: 0, width: 300, height: 200)
    )
  }

  func testNegativeInsetClampsToZero() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea, inset: -50),
      screenArea
    )
  }

  func testOversizedInsetClampsToAvailableArea() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea, inset: 500),
      CGRect(x: 110, y: 120, width: 100, height: 0)
    )
  }

  func testNonFiniteInsetClampsToAvailableArea() {
    let screenArea = CGRect(x: 10, y: 20, width: 300, height: 200)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea, inset: .infinity),
      CGRect(x: 110, y: 120, width: 100, height: 0)
    )

    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea, inset: .nan),
      screenArea
    )
  }

  func testFrameStandardizesScreenAreaBeforePlacement() {
    let screenArea = CGRect(x: 310, y: 220, width: -300, height: -200)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea, inset: 10),
      CGRect(x: 20, y: 30, width: 280, height: 180)
    )
  }

  func testFrameSanitizesNonFiniteScreenAreaBeforePlacement() {
    let screenArea = CGRect(
      x: CGFloat.infinity,
      y: CGFloat.nan,
      width: CGFloat.infinity,
      height: -CGFloat.infinity
    )

    XCTAssertEqual(
      WindowPlacementCalculator.frame(for: .fill, in: screenArea),
      CGRect(x: 0, y: 0, width: 0, height: 0)
    )
    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .centered(widthRatio: 0.5, heightRatio: 0.5), in: screenArea),
      CGRect(x: 0, y: 0, width: 0, height: 0)
    )
  }

  func testCenteredClampsRatiosToZeroToOne() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)
    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .centered(widthRatio: 2, heightRatio: -1), in: screenArea),
      CGRect(x: 0, y: 50, width: 200, height: 0)
    )
  }

  func testCenteredClampsNonFiniteRatios() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .centered(widthRatio: .infinity, heightRatio: .nan), in: screenArea),
      CGRect(x: 0, y: 50, width: 200, height: 0)
    )
  }

  func testCenteredUsesRatiosWithinBounds() {
    let screenArea = CGRect(x: 0, y: 0, width: 200, height: 100)

    XCTAssertEqual(
      WindowPlacementCalculator.frame(
        for: .centered(widthRatio: 0.5, heightRatio: 0.4), in: screenArea),
      CGRect(x: 50, y: 30, width: 100, height: 40)
    )
  }

}
