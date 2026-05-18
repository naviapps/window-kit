import XCTest

@testable import WindowKit

final class WindowStateTests: XCTestCase {
  func testInitStoresStateFields() {
    let state = WindowState(isMinimized: false, isFullScreen: true)

    XCTAssertEqual(state.isMinimized, false)
    XCTAssertEqual(state.isFullScreen, true)
  }

  func testWindowStateValueConformance() throws {
    try assertValueConformance(WindowState(isMinimized: false, isFullScreen: true))
    try assertValueConformance(WindowState(isMinimized: nil, isFullScreen: nil))
  }

  func testWindowStateIsSendable() {
    assertSendable(WindowState(isMinimized: true, isFullScreen: false))
  }

  @MainActor
  func testWindowStateCanBeReadThroughProvidingProtocol() throws {
    let provider: any WindowStateProviding = WindowStateProviderStub(
      state: WindowState(isMinimized: true, isFullScreen: nil)
    )

    XCTAssertEqual(
      try provider.state(for: .focused),
      WindowState(isMinimized: true, isFullScreen: nil)
    )
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}

private struct WindowStateProviderStub: WindowStateProviding {
  let state: WindowState

  func state(for _: WindowTarget) throws -> WindowState {
    state
  }
}
