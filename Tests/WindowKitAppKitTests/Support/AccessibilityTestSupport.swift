import ApplicationServices
import CoreGraphics
import Foundation

@testable import WindowKitAppKit

struct RunningApplicationCheckerStub: RunningApplicationChecking {
  let isRunning: Bool

  init(isRunning: Bool = true) {
    self.isRunning = isRunning
  }

  func isRunningApplication(processIdentifier _: pid_t) -> Bool {
    isRunning
  }
}

struct CGWindowListInfoProviderStub: CGWindowListInfoProviding, @unchecked Sendable {
  let entries: [CGWindowListInfoEntry]?

  init(entries: [CGWindowListInfoEntry]?) {
    self.entries = entries
  }

  init(ownerProcessIdentifier: pid_t) {
    entries = [[kCGWindowOwnerPID as String: NSNumber(value: ownerProcessIdentifier)]]
  }

  func windowListInfo(options _: CGWindowListOption, relativeToWindow _: CGWindowID)
    -> [CGWindowListInfoEntry]?
  {
    entries
  }
}

@MainActor
struct FocusedWindowAXFixture {
  let systemWideElement: AXUIElement
  let appElement: AXUIElement
  let windowElement: AXUIElement

  init(
    processIdentifier: pid_t = getpid(),
    windowProcessIdentifier: pid_t? = nil
  ) {
    systemWideElement = AXUIElementCreateSystemWide()
    appElement = AXUIElementCreateApplication(processIdentifier)
    windowElement = AXUIElementCreateApplication(windowProcessIdentifier ?? processIdentifier + 1)
  }

  func installCopyAttributeValue(
    additionalHandler:
      @escaping (
        AXUIElement,
        CFString,
        UnsafeMutablePointer<CFTypeRef?>
      ) -> AXError = { _, _, value in
        value.pointee = nil
        return .noValue
      }
  ) {
    let focusedAppAttribute = kAXFocusedApplicationAttribute as String
    let focusedWindowAttribute = kAXFocusedWindowAttribute as String

    AXAPI.copyAttributeValue = { element, attribute, value in
      switch attribute as String {
      case focusedAppAttribute where CFEqual(element, systemWideElement):
        value.pointee = appElement
        return .success
      case focusedWindowAttribute where CFEqual(element, appElement):
        value.pointee = windowElement
        return .success
      default:
        return additionalHandler(element, attribute, value)
      }
    }
  }

  func commandController(
    isRunningApplication: Bool = false
  ) -> AXWindowCommandController {
    AXWindowCommandController(
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }

  func frameController(
    isRunningApplication: Bool = false
  ) -> AXWindowFrameController {
    AXWindowFrameController(
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }

  func stateProvider(
    isRunningApplication: Bool = false
  ) -> AXWindowStateProvider {
    AXWindowStateProvider(
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }

  func roleProvider(
    isRunningApplication: Bool = false
  ) -> AXWindowRoleProvider {
    AXWindowRoleProvider(
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }
}
