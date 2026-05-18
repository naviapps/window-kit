import ApplicationServices
import CoreGraphics
import WindowKit

@MainActor
struct AXWindowElementResolver {
  private let systemWideElement: AXUIElement
  private let applicationChecker: any RunningApplicationChecking
  private let windowListInfoProvider: any CGWindowListInfoProviding

  init(
    systemWideElement: AXUIElement,
    applicationChecker: any RunningApplicationChecking,
    windowListInfoProvider: any CGWindowListInfoProviding = SystemCGWindowListInfoProvider()
  ) {
    self.systemWideElement = systemWideElement
    self.applicationChecker = applicationChecker
    self.windowListInfoProvider = windowListInfoProvider
  }

  func windowElement(for target: WindowTarget) throws -> AXUIElement {
    switch target {
    case .focused:
      return try focusedWindowElement()
    case let .windowIdentifier(windowIdentifier):
      return try windowElement(forWindowIdentifier: windowIdentifier)
    }
  }

  private func focusedWindowElement() throws -> AXUIElement {
    try requireAccessibilityTrust()

    guard
      let focusedApplication = try systemWideElement.attributeElement(
        kAXFocusedApplicationAttribute)
    else {
      throw AXWindowError.applicationNotFound(.focused)
    }

    guard let focusedWindow = try focusedApplication.attributeElement(kAXFocusedWindowAttribute)
    else {
      throw AXWindowError.windowNotFound(.focused)
    }

    return focusedWindow
  }

  private func windowElement(forWindowIdentifier windowIdentifier: CGWindowID) throws
    -> AXUIElement
  {
    try requireAccessibilityTrust()
    let target = WindowTarget.windowIdentifier(windowIdentifier)

    guard
      let windowListInfo = windowListInfoProvider.windowListInfo(
        options: [.optionIncludingWindow, .excludeDesktopElements],
        relativeToWindow: windowIdentifier
      ),
      let ownerProcessIdentifierValue = windowListInfo.first?[kCGWindowOwnerPID as String]
        as? NSNumber
    else {
      throw AXWindowError.windowNotFound(target)
    }

    let ownerProcessIdentifier = pid_t(ownerProcessIdentifierValue.int32Value)
    guard
      applicationChecker.isRunningApplication(processIdentifier: ownerProcessIdentifier)
    else {
      throw AXWindowError.applicationNotFound(target)
    }

    let appElement = AXAPI.createApplicationElement(ownerProcessIdentifier)
    guard let windows = try appElement.attributeElements(kAXWindowsAttribute) else {
      throw AXWindowError.windowNotFound(target)
    }

    for window in windows {
      if let axId = try window.attributeUInt32(AXWindowAttributeName.windowIdentifier),
        axId == windowIdentifier
      {
        return window
      }
    }

    throw AXWindowError.windowNotFound(target)
  }

  private func requireAccessibilityTrust() throws {
    guard AXAPI.isProcessTrusted() else {
      throw AXWindowError.accessibilityNotTrusted
    }
  }
}
