import ApplicationServices
import WindowKit

/// Controls live macOS window commands through Accessibility actions and attributes.
@MainActor
public struct AXWindowCommandController: WindowCommandControlling {
  private let resolver: AXWindowElementResolver

  /// Creates a command controller backed by the system-wide Accessibility element.
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

  /// Sets the target window's minimized state.
  public func setMinimized(_ target: WindowTarget, isMinimized: Bool) throws {
    let window = try resolver.windowElement(for: target)
    try window.setAttributeBool(kAXMinimizedAttribute, value: isMinimized)
  }

  /// Sets the target window's full-screen state.
  public func setFullScreen(_ target: WindowTarget, isFullScreen: Bool) throws {
    let window = try resolver.windowElement(for: target)
    try window.setAttributeBool(AXWindowAttributeName.fullScreen, value: isFullScreen)
  }

  /// Raises the target window above other windows when the system allows it.
  public func raise(_ target: WindowTarget) throws {
    let window = try resolver.windowElement(for: target)
    try window.performAction(kAXRaiseAction)
  }

  /// Lowers the target window when the system exposes the Accessibility action.
  public func lower(_ target: WindowTarget) throws {
    let window = try resolver.windowElement(for: target)
    try window.performAction(AXWindowActionName.lower)
  }
}
