import Darwin

/// Resolves owner bundle identifiers while enriching window snapshots.
public protocol WindowOwnerBundleIdentifierProviding: Sendable {
  /// Returns the bundle identifier for the given process identifier, when available.
  func bundleIdentifier(forProcessIdentifier pid: pid_t) -> String?
}
