import CoreGraphics
import Foundation

struct WindowListSnapshotMapper: Sendable {
  private let allowedLayers: Set<Int>
  private let ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding
  private let filter: WindowSnapshotFilter

  init(
    allowedLayers: Set<Int> = [0],
    ownerBundleIdentifierProvider: any WindowOwnerBundleIdentifierProviding =
      NullWindowOwnerBundleIdentifierProvider(),
    filter: WindowSnapshotFilter = .init()
  ) {
    self.allowedLayers = allowedLayers
    self.ownerBundleIdentifierProvider = ownerBundleIdentifierProvider
    self.filter = filter
  }

  func snapshot(from entry: WindowListEntry, containing point: CGPoint? = nil) -> WindowSnapshot? {
    guard let layerValue = entry[kCGWindowLayer as String] as? NSNumber,
      let boundsDictionary = entry[kCGWindowBounds as String] as? NSDictionary,
      let rawBounds = CGRect(dictionaryRepresentation: boundsDictionary),
      let ownerProcessIdentifierValue = entry[kCGWindowOwnerPID as String] as? NSNumber,
      let windowIdentifierValue = entry[kCGWindowNumber as String] as? NSNumber
    else {
      return nil
    }

    let frame = rawBounds.standardized
    let layer = layerValue.intValue
    guard allowedLayers.contains(layer) else { return nil }
    if let point, !frame.contains(point) {
      return nil
    }

    let ownerProcessIdentifier = pid_t(ownerProcessIdentifierValue.int32Value)
    let windowIdentifier = CGWindowID(windowIdentifierValue.uint32Value)
    let isMinimized = (entry[WindowListEntryKeys.isMinimized] as? NSNumber)?.boolValue

    if !filter.includedOwnerProcessIdentifiers.isEmpty,
      !filter.includedOwnerProcessIdentifiers.contains(ownerProcessIdentifier)
    {
      return nil
    }
    if !filter.includedWindowIdentifiers.isEmpty,
      !filter.includedWindowIdentifiers.contains(windowIdentifier)
    {
      return nil
    }
    if filter.excludedOwnerProcessIdentifiers.contains(ownerProcessIdentifier) {
      return nil
    }
    if filter.excludedWindowIdentifiers.contains(windowIdentifier) {
      return nil
    }
    if filter.excludesMinimizedWindows, isMinimized == true {
      return nil
    }

    let ownerBundleIdentifier = ownerBundleIdentifierProvider.bundleIdentifier(
      forProcessIdentifier: ownerProcessIdentifier)

    if !filter.includedOwnerBundleIdentifiers.isEmpty {
      guard let ownerBundleIdentifier,
        filter.includedOwnerBundleIdentifiers.contains(ownerBundleIdentifier)
      else {
        return nil
      }
    }
    if let ownerBundleIdentifier,
      filter.excludedOwnerBundleIdentifiers.contains(ownerBundleIdentifier)
    {
      return nil
    }

    return WindowSnapshot(
      ownerProcessIdentifier: ownerProcessIdentifier,
      windowIdentifier: windowIdentifier,
      ownerName: entry[kCGWindowOwnerName as String] as? String,
      ownerBundleIdentifier: ownerBundleIdentifier,
      title: entry[kCGWindowName as String] as? String,
      frame: frame,
      layer: layer,
      isMinimized: isMinimized
    )
  }
}
