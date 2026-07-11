import AppKit

/// Bundle identifier provider backed by `NSRunningApplication`.
public struct NSRunningApplicationBundleIdentifierProvider:
  WindowOwnerBundleIdentifierProviding
{
  /// Creates a running-application bundle identifier provider.
  public init() {}

  /// Returns the bundle identifier for a running application process.
  public func bundleIdentifier(forProcessIdentifier pid: pid_t) -> String? {
    NSRunningApplication(processIdentifier: pid)?.bundleIdentifier
  }
}
