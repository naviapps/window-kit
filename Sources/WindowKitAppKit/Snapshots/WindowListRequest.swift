import CoreGraphics

struct WindowListRequest: Equatable, Sendable {
  let options: CGWindowListOption
  let windowIdentifier: CGWindowID

  static let onScreenWindows = windows(options: [.optionOnScreenOnly, .excludeDesktopElements])

  static func windows(options: CGWindowListOption) -> WindowListRequest {
    WindowListRequest(options: options, windowIdentifier: kCGNullWindowID)
  }

  static func window(
    _ windowIdentifier: CGWindowID,
    options: CGWindowListOption = [.optionIncludingWindow, .excludeDesktopElements]
  ) -> WindowListRequest {
    WindowListRequest(options: options, windowIdentifier: windowIdentifier)
  }
}
