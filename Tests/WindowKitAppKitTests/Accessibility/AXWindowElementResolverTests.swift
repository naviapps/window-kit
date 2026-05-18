import ApplicationServices
import XCTest

@testable import WindowKit
@testable import WindowKitAppKit

@MainActor
final class AXWindowElementResolverTests: XCTestCase {
  func testFocusedTargetReturnsFocusedWindow() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let systemElement = AXUIElementCreateSystemWide()
    let appElement = AXUIElementCreateApplication(getpid())
    let windowElement = AXUIElementCreateApplication(getpid())

    let focusedApplicationAttribute = kAXFocusedApplicationAttribute as String
    let focusedWindowAttribute = kAXFocusedWindowAttribute as String
    AXAPI.copyAttributeValue = { element, attribute, value in
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
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: systemElement,
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    let resolved = try resolver.windowElement(for: .focused)
    XCTAssertEqual(CFEqual(resolved, windowElement), true)
  }

  func testFocusedTargetThrowsWhenAccessibilityNotTrusted() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { false }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .accessibilityNotTrusted)
    }
  }

  func testFocusedTargetThrowsWhenFocusedApplicationMissing() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }
    AXAPI.copyAttributeValue = { _, _, value in
      value.pointee = nil
      return .noValue
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .applicationNotFound(.focused))
    }
  }

  func testFocusedTargetThrowsInvalidAXValueWhenFocusedApplicationHasUnexpectedType() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    AXAPI.copyAttributeValue = { _, attribute, value in
      XCTAssertEqual(attribute as String, kAXFocusedApplicationAttribute as String)
      value.pointee = "invalid" as CFString
      return .success
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testFocusedTargetThrowsUnderlyingAccessibilityErrorWhenFocusedApplicationReadFails() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    AXAPI.copyAttributeValue = { _, attribute, value in
      XCTAssertEqual(attribute as String, kAXFocusedApplicationAttribute as String)
      value.pointee = nil
      return .cannotComplete
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .underlyingAccessibilityError(.cannotComplete))
    }
  }

  func testFocusedTargetThrowsWhenFocusedWindowMissing() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let appElement = AXUIElementCreateApplication(getpid())
    let focusedApplicationAttribute = kAXFocusedApplicationAttribute as String
    let focusedWindowAttribute = kAXFocusedWindowAttribute as String
    AXAPI.copyAttributeValue = { _, attribute, value in
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
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .focused)) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.focused))
    }
  }

  func testWindowIdentifierTargetThrowsWhenAccessibilityNotTrusted() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { false }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .accessibilityNotTrusted)
    }
  }

  func testWindowIdentifierTargetThrowsWhenRunningApplicationMissing() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let applicationChecker = RecordingRunningApplicationChecker(isRunning: false)
    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: applicationChecker,
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .applicationNotFound(.windowIdentifier(42)))
    }
    XCTAssertEqual(applicationChecker.requests, [1234])
  }

  func testWindowIdentifierTargetThrowsWhenWindowListInfoIsMissing() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false),
      windowListInfoProvider: CGWindowListInfoProviderStub(entries: nil)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetThrowsWhenOwnerProcessIdentifierIsMissing() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(isRunning: false),
      windowListInfoProvider: CGWindowListInfoProviderStub(entries: [[:]])
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetReturnsMatchingAccessibilityWindow() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let matchedWindow = AXUIElementCreateApplication(getpid())
    AXAPI.copyAttributeValue = { element, attribute, value in
      switch attribute as String {
      case kAXWindowsAttribute:
        value.pointee = [matchedWindow] as CFArray
        return .success
      case AXWindowAttributeName.windowIdentifier:
        XCTAssertEqual(CFEqual(element, matchedWindow), true)
        value.pointee = NSNumber(value: UInt32(42))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    let resolved = try resolver.windowElement(for: .windowIdentifier(42))
    XCTAssertEqual(CFEqual(resolved, matchedWindow), true)
  }

  func testWindowIdentifierTargetRequestsSingleWindowListInfo() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let windowListInfoProvider = RecordingCGWindowListInfoProvider(
      entries: [[kCGWindowOwnerPID as String: NSNumber(value: pid_t(1234))]]
    )
    let matchedWindow = AXUIElementCreateApplication(getpid())
    AXAPI.copyAttributeValue = { _, attribute, value in
      switch attribute as String {
      case kAXWindowsAttribute:
        value.pointee = [matchedWindow] as CFArray
        return .success
      case AXWindowAttributeName.windowIdentifier:
        value.pointee = NSNumber(value: UInt32(42))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: windowListInfoProvider
    )

    _ = try resolver.windowElement(for: .windowIdentifier(42))

    XCTAssertEqual(windowListInfoProvider.requests.count, 1)
    XCTAssertEqual(windowListInfoProvider.requests.first?.relativeToWindow, 42)
    XCTAssertEqual(
      windowListInfoProvider.requests.first?.options,
      [.optionIncludingWindow, .excludeDesktopElements]
    )
  }

  func testWindowIdentifierTargetCreatesApplicationElementForOwnerProcessIdentifier() throws {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    let appElement = AXUIElementCreateApplication(1234)
    let matchedWindow = AXUIElementCreateApplication(getpid())
    var createdApplicationProcessIdentifier: pid_t?
    AXAPI.createApplicationElement = { processIdentifier in
      createdApplicationProcessIdentifier = processIdentifier
      return appElement
    }
    AXAPI.copyAttributeValue = { element, attribute, value in
      switch attribute as String {
      case kAXWindowsAttribute:
        XCTAssertEqual(CFEqual(element, appElement), true)
        value.pointee = [matchedWindow] as CFArray
        return .success
      case AXWindowAttributeName.windowIdentifier:
        XCTAssertEqual(CFEqual(element, matchedWindow), true)
        value.pointee = NSNumber(value: UInt32(42))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    _ = try resolver.windowElement(for: .windowIdentifier(42))

    XCTAssertEqual(createdApplicationProcessIdentifier, 1234)
  }

  func testWindowIdentifierTargetThrowsWhenApplicationWindowsAreMissing() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }
    AXAPI.copyAttributeValue = { _, attribute, value in
      XCTAssertEqual(attribute as String, kAXWindowsAttribute as String)
      value.pointee = nil
      return .noValue
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetThrowsInvalidAXValueWhenApplicationWindowsHaveUnexpectedType() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }
    AXAPI.copyAttributeValue = { _, attribute, value in
      XCTAssertEqual(attribute as String, kAXWindowsAttribute as String)
      value.pointee = "invalid" as CFString
      return .success
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }

  func testWindowIdentifierTargetThrowsWhenNoAccessibilityWindowMatches() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    AXAPI.copyAttributeValue = { _, attribute, value in
      switch attribute as String {
      case kAXWindowsAttribute:
        value.pointee = [AXUIElementCreateApplication(getpid())] as CFArray
        return .success
      case AXWindowAttributeName.windowIdentifier:
        value.pointee = NSNumber(value: UInt32(7))
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .windowNotFound(.windowIdentifier(42)))
    }
  }

  func testWindowIdentifierTargetThrowsInvalidAXValueWhenWindowIdentifierHasUnexpectedType() {
    defer { AXAPI.reset() }
    AXAPI.isProcessTrusted = { true }

    AXAPI.copyAttributeValue = { _, attribute, value in
      switch attribute as String {
      case kAXWindowsAttribute:
        value.pointee = [AXUIElementCreateApplication(getpid())] as CFArray
        return .success
      case AXWindowAttributeName.windowIdentifier:
        value.pointee = "invalid" as CFString
        return .success
      default:
        value.pointee = nil
        return .noValue
      }
    }

    let resolver = AXWindowElementResolver(
      systemWideElement: AXUIElementCreateSystemWide(),
      applicationChecker: RunningApplicationCheckerStub(),
      windowListInfoProvider: CGWindowListInfoProviderStub(ownerProcessIdentifier: 1234)
    )

    XCTAssertThrowsError(try resolver.windowElement(for: .windowIdentifier(42))) { error in
      XCTAssertEqual(error as? AXWindowError, .invalidAXValue)
    }
  }
}

private final class RecordingRunningApplicationChecker:
  RunningApplicationChecking, @unchecked Sendable
{
  private(set) var requests: [pid_t] = []
  let isRunning: Bool

  init(isRunning: Bool) {
    self.isRunning = isRunning
  }

  func isRunningApplication(processIdentifier: pid_t) -> Bool {
    requests.append(processIdentifier)
    return isRunning
  }
}

private final class RecordingCGWindowListInfoProvider:
  CGWindowListInfoProviding, @unchecked Sendable
{
  private(set) var requests: [(options: CGWindowListOption, relativeToWindow: CGWindowID)] = []
  let entries: [CGWindowListInfoEntry]?

  init(entries: [CGWindowListInfoEntry]?) {
    self.entries = entries
  }

  func windowListInfo(options: CGWindowListOption, relativeToWindow: CGWindowID)
    -> [CGWindowListInfoEntry]?
  {
    requests.append((options: options, relativeToWindow: relativeToWindow))
    return entries
  }
}
