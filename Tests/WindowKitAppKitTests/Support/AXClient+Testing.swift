import ApplicationServices

@testable import WindowKitAppKit

extension AXClient {
  static func testing(
    isProcessTrusted: @escaping () -> Bool = { true },
    createSystemWideElement: @escaping () -> AXUIElement = AXUIElementCreateSystemWide,
    createApplicationElement: @escaping (pid_t) -> AXUIElement = AXUIElementCreateApplication,
    copyAttributeValue:
      @escaping (
        AXUIElement,
        CFString,
        UnsafeMutablePointer<CFTypeRef?>
      ) -> AXError = { _, _, value in
        value.pointee = nil
        return .noValue
      },
    setAttributeValue: @escaping (AXUIElement, CFString, CFTypeRef) -> AXError = { _, _, _ in
      .success
    },
    valueGet: @escaping (AXValue, AXValueType, UnsafeMutableRawPointer) -> Bool = AXValueGetValue,
    valueCreate: @escaping (AXValueType, UnsafeRawPointer) -> AXValue? = AXValueCreate,
    performAction: @escaping (AXUIElement, CFString) -> AXError = { _, _ in .success }
  ) -> AXClient {
    AXClient(
      isProcessTrusted: isProcessTrusted,
      createSystemWideElement: createSystemWideElement,
      createApplicationElement: createApplicationElement,
      copyAttributeValue: copyAttributeValue,
      setAttributeValue: setAttributeValue,
      valueGet: valueGet,
      valueCreate: valueCreate,
      performAction: performAction
    )
  }
}
