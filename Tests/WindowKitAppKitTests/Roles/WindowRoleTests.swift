import WindowKit
import WindowKitAppKit
import XCTest

final class WindowRoleTests: XCTestCase {
  func testWindowRoleValueConformance() throws {
    try assertValueConformance(WindowRole.standard)
    try assertValueConformance(WindowRole.dialog)
    try assertValueConformance(WindowRole.sheet)
    try assertValueConformance(WindowRole.panel)
    try assertValueConformance(WindowRole.popover)
    try assertValueConformance(WindowRole.systemDialog)
    try assertValueConformance(WindowRole.unknown(role: "AXWindow", subrole: "AXDialog"))
    try assertValueConformance(WindowRole.unknown(role: nil, subrole: nil))
  }

  func testWindowRoleIsSendable() {
    assertSendable(WindowRole.standard)
    assertSendable(WindowRole.unknown(role: "AXWindow", subrole: "AXDialog"))
  }

  @MainActor
  func testWindowRoleCanBeReadThroughProvidingProtocol() throws {
    let provider: any WindowRoleProviding = WindowRoleProviderStub(role: .panel)

    XCTAssertEqual(try provider.role(for: .focused), .panel)
  }

  private func assertSendable<Value: Sendable>(_: Value) {}
}

private struct WindowRoleProviderStub: WindowRoleProviding {
  let role: WindowRole

  func role(for _: WindowTarget) throws -> WindowRole {
    role
  }
}
