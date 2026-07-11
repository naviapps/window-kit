import CoreGraphics
import WindowKit
import XCTest

final class WindowPlacementTests: XCTestCase {
  func testWindowPlacementValueConformance() throws {
    let placements: [WindowPlacement] = [
      .fill,
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
