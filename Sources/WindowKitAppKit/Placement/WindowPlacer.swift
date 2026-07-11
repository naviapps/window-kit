import CoreGraphics
import WindowKit

/// Places live macOS windows using WindowKit placement values and screen providers.
@MainActor
public struct WindowPlacer {
  private let frameController: any WindowFrameControlling
  private let screenProvider: any WindowScreenProviding

  /// Creates a placer backed by Accessibility window frame control and AppKit screens.
  public init() {
    self.init(
      frameController: AXWindowController(),
      screenProvider: NSScreenProvider()
    )
  }

  /// Creates a placer with caller-supplied frame and screen providers.
  public init(
    frameController: any WindowFrameControlling,
    screenProvider: any WindowScreenProviding
  ) {
    self.frameController = frameController
    self.screenProvider = screenProvider
  }

  /// Places a target window according to a placement value.
  ///
  /// Unresolved screen targets use the first ordered screen by default. Missing screens always
  /// throw ``WindowPlacerError/screenNotFound(_:)``. Pass
  /// ``WindowKit/WindowScreenFallback/none`` to also reject an unmatched target when screens exist.
  public func place(
    _ placement: WindowPlacement,
    for target: WindowTarget,
    screen screenTarget: WindowScreenTarget = .containingWindow,
    area: WindowScreenArea = .visible,
    inset: CGFloat = 0,
    screenFallback: WindowScreenFallback = .firstScreen
  ) throws {
    let screens = screenProvider.screens()
    guard !screens.isEmpty else { throw WindowPlacerError.screenNotFound(screenTarget) }

    let windowFrame =
      screenTarget == .containingWindow
      ? try frameController.frame(for: target)
      : .zero
    guard
      let selectedScreen = WindowScreenSelector.screen(
        for: screenTarget,
        windowFrame: windowFrame,
        in: screens,
        fallback: screenFallback
      )
    else {
      throw WindowPlacerError.screenNotFound(screenTarget)
    }

    let frame = WindowPlacementCalculator.frame(
      for: placement,
      in: selectedScreen.frame(for: area),
      inset: inset
    )
    try frameController.setFrame(frame, for: target)
  }

  /// Moves a target window to the next or previous ordered screen.
  ///
  /// A window outside all known screens is treated as if it were on the first ordered screen by
  /// default. Missing screens always throw ``WindowPlacerError/screenNotFound(_:)``. Pass
  /// ``WindowKit/WindowScreenFallback/none`` to also reject a window outside every known screen.
  public func moveToAdjacentScreen(
    _ direction: WindowScreenCycleDirection,
    for target: WindowTarget,
    preservingRelativePosition: Bool = true,
    screenFallback: WindowScreenFallback = .firstScreen
  ) throws {
    let screens = WindowScreenSelector.orderedScreens(from: screenProvider.screens())
    guard !screens.isEmpty else { throw WindowPlacerError.screenNotFound(.containingWindow) }

    let window = try frameController.frame(for: target)
    let currentScreenIndex: Int
    if let index = WindowScreenSelector.index(containing: window.center, in: screens) {
      currentScreenIndex = index
    } else {
      try handleMissingContainingWindow(screenFallback: screenFallback)
      currentScreenIndex = 0
    }
    guard
      let targetIndex = WindowScreenSelector.adjacentIndex(
        from: currentScreenIndex,
        direction: direction,
        screenCount: screens.count
      )
    else {
      try handleMissingContainingWindow(screenFallback: screenFallback)
      return
    }

    let currentVisible = screens[currentScreenIndex].visibleFrame
    let targetVisible = screens[targetIndex].visibleFrame

    let nextFrame =
      preservingRelativePosition
      ? WindowScreenMovement.preservingRelativePosition(
        windowFrame: window,
        from: currentVisible,
        to: targetVisible
      )
      : WindowScreenMovement.centerPreservingSize(windowFrame: window, in: targetVisible)

    try frameController.setFrame(nextFrame, for: target)
  }

  private func handleMissingContainingWindow(screenFallback: WindowScreenFallback) throws {
    if screenFallback == .none {
      throw WindowPlacerError.screenNotFound(.containingWindow)
    }
  }
}

private extension CGRect {
  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}
