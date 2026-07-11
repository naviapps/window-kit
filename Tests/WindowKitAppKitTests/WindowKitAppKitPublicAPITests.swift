import CoreGraphics
import WindowKit
import WindowKitAppKit
import XCTest

@MainActor
final class WindowKitAppKitPublicAPITests: XCTestCase {
  func testPlacementAndRoleAPIsAreUsableFromPublicImport() throws {
    let frameController = PublicFrameController(
      frame: CGRect(x: 0, y: 0, width: 100, height: 100)
    )
    let frameProvider: any WindowFrameProviding = frameController
    let commandController = PublicCommandController()
    let stateProvider: any WindowStateProviding = PublicStateProvider(
      state: WindowState(isMinimized: false, isFullScreen: false)
    )
    let screenProvider = PublicScreenProvider(screens: [publicScreen()])
    let placer = WindowPlacer(frameController: frameController, screenProvider: screenProvider)
    let defaultPlacer = WindowPlacer()
    let roleProvider: any WindowRoleProviding = PublicRoleProvider(role: WindowRole.standard)

    try placer.place(WindowPlacement.fill, for: WindowTarget.windowIdentifier(1))
    XCTAssertEqual(
      try frameProvider.frame(for: .focused), CGRect(x: 0, y: 0, width: 100, height: 100))
    XCTAssertEqual(try stateProvider.state(for: .focused).isMinimized, false)
    try commandController.raise(.focused)
    XCTAssertEqual(commandController.raisedTarget, .focused)
    XCTAssertEqual(try roleProvider.role(for: .focused), .standard)
    XCTAssertEqual(WindowPlacerError.screenNotFound(.main), .screenNotFound(.main))
    XCTAssertEqual(WindowRole.dialog, .dialog)
    XCTAssertEqual(
      WindowRole.unclassified(accessibilityRole: "AXWindow", accessibilitySubrole: nil),
      .unclassified(accessibilityRole: "AXWindow", accessibilitySubrole: nil)
    )
    withExtendedLifetime(defaultPlacer) {}
  }

  func testAppKitHitTestingAndSnapshotQueriesAreUsableFromPublicImport() {
    let defaultHitTester: any WindowHitTesting = WindowHitTester()
    let configuredHitTester: any WindowHitTesting = WindowHitTester(
      pointTransform: { $0 },
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.app"])
    )
    let ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      PublicOwnerBundleIdentifierProvider(bundleIdentifier: "com.example.app")
    let query = WindowSnapshotQuery(
      ownerBundleIdentifierProvider: ownerBundleIdentifierProvider,
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.app"]),
      limit: WindowSnapshotQueryLimit.topmostMatchingWindow
    )
    let snapshots: () throws -> [WindowSnapshot] = query.snapshots
    let snapshot: (CGWindowID) throws -> WindowSnapshot? = query.snapshot(for:)

    XCTAssertNotNil(defaultHitTester)
    XCTAssertNotNil(configuredHitTester)
    assertPublicSendableValue(WindowHitTester())
    assertPublicSendableValue(query)
    withExtendedLifetime(snapshots) {}
    withExtendedLifetime(snapshot) {}
    XCTAssertEqual(WindowSnapshotQueryError.windowListUnavailable, .windowListUnavailable)
    XCTAssertNotNil(NSRunningApplicationBundleIdentifierProvider())
    XCTAssertNotNil(NSScreenProvider())
  }

  func testAccessibilityImplementationsAreUsableFromPublicImport() {
    let controller = AXWindowController()
    let windowController: any WindowControlling = controller
    let frameController: any WindowFrameControlling = controller
    let commandController: any WindowCommandControlling = controller
    let stateProvider: any WindowStateProviding = controller
    let roleProvider: any WindowRoleProviding = controller

    assertPublicSendableValue(controller)
    withExtendedLifetime(windowController) {}
    withExtendedLifetime(frameController) {}
    withExtendedLifetime(commandController) {}
    withExtendedLifetime(stateProvider) {}
    withExtendedLifetime(roleProvider) {}
  }

