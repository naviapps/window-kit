import ApplicationServices
import CoreGraphics

@MainActor
extension AXUIElement {
  func attributeElement(_ attribute: String) throws -> AXUIElement? {
    guard let value = try optionalAttributeValue(attribute) else { return nil }
    guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    return unsafeDowncast(value, to: AXUIElement.self)
  }

  func attributeElements(_ attribute: String) throws -> [AXUIElement]? {
    guard let value = try optionalAttributeValue(attribute) else { return nil }
    guard CFGetTypeID(value) == CFArrayGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    guard let array = value as? [AXUIElement] else {
      throw AXWindowError.invalidAXValue
    }
    return array
  }

  func attributeUInt32(_ attribute: String) throws -> UInt32? {
    guard let value = try optionalAttributeValue(attribute) else { return nil }
    guard let number = value as? NSNumber else {
      throw AXWindowError.invalidAXValue
    }
    return number.uint32Value
  }

  func attributeString(_ attribute: String) throws -> String? {
    guard let value = try optionalAttributeValue(attribute) else { return nil }
    guard let string = value as? String else {
      throw AXWindowError.invalidAXValue
    }
    return string
  }

  func attributeBool(_ attribute: String) throws -> Bool? {
    guard let value = try optionalAttributeValue(attribute) else { return nil }
    guard CFGetTypeID(value) == CFBooleanGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    return CFBooleanGetValue(unsafeDowncast(value, to: CFBoolean.self))
  }

  func attributeCGPoint(_ attribute: String) throws -> CGPoint {
    let value = try attributeAXValue(attribute)
    var point = CGPoint.zero
    guard AXAPI.valueGet(value, .cgPoint, &point) else {
      throw AXWindowError.invalidAXValue
    }
    return point
  }

  func attributeCGSize(_ attribute: String) throws -> CGSize {
    let value = try attributeAXValue(attribute)
    var size = CGSize.zero
    guard AXAPI.valueGet(value, .cgSize, &size) else {
      throw AXWindowError.invalidAXValue
    }
    return size
  }

  func performAction(_ action: String) throws {
    let error = AXAPI.performAction(self, action as CFString)
    if error == .actionUnsupported {
      throw AXWindowError.unsupportedAction(action)
    }
    guard error == .success else {
      throw AXWindowError.underlyingAccessibilityError(error)
    }
  }

  func setAttributeBool(_ attribute: String, value: Bool) throws {
    let boolValue: CFBoolean = value ? kCFBooleanTrue : kCFBooleanFalse
    let error = AXAPI.setAttributeValue(self, attribute as CFString, boolValue)
    guard error == .success else {
      throw AXWindowError.underlyingAccessibilityError(error)
    }
  }

  func setAttributeValue(_ attribute: String, value: AXValue) throws {
    let error = AXAPI.setAttributeValue(self, attribute as CFString, value)
    guard error == .success else {
      throw AXWindowError.underlyingAccessibilityError(error)
    }
  }

  private func attributeAXValue(_ attribute: String) throws -> AXValue {
    let value = try requiredAttributeValue(attribute)
    guard CFGetTypeID(value) == AXValueGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    return unsafeDowncast(value, to: AXValue.self)
  }

  private func optionalAttributeValue(_ attribute: String) throws -> CFTypeRef? {
    let result = copyAttributeValue(attribute)
    if result.error == .attributeUnsupported || result.error == .noValue {
      return nil
    }
    guard result.error == .success else {
      throw AXWindowError.underlyingAccessibilityError(result.error)
    }
    return result.value
  }

  private func requiredAttributeValue(_ attribute: String) throws -> CFTypeRef {
    let result = copyAttributeValue(attribute)
    guard result.error == .success else {
      throw AXWindowError.underlyingAccessibilityError(result.error)
    }
    guard let value = result.value else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }

  private func copyAttributeValue(_ attribute: String) -> (
    error: AXError, value: CFTypeRef?
  ) {
    var value: CFTypeRef?
    let error = AXAPI.copyAttributeValue(self, attribute as CFString, &value)
    return (error, value)
  }
}
