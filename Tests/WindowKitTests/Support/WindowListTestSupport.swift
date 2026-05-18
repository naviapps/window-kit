import CoreGraphics
import Foundation

@testable import WindowKit

final class WindowListProviderSpy: WindowListProviding, @unchecked Sendable {
  let entries: [WindowListEntry]?
  private(set) var requests: [(options: CGWindowListOption, windowIdentifier: CGWindowID)] =
    []

  init(entries: [WindowListEntry]?) {
    self.entries = entries
  }

  func windowList(options: CGWindowListOption, windowIdentifier: CGWindowID) -> [WindowListEntry]? {
    requests.append((options: options, windowIdentifier: windowIdentifier))
    return entries
  }
}

struct WindowOwnerBundleIdentifierProviderStub: WindowOwnerBundleIdentifierProviding {
  let bundleIdentifier: String?

  func bundleIdentifier(forProcessIdentifier _: pid_t) -> String? {
    bundleIdentifier
  }
}

final class WindowOwnerBundleIdentifierProviderSpy:
  WindowOwnerBundleIdentifierProviding, @unchecked Sendable
{
  let bundleIdentifier: String?
  private(set) var processIdentifiers: [pid_t] = []

  init(bundleIdentifier: String? = nil) {
    self.bundleIdentifier = bundleIdentifier
  }

  func bundleIdentifier(forProcessIdentifier processIdentifier: pid_t) -> String? {
    processIdentifiers.append(processIdentifier)
    return bundleIdentifier
  }
}

func makeWindowEntry(
  layer: Int,
  frame: CGRect,
  ownerProcessIdentifier: Int32?,
  isMinimized: Bool = false,
  windowIdentifier: UInt32? = 12345
) -> WindowListEntry {
  var entry: WindowListEntry = [:]
  entry[kCGWindowLayer as String] = NSNumber(value: layer)
  entry[kCGWindowBounds as String] = frame.dictionaryRepresentation as NSDictionary
  if let ownerProcessIdentifier {
    entry[kCGWindowOwnerPID as String] = NSNumber(value: ownerProcessIdentifier)
  }
  entry[WindowListEntryKeys.isMinimized] = NSNumber(value: isMinimized)
  if let windowIdentifier {
    entry[kCGWindowNumber as String] = NSNumber(value: windowIdentifier)
  }
  entry[kCGWindowOwnerName as String] = "ExampleApp"
  entry[kCGWindowName as String] = "Main"
  return entry
}
