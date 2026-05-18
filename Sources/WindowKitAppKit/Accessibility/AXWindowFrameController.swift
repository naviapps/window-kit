import ApplicationServices
import CoreGraphics
import WindowKit

/// Reads and writes live macOS window frames through Accessibility attributes.
@MainActor
public struct AXWindowFrameController: WindowFrameControlling {
  private let resolver: AXWindowElementResolver

  /// Creates a frame controller backed by the system-wide Accessibility element.
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

  /// Returns the current frame of the target window.
  public func frame(for target: WindowTarget) throws -> CGRect {
    let window = try resolver.windowElement(for: target)
    let position = try window.attributeCGPoint(kAXPositionAttribute)
    let size = try window.attributeCGSize(kAXSizeAttribute)
    return CGRect(origin: position, size: size)
  }

  /// Sets the frame of the target window.
  public func setFrame(_ frame: CGRect, for target: WindowTarget) throws {
    let window = try resolver.windowElement(for: target)
    try window.setAttributeValue(kAXPositionAttribute, value: frame.origin.axValue())
    try window.setAttributeValue(kAXSizeAttribute, value: frame.size.axValue())
  }
}