  func testDocumentationExamplesAreUsableWithoutTestableImport() throws {
    let query = WindowSnapshotQuery()
    let snapshots: () throws -> [WindowSnapshot] = query.snapshots
    let snapshot: (CGWindowID) throws -> WindowSnapshot? = query.snapshot(for:)
    let hitTester = WindowHitTester()
    let topmost: (CGPoint) -> WindowSnapshot? = hitTester.topmost(at:)
    let placer = WindowPlacer()
    let place: (WindowPlacement, WindowTarget) throws -> Void = {
      try placer.place($0, for: $1)
    }

    withExtendedLifetime(snapshots) {}
    withExtendedLifetime(snapshot) {}
    withExtendedLifetime(topmost) {}
    withExtendedLifetime(place) {}
  }

  func testPublicValueConformancesAreUsableFromPublicImport() throws {
    try assertValueConformance(WindowRole.self, WindowRole.standard)
    try assertValueConformance(
      WindowRole.self,
      WindowRole.unclassified(accessibilityRole: "AXWindow", accessibilitySubrole: nil)
    )
    try assertValueConformance(
      WindowAccessibilityOperation.self,
      WindowAccessibilityOperation.raise
    )
    try assertValueConformance(
      WindowAccessibilityOperationFailure.self,
      WindowAccessibilityOperationFailure.cannotComplete
    )
    try assertValueConformance(
      WindowSnapshotQueryLimit.self,
      WindowSnapshotQueryLimit.allMatchingWindows
    )

    assertPublicSendableValue(WindowAccessibilityError.accessibilityNotTrusted)
    assertPublicSendableValue(WindowPlacer())
    assertPublicSendableValue(WindowPlacerError.screenNotFound(.main))
    assertPublicSendableValue(WindowSnapshotQuery())
    assertPublicSendableValue(WindowSnapshotQueryError.windowListUnavailable)
    assertSendable((any WindowRoleProviding).self)
    assertSendable((any WindowOwnerBundleIdentifierProviding).self)
  }
}

private func publicScreen() -> WindowScreen {
  WindowScreen(
    displayIdentifier: 1,
    frame: CGRect(x: 0, y: 0, width: 800, height: 600),
    visibleFrame: CGRect(x: 0, y: 0, width: 800, height: 560),
    isMain: true
  )
}

@MainActor
private final class PublicFrameController: WindowFrameControlling {
  private let frame: CGRect
  private(set) var assignedFrame: CGRect?

  init(frame: CGRect) {
    self.frame = frame
  }

  func frame(for _: WindowTarget) throws -> CGRect {
    frame
  }

  func setFrame(_ frame: CGRect, for _: WindowTarget) throws {
    assignedFrame = frame
  }
}

private struct PublicScreenProvider: WindowScreenProviding {
  let screensValue: [WindowScreen]

  init(screens: [WindowScreen]) {
    screensValue = screens
  }

  func screens() -> [WindowScreen] {
    screensValue
  }
}

private struct PublicOwnerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviding {
  let bundleIdentifierValue: String?

  init(bundleIdentifier: String?) {
    bundleIdentifierValue = bundleIdentifier
  }

  func bundleIdentifier(forProcessIdentifier _: pid_t) -> String? {
    bundleIdentifierValue
  }
}

@MainActor
private final class PublicCommandController: WindowCommandControlling {
  private(set) var raisedTarget: WindowTarget?

  func setMinimized(_: WindowTarget, isMinimized _: Bool) throws {}
  func setFullScreen(_: WindowTarget, isFullScreen _: Bool) throws {}

  func raise(_ target: WindowTarget) throws {
    raisedTarget = target
  }

  func lower(_: WindowTarget) throws {}
}

@MainActor
private struct PublicRoleProvider: WindowRoleProviding {
  let roleValue: WindowRole

  init(role: WindowRole) {
    roleValue = role
  }

  func role(for _: WindowTarget) throws -> WindowRole {
    roleValue
  }
}

@MainActor
private struct PublicStateProvider: WindowStateProviding {
  let stateValue: WindowState

  init(state: WindowState) {
    stateValue = state
  }

  func state(for _: WindowTarget) throws -> WindowState {
    stateValue
  }
}

private func assertPublicSendableValue<Value: Sendable>(_: Value) {}
