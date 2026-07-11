import WindowKit
import XCTest

@MainActor
final class WindowControlProtocolTests: XCTestCase {
  func testWindowControllingComposesEveryControlCapability() throws {
    let controller: any WindowControlling = CompleteWindowControllerStub()

    XCTAssertEqual(try controller.frame(for: .focused), .zero)
    XCTAssertEqual(try controller.state(for: .focused), WindowState())
    try controller.setFrame(.zero, for: .focused)
    try controller.setMinimized(.focused, isMinimized: false)
    try controller.setFullScreen(.focused, isFullScreen: false)
    try controller.raise(.focused)
    try controller.lower(.focused)
  }

  func testFrameControllingRefinesFrameProviding() throws {
    let frame = CGRect(x: 10, y: 20, width: 300, height: 200)
    let controller = WindowFrameControllerSpy(frame: frame)
    let provider: any WindowFrameProviding = controller
    let controlling: any WindowFrameControlling = controller

    XCTAssertEqual(try provider.frame(for: .focused), frame)
    try controlling.setFrame(frame, for: .windowIdentifier(42))
    XCTAssertEqual(controller.assignedFrames, [.init(frame: frame, target: .windowIdentifier(42))])
  }

  func testCommandControllingKeepsStateAndOrderingCommandsSeparate() throws {
    let controller = WindowCommandControllerSpy()

    try controller.setMinimized(.focused, isMinimized: true)
    try controller.setFullScreen(.windowIdentifier(42), isFullScreen: false)
    try controller.raise(.focused)
    try controller.lower(.windowIdentifier(42))

    XCTAssertEqual(
      controller.commands,
      [
        .setMinimized(.focused, true),
        .setFullScreen(.windowIdentifier(42), false),
        .raise(.focused),
        .lower(.windowIdentifier(42)),
      ]
    )
  }
}

@MainActor
private struct CompleteWindowControllerStub: WindowControlling {
  func frame(for _: WindowTarget) throws -> CGRect { .zero }
  func setFrame(_: CGRect, for _: WindowTarget) throws {}
  func state(for _: WindowTarget) throws -> WindowState { WindowState() }
  func setMinimized(_: WindowTarget, isMinimized _: Bool) throws {}
  func setFullScreen(_: WindowTarget, isFullScreen _: Bool) throws {}
  func raise(_: WindowTarget) throws {}
  func lower(_: WindowTarget) throws {}
}

@MainActor
private final class WindowFrameControllerSpy: WindowFrameControlling {
  struct Assignment: Equatable {
    let frame: CGRect
    let target: WindowTarget
  }

  private let frameValue: CGRect
  private(set) var assignedFrames: [Assignment] = []

  init(frame: CGRect) {
    frameValue = frame
  }

  func frame(for _: WindowTarget) throws -> CGRect {
    frameValue
  }

  func setFrame(_ frame: CGRect, for target: WindowTarget) throws {
    assignedFrames.append(.init(frame: frame, target: target))
  }
}

@MainActor
private final class WindowCommandControllerSpy: WindowCommandControlling {
  enum Command: Equatable {
    case setMinimized(WindowTarget, Bool)
    case setFullScreen(WindowTarget, Bool)
    case raise(WindowTarget)
    case lower(WindowTarget)
  }

  private(set) var commands: [Command] = []

  func setMinimized(_ target: WindowTarget, isMinimized: Bool) throws {
    commands.append(.setMinimized(target, isMinimized))
  }

  func setFullScreen(_ target: WindowTarget, isFullScreen: Bool) throws {
    commands.append(.setFullScreen(target, isFullScreen))
  }

  func raise(_ target: WindowTarget) throws {
    commands.append(.raise(target))
  }

  func lower(_ target: WindowTarget) throws {
    commands.append(.lower(target))
  }
}
