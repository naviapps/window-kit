import CoreGraphics
import WindowKit

/// Errors thrown by live window placement operations.
public enum WindowPlacerError: Error, Equatable, Sendable {
  /// The requested screen target could not be resolved.
  case screenNotFound(WindowScreenTarget)
}

/// Places live macOS windows using WindowKit placement values and screen providers.
@MainActor
public struct WindowPlacer {
  private let frameController: any WindowFrameControlling
  private let screenProvider: any WindowScreenProviding
  private let placementCalculator: WindowPlacementCalculator

  /// Creates a placer backed by Accessibility window frame control and AppKit screens.
  public init() {
    self.init(
      frameController: AXWindowFrameController(),
      screenProvider: NSScreenProvider(),
      placementCalculator: .init()
    )
  }

  init(
    applicationChecker: any RunningApplicationChecking =
      NSRunningApplicationChecker(),
    placementCalculator: WindowPlacementCalculator = .init()
  ) {
    self.init(
      frameController: AXWindowFrameController(
        systemWideElement: AXAPI.createSystemWideElement(),
        applicationChecker: applicationChecker
      ),
      screenProvider: NSScreenProvider(),
      placementCalculator: placementCalculator
    )
  }

  /// Creates a placer with caller-supplied frame and screen providers.
  public init(
    frameController: any WindowFrameControlling,
    screenProvider: any WindowScreenProviding,
    placementCalculator: WindowPlacementCalculator = .init()
  ) {
    self.frameController = frameController
    self.screenProvider = screenProvider
    self.placementCalculator = placementCalculator
  }

  /// Places a target window according to a placement value.
  public func place(
    _ placement: WindowPlacement,
    for target: WindowTarget,
    screen screenTarget: WindowScreenTarget = .containingWindow,
    area: WindowScreenArea = .visible,
    inset: CGFloat = 0,
    allowsScreenFallback: Bool = true
  ) throws {
    let windowFrame = try frameController.frame(for: target)
    let screens = WindowScreenSelector.orderedScreens(from: screenProvider.screens())

    guard
      let selectedScreen = WindowScreenSelector.screen(
        for: screenTarget,
        windowFrame: windowFrame,
        in: screens,
        fallsBackToFirstScreen: allowsScreenFallback
      )
    else {
      if !allowsScreenFallback {
        throw WindowPlacerError.screenNotFound(screenTarget)
      }
      return
    }

    let frame = placementCalculator.frame(
      for: placement,
      in: selectedScreen.frame(for: area),
      inset: inset
    )
    try frameController.setFrame(frame, for: target)
  }

  /// Moves a target window to the next or previous ordered screen.
  public func moveToAdjacentScreen(
    _ direction: WindowScreenCycleDirection,
    for target: WindowTarget,
    preservingRelativePosition: Bool = true,
    allowsScreenFallback: Bool = true
  ) throws {
    let window = try frameController.frame(for: target)
    let screens = WindowScreenSelector.orderedScreens(from: screenProvider.screens())
    guard !screens.isEmpty else {
      try handleMissingContainingWindow(allowsScreenFallback: allowsScreenFallback)
      return
    }

    let currentScreenIndex: Int
    if let index = WindowScreenSelector.index(containing: window.center, in: screens) {
      currentScreenIndex = index
    } else {
      try handleMissingContainingWindow(allowsScreenFallback: allowsScreenFallback)
      currentScreenIndex = 0
    }
    guard
      let targetIndex = WindowScreenSelector.adjacentIndex(
        from: currentScreenIndex,
        direction: direction,
        screenCount: screens.count
      )
    else {
      try handleMissingContainingWindow(allowsScreenFallback: allowsScreenFallback)
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

  private func handleMissingContainingWindow(allowsScreenFallback: Bool) throws {
    if !allowsScreenFallback {
      throw WindowPlacerError.screenNotFound(.containingWindow)
    }
  }
}

private extension CGRect {
  var center: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}
