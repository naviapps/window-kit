import AppKit
import WindowKit

/// Bundle identifier provider backed by `NSRunningApplication`.
public struct NSRunningApplicationBundleIdentifierProvider: WindowOwnerBundleIdentifierProviding {
  /// Creates a running-application bundle identifier provider.
  public init() {}

  /// Returns the bundle identifier for a running application process.
  public func bundleIdentifier(forProcessIdentifier pid: pid_t) -> String? {
    NSRunningApplication(processIdentifier: pid)?.bundleIdentifier
  }
}

protocol RunningApplicationChecking: Sendable {
  func isRunningApplication(processIdentifier: pid_t) -> Bool
}

struct NSRunningApplicationChecker: RunningApplicationChecking {
  init() {}

  func isRunningApplication(processIdentifier pid: pid_t) -> Bool {
    NSRunningApplication(processIdentifier: pid) != nil
  }
}
