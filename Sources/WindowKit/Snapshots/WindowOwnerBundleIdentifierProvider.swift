import Darwin

/// Resolves an owner bundle identifier for a process identifier.
public protocol WindowOwnerBundleIdentifierProviding: Sendable {
  /// Returns the bundle identifier for the given process identifier, when available.
  func bundleIdentifier(forProcessIdentifier pid: pid_t) -> String?
}

/// Bundle identifier provider that always returns `nil`.
public struct NullWindowOwnerBundleIdentifierProvider: WindowOwnerBundleIdentifierProviding {
  /// Creates a null bundle identifier provider.
  public init() {}

  /// Always returns `nil`.
  public func bundleIdentifier(forProcessIdentifier _: pid_t) -> String? {
    nil
  }
}
