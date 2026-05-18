import CoreGraphics

typealias CGWindowListInfoEntry = [String: Any]

protocol CGWindowListInfoProviding: Sendable {
  func windowListInfo(options: CGWindowListOption, relativeToWindow: CGWindowID)
    -> [CGWindowListInfoEntry]?
}

struct SystemCGWindowListInfoProvider: CGWindowListInfoProviding {
  func windowListInfo(options: CGWindowListOption, relativeToWindow: CGWindowID)
    -> [CGWindowListInfoEntry]?
  {
    CGWindowListCopyWindowInfo(options, relativeToWindow) as? [CGWindowListInfoEntry]
  }
}
