import ApplicationServices
import XCTest

@testable import WindowKitAppKit

final class WindowRoleResolverTests: XCTestCase {
  func testResolveClassifiesStandardWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(resolver.resolve(role: kAXWindowRole as String, subrole: nil), .standard)
    XCTAssertEqual(
      resolver.resolve(role: kAXWindowRole as String, subrole: kAXStandardWindowSubrole as String),
      .standard
    )
  }

  func testResolveClassifiesDialogWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(role: kAXWindowRole as String, subrole: kAXDialogSubrole as String),
      .dialog
    )
  }

  func testResolveClassifiesSheetWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(resolver.resolve(role: kAXSheetRole as String, subrole: nil), .sheet)
    XCTAssertEqual(
      resolver.resolve(role: kAXSheetRole as String, subrole: kAXDialogSubrole as String),
      .sheet
    )
  }

  func testResolveClassifiesPanelWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(resolver.resolve(role: "AXPanel", subrole: nil), .panel)
    XCTAssertEqual(
      resolver.resolve(role: kAXWindowRole as String, subrole: kAXFloatingWindowSubrole as String),
      .panel
    )
    XCTAssertEqual(
      resolver.resolve(
        role: kAXWindowRole as String,
        subrole: kAXSystemFloatingWindowSubrole as String
      ),
      .panel
    )
  }

  func testResolveClassifiesPopoverWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(resolver.resolve(role: kAXPopoverRole as String, subrole: nil), .popover)
    XCTAssertEqual(
      resolver.resolve(role: kAXPopoverRole as String, subrole: kAXDialogSubrole as String),
      .popover
    )
  }

  func testResolveClassifiesSystemDialogWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(role: kAXWindowRole as String, subrole: kAXSystemDialogSubrole as String),
      .systemDialog
    )
  }

  func testResolveClassifiesWindowBySubroleWhenRoleIsUnavailable() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(resolver.resolve(role: nil, subrole: kAXDialogSubrole as String), .dialog)
  }

  func testResolvePreservesUnknownRoleMetadata() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(role: "Custom", subrole: "Other"), .unknown(role: "Custom", subrole: "Other")
    )
    XCTAssertEqual(
      resolver.resolve(role: kAXDialogSubrole as String, subrole: nil),
      .unknown(role: kAXDialogSubrole as String, subrole: nil)
    )
    XCTAssertEqual(
      resolver.resolve(role: kAXWindowRole as String, subrole: "AXUtilityWindow"),
      .unknown(role: kAXWindowRole as String, subrole: "AXUtilityWindow")
    )
  }

  func testResolveReturnsUnknownWhenRoleAndSubroleAreMissing() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(resolver.resolve(role: nil, subrole: nil), .unknown(role: nil, subrole: nil))
  }
}
