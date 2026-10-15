import CoreGraphics
import WindowKit

/// Adapts AppKit screen geometry for Accessibility frame control.
@MainActor
struct AccessibilityScreenProvider: WindowScreenProviding {
  private let appKitScreenProvider: any WindowScreenProviding

  init(
    appKitScreenProvider: any WindowScreenProviding = NSScreenProvider()
  ) {
    self.appKitScreenProvider = appKitScreenProvider
  }

  func screens() -> [WindowScreen] {
    let screens = appKitScreenProvider.screens()
    // NSScreenProvider preserves NSScreen.screens order: the primary display is first.
    // Use this same snapshot for the origin and all screen frames.
    guard let primary = screens.first else { return [] }
    let topY = primary.frame.maxY
    return screens.map { screen in
      WindowScreen(
        displayIdentifier: screen.displayIdentifier,
        frame: accessibilityFrame(screen.frame, primaryTopY: topY),
        visibleFrame: accessibilityFrame(screen.visibleFrame, primaryTopY: topY),
        isMain: screen.isMain
      )
    }
  }

  private func accessibilityFrame(_ frame: CGRect, primaryTopY: CGFloat) -> CGRect {
    CGRect(x: frame.minX, y: primaryTopY - frame.maxY, width: frame.width, height: frame.height)
  }
}
