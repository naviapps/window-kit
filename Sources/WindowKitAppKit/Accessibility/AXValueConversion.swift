import ApplicationServices
import CoreGraphics

@MainActor
extension CGPoint {
  func axValue() throws -> AXValue {
    var point = self
    let value = withUnsafePointer(to: &point) { AXAPI.valueCreate(.cgPoint, $0) }
    guard let value else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }
}

@MainActor
extension CGSize {
  func axValue() throws -> AXValue {
    var size = self
    let value = withUnsafePointer(to: &size) { AXAPI.valueCreate(.cgSize, $0) }
    guard let value else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }
}
