import ApplicationServices
import WindowKit

/// Reads Accessibility role metadata for target windows.
@MainActor
public struct AXWindowRoleProvider: WindowRoleProviding {
  private let resolver: AXWindowElementResolver
  private let roleResolver = WindowRoleResolver()

  /// Creates a role provider backed by the system-wide Accessibility element.
  public init() {
    self.init(
      systemWideElement: AXAPI.createSystemWideElement(),
      applicationChecker: NSRunningApplicationChecker()
    )
  }

  init(
    systemWideElement: AXUIElement,
    applicationChecker: any RunningApplicationChecking =
      NSRunningApplicationChecker(),
    windowListInfoProvider: any CGWindowListInfoProviding = SystemCGWindowListInfoProvider()
  ) {
    resolver = AXWindowElementResolver(
      systemWideElement: systemWideElement,
      applicationChecker: applicationChecker,
      windowListInfoProvider: windowListInfoProvider
    )
  }

  /// Returns the app-facing role classification for a target window.
  public func role(for target: WindowTarget) throws -> WindowRole {
    let window = try resolver.windowElement(for: target)
    let role = try window.attributeString(kAXRoleAttribute)
    let subrole = try window.attributeString(kAXSubroleAttribute)
    return roleResolver.resolve(role: role, subrole: subrole)
  }
}
