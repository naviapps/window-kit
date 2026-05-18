import ApplicationServices
import WindowKit

/// Reads live macOS window state through Accessibility attributes.
@MainActor
public struct AXWindowStateProvider: WindowStateProviding {
  private let resolver: AXWindowElementResolver

  /// Creates a state provider backed by the system-wide Accessibility element.
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

  /// Returns the current app-facing state for the target window.
  public func state(for target: WindowTarget) throws -> WindowState {
    let window = try resolver.windowElement(for: target)
    let isMinimized = try window.attributeBool(kAXMinimizedAttribute)
    let isFullScreen = try window.attributeBool(AXWindowAttributeName.fullScreen)
    return WindowState(isMinimized: isMinimized, isFullScreen: isFullScreen)
  }
}
