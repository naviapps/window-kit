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

struct WindowListProviderStub: WindowListProviding {
  let entries: [WindowListEntry]?

  init(entries: [WindowListEntry]?) {
    self.entries = entries
  }

  init(ownerProcessIdentifier: pid_t, windowIdentifier: CGWindowID = 42) {
    entries = [
      WindowListEntry(
        ownerProcessIdentifier: ownerProcessIdentifier,
        windowIdentifier: windowIdentifier
      )
    ]
  }

  func windowList(for _: WindowListRequest) -> [WindowListEntry]? {
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

  func accessibilityClient(
    additionalHandler:
      @escaping (
        AXUIElement,
        CFString,
        UnsafeMutablePointer<CFTypeRef?>
      ) -> AXError = { _, _, value in
        value.pointee = nil
        return .noValue
      },
    setAttributeValue: @escaping (AXUIElement, CFString, CFTypeRef) -> AXError = { _, _, _ in
      .success
    },
    valueCreate: @escaping (AXValueType, UnsafeRawPointer) -> AXValue? = AXValueCreate,
    performAction: @escaping (AXUIElement, CFString) -> AXError = { _, _ in .success }
  ) -> AXClient {
    let focusedAppAttribute = AXWindowAttribute.focusedApplication.accessibilityName
    let focusedWindowAttribute = AXWindowAttribute.focusedWindow.accessibilityName

    return .testing(
      copyAttributeValue: { element, attribute, value in
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
      },
      setAttributeValue: setAttributeValue,
      valueCreate: valueCreate,
      performAction: performAction
    )
  }

  func commandController(
    accessibilityClient: AXClient? = nil,
    isRunningApplication: Bool = false
  ) -> AXWindowController {
    AXWindowController(
      accessibilityClient: accessibilityClient ?? self.accessibilityClient(),
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }

  func frameController(
    accessibilityClient: AXClient? = nil,
    isRunningApplication: Bool = false
  ) -> AXWindowController {
    AXWindowController(
      accessibilityClient: accessibilityClient ?? self.accessibilityClient(),
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }

  func stateProvider(
    accessibilityClient: AXClient? = nil,
    isRunningApplication: Bool = false
  ) -> AXWindowController {
    AXWindowController(
      accessibilityClient: accessibilityClient ?? self.accessibilityClient(),
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }

  func roleProvider(
    accessibilityClient: AXClient? = nil,
    isRunningApplication: Bool = false
  ) -> AXWindowController {
    AXWindowController(
      accessibilityClient: accessibilityClient ?? self.accessibilityClient(),
      systemWideElement: systemWideElement,
      applicationChecker: RunningApplicationCheckerStub(
        isRunning: isRunningApplication)
    )
  }
}
