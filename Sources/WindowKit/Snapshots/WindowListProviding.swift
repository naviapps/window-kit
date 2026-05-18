import CoreGraphics

typealias WindowListEntry = [String: Any]

enum WindowListEntryKeys {
  static let isMinimized = "kCGWindowIsMinimized"
}

protocol WindowListProviding: Sendable {
  func windowList(options: CGWindowListOption, windowIdentifier: CGWindowID) -> [WindowListEntry]?
}

struct SystemWindowListProvider: WindowListProviding {
  func windowList(options: CGWindowListOption, windowIdentifier: CGWindowID) -> [WindowListEntry]? {
    CGWindowListCopyWindowInfo(options, windowIdentifier) as? [WindowListEntry]
  }
}
