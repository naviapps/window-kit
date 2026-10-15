import ApplicationServices
import CoreGraphics
import WindowKit

/// Reads and controls live macOS windows through Accessibility.
@MainActor
public struct AXWindowController: WindowControlling, WindowRoleProviding {
  private let access: AXWindowAccess
  private let roleResolver = WindowRoleResolver()

  /// Creates a controller backed by the system-wide Accessibility element.
  public init() {
    access = .live()
  }

  init(
    accessibilityClient: AXClient = .live,
    systemWideElement: AXUIElement,
    applicationChecker: any RunningApplicationChecking =
      NSRunningApplicationChecker(),
    windowListProvider: any WindowListProviding = SystemWindowListProvider()
  ) {
    access = AXWindowAccess(
      accessibilityClient: accessibilityClient,
      systemWideElement: systemWideElement,
      applicationChecker: applicationChecker,
      windowListProvider: windowListProvider
    )
  }

  /// Returns the current frame of the target window.
  /// Coordinates start at the primary display's top-left, with y increasing downward.
  public func frame(for target: WindowTarget) throws -> CGRect {
    try translateAXWindowErrors(for: .readFrame) {
      let window = try access.resolver.windowElement(for: target)
      let position = try access.accessibilityClient.attributeCGPoint(.position, of: window)
      let size = try access.accessibilityClient.attributeCGSize(.size, of: window)
      return CGRect(origin: position, size: size)
    }
  }

  /// Sets the frame of the target window.
  /// Uses the same top-left-origin Accessibility coordinates as ``frame(for:)``.
  public func setFrame(_ frame: CGRect, for target: WindowTarget) throws {
    try translateAXWindowErrors(for: .setFrame) {
      let window = try access.resolver.windowElement(for: target)
      let standardizedFrame = frame.standardized
      let positionValue = try standardizedFrame.origin.axValue(using: access.accessibilityClient)
      let sizeValue = try standardizedFrame.size.axValue(using: access.accessibilityClient)

      try access.accessibilityClient.setAttributeValue(
        .position,
        value: positionValue,
        on: window)
      try access.accessibilityClient.setAttributeValue(
        .size,
        value: sizeValue,
        on: window)
    }
  }

  /// Returns the current app-facing state for the target window.
  public func state(for target: WindowTarget) throws -> WindowState {
    try translateAXWindowErrors(for: .readState) {
      let window = try access.resolver.windowElement(for: target)
      let isMinimized = try access.accessibilityClient.attributeBool(.minimized, of: window)
      let isFullScreen = try access.accessibilityClient.attributeBool(.fullScreen, of: window)
      return WindowState(isMinimized: isMinimized, isFullScreen: isFullScreen)
    }
  }

  /// Sets the target window's minimized state.
  public func setMinimized(_ target: WindowTarget, isMinimized: Bool) throws {
    try translateAXWindowErrors(for: .setMinimized) {
      let window = try access.resolver.windowElement(for: target)
      try access.accessibilityClient.setAttributeBool(
        .minimized,
        value: isMinimized,
        on: window)
    }
  }

  /// Sets the target window's full-screen state.
  public func setFullScreen(_ target: WindowTarget, isFullScreen: Bool) throws {
    try translateAXWindowErrors(for: .setFullScreen) {
      let window = try access.resolver.windowElement(for: target)
      try access.accessibilityClient.setAttributeBool(
        .fullScreen,
        value: isFullScreen,
        on: window)
    }
  }

  /// Raises the target window above other windows when the system allows it.
  public func raise(_ target: WindowTarget) throws {
    try translateAXWindowErrors(for: .raise) {
      let window = try access.resolver.windowElement(for: target)
      try access.accessibilityClient.performAction(.raise, on: window)
    }
  }

  /// Lowers the target window when the system exposes the Accessibility action.
  public func lower(_ target: WindowTarget) throws {
    try translateAXWindowErrors(for: .lower) {
      let window = try access.resolver.windowElement(for: target)
      try access.accessibilityClient.performAction(.lower, on: window)
    }
  }

  /// Returns the app-facing role classification for the target window.
  public func role(for target: WindowTarget) throws -> WindowRole {
    try translateAXWindowErrors(for: .readRole) {
      let window = try access.resolver.windowElement(for: target)
      let accessibilityRole = try access.accessibilityClient.attributeString(.role, of: window)
      let accessibilitySubrole = try access.accessibilityClient.attributeString(
        .subrole, of: window)
      return roleResolver.resolve(
        accessibilityRole: accessibilityRole,
        accessibilitySubrole: accessibilitySubrole
      )
    }
  }
}
