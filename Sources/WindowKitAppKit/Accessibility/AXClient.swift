import ApplicationServices

@MainActor
struct AXClient {
  let isProcessTrusted: () -> Bool
  let createSystemWideElement: () -> AXUIElement
  let createApplicationElement: (pid_t) -> AXUIElement
  let copyAttributeValue:
    (AXUIElement, CFString, UnsafeMutablePointer<CFTypeRef?>)
      -> AXError
  let setAttributeValue: (AXUIElement, CFString, CFTypeRef) -> AXError
  let valueGet: (AXValue, AXValueType, UnsafeMutableRawPointer) -> Bool
  let valueCreate: (AXValueType, UnsafeRawPointer) -> AXValue?
  let performAction: (AXUIElement, CFString) -> AXError

  static let live = AXClient(
    isProcessTrusted: AXIsProcessTrusted,
    createSystemWideElement: AXUIElementCreateSystemWide,
    createApplicationElement: AXUIElementCreateApplication,
    copyAttributeValue: AXUIElementCopyAttributeValue,
    setAttributeValue: AXUIElementSetAttributeValue,
    valueGet: AXValueGetValue,
    valueCreate: AXValueCreate,
    performAction: AXUIElementPerformAction
  )

  init(
    isProcessTrusted: @escaping () -> Bool = AXIsProcessTrusted,
    createSystemWideElement: @escaping () -> AXUIElement = AXUIElementCreateSystemWide,
    createApplicationElement: @escaping (pid_t) -> AXUIElement = AXUIElementCreateApplication,
    copyAttributeValue:
      @escaping (
        AXUIElement,
        CFString,
        UnsafeMutablePointer<CFTypeRef?>
      ) -> AXError = AXUIElementCopyAttributeValue,
    setAttributeValue: @escaping (AXUIElement, CFString, CFTypeRef) -> AXError =
      AXUIElementSetAttributeValue,
    valueGet: @escaping (AXValue, AXValueType, UnsafeMutableRawPointer) -> Bool =
      AXValueGetValue,
    valueCreate: @escaping (AXValueType, UnsafeRawPointer) -> AXValue? = AXValueCreate,
    performAction: @escaping (AXUIElement, CFString) -> AXError = AXUIElementPerformAction
  ) {
    self.isProcessTrusted = isProcessTrusted
    self.createSystemWideElement = createSystemWideElement
    self.createApplicationElement = createApplicationElement
    self.copyAttributeValue = copyAttributeValue
    self.setAttributeValue = setAttributeValue
    self.valueGet = valueGet
    self.valueCreate = valueCreate
    self.performAction = performAction
  }
}
