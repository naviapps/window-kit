import AppKit
import CoreGraphics
import WindowKit

/// Screen provider backed by `NSScreen`.
@MainActor
public struct NSScreenProvider: WindowScreenProviding {
  /// Creates an AppKit screen provider.
  public init() {}

  /// Returns current AppKit screens as `WindowScreen` values.
  /// Frames retain AppKit coordinates, with the origin at the primary display's bottom-left.
  public func screens() -> [WindowScreen] {
    let mainScreen = NSScreen.main
    return NSScreen.screens.map {
      let screenNumber = $0.deviceDescription[Self.screenNumberKey] as? NSNumber
      let displayIdentifier = screenNumber.map { CGDirectDisplayID($0.uint32Value) }
      return WindowScreen(
        displayIdentifier: displayIdentifier,
        frame: $0.frame,
        visibleFrame: $0.visibleFrame,
        isMain: $0 == mainScreen
      )
    }
  }

  private static let screenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")
}
