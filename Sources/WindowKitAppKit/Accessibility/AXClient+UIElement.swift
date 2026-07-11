import ApplicationServices
import CoreGraphics

@MainActor
extension AXClient {
  func attributeElement(_ attribute: AXWindowAttribute, of element: AXUIElement) throws
    -> AXUIElement?
  {
    guard let value = try optionalAttributeValue(attribute, of: element) else { return nil }
    guard CFGetTypeID(value) == AXUIElementGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    return typedReference(value, as: AXUIElement.self)
  }

  func attributeElements(_ attribute: AXWindowAttribute, of element: AXUIElement) throws
    -> [AXUIElement]?
  {
    guard let value = try optionalAttributeValue(attribute, of: element) else { return nil }
    guard CFGetTypeID(value) == CFArrayGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    guard let array = value as? [AXUIElement] else {
      throw AXWindowError.invalidAXValue
    }
    return array
  }

  func attributeUInt32(_ attribute: AXWindowAttribute, of element: AXUIElement) throws -> UInt32? {
    guard let value = try optionalAttributeValue(attribute, of: element) else { return nil }
    guard CFGetTypeID(value) == CFNumberGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    guard let number = value as? NSNumber else {
      throw AXWindowError.invalidAXValue
    }
    return try exactUInt32(number)
  }

  func attributeString(_ attribute: AXWindowAttribute, of element: AXUIElement) throws -> String? {
    guard let value = try optionalAttributeValue(attribute, of: element) else { return nil }
    guard let string = value as? String else {
      throw AXWindowError.invalidAXValue
    }
    return string
  }

  func attributeBool(_ attribute: AXWindowAttribute, of element: AXUIElement) throws -> Bool? {
    guard let value = try optionalAttributeValue(attribute, of: element) else { return nil }
    guard CFGetTypeID(value) == CFBooleanGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    guard let boolValue = value as? Bool else {
      throw AXWindowError.invalidAXValue
    }
    return boolValue
  }

  func attributeCGPoint(_ attribute: AXWindowAttribute, of element: AXUIElement) throws -> CGPoint {
    let value = try attributeAXValue(attribute, of: element)
    var point = CGPoint.zero
    guard valueGet(value, .cgPoint, &point) else {
      throw AXWindowError.invalidAXValue
    }
    guard point.x.isFinite, point.y.isFinite else {
      throw AXWindowError.invalidAXValue
    }
    return point
  }

  func attributeCGSize(_ attribute: AXWindowAttribute, of element: AXUIElement) throws -> CGSize {
    let value = try attributeAXValue(attribute, of: element)
    var size = CGSize.zero
    guard valueGet(value, .cgSize, &size) else {
      throw AXWindowError.invalidAXValue
    }
    guard size.width.isFinite, size.height.isFinite else {
      throw AXWindowError.invalidAXValue
    }
    return size
  }

  func performAction(_ action: AXWindowAction, on element: AXUIElement) throws {
    let error = performAction(element, action.accessibilityName as CFString)
    if error == .actionUnsupported {
      throw AXWindowError.unsupportedOperation
    }
    guard error == .success else {
      throw AXWindowError.underlyingAccessibilityError(error)
    }
  }

  func setAttributeBool(_ attribute: AXWindowAttribute, value: Bool, on element: AXUIElement) throws
  {
    let boolValue: CFBoolean = value ? kCFBooleanTrue : kCFBooleanFalse
    let error = setAttributeValue(element, attribute.accessibilityName as CFString, boolValue)
    guard error == .success else {
      throw AXWindowError.underlyingAccessibilityError(error)
    }
  }

  func setAttributeValue(_ attribute: AXWindowAttribute, value: AXValue, on element: AXUIElement)
    throws
  {
    let error = setAttributeValue(element, attribute.accessibilityName as CFString, value)
    guard error == .success else {
      throw AXWindowError.underlyingAccessibilityError(error)
    }
  }

  private func attributeAXValue(_ attribute: AXWindowAttribute, of element: AXUIElement) throws
    -> AXValue
  {
    let value = try requiredAttributeValue(attribute, of: element)
    guard CFGetTypeID(value) == AXValueGetTypeID() else {
      throw AXWindowError.invalidAXValue
    }
    return typedReference(value, as: AXValue.self)
  }

  private func typedReference<Value: AnyObject>(
    _ value: CFTypeRef,
    as _: Value.Type
  ) -> Value {
    Unmanaged<Value>
      .fromOpaque(Unmanaged.passUnretained(value).toOpaque())
      .takeUnretainedValue()
  }

  private func exactUInt32(_ number: NSNumber) throws -> UInt32 {
    guard
      number.compare(NSNumber(value: UInt32.min)) != .orderedAscending,
      number.compare(NSNumber(value: UInt32.max)) != .orderedDescending
    else {
      throw AXWindowError.invalidAXValue
    }

    let value = number.uint32Value
    guard NSNumber(value: value).compare(number) == .orderedSame else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }

  private func optionalAttributeValue(_ attribute: AXWindowAttribute, of element: AXUIElement)
    throws
    -> CFTypeRef?
  {
    let result = copyAttributeValue(attribute, of: element)
    if result.error == .attributeUnsupported || result.error == .noValue {
      return nil
    }
    guard result.error == .success else {
      throw AXWindowError.underlyingAccessibilityError(result.error)
    }
    return result.value
  }

  private func requiredAttributeValue(_ attribute: AXWindowAttribute, of element: AXUIElement)
    throws
    -> CFTypeRef
  {
    let result = copyAttributeValue(attribute, of: element)
    guard result.error == .success else {
      throw AXWindowError.underlyingAccessibilityError(result.error)
    }
    guard let value = result.value else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }

  private func copyAttributeValue(_ attribute: AXWindowAttribute, of element: AXUIElement) -> (
    error: AXError, value: CFTypeRef?
  ) {
    var value: CFTypeRef?
    let error = copyAttributeValue(element, attribute.accessibilityName as CFString, &value)
    return (error, value)
  }
}
