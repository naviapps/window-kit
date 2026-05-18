import CoreGraphics
import XCTest

@testable import WindowKit

final class WindowPlacementTests: XCTestCase {
  func testWindowPlacementValueConformance() throws {
    let placements: [WindowPlacement] = [
      .fill,
      .leftHalf,
      .rightHalf,
      .topHalf,
      .bottomHalf,
      .topLeftQuarter,
      .topRightQuarter,
      .bottomLeftQuarter,
      .bottomRightQuarter,
      .leftThird,
      .centerThird,
      .rightThird,
      .topThird,
      .middleThird,
      .bottomThird,
      .leftTwoThirds,
      .rightTwoThirds,
      .topTwoThirds,
      .bottomTwoThirds,
      .grid(columns: 3, rows: 2, column: 1, row: 0, columnSpan: 2, rowSpan: 1),
      .centered(widthRatio: 0.5, heightRatio: 0.5),
    ]

    for placement in placements {
      try assertValueConformance(placement)
    }
  }

  func testWindowPlacementIsSendable() {
    assertSendable(WindowPlacement.fill)
    assertSendable(
      WindowPlacement.grid(columns: 3, rows: 2, column: 1, row: 0, columnSpan: 2, rowSpan: 1)
    )
    assertSendable(WindowPlacement.centered(widthRatio: 0.5, heightRatio: 0.5))
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
