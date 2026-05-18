import ApplicationServices

@MainActor
enum AXAPI {
  static var isProcessTrusted: () -> Bool = AXIsProcessTrusted
  static var createSystemWideElement: () -> AXUIElement = AXUIElementCreateSystemWide
  static var createApplicationElement: (pid_t) -> AXUIElement = AXUIElementCreateApplication
  static var copyAttributeValue:
    (AXUIElement, CFString, UnsafeMutablePointer<CFTypeRef?>)
      -> AXError = AXUIElementCopyAttributeValue
  static var setAttributeValue: (AXUIElement, CFString, CFTypeRef) -> AXError =
    AXUIElementSetAttributeValue
  static var valueGet: (AXValue, AXValueType, UnsafeMutableRawPointer) -> Bool = AXValueGetValue
  static var valueCreate: (AXValueType, UnsafeRawPointer) -> AXValue? = AXValueCreate
  static var performAction: (AXUIElement, CFString) -> AXError = AXUIElementPerformAction
}
