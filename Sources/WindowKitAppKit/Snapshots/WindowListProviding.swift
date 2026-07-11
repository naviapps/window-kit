import CoreGraphics
import Foundation

protocol WindowListProviding: Sendable {
  func windowList(for request: WindowListRequest) -> [WindowListEntry]?
}

struct SystemWindowListProvider: WindowListProviding {
  func windowList(for request: WindowListRequest) -> [WindowListEntry]? {
    (CGWindowListCopyWindowInfo(request.options, request.windowIdentifier) as? [NSDictionary])?
      .map(WindowListEntry.init(cgWindowInfo:))
  }
}
