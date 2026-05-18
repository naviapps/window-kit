import WindowKit
import WindowKitAppKit
import XCTest

final class AppKitFactoriesTests: XCTestCase {
  func testWindowHitTesterFactorySupportsDefaultAndConfiguredPublicAPI() {
    let defaultHitTester: any WindowHitTesting = WindowHitTester.appKit()
    let hitTester = WindowHitTester.appKit(
      pointTransform: { $0 },
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.app"])
    )
    let publicValue: any WindowHitTesting = hitTester

    assertSendable(hitTester)
    _ = defaultHitTester
    _ = publicValue
  }

  func testWindowSnapshotQueryFactorySupportsDefaultAndConfiguredPublicAPI() {
    let defaultQuery: any WindowSnapshotProviding = WindowSnapshotQuery.appKit()
    let query = WindowSnapshotQuery.appKit(
      filter: WindowSnapshotFilter(includedOwnerBundleIdentifiers: ["com.example.app"]),
      limitsToTopmostWindow: true
    )
    let publicValue: any WindowSnapshotProviding = query

    assertSendable(query)
    _ = defaultQuery
    _ = publicValue
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
