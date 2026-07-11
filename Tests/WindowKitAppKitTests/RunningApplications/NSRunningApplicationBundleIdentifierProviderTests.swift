import WindowKitAppKit
import XCTest

final class NSRunningApplicationBundleIdentifierProviderTests: XCTestCase {
  private let unknownProcessIdentifier = pid_t(-1)

  func testBundleIdentifierProviderCanBeUsedThroughOwnerBundleIdentifierProvidingProtocol() {
    let provider: any WindowOwnerBundleIdentifierProviding =
      NSRunningApplicationBundleIdentifierProvider()

    XCTAssertNil(provider.bundleIdentifier(forProcessIdentifier: unknownProcessIdentifier))
  }

  func testBundleIdentifierProviderReturnsNilForUnknownProcessIdentifier() {
    let provider = NSRunningApplicationBundleIdentifierProvider()
    XCTAssertNil(provider.bundleIdentifier(forProcessIdentifier: unknownProcessIdentifier))
  }

  func testBundleIdentifierProviderIsSendable() {
    assertSendable(NSRunningApplicationBundleIdentifierProvider())
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
