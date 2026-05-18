import WindowKit
import XCTest

@testable import WindowKitAppKit

final class NSRunningApplicationAdaptersTests: XCTestCase {
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

  func testAdaptersAreSendable() {
    assertSendable(NSRunningApplicationBundleIdentifierProvider())
    assertSendable(NSRunningApplicationChecker())
  }

  func testRunningApplicationCheckerReturnsFalseForUnknownProcessIdentifier() {
    let checker = NSRunningApplicationChecker()
    XCTAssertFalse(checker.isRunningApplication(processIdentifier: unknownProcessIdentifier))
  }

  func testRunningApplicationCheckerCanBeUsedThroughCheckingProtocol() {
    let checker: any RunningApplicationChecking = NSRunningApplicationChecker()

    XCTAssertFalse(checker.isRunningApplication(processIdentifier: unknownProcessIdentifier))
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}
