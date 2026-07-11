import WindowKit
import XCTest

@MainActor
final class WindowScreenProvidingTests: XCTestCase {
  func testScreensCanBeReadThroughProvidingProtocol() {
    let screen = WindowScreen(frame: .zero, visibleFrame: .zero)
    let provider: any WindowScreenProviding = WindowScreenProviderStub(screens: [screen])

    XCTAssertEqual(provider.screens(), [screen])
  }
}

private struct WindowScreenProviderStub: WindowScreenProviding {
  let screenValues: [WindowScreen]

  init(screens: [WindowScreen]) {
    screenValues = screens
  }

  func screens() -> [WindowScreen] {
    screenValues
  }
}
