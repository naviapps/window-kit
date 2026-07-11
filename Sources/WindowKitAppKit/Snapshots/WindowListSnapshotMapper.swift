import CoreGraphics
import WindowKit

struct WindowListSnapshotMapper: Sendable {
  private let ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding
  private let filter: WindowSnapshotFilter

  init(
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NSRunningApplicationBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init()
  ) {
    self.ownerBundleIdentifierProvider = ownerBundleIdentifierProvider
    self.filter = filter
  }

  func snapshot(from entry: WindowListEntry, containing point: CGPoint? = nil) -> WindowSnapshot? {
    guard let rawBounds = entry.frame,
      let ownerProcessIdentifier = entry.ownerProcessIdentifier,
      let windowIdentifier = entry.windowIdentifier,
      let layer = entry.layer
    else {
      return nil
    }

    guard layer == 0, rawBounds.hasFiniteComponents else { return nil }
    let frame = rawBounds.standardized
    if let point, !frame.contains(point) { return nil }

    let ownerBundleIdentifier = ownerBundleIdentifierProvider.bundleIdentifier(
      forProcessIdentifier: ownerProcessIdentifier)

    let snapshot = WindowSnapshot(
      ownerProcessIdentifier: ownerProcessIdentifier,
      windowIdentifier: windowIdentifier,
      ownerName: entry.ownerName,
      ownerBundleIdentifier: ownerBundleIdentifier,
      title: entry.title,
      frame: frame
    )
    return filter.includes(snapshot) ? snapshot : nil
  }
}

private extension CGRect {
  var hasFiniteComponents: Bool {
    origin.x.isFinite && origin.y.isFinite && width.isFinite && height.isFinite
  }
}
