import ApplicationServices
import CoreGraphics

@MainActor
extension CGPoint {
  func axValue(using accessibilityClient: AXClient) throws -> AXValue {
    guard x.isFinite, y.isFinite else {
      throw AXWindowError.invalidAXValue
    }
    var point = self
    let value = withUnsafePointer(to: &point) { accessibilityClient.valueCreate(.cgPoint, $0) }
    guard let value else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }
}

@MainActor
extension CGSize {
  func axValue(using accessibilityClient: AXClient) throws -> AXValue {
    guard width.isFinite, height.isFinite else {
      throw AXWindowError.invalidAXValue
    }
    var size = self
    let value = withUnsafePointer(to: &size) { accessibilityClient.valueCreate(.cgSize, $0) }
    guard let value else {
      throw AXWindowError.invalidAXValue
    }
    return value
  }
}
