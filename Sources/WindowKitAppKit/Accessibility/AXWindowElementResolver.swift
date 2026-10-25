import ApplicationServices
import CoreGraphics
import WindowKit

@MainActor
struct AXWindowElementResolver {
  private let accessibilityClient: AXClient
  private let systemWideElement: AXUIElement
  private let applicationChecker: any RunningApplicationChecking
  private let windowListProvider: any WindowListProviding

  init(
    accessibilityClient: AXClient,
    applicationChecker: any RunningApplicationChecking = NSRunningApplicationChecker(),
    windowListProvider: any WindowListProviding = SystemWindowListProvider()
  ) {
    self.init(
      accessibilityClient: accessibilityClient,
      systemWideElement: accessibilityClient.createSystemWideElement(),
      applicationChecker: applicationChecker,
      windowListProvider: windowListProvider
    )
  }

  init(
    accessibilityClient: AXClient = .live,
    systemWideElement: AXUIElement,
    applicationChecker: any RunningApplicationChecking,
    windowListProvider: any WindowListProviding = SystemWindowListProvider()
  ) {
    self.accessibilityClient = accessibilityClient
    self.systemWideElement = systemWideElement
    self.applicationChecker = applicationChecker
    self.windowListProvider = windowListProvider
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
      let focusedApplication = try accessibilityClient.attributeElement(
        .focusedApplication,
        of: systemWideElement)
    else {
      throw AXWindowError.applicationNotFound(.focused)
    }

    guard
      let focusedWindow = try accessibilityClient.attributeElement(
        .focusedWindow,
        of: focusedApplication)
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
      let windowListEntry = windowListProvider.windowList(
        for: .window(windowIdentifier)
      )?.first(where: { $0.windowIdentifier == windowIdentifier }),
      let ownerProcessIdentifier = windowListEntry.ownerProcessIdentifier
    else {
      throw AXWindowError.windowNotFound(target)
    }

    guard
      applicationChecker.isRunningApplication(processIdentifier: ownerProcessIdentifier)
    else {
      throw AXWindowError.applicationNotFound(target)
    }

    let appElement = accessibilityClient.createApplicationElement(ownerProcessIdentifier)
    guard
      let windows = try accessibilityClient.attributeElements(.windows, of: appElement)
    else {
      throw AXWindowError.windowNotFound(target)
    }

    for window in windows {
      do {
        if let axId = try accessibilityClient.attributeUInt32(
          .windowIdentifier,
          of: window),
          axId == windowIdentifier
        {
          return window
        }
      } catch AXWindowError.underlyingAccessibilityError(.invalidUIElement) {
        // A sibling window can close after the application window list was read.
        continue
      }
    }

    throw AXWindowError.windowNotFound(target)
  }

  private func requireAccessibilityTrust() throws {
    guard accessibilityClient.isProcessTrusted() else {
      throw AXWindowError.accessibilityNotTrusted
    }
  }
}
