import ApplicationServices
import os
import XCTest

import WindowKit
@testable import WindowKitAppKit

@MainActor
final class AXWindowElementResolverTests: XCTestCase {
  func testFocusedTargetReturnsFocusedWindow() throws {
    let systemElement = AXUIElementCreateSystemWide()
    let appElement = AXUIElementCreateApplication(getpid())
    let windowElement = AXUIElementCreateApplication(getpid())

    let focusedApplicationAttribute = AXWindowAttribute.focusedApplication.accessibilityName
    let focusedWindowAttribute = AXWindowAttribute.focusedWindow.accessibilityName
    let accessibilityClient = AXClient.testing(copyAttributeValue: { element, attribute, value in
      switch attribute as String {
      case focusedApplicationAttribute:
        XCTAssertEqual(CFEqual(element, systemElement), true)
        value.pointee = appElement
        return .success
      case focusedWindowAttribute:
        XCTAssertEqual(CFEqual(element, appElement), true)
        value.pointee = windowElement
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: systemElement,
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    let resolved = try resolver.windowElement(for: .focused)
    XCTAssertEqual(CFEqual(resolved, windowElement), true)
  }

  func testFocusedTargetThrowsWhenAccessibilityNotTrusted() {
    let resolver = AXWindowElementResolver(
      accessibilityClient: .testing(isProcessTrusted: { false }),
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .accessibilityNotTrusted)
    }
  }

  func testFocusedTargetThrowsWhenFocusedApplicationMissing() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, _, value in
      value.pointee = nil
      return .noValue
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .applicationNotFound(.focused))
    }
  }

  func testFocusedTargetThrowsInvalidAXValueWhenFocusedApplicationHasUnexpectedType() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      XCTAssertEqual(attribute as String, AXWindowAttribute.focusedApplication.accessibilityName)
      value.pointee = "invalid" as CFString
      return .success
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testFocusedTargetThrowsUnderlyingAccessibilityErrorWhenFocusedApplicationReadFails() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      XCTAssertEqual(attribute as String, AXWindowAttribute.focusedApplication.accessibilityName)
      value.pointee = nil
      return .cannotComplete
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
  }

  func testFocusedTargetThrowsWhenFocusedWindowMissing() {
    let appElement = AXUIElementCreateApplication(getpid())
    let focusedApplicationAttribute = AXWindowAttribute.focusedApplication.accessibilityName
    let focusedWindowAttribute = AXWindowAttribute.focusedWindow.accessibilityName
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      switch attribute as String {
      case focusedApplicationAttribute:
        value.pointee = appElement
        return .success
      case focusedWindowAttribute:
        value.pointee = nil
        return .noValue
      default:
        value.pointee = nil
        return .noValue
      }
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.focused))
    }
  }

  func testWindowIdentifierTargetThrowsWhenAccessibilityNotTrusted() {
    let resolver = AXWindowElementResolver(
      accessibilityClient: .testing(isProcessTrusted: { false }),
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .accessibilityNotTrusted)
    }
  }

  func testWindowIdentifierTargetThrowsWhenRunningApplicationMissing() {
    let applicationChecker = RecordingRunningApplicationChecker(isRunning: false)
    let resolver = AXWindowElementResolver(
      accessibilityClient: .testing(),
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: applicationChecker,
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .applicationNotFound(.windowIdentifier(42)))
    }
    XCTAssertEqual(applicationChecker.requests, [1234])
  }

  func testWindowIdentifierTargetThrowsWhenWindowListIsMissing() {
    let resolver = AXWindowElementResolver(
      accessibilityClient: .testing(),
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false),
      windowListProvider: WindowListProviderStub(entries: nil)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetThrowsWhenOwnerProcessIdentifierIsMissing() {
    let resolver = AXWindowElementResolver(
      accessibilityClient: .testing(),
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false),
      windowListProvider: WindowListProviderStub(entries: [WindowListEntry()])
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetReturnsMatchingAccessibilityWindow() throws {
    let matchedWindow = AXUIElementCreateApplication(getpid())
    let accessibilityClient = AXClient.testing(copyAttributeValue: { element, attribute, value in
      switch attribute as String {
      case AXWindowAttribute.windows.accessibilityName:
        value.pointee = [matchedWindow] as CFArray
        return .success
      case AXWindowAttribute.windowIdentifier.accessibilityName:
        XCTAssertEqual(CFEqual(element, matchedWindow), true)
        value.pointee = NSNumber(value: UInt32(42))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    let resolved = try resolver.windowElement(for: .windowIdentifier(42))
    XCTAssertEqual(CFEqual(resolved, matchedWindow), true)
  }

  func testWindowIdentifierTargetRequestsSingleWindowList() throws {
    let windowListProvider = RecordingWindowListProvider(
      entries: [WindowListEntry(ownerProcessIdentifier: 1234, windowIdentifier: 42)]
    )
    let matchedWindow = AXUIElementCreateApplication(getpid())
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      switch attribute as String {
      case AXWindowAttribute.windows.accessibilityName:
        value.pointee = [matchedWindow] as CFArray
        return .success
      case AXWindowAttribute.windowIdentifier.accessibilityName:
        value.pointee = NSNumber(value: UInt32(42))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: windowListProvider
    )

    _ = try resolver.windowElement(for: .windowIdentifier(42))

    XCTAssertEqual(windowListProvider.requests.count, 1)
    XCTAssertEqual(windowListProvider.requests.first?.windowIdentifier, 42)
    XCTAssertEqual(
      windowListProvider.requests.first?.options,
      [.optionIncludingWindow, .excludeDesktopElements]
    )
  }

  func testWindowIdentifierTargetCreatesApplicationElementForOwnerProcessIdentifier() throws {
    let appElement = AXUIElementCreateApplication(1234)
    let matchedWindow = AXUIElementCreateApplication(getpid())
    var createdApplicationProcessIdentifier: pid_t?
    let accessibilityClient = AXClient.testing(
      createApplicationElement: { processIdentifier in
        createdApplicationProcessIdentifier = processIdentifier
        return appElement
      },
      copyAttributeValue: { element, attribute, value in
        switch attribute as String {
        case AXWindowAttribute.windows.accessibilityName:
          XCTAssertEqual(CFEqual(element, appElement), true)
          value.pointee = [matchedWindow] as CFArray
          return .success
        case AXWindowAttribute.windowIdentifier.accessibilityName:
          XCTAssertEqual(CFEqual(element, matchedWindow), true)
          value.pointee = NSNumber(value: UInt32(42))
          return .success
        default:
          value.pointee = nil
          return .noValue
        }
      }
    )

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    _ = try resolver.windowElement(for: .windowIdentifier(42))

    XCTAssertEqual(createdApplicationProcessIdentifier, 1234)
  }

  func testWindowIdentifierTargetUsesOwnerProcessIdentifierFromMatchingWindowListEntry() throws {
    let appElement = AXUIElementCreateApplication(1234)
    let matchedWindow = AXUIElementCreateApplication(getpid())
    var createdApplicationProcessIdentifier: pid_t?
    let accessibilityClient = AXClient.testing(
      createApplicationElement: { processIdentifier in
        createdApplicationProcessIdentifier = processIdentifier
        return appElement
      },
      copyAttributeValue: { element, attribute, value in
        switch attribute as String {
        case AXWindowAttribute.windows.accessibilityName:
          XCTAssertEqual(CFEqual(element, appElement), true)
          value.pointee = [matchedWindow] as CFArray
          return .success
        case AXWindowAttribute.windowIdentifier.accessibilityName:
          XCTAssertEqual(CFEqual(element, matchedWindow), true)
          value.pointee = NSNumber(value: UInt32(42))
          return .success
        default:
          value.pointee = nil
          return .noValue
        }
      }
    )

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(entries: [
        WindowListEntry(ownerProcessIdentifier: 9999, windowIdentifier: 7),
        WindowListEntry(ownerProcessIdentifier: 1234, windowIdentifier: 42),
      ])
    )

    _ = try resolver.windowElement(for: .windowIdentifier(42))

    XCTAssertEqual(createdApplicationProcessIdentifier, 1234)
  }

  func testWindowIdentifierTargetThrowsWhenApplicationWindowsAreMissing() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      XCTAssertEqual(attribute as String, AXWindowAttribute.windows.accessibilityName)
      value.pointee = nil
      return .noValue
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetThrowsInvalidAXValueWhenApplicationWindowsHaveUnexpectedType() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      XCTAssertEqual(attribute as String, AXWindowAttribute.windows.accessibilityName)
      value.pointee = "invalid" as CFString
      return .success
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testWindowIdentifierTargetThrowsWhenNoAccessibilityWindowMatches() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      switch attribute as String {
      case AXWindowAttribute.windows.accessibilityName:
        value.pointee = [AXUIElementCreateApplication(getpid())] as CFArray
        return .success
      case AXWindowAttribute.windowIdentifier.accessibilityName:
        value.pointee = NSNumber(value: UInt32(7))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetThrowsInvalidAXValueWhenWindowIdentifierHasUnexpectedType() {
    let accessibilityClient = AXClient.testing(copyAttributeValue: { _, attribute, value in
      switch attribute as String {
      case AXWindowAttribute.windows.accessibilityName:
        value.pointee = [AXUIElementCreateApplication(getpid())] as CFArray
        return .success
      case AXWindowAttribute.windowIdentifier.accessibilityName:
        value.pointee = "invalid" as CFString
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    })

    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testWindowIdentifierTargetSkipsInvalidatedSibling() throws {
    let fixture = makeSiblingLookup(siblingError: .invalidUIElement)

    let resolved = try fixture.resolver.windowElement(for: .windowIdentifier(42))

    XCTAssertTrue(CFEqual(resolved, fixture.targetWindow))
  }

  func testWindowIdentifierTargetIsUnavailableWhenOnlySiblingWasInvalidated() {
    let fixture = makeSiblingLookup(siblingError: .invalidUIElement, includesTarget: false)

    XCTAssertThrowsError(try fixture.resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetPropagatesOtherSiblingReadFailures() {
    let fixture = makeSiblingLookup(siblingError: .cannotComplete)

    XCTAssertThrowsError(try fixture.resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
  }

  private func makeSiblingLookup(siblingError: AXError, includesTarget: Bool = true) -> (
    resolver: AXWindowElementResolver, targetWindow: AXUIElement
  ) {
    let staleWindow = AXUIElementCreateApplication(1234)
    let targetWindow = AXUIElementCreateApplication(5678)
    let accessibilityClient = AXClient.testing(copyAttributeValue: { element, attribute, value in
      value.pointee = nil
      switch attribute as String {
      case AXWindowAttribute.windows.accessibilityName:
        value.pointee = (includesTarget ? [staleWindow, targetWindow] : [staleWindow]) as CFArray
        return .success
      case AXWindowAttribute.windowIdentifier.accessibilityName:
        if CFEqual(element, staleWindow) { return siblingError }
        value.pointee = NSNumber(value: UInt32(42))
        return .success
      default:
        return .noValue
      }
    })
    let resolver = AXWindowElementResolver(
      accessibilityClient: accessibilityClient,
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListProvider: WindowListProviderStub(ownerProcessIdentifier: 1234)
    )
    return (resolver, targetWindow)
  }
}

private final class RecordingRunningApplicationChecker:
  RunningApplicationChecking
{
  private let requestsStorage = OSAllocatedUnfairLock(initialState: [pid_t]())
  let isRunning: Bool

  var requests: [pid_t] {
    requestsStorage.withLock { $0 }
  }

  init(isRunning: Bool) {
    self.isRunning = isRunning
  }

  func isRunningApplication(processIdentifier: pid_t) -> Bool {
    requestsStorage.withLock {
      $0.append(processIdentifier)
    }
    return isRunning
  }
}

private final class RecordingWindowListProvider:
  WindowListProviding
{
  private let requestsStorage = OSAllocatedUnfairLock(initialState: [WindowListRequest]())
  let entries: [WindowListEntry]?

  var requests: [WindowListRequest] {
    requestsStorage.withLock { $0 }
  }

  init(entries: [WindowListEntry]?) {
    self.entries = entries
  }

  func windowList(for request: WindowListRequest) -> [WindowListEntry]? {
    requestsStorage.withLock {
      $0.append(request)
    }
    return entries
  }
}
