import CoreGraphics
import Foundation

struct WindowListEntry: Sendable {
  let layer: Int?
  let frame: CGRect?
  let ownerProcessIdentifier: pid_t?
  let windowIdentifier: CGWindowID?
  let ownerName: String?
  let title: String?

  init(
    layer: Int? = nil,
    frame: CGRect? = nil,
    ownerProcessIdentifier: pid_t? = nil,
    windowIdentifier: CGWindowID? = nil,
    ownerName: String? = nil,
    title: String? = nil
  ) {
    self.layer = layer
    self.frame = frame
    self.ownerProcessIdentifier = ownerProcessIdentifier
    self.windowIdentifier = windowIdentifier
    self.ownerName = ownerName
    self.title = title
  }
}

extension WindowListEntry {
  init(cgWindowInfo values: NSDictionary) {
    let boundsDictionary = values[CGWindowInfoKey.bounds.dictionaryName] as? NSDictionary
    self.init(
      layer: Self.layer(from: values[CGWindowInfoKey.layer.dictionaryName]),
      frame: boundsDictionary.flatMap(CGRect.init(dictionaryRepresentation:)),
      ownerProcessIdentifier: Self.processIdentifier(
        from: values[CGWindowInfoKey.ownerProcessIdentifier.dictionaryName]),
      windowIdentifier: Self.windowIdentifier(
        from: values[CGWindowInfoKey.windowIdentifier.dictionaryName]),
      ownerName: values[CGWindowInfoKey.ownerName.dictionaryName] as? String,
      title: values[CGWindowInfoKey.title.dictionaryName] as? String
    )
  }

  private static func layer(from value: Any?) -> Int? {
    guard let integer = integerValue(from: value),
      integer >= Int64(Int.min),
      integer <= Int64(Int.max)
    else {
      return nil
    }
    return Int(integer)
  }

  private static func processIdentifier(from value: Any?) -> pid_t? {
    guard let integer = integerValue(from: value),
      integer >= 0,
      integer <= Int64(Int32.max)
    else {
      return nil
    }
    return pid_t(integer)
  }

  private static func windowIdentifier(from value: Any?) -> CGWindowID? {
    guard let integer = integerValue(from: value),
      integer >= 0,
      integer <= Int64(UInt32.max)
    else {
      return nil
    }
    return CGWindowID(integer)
  }

  private static func integerValue(from value: Any?) -> Int64? {
    guard let number = value as? NSNumber,
      CFGetTypeID(number) != CFBooleanGetTypeID()
    else {
      return nil
    }

    let doubleValue = number.doubleValue
    guard doubleValue.isFinite,
      doubleValue.rounded(.towardZero) == doubleValue,
      doubleValue >= Double(Int64.min),
      doubleValue <= Double(Int64.max)
    else {
      return nil
    }
    return number.int64Value
  }
}

enum CGWindowInfoKey {
  case bounds
  case layer
  case ownerName
  case ownerProcessIdentifier
  case title
  case windowIdentifier
}

extension CGWindowInfoKey {
  var dictionaryName: String {
    switch self {
    case .bounds:
      kCGWindowBounds as String
    case .layer:
      kCGWindowLayer as String
    case .ownerName:
      kCGWindowOwnerName as String
    case .ownerProcessIdentifier:
      kCGWindowOwnerPID as String
    case .title:
      kCGWindowName as String
    case .windowIdentifier:
      kCGWindowNumber as String
    }
  }
}
