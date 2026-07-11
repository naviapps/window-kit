import XCTest

@testable import WindowKitAppKit

final class NSRunningApplicationCheckerTests: XCTestCase {
  private let unknownProcessIdentifier = pid_t(-1)

  func testRunningApplicationCheckerIsSendable() {
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
