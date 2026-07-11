import XCTest

@testable import WindowKitAppKit

final class WindowRoleResolverTests: XCTestCase {
  func testResolveClassifiesStandardWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: nil),
      .standard)
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.standardWindow.accessibilityName),
      .standard
    )
  }

  func testResolveClassifiesDialogWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName
      ),
      .dialog
    )
  }

  func testResolveClassifiesSheetWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.sheet.accessibilityName,
        accessibilitySubrole: nil), .sheet
    )
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.sheet.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName),
      .sheet
    )
  }

  func testResolveClassifiesPanelWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.panel.accessibilityName,
        accessibilitySubrole: nil), .panel)
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.floatingWindow.accessibilityName),
      .panel
    )
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.systemFloatingWindow.accessibilityName
      ),
      .panel
    )
  }

  func testResolveClassifiesPopoverWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.popover.accessibilityName,
        accessibilitySubrole: nil),
      .popover)
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.popover.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName),
      .popover
    )
  }

  func testResolveClassifiesSystemDialogWindow() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: AXWindowSubroleValue.systemDialog.accessibilityName),
      .systemDialog
    )
  }

  func testResolvePreservesSubroleMetadataWhenRoleIsUnavailable() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: nil,
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName),
      .unclassified(
        accessibilityRole: nil,
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName
      )
    )
  }

  func testResolvePreservesUnclassifiedRoleMetadata() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(accessibilityRole: "Custom", accessibilitySubrole: "Other"),
      .unclassified(accessibilityRole: "Custom", accessibilitySubrole: "Other")
    )
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowSubroleValue.dialog.accessibilityName,
        accessibilitySubrole: nil),
      .unclassified(
        accessibilityRole: AXWindowSubroleValue.dialog.accessibilityName,
        accessibilitySubrole: nil)
    )
    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: "AXUtilityWindow"),
      .unclassified(
        accessibilityRole: AXWindowRoleValue.window.accessibilityName,
        accessibilitySubrole: "AXUtilityWindow")
    )
  }

  func testResolvePreservesUnknownRoleEvenWhenSubroleIsKnown() {
    let resolver = WindowRoleResolver()

    XCTAssertEqual(
      resolver.resolve(
        accessibilityRole: "CustomRole",
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName
      ),
      .unclassified(
        accessibilityRole: "CustomRole",
        accessibilitySubrole: AXWindowSubroleValue.dialog.accessibilityName
      )
    )
  }

  func testResolveReturnsUnclassifiedRoleWhenRoleAndSubroleAreMissing() {
    let resolver = WindowRoleResolver()
    XCTAssertEqual(
      resolver.resolve(accessibilityRole: nil, accessibilitySubrole: nil),
      .unclassified(accessibilityRole: nil, accessibilitySubrole: nil))
  }
}
