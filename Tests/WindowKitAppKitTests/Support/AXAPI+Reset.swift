import ApplicationServices

@testable import WindowKitAppKit

extension AXAPI {
  static func reset() {
    isProcessTrusted = AXIsProcessTrusted
    createSystemWideElement = AXUIElementCreateSystemWide
    createApplicationElement = AXUIElementCreateApplication
    copyAttributeValue = AXUIElementCopyAttributeValue
    setAttributeValue = AXUIElementSetAttributeValue
    valueGet = AXValueGetValue
    valueCreate = AXValueCreate
    performAction = AXUIElementPerformAction
  }
}
